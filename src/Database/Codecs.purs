module Database.Codecs 
  ( decodeCustomer
  , encodeCustomer
  ) where

import Prelude

import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode (class DecodeJson, decodeJson, (.:), JsonDecodeError(..), printJsonDecodeError)
import Data.Argonaut.Encode (class EncodeJson, encodeJson, (:=), (~>))
import Data.Either (Either(..))
import Data.Bifunctor (lmap)
import Data.Maybe (Maybe(..))
import Database.Types (Customer)
import Data.Number (fromString) as Number

-- Helper to parse string to number (server sends as strings for precision)
parseNumber :: String -> Either JsonDecodeError Number
parseNumber str = case Number.fromString str of
  Just n -> Right n
  Nothing -> Left $ TypeMismatch $ "Invalid number: " <> str

-- | Decode a Customer from JSON
decodeCustomer :: Json -> Either String Customer
decodeCustomer json = lmap printJsonDecodeError do
  obj <- decodeJson json
  id <- obj .: "id"
  name <- obj .: "name"
  moneyStr <- obj .: "money"
  gramJewelryStr <- obj .: "gram_jewelry"
  bahtJewelryStr <- obj .: "baht_jewelry"
  gramBar96Str <- obj .: "gram_bar96"
  bahtBar96Str <- obj .: "baht_bar96"
  gramBar99Str <- obj .: "gram_bar99"
  bahtBar99Str <- obj .: "baht_bar99"
  created_at <- obj .: "created_at"
  updated_at <- obj .: "updated_at"
  
  -- Parse string numbers to Number
  money <- parseNumber moneyStr
  gram_jewelry <- parseNumber gramJewelryStr
  baht_jewelry <- parseNumber bahtJewelryStr
  gram_bar96 <- parseNumber gramBar96Str
  baht_bar96 <- parseNumber bahtBar96Str
  gram_bar99 <- parseNumber gramBar99Str
  baht_bar99 <- parseNumber bahtBar99Str
  
  pure 
    { id
    , name
    , money
    , gram_jewelry
    , baht_jewelry
    , gram_bar96
    , baht_bar96
    , gram_bar99
    , baht_bar99
    , created_at
    , updated_at
    , rowHeight: Nothing
    }

-- | Encode a Customer to JSON
encodeCustomer :: Customer -> Json
encodeCustomer customer = encodeJson
  { id: customer.id
  , name: customer.name
  , money: customer.money
  , gram_jewelry: customer.gram_jewelry
  , baht_jewelry: customer.baht_jewelry
  , gram_bar96: customer.gram_bar96
  , baht_bar96: customer.baht_bar96
  , gram_bar99: customer.gram_bar99
  , baht_bar99: customer.baht_bar99
  , created_at: customer.created_at
  , updated_at: customer.updated_at
  }
