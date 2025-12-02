module Bill.API where

import Prelude

import Affjax.ResponseFormat as ResponseFormat
import Affjax.Web as AX
import Affjax.RequestBody as RequestBody
import Data.Argonaut.Decode (decodeJson, (.:), printJsonDecodeError)
import Data.Argonaut.Encode (encodeJson)
import Data.Either (Either(..))
import Data.Traversable (traverse)
import Data.Bifunctor (lmap)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Number as Number
import Effect.Aff (throwError, error)
import Effect.Aff.Class (class MonadAff, liftAff)
import Bill.Types
import Bill.Database (BillDatabaseInterface)

apiUrl :: String
apiUrl = "/api/bills"

-- ============================================================================
-- STANDALONE API FUNCTIONS
-- ============================================================================

-- Tray item operations
addTrayItem :: forall m. MonadAff m => Int -> ItemData -> m ItemData
addTrayItem trayId item = liftAff do
  let
    itemData = encodeJson
      { tray_id: trayId
      , making_charge: item.making_charge
      , jewelry_type_id: item.jewelry_type_id
      , design_name: item.design_name
      , nominal_weight: item.nominal_weight
      , nominal_weight_id: item.nominal_weight_id
      , quantity: item.quantity
      }
  result <- AX.post ResponseFormat.json "/api/tray-items"
    (Just $ RequestBody.json itemData)
  case result of
    Left err -> throwError $ error $ "API error: " <> AX.printError err
    Right response -> case decodeItemData response.body of
      Left err -> throwError $ error $ "Decode error: " <> err
      Right newItem -> pure newItem

updateTrayItem :: forall m. MonadAff m => Int -> ItemData -> m ItemData
updateTrayItem itemId item = liftAff do
  let
    itemData = encodeJson
      { making_charge: item.making_charge
      , jewelry_type_id: item.jewelry_type_id
      , design_name: item.design_name
      , nominal_weight: item.nominal_weight
      , nominal_weight_id: item.nominal_weight_id
      , quantity: item.quantity
      }
  result <- AX.put ResponseFormat.json ("/api/tray-items/" <> show itemId)
    (Just $ RequestBody.json itemData)
  case result of
    Left err -> throwError $ error $ "API error: " <> AX.printError err
    Right response -> case decodeItemData response.body of
      Left err -> throwError $ error $ "Decode error: " <> err
      Right updatedItem -> pure updatedItem

deleteTrayItem :: forall m. MonadAff m => Int -> m Unit
deleteTrayItem itemId = liftAff do
  result <- AX.delete ResponseFormat.json ("/api/tray-items/" <> show itemId)
  case result of
    Left err -> throwError $ error $ "API error: " <> AX.printError err
    Right _ -> pure unit

updateTray :: forall m. MonadAff m => Int -> { price_rate :: Maybe String, purity :: Maybe String, discount :: Maybe Int, actual_weight_grams :: Maybe String, additional_charge_rate :: Maybe String } -> m Unit
updateTray trayId updates = liftAff do
  let trayData = encodeJson updates
  result <- AX.put ResponseFormat.json ("/api/trays/" <> show trayId)
    (Just $ RequestBody.json trayData)
  case result of
    Left err -> throwError $ error $ "API error: " <> AX.printError err
    Right _ -> pure unit

type JewelryType =
  { id :: Int
  , name :: String
  }

type NominalWeight =
  { id :: Int
  , label :: String
  , weight_grams :: Number
  }

getJewelryTypes :: forall m. MonadAff m => m (Array JewelryType)
getJewelryTypes = liftAff do
  result <- AX.get ResponseFormat.json "/api/jewelry-types"
  case result of
    Left err -> throwError $ error $ "API error: " <> AX.printError err
    Right response -> case decodeJson response.body of
      Left err -> throwError $ error $ "JSON decode error: " <> show err
      Right types -> pure types

decodeNominalWeight :: _ -> Either String NominalWeight
decodeNominalWeight json = lmap printJsonDecodeError do
  obj <- decodeJson json
  id <- obj .: "id"
  label <- obj .: "label"
  weightStr <- obj .: "weight_grams"
  -- Parse string to number
  let
    weight_grams = case Number.fromString weightStr of
      Just n -> n
      Nothing -> 0.0
  pure { id, label, weight_grams }

getNominalWeights :: forall m. MonadAff m => m (Array NominalWeight)
getNominalWeights = liftAff do
  result <- AX.get ResponseFormat.json "/api/nominal-weights"
  case result of
    Left err -> throwError $ error $ "API error: " <> AX.printError err
    Right response -> do
      arr <- case decodeJson response.body of
        Left err -> throwError $ error $ "JSON decode error: " <> show err
        Right (a :: Array _) -> pure a
      case traverse decodeNominalWeight arr of
        Left err -> throwError $ error $ "Decode error: " <> err
        Right weights -> pure weights

type PredefinedPurity =
  { id :: Int
  , purity :: Maybe Number
  , metal_type :: String
  , display_val :: Number
  }

getPredefinedPurities :: forall m. MonadAff m => m (Array PredefinedPurity)
getPredefinedPurities = liftAff do
  result <- AX.get ResponseFormat.json "/api/predefined-purities"
  case result of
    Left err -> throwError $ error $ "API error: " <> AX.printError err
    Right response -> do
      arr <- case decodeJson response.body of
        Left err -> throwError $ error $ "JSON decode error: " <> show err
        Right (a :: Array _) -> pure a
      case traverse decodePredefinedPurity arr of
        Left err -> throwError $ error $ "Decode error: " <> err
        Right purities -> pure purities

decodePredefinedPurity :: _ -> Either String PredefinedPurity
decodePredefinedPurity json = lmap printJsonDecodeError do
  obj <- decodeJson json
  id <- obj .: "id"
  metal_type <- obj .: "metal_type"
  display_val_str <- obj .: "display_val"
  let display_val = fromMaybe 0.0 $ Number.fromString display_val_str
  purityStr <- obj .: "purity"
  let purity = Number.fromString =<< purityStr
  pure { id, purity, metal_type, display_val }

-- Response type for bill with groups
type BillWithGroups =
  { bill :: Bill
  , groups :: Array BillGroup
  }

getBill :: forall m. MonadAff m => Int -> m (Either String Bill)
getBill billId = liftAff do
  result <- AX.get ResponseFormat.json (apiUrl <> "/" <> show billId)
  pure $ case result of
    Left err -> Left $ "API error: " <> AX.printError err
    Right response -> do
      obj <- lmap printJsonDecodeError $ decodeJson response.body
      billJson <- lmap printJsonDecodeError $ obj .: "bill"
      decodeBill billJson

getBillWithGroups :: forall m. MonadAff m => Int -> m (Either String BillWithGroups)
getBillWithGroups billId = liftAff do
  result <- AX.get ResponseFormat.json (apiUrl <> "/" <> show billId)
  pure $ case result of
    Left err -> Left $ "API error: " <> AX.printError err
    Right response -> do
      obj <- lmap printJsonDecodeError $ decodeJson response.body
      billJson <- lmap printJsonDecodeError $ obj .: "bill"
      groupsJson <- lmap printJsonDecodeError $ obj .: "groups"
      bill <- decodeBill billJson
      groups <- traverse decodeBillGroup groupsJson
      pure { bill, groups }

createBill :: forall m. MonadAff m => Int -> m (Either String Bill)
createBill customerId = liftAff do
  result <- AX.post ResponseFormat.json apiUrl
    (Just $ RequestBody.json $ encodeJson { customer_id: customerId })
  pure $ case result of
    Left err -> Left $ "API error: " <> AX.printError err
    Right response -> decodeBill response.body

updateBill :: forall m. MonadAff m => Bill -> m (Either String Bill)
updateBill bill = liftAff do
  result <- AX.put ResponseFormat.json (apiUrl <> "/" <> show bill.id)
    (Just $ RequestBody.json $ encodeBill bill)
  pure $ case result of
    Left err -> Left $ "API error: " <> AX.printError err
    Right response -> decodeBill response.body

deleteBill :: forall m. MonadAff m => Int -> m (Either String Unit)
deleteBill billId = liftAff do
  result <- AX.delete ResponseFormat.json (apiUrl <> "/" <> show billId)
  pure $ case result of
    Left err -> Left $ "API error: " <> AX.printError err
    Right _ -> Right unit

getCustomerBills :: forall m. MonadAff m => Int -> m (Either String (Array Bill))
getCustomerBills customerId = liftAff do
  result <- AX.get ResponseFormat.json (apiUrl <> "/customer/" <> show customerId)
  pure $ case result of
    Left err -> Left $ "API error: " <> AX.printError err
    Right response -> do
      billsJson <- lmap printJsonDecodeError $ decodeJson response.body
      traverse decodeBill billsJson

-- ============================================================================
-- CREATE API DATABASE INTERFACE
-- ============================================================================

-- Commented out for now - will implement after testing UI
{-
createAPIDatabase :: forall m. MonadAff m => BillDatabaseInterface m
createAPIDatabase =
  { getBill: \billId -> liftAff do
      result <- AX.get ResponseFormat.json (apiUrl <> "/" <> show billId)
      case result of
        Left err -> throwError $ error $ "API error: " <> AX.printError err
        Right response -> case decodeJson response.body of
          Left err -> throwError $ error $ "JSON decode error: " <> show err
          Right billData -> pure (Just billData.bill)  -- Simplified
  
  , createBill: \customerId -> liftAff do
      result <- AX.post ResponseFormat.json apiUrl 
        (Just $ RequestBody.json $ encodeJson { customer_id: customerId })
      case result of
        Left err -> throwError $ error $ "API error: " <> AX.printError err
        Right response -> case decodeJson response.body of
          Left err -> throwError $ error $ "JSON decode error: " <> show err
          Right bill -> pure bill
  
  , updateBill: \bill -> liftAff do
      result <- AX.put ResponseFormat.json (apiUrl <> "/" <> show bill.id)
        (Just $ RequestBody.json $ encodeJson bill)
      case result of
        Left err -> throwError $ error $ "API error: " <> AX.printError err
        Right response -> case decodeJson response.body of
          Left err -> throwError $ error $ "JSON decode error: " <> show err
          Right updatedBill -> pure updatedBill
  
  , deleteBill: \billId -> liftAff do
      result <- AX.delete ResponseFormat.json (apiUrl <> "/" <> show billId)
      case result of
        Left err -> throwError $ error $ "API error: " <> AX.printError err
        Right _ -> pure unit
  
  , getBillsByCustomer: \customerId -> liftAff do
      result <- AX.get ResponseFormat.json (apiUrl <> "/customer/" <> show customerId)
      case result of
        Left err -> throwError $ error $ "API error: " <> AX.printError err
        Right response -> case decodeJson response.body of
          Left err -> throwError $ error $ "JSON decode error: " <> show err
          Right bills -> pure bills
  
  , getBillsByDate: \date -> liftAff do
      result <- AX.get ResponseFormat.json (apiUrl <> "/date/" <> date)
      case result of
        Left err -> throwError $ error $ "API error: " <> AX.printError err
        Right response -> case decodeJson response.body of
          Left err -> throwError $ error $ "JSON decode error: " <> show err
          Right bills -> pure bills
  
  , finalizeBill: \billId -> liftAff do
      result <- AX.post ResponseFormat.json (apiUrl <> "/" <> show billId <> "/finalize")
        (Just $ RequestBody.json $ encodeJson {})
      case result of
        Left err -> throwError $ error $ "API error: " <> AX.printError err
        Right response -> case decodeJson response.body of
          Left err -> throwError $ error $ "JSON decode error: " <> show err
          Right bill -> pure bill
  
  -- Group operations (simplified - full implementation would be similar)
  , getBillGroups: \billId -> liftAff do
      pure []  -- Placeholder
  
  , addTrayGroup: \billId tray items -> liftAff do
      throwError $ error "Not implemented"
  
  , addPackGroup: \billId pack items -> liftAff do
      throwError $ error "Not implemented"
  
  , addTransactionGroup: \billId transaction items -> liftAff do
      throwError $ error "Not implemented"
  
  , updateGroup: \group -> liftAff do
      throwError $ error "Not implemented"
  
  , deleteGroup: \groupId -> liftAff do
      pure unit
  
  , reorderGroups: \billId orders -> liftAff do
      pure unit
  
  -- Item operations
  , addTrayItem: \trayId item -> liftAff do
      let itemData = encodeJson
            { tray_id: trayId
            , making_charge: item.making_charge
            , jewelry_type_id: item.jewelry_type_id
            , design_name: item.design_name
            , nominal_weight: item.nominal_weight
            , quantity: item.quantity
            }
      result <- AX.post ResponseFormat.json "/api/tray-items"
        (Just $ RequestBody.json itemData)
      case result of
        Left err -> throwError $ error $ "API error: " <> AX.printError err
        Right response -> case decodeItemData response.body of
          Left err -> throwError $ error $ "Decode error: " <> err
          Right newItem -> pure newItem
  
  , updateTrayItem: \item -> liftAff do
      throwError $ error "Not implemented"
  
  , deleteTrayItem: \itemId -> liftAff do
      result <- AX.delete ResponseFormat.json ("/api/tray-items/" <> show itemId)
      case result of
        Left err -> throwError $ error $ "API error: " <> AX.printError err
        Right _ -> pure unit
  
  , reorderTrayItems: \trayId orders -> liftAff do
      pure unit
  
  , addPackItem: \packId item -> liftAff do
      throwError $ error "Not implemented"
  
  , updatePackItem: \item -> liftAff do
      throwError $ error "Not implemented"
  
  , deletePackItem: \itemId -> liftAff do
      pure unit
  
  , reorderPackItems: \packId orders -> liftAff do
      pure unit
  
  , addTransactionItem: \transactionId item -> liftAff do
      throwError $ error "Not implemented"
  
  , updateTransactionItem: \item -> liftAff do
      throwError $ error "Not implemented"
  
  , deleteTransactionItem: \itemId -> liftAff do
      pure unit
  
  , reorderTransactionItems: \transactionId orders -> liftAff do
      pure unit
  }
-}
