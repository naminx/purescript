module Database.API where

import Prelude

import Affjax.ResponseFormat as ResponseFormat
import Affjax.Web as AX
import Affjax.RequestBody as RequestBody
import Data.Argonaut.Decode (decodeJson)
import Data.Argonaut.Encode (encodeJson)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Database.Types (Customer, DatabaseInterface, FieldUpdate)
import Database.Codecs (decodeCustomer)
import Data.Traversable (traverse)
import Data.Array (length)
import Effect.Aff (throwError, error)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)

apiUrl :: String
apiUrl = "/api/customers"

-- | Create a database interface that uses HTTP API
createAPIDatabase :: forall m. MonadAff m => DatabaseInterface m
createAPIDatabase =
  { getAllCustomers: liftAff do
      _ <- liftEffect $ log "Fetching all customers..."
      result <- AX.get ResponseFormat.json apiUrl
      case result of
        Left err -> do
          _ <- liftEffect $ log $ "API error: " <> AX.printError err
          throwError $ error $ "API error: " <> AX.printError err
        Right response -> do
          _ <- liftEffect $ log "Got response, decoding JSON array..."
          customersJson <- case decodeJson response.body of
            Left err -> do
              _ <- liftEffect $ log $ "JSON array decode error: " <> show err
              throwError $ error $ "JSON array decode error: " <> show err
            Right arr -> do
              _ <- liftEffect $ log $ "Decoded array with " <> show (length arr) <> " items"
              pure arr
          _ <- liftEffect $ log "Decoding customers..."
          case traverse decodeCustomer customersJson of
            Left err -> do
              _ <- liftEffect $ log $ "Customer decode error: " <> err
              throwError $ error $ "Customer decode error: " <> err
            Right customers -> do
              _ <- liftEffect $ log $ "Successfully decoded " <> show (length customers) <> " customers"
              pure customers
  
  , getChangesSince: \since -> liftAff do
      result <- AX.get ResponseFormat.json (apiUrl <> "/changes?since=" <> since)
      case result of
        Left err -> throwError $ error $ "API error: " <> AX.printError err
        Right response -> do
          changesJson <- case decodeJson response.body of
            Left err -> throwError $ error $ "JSON array decode error: " <> show err
            Right arr -> pure arr
          case traverse decodeCustomer changesJson of
            Left err -> throwError $ error $ "Customer decode error: " <> err
            Right customers -> pure customers
  
  , addNewCustomer: \name -> liftAff do
      result <- AX.post ResponseFormat.json apiUrl (Just $ RequestBody.json $ encodeJson { name })
      case result of
        Left err -> throwError $ error $ "API error: " <> AX.printError err
        Right response -> case decodeCustomer response.body of
          Left err -> throwError $ error $ "Customer decode error: " <> err
          Right customer -> pure customer
  
  , updateCustomerField: \{ id, field, value } -> liftAff do
      result <- AX.put ResponseFormat.json (apiUrl <> "/" <> show id) (Just $ RequestBody.json $ encodeJson { field, value })
      case result of
        Left err -> throwError $ error $ "API error: " <> AX.printError err
        Right response -> case decodeCustomer response.body of
          Left err -> throwError $ error $ "Customer decode error: " <> err
          Right customer -> pure customer
  
  , deleteCustomer: \id -> liftAff do
      result <- AX.delete_ (apiUrl <> "/" <> show id)
      case result of
        Left err -> throwError $ error $ "API error: " <> AX.printError err
        Right _ -> pure unit
  }
