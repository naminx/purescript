module Bill.Database where

import Prelude
import Data.Maybe (Maybe)
import Effect.Aff.Class (class MonadAff)
import Bill.Types

-- ============================================================================
-- DATABASE INTERFACE
-- ============================================================================

type BillDatabaseInterface m =
  { -- Bill operations
    getBill :: Int -> m (Maybe Bill)
  , createBill :: Int -> m Bill  -- customer_id -> new bill
  , updateBill :: Bill -> m Bill
  , deleteBill :: Int -> m Unit
  , getBillsByCustomer :: Int -> m (Array Bill)
  , getBillsByDate :: String -> m (Array Bill)
  , finalizeBill :: Int -> m Bill
  
  -- Group operations
  , getBillGroups :: Int -> m (Array BillGroup)  -- bill_id
  , addTrayGroup :: Int -> Tray -> Array TrayItem -> m BillGroup
  , addPackGroup :: Int -> Pack -> Array PackItem -> m BillGroup
  , addTransactionGroup :: Int -> Transaction -> Array TransactionItem -> m BillGroup
  , updateGroup :: BillGroup -> m BillGroup
  , deleteGroup :: Int -> m Unit
  , reorderGroups :: Int -> Array { id :: Int, order :: Int } -> m Unit
  
  -- Tray item operations
  , addTrayItem :: Int -> TrayItem -> m TrayItem
  , updateTrayItem :: TrayItem -> m TrayItem
  , deleteTrayItem :: Int -> m Unit
  , reorderTrayItems :: Int -> Array { id :: Int, order :: Int } -> m Unit
  
  -- Pack item operations
  , addPackItem :: Int -> PackItem -> m PackItem
  , updatePackItem :: PackItem -> m PackItem
  , deletePackItem :: Int -> m Unit
  , reorderPackItems :: Int -> Array { id :: Int, order :: Int } -> m Unit
  
  -- Transaction item operations
  , addTransactionItem :: Int -> TransactionItem -> m TransactionItem
  , updateTransactionItem :: TransactionItem -> m TransactionItem
  , deleteTransactionItem :: Int -> m Unit
  , reorderTransactionItems :: Int -> Array { id :: Int, order :: Int } -> m Unit
  }
