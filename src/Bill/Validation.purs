module Bill.Validation where

import Prelude
import Data.Either (Either(..))
import Data.Number (abs)
import Data.Maybe (Maybe(..), isJust, isNothing)
import Data.Array (elem)
import Bill.Types
import Bill.Constants

-- ============================================================================
-- VALIDATION FUNCTIONS
-- ============================================================================

-- Validate a tray
validateTray :: Tray -> Array TrayItem -> Either String Unit
validateTray tray items = do
  -- Check discount is valid
  unless (tray.discount `elem` validDiscounts) do
    Left $ "Invalid discount: " <> show tray.discount <> ". Must be 0, 5, or 10."
  
  -- Check if 99.99% premium rate is set when purity > 96.5%
  case tray.purity of
    Just p | p > purity965 ->
      when (isNothing tray.additionalChargeRate) do
        Left "99.99% premium rate must be set for high purity gold"
    _ -> pure unit
  
  -- Check actual weight is positive
  when (tray.actualWeightGrams <= 0.0) do
    Left "Actual weight must be positive"
  
  -- Check all items have positive quantity
  validateTrayItems items

-- Validate tray items
validateTrayItems :: Array TrayItem -> Either String Unit
validateTrayItems items =
  case items of
    [] -> Left "Tray must have at least one item"
    _ -> do
      -- Check all items have positive quantity and amount
      let invalidItems = items # filter (\item -> 
            item.quantity <= 0 || item.amount <= 0.0)
      unless (invalidItems == []) do
        Left "All tray items must have positive quantity and amount"
      pure unit
  where
    filter f arr = arr  -- Placeholder, will use actual filter

-- Validate a pack
validatePack :: Pack -> Array PackItem -> Either String Unit
validatePack pack items = do
  -- Check pack has items
  when (items == []) do
    Left "Pack must have at least one item"
  
  -- Validate all pack items
  validatePackItems items

-- Validate pack items
validatePackItems :: Array PackItem -> Either String Unit
validatePackItems items = do
  -- Check each item has either grams or baht (not both, not neither)
  let invalidItems = items # filter (\item ->
        not (hasExactlyOneWeight item))
  unless (invalidItems == []) do
    Left "Each pack item must have either grams or baht weight (not both)"
  pure unit
  where
    hasExactlyOneWeight item =
      (isJust item.weightGrams && isNothing item.weightBaht) ||
      (isNothing item.weightGrams && isJust item.weightBaht)
    filter f arr = arr  -- Placeholder

-- Validate a transaction
validateTransaction :: Transaction -> Array TransactionItem -> Either String Unit
validateTransaction transaction items = do
  -- Check transaction has items
  when (items == []) do
    Left "Transaction must have at least one item"
  
  -- Validate all transaction items
  validateTransactionItems items

-- Validate transaction items
validateTransactionItems :: Array TransactionItem -> Either String Unit
validateTransactionItems items = do
  -- Check each item has valid amounts based on transaction type
  let invalidItems = items # filter (\item -> not (isValidTransactionItem item))
  unless (invalidItems == []) do
    Left "Invalid transaction item amounts"
  pure unit
  where
    filter f arr = arr  -- Placeholder

-- Check if transaction item is valid
isValidTransactionItem :: TransactionItem -> Boolean
isValidTransactionItem item =
  case item.transactionType of
    MoneyIn -> isJust item.amountMoney
    MoneyOut -> isJust item.amountMoney
    JewelIn -> hasExactlyOneGoldAmount item
    JewelOut -> hasExactlyOneGoldAmount item
    Bar96In -> hasExactlyOneGoldAmount item
    Bar96Out -> hasExactlyOneGoldAmount item
    Bar99In -> hasExactlyOneGoldAmount item
    Bar99Out -> hasExactlyOneGoldAmount item
    BuyJewel -> hasExactlyOneGoldAmount item && isJust item.priceRate
    SellJewel -> hasExactlyOneGoldAmount item && isJust item.priceRate
    BuyBar96 -> hasExactlyOneGoldAmount item && isJust item.priceRate
    SellBar96 -> hasExactlyOneGoldAmount item && isJust item.priceRate
    BuyBar99 -> hasExactlyOneGoldAmount item && isJust item.priceRate
    SellBar99 -> hasExactlyOneGoldAmount item && isJust item.priceRate
    _ -> true  -- Other types validated separately
  where
    hasExactlyOneGoldAmount i =
      (isJust i.amountGrams && isNothing i.amountBaht) ||
      (isNothing i.amountGrams && isJust i.amountBaht)

-- Validate VAT calculation requirements
validateVATRequirements :: Bill -> Either String Unit
validateVATRequirements bill = do
  -- If VAT not deferred, market price must be set
  unless bill.is_vat_deferred do
    when (isNothing bill.market_buying_price_jewel) do
      Left "Market buying price must be set for VAT calculation"
  pure unit

-- Validate price rate is within threshold of announced price
validatePriceRate :: Number -> Number -> Number -> Boolean
validatePriceRate priceRate announcedPrice threshold =
  let diff = abs (priceRate - announcedPrice)
  in diff <= threshold

-- Validate customer has sufficient balance
validateSufficientBalance :: Balance -> Balance -> Either String Unit
validateSufficientBalance customerBalance requiredBalance = do
  -- Check money
  when (customerBalance.money < requiredBalance.money) do
    Left "Insufficient money balance"
  
  -- Check gold balances (simplified - actual logic would be more complex)
  when (customerBalance.gramJewel < requiredBalance.gramJewel) do
    Left "Insufficient jewelry (grams) balance"
  
  when (customerBalance.bahtJewel < requiredBalance.bahtJewel) do
    Left "Insufficient jewelry (baht) balance"
  
  pure unit
