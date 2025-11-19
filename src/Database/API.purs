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
import Effect.Aff (throwError, error)
import Effect.Aff.Class (class MonadAff, liftAff)

apiUrl :: String
apiUrl = "/api/customers"

-- | Create a database interface that uses HTTP API
createAPIDatabase :: forall m. MonadAff m => DatabaseInterface m
createAPIDatabase =
  { getAllCustomers: liftAff do
      result <- AX.get ResponseFormat.json apiUrl
      case result of
        Left err -> throwError $ error $ "API error: " <> AX.printError err
        Right response -> case decodeJson response.body of
          Left err -> throwError $ error $ "JSON decode error: " <> show err
          Right customers -> pure customers
  
  , getChangesSince: \since -> liftAff do
      result <- AX.get ResponseFormat.json (apiUrl <> "/changes?since=" <> since)
      case result of
        Left err -> throwError $ error $ "API error: " <> AX.printError err
        Right response -> case decodeJson response.body of
          Left err -> throwError $ error $ "JSON decode error: " <> show err
          Right customers -> pure customers
  
  , addNewCustomer: \name -> liftAff do
      result <- AX.post ResponseFormat.json apiUrl (Just $ RequestBody.json $ encodeJson { name })
      case result of
        Left err -> throwError $ error $ "API error: " <> AX.printError err
        Right response -> case decodeJson response.body of
          Left err -> throwError $ error $ "JSON decode error: " <> show err
          Right customer -> pure customer
  
  , updateCustomerField: \{ id, field, value } -> liftAff do
      result <- AX.put ResponseFormat.json (apiUrl <> "/" <> show id) (Just $ RequestBody.json $ encodeJson { field, value })
      case result of
        Left err -> throwError $ error $ "API error: " <> AX.printError err
        Right response -> case decodeJson response.body of
          Left err -> throwError $ error $ "JSON decode error: " <> show err
          Right customer -> pure customer
  
  , deleteCustomer: \id -> liftAff do
      result <- AX.delete_ (apiUrl <> "/" <> show id)
      case result of
        Left err -> throwError $ error $ "API error: " <> AX.printError err
        Right _ -> pure unit
  }
