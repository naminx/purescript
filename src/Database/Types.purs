module Database.Types where

import Prelude

-- | Customer record type
type Customer =
  { id :: Int
  , name :: String
  }

-- | Database interface that can be implemented by mock or real database
type DatabaseInterface m =
  { getAllCustomers :: m (Array Customer)
  , addNewCustomer :: String -> m Unit
  , updateCustomerName :: { id :: Int, name :: String } -> m Unit
  , deleteCustomer :: Int -> m Unit
  }
