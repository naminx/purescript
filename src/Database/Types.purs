module Database.Types where

import Prelude
import Data.Maybe (Maybe)

-- | Customer record type with cached row height
-- rowHeight is cached in memory only (not stored in database)
-- It's initially Nothing and gets populated when the row is first rendered
type Customer =
  { id :: Int
  , name :: String
  , money :: Number
  , gram_jewelry :: Number
  , baht_jewelry :: Number
  , gram_bar96 :: Number
  , baht_bar96 :: Number
  , gram_bar99 :: Number
  , baht_bar99 :: Number
  , created_at :: Maybe String
  , updated_at :: Maybe String
  , rowHeight :: Maybe Number
  }

-- | Field update type for flexible field editing
type FieldUpdate =
  { id :: Int
  , field :: String
  , value :: String
  }

-- | Database interface that can be implemented by mock or real database
type DatabaseInterface m =
  { getAllCustomers :: m (Array Customer)
  , getChangesSince :: String -> m (Array Customer)
  , addNewCustomer :: String -> m Customer
  , updateCustomerField :: FieldUpdate -> m Customer
  , deleteCustomer :: Int -> m Unit
  }
