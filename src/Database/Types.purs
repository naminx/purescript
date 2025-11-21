module Database.Types where

import Prelude
import Data.Maybe (Maybe)
import Decimal (Decimal)

-- | Customer record type with cached row height
-- rowHeight is cached in memory only (not stored in database)
-- It's initially Nothing and gets populated when the row is first rendered
type Customer =
  { id :: Int
  , name :: String
  , money :: Decimal
  , gram_jewelry :: Decimal
  , baht_jewelry :: Decimal
  , gram_bar96 :: Decimal
  , baht_bar96 :: Decimal
  , gram_bar99 :: Decimal
  , baht_bar99 :: Decimal
  , created_at :: Maybe String
  , updated_at :: Maybe String
  , rowHeight :: Maybe Number  -- Keep as Number (not financial)
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
