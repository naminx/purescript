module Bill.Calculations where

import Prelude
import Data.Array (filter, foldl, cons, drop, (!!))
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Either (Either(..))
import Data.Int (toNumber)
import Bill.Types
import Bill.Constants

-- ============================================================================
-- BALANCE OPERATIONS
-- ============================================================================

-- Add two balances
addBalance :: Balance -> Balance -> Balance
addBalance b1 b2 =
  { money: b1.money + b2.money
  , gramJewel: b1.gramJewel + b2.gramJewel
  , bahtJewel: b1.bahtJewel + b2.bahtJewel
  , gramBar96: b1.gramBar96 + b2.gramBar96
  , bahtBar96: b1.bahtBar96 + b2.bahtBar96
  , gramBar99: b1.gramBar99 + b2.gramBar99
  , bahtBar99: b1.bahtBar99 + b2.bahtBar99
  }

-- Negate a balance (flip debit/credit)
negateBalance :: Balance -> Balance
negateBalance b =
  { money: -b.money
  , gramJewel: -b.gramJewel
  , bahtJewel: -b.bahtJewel
  , gramBar96: -b.gramBar96
  , bahtBar96: -b.bahtBar96
  , gramBar99: -b.gramBar99
  , bahtBar99: -b.bahtBar99
  }

-- ============================================================================
-- TRAY CALCULATIONS
-- ============================================================================

-- Calculate tray totals from items
calculateTrayTotal :: Tray -> Array TrayItem -> Balance
calculateTrayTotal tray items =
  let
    -- Calculate making charge total (after discount)
    makingChargeTotal = foldl (\acc item -> acc + item.amount) 0.0 items
    discountedCharge = makingChargeTotal * (100.0 - toNumber tray.discount) / 100.0

    -- Calculate 99.99% premium if applicable
    premium = case tray.purity of
      Just 100.0 ->
        case tray.additionalChargeRate of
          Just rate -> tray.actualWeightGrams * bahtPerGram * rate
          Nothing -> 0.0 -- Should be validated before calculation
      _ -> 0.0

    -- Total charges
    totalCharges = discountedCharge + premium

    -- Calculate gold value if price_rate is set
    goldValue = case tray.priceRate of
      Just rate -> tray.actualWeightGrams * bahtPerGram * rate
      Nothing -> 0.0

    -- Total money (negative for customer buying, positive for return)
    totalMoney =
      if tray.isReturn then goldValue - totalCharges -- Return: customer gets money back
      else -(goldValue + totalCharges) -- Buy: customer pays

    -- Gold balance (positive for customer buying, negative for return)
    goldWeight =
      if tray.isReturn then -tray.actualWeightGrams -- Return: customer gives back gold
      else tray.actualWeightGrams -- Buy: customer gets gold
  in
    { money: totalMoney
    , gramJewel: goldWeight
    , bahtJewel: 0.0 -- Trays only affect grams
    , gramBar96: 0.0
    , bahtBar96: 0.0
    , gramBar99: 0.0
    , bahtBar99: 0.0
    }

-- ============================================================================
-- PACK CALCULATIONS
-- ============================================================================

-- Calculate pack totals from items
calculatePackTotal :: Pack -> Array PackItem -> Balance
calculatePackTotal pack items =
  foldl addBalance emptyBalance (map calculatePackItemBalance items)

-- Calculate balance for a single pack item
calculatePackItemBalance :: PackItem -> Balance
calculatePackItemBalance item =
  let
    -- Get weight in grams
    weightGrams = fromMaybe 0.0 item.weightGrams
    weightBaht = fromMaybe 0.0 item.weightBaht

    -- Convert baht to grams if needed
    totalGrams = weightGrams + (weightBaht * gramsPerBahtJewelry)

    -- Apply deduction (simplified - actual parsing would be more complex)
    -- For now, assume calculation_amount is already calculated

    -- Determine which balance type based on shape and purity
    balance = case item.shape, item.purity of
      Jewelry, _ ->
        { money: item.calculationAmount
        , gramJewel: if isNothing item.weightGrams then 0.0 else weightGrams
        , bahtJewel: if isNothing item.weightBaht then 0.0 else weightBaht
        , gramBar96: 0.0
        , bahtBar96: 0.0
        , gramBar99: 0.0
        , bahtBar99: 0.0
        }
      Bar, Just 100.0 -> -- 99.99% bar
        { money: item.calculationAmount
        , gramJewel: 0.0
        , bahtJewel: 0.0
        , gramBar96: 0.0
        , bahtBar96: 0.0
        , gramBar99: if isNothing item.weightGrams then 0.0 else weightGrams
        , bahtBar99: if isNothing item.weightBaht then 0.0 else weightBaht
        }
      Bar, _ -> -- 96.5% bar (default)
        { money: item.calculationAmount
        , gramJewel: 0.0
        , bahtJewel: 0.0
        , gramBar96: if isNothing item.weightGrams then 0.0 else weightGrams
        , bahtBar96: if isNothing item.weightBaht then 0.0 else weightBaht
        , gramBar99: 0.0
        , bahtBar99: 0.0
        }
  in
    balance
  where
  isNothing Nothing = true
  isNothing (Just _) = false

-- ============================================================================
-- TRANSACTION CALCULATIONS
-- ============================================================================

-- Calculate transaction totals from items
calculateTransactionTotal :: Transaction -> Array TransactionItem -> Balance
calculateTransactionTotal transaction items =
  foldl addBalance emptyBalance (map calculateTransactionItemBalance items)

-- Calculate balance for a single transaction item
calculateTransactionItemBalance :: TransactionItem -> Balance
calculateTransactionItemBalance item =
  case item.transactionType of
    MoneyIn ->
      { money: fromMaybe 0.0 item.amountMoney
      , gramJewel: 0.0
      , bahtJewel: 0.0
      , gramBar96: 0.0
      , bahtBar96: 0.0
      , gramBar99: 0.0
      , bahtBar99: 0.0
      }

    MoneyOut ->
      { money: -(fromMaybe 0.0 item.amountMoney)
      , gramJewel: 0.0
      , bahtJewel: 0.0
      , gramBar96: 0.0
      , bahtBar96: 0.0
      , gramBar99: 0.0
      , bahtBar99: 0.0
      }

    -- Add more transaction types as needed
    _ -> emptyBalance -- Placeholder for other transaction types

-- ============================================================================
-- BILL CALCULATIONS
-- ============================================================================

-- Calculate accumulated totals for all groups (simplified - not implemented yet)
calculateAccumulated :: Array BillGroup -> Array BillGroup
calculateAccumulated groups = groups -- TODO: Implement when we have proper group data structure

-- Calculate total for a single group (simplified - not implemented yet)
calculateGroupTotal :: BillGroup -> Balance
calculateGroupTotal group = emptyBalance -- TODO: Implement when we have proper group data structure

-- Calculate grand total for entire bill (simplified - not implemented yet)
calculateBillTotal :: Bill -> Array BillGroup -> Balance
calculateBillTotal bill groups = emptyBalance -- TODO: Implement when we have proper group data structure

-- ============================================================================
-- VAT CALCULATIONS
-- ============================================================================

-- Calculate VAT for a bill
calculateVAT :: Bill -> Array BillGroup -> Either String VATCalculation
calculateVAT bill groups = do
  -- Check if VAT deferred
  if bill.is_vat_deferred then Left "VAT is deferred for this bill"
  else pure unit

  -- Check if market price is set
  marketPrice <- case bill.market_buying_price_jewel of
    Nothing -> Left "Market buying price not set"
    Just price -> Right 0.0 -- TODO: Parse from string

  -- Get all non-return trays
  let trays = getNonReturnTrays groups

  -- Calculate jewelry VAT (EXCLUSIVE)
  let jewelryVAT = calculateJewelryVAT bill trays marketPrice

  -- Get all Buy Bar transactions
  let barTransactions = getBuyBarTransactions groups

  -- Calculate bar making charge VAT (INCLUSIVE - extracted)
  let barVAT = calculateBarMakingChargeVAT barTransactions 7.0 -- TODO: Parse from bill.vat_rate string

  -- Total VAT
  let totalVAT = jewelryVAT + barVAT
  let taxableAmount = calculateTaxableAmount bill trays marketPrice

  pure { jewelryVAT, barVAT, totalVAT, taxableAmount }

-- Helper: Get non-return trays from groups (simplified - not implemented yet)
getNonReturnTrays :: Array BillGroup -> Array { tray :: Tray, items :: Array TrayItem }
getNonReturnTrays groups = [] -- TODO: Implement when we have proper group data structure

-- Helper: Get Buy Bar transactions
getBuyBarTransactions :: Array BillGroup -> Array TransactionItem
getBuyBarTransactions groups = [] -- TODO: Implement when we have proper group data structure

-- Calculate jewelry VAT (exclusive)
calculateJewelryVAT :: Bill -> Array { tray :: Tray, items :: Array TrayItem } -> Number -> Number
calculateJewelryVAT bill trays marketPrice =
  let
    taxableAmount = calculateTaxableAmount bill trays marketPrice
  in
    round2 (taxableAmount * 7.0 / 100.0) -- TODO: Parse from bill.vat_rate string

-- Calculate taxable amount for jewelry
calculateTaxableAmount :: Bill -> Array { tray :: Tray, items :: Array TrayItem } -> Number -> Number
calculateTaxableAmount bill trays marketPrice =
  let
    totalWeight = foldl (\acc t -> acc + (t.tray.actualWeightGrams * bahtPerGram)) 0.0 trays
    totalCharges = foldl (\acc t -> acc + calculateTrayCharges t.tray t.items) 0.0 trays
    priceRate = 0.0 -- TODO: Parse from bill.market_buying_price_jewel string
    netAmount = totalWeight * priceRate + totalCharges
    deduction = totalWeight * marketPrice
  in
    netAmount - deduction

-- Calculate charges for a tray
calculateTrayCharges :: Tray -> Array TrayItem -> Number
calculateTrayCharges tray items =
  let
    makingCharge = foldl (\acc item -> acc + item.amount) 0.0 items
    discountedCharge = makingCharge * (100.0 - toNumber tray.discount) / 100.0
    premium = case tray.purity of
      Just 100.0 ->
        case tray.additionalChargeRate of
          Just rate -> tray.actualWeightGrams * bahtPerGram * rate
          Nothing -> 0.0
      _ -> 0.0
  in
    discountedCharge + premium

-- Calculate bar making charge VAT (inclusive - extracted)
calculateBarMakingChargeVAT :: Array TransactionItem -> Number -> Number
calculateBarMakingChargeVAT items vatRate =
  let
    totalMakingCharge = foldl (\acc item -> acc + getBarMakingCharge item) 0.0 items
  in
    round2 (totalMakingCharge * vatRate / (100.0 + vatRate))

-- Get bar making charge from transaction item
getBarMakingCharge :: TransactionItem -> Number
getBarMakingCharge item =
  case item.blockMakingChargeRate of
    Just rate ->
      let
        weight = fromMaybe 0.0 item.amountBaht + (fromMaybe 0.0 item.amountGrams * bahtPerGram)
      in
        weight * rate
    Nothing -> 0.0
