module Database.Codecs 
  ( decodeCustomer
  , encodeCustomer
  ) where

import Prelude

import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode (class DecodeJson, decodeJson, (.:), JsonDecodeError, printJsonDecodeError)
import Data.Argonaut.Encode (class EncodeJson, encodeJson, (:=), (~>))
import Data.Either (Either)
import Data.Bifunctor (lmap)
import Data.Maybe (Maybe(..))
import Database.Types (Customer)
import Decimal (Decimal)

-- | Decode a Customer from JSON
decodeCustomer :: Json -> Either String Customer
decodeCustomer json = lmap printJsonDecodeError do
  obj <- decodeJson json
  id <- obj .: "id"
  name <- obj .: "name"
  money <- obj .: "money"
  gram_jewelry <- obj .: "gram_jewelry"
  baht_jewelry <- obj .: "baht_jewelry"
  gram_bar96 <- obj .: "gram_bar96"
  baht_bar96 <- obj .: "baht_bar96"
  gram_bar99 <- obj .: "gram_bar99"
  baht_bar99 <- obj .: "baht_bar99"
  created_at <- obj .: "created_at"
  updated_at <- obj .: "updated_at"
  
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
