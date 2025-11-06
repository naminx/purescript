module Database.Mock where

import Prelude

import Data.Array (snoc, filter)
import Data.Maybe (Maybe(..))
import Database.Types (Customer, DatabaseInterface)
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Ref (Ref)
import Effect.Ref as Ref

-- | Create a mock database interface using an in-memory Ref
createMockDatabase :: forall m. MonadEffect m => Effect (DatabaseInterface m)
createMockDatabase = do
  -- Initialize with some test customers
  customersRef <- Ref.new initialCustomers
  nextIdRef <- Ref.new 4 -- Next available ID
  
  pure
    { getAllCustomers: liftEffect $ Ref.read customersRef
    
    , addNewCustomer: \name -> liftEffect do
        customers <- Ref.read customersRef
        nextId <- Ref.read nextIdRef
        let newCustomer = { id: nextId, name }
        Ref.write (snoc customers newCustomer) customersRef
        Ref.write (nextId + 1) nextIdRef
    
    , updateCustomerName: \{ id, name } -> liftEffect do
        customers <- Ref.read customersRef
        let updatedCustomers = map (\c -> if c.id == id then c { name = name } else c) customers
        Ref.write updatedCustomers customersRef
    
    , deleteCustomer: \id -> liftEffect do
        customers <- Ref.read customersRef
        let filteredCustomers = filter (\c -> c.id /= id) customers
        Ref.write filteredCustomers customersRef
    }

-- | Initial test data
initialCustomers :: Array Customer
initialCustomers =
  [ { id: 1, name: "Alice Johnson" }
  , { id: 2, name: "Bob Smith" }
  , { id: 3, name: "Charlie Brown" }
  ]
