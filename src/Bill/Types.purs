module Bill.Types where

import Prelude
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Argonaut.Decode (class DecodeJson, decodeJson, (.:), (.:?), JsonDecodeError, printJsonDecodeError)
import Data.Argonaut.Encode (class EncodeJson, encodeJson, (:=), (~>))
import Data.Argonaut.Core (jsonEmptyObject)
import Data.Generic.Rep (class Generic)
import Data.Either (Either)
import Data.Bifunctor (lmap)
import Data.Traversable (traverse)
import Data.Number as Number
import Data.Int (round)

-- Helper to parse string to number
parseNumber :: String -> Number
parseNumber s = case Number.fromString s of
  Just n -> n
  Nothing -> 0.0

-- ============================================================================
-- ENUMS
-- ============================================================================

data Shape = Jewelry | Bar

derive instance eqShape :: Eq Shape
derive instance ordShape :: Ord Shape
derive instance genericShape :: Generic Shape _

instance showShape :: Show Shape where
  show Jewelry = "jewelry"
  show Bar = "bar"

data BalanceType = Jewel | Bar96 | Bar99

derive instance eqBalanceType :: Eq BalanceType
derive instance ordBalanceType :: Ord BalanceType
derive instance genericBalanceType :: Generic BalanceType _

instance showBalanceType :: Show BalanceType where
  show Jewel = "jewel"
  show Bar96 = "bar96"
  show Bar99 = "bar99"

data GroupType = TrayGroup | PackGroup | TransactionGroup

derive instance eqGroupType :: Eq GroupType
derive instance ordGroupType :: Ord GroupType
derive instance genericGroupType :: Generic GroupType _

instance showGroupType :: Show GroupType where
  show TrayGroup = "tray"
  show PackGroup = "pack"
  show TransactionGroup = "transaction"

data TransactionType
  = PrevDebitMoney
  | PrevCreditMoney
  | PrevDebitJewel
  | PrevCreditJewel
  | PrevDebitBar96
  | PrevCreditBar96
  | PrevDebitBar99
  | PrevCreditBar99
  | MoneyIn
  | MoneyOut
  | JewelIn
  | JewelOut
  | Bar96In
  | Bar96Out
  | Bar99In
  | Bar99Out
  | BuyJewel
  | SellJewel
  | BuyBar96
  | SellBar96
  | BuyBar99
  | SellBar99
  | ConvertJewelToBar96
  | ConvertBar96ToJewel
  | ConvertGramsToBaht
  | ConvertBahtToGrams
  | SplitBar

derive instance eqTransactionType :: Eq TransactionType
derive instance ordTransactionType :: Ord TransactionType
derive instance genericTransactionType :: Generic TransactionType _

instance showTransactionType :: Show TransactionType where
  show PrevDebitMoney = "prev_debit_money"
  show PrevCreditMoney = "prev_credit_money"
  show PrevDebitJewel = "prev_debit_jewel"
  show PrevCreditJewel = "prev_credit_jewel"
  show PrevDebitBar96 = "prev_debit_bar96"
  show PrevCreditBar96 = "prev_credit_bar96"
  show PrevDebitBar99 = "prev_debit_bar99"
  show PrevCreditBar99 = "prev_credit_bar99"
  show MoneyIn = "money_in"
  show MoneyOut = "money_out"
  show JewelIn = "jewel_in"
  show JewelOut = "jewel_out"
  show Bar96In = "bar96_in"
  show Bar96Out = "bar96_out"
  show Bar99In = "bar99_in"
  show Bar99Out = "bar99_out"
  show BuyJewel = "buy_jewel"
  show SellJewel = "sell_jewel"
  show BuyBar96 = "buy_bar96"
  show SellBar96 = "sell_bar96"
  show BuyBar99 = "buy_bar99"
  show SellBar99 = "sell_bar99"
  show ConvertJewelToBar96 = "convert_jewel_to_bar96"
  show ConvertBar96ToJewel = "convert_bar96_to_jewel"
  show ConvertGramsToBaht = "convert_grams_to_baht"
  show ConvertBahtToGrams = "convert_baht_to_grams"
  show SplitBar = "split_bar"

-- ============================================================================
-- BALANCE
-- ============================================================================

type Balance =
  { money :: Number
  , gramJewel :: Number
  , bahtJewel :: Number
  , gramBar96 :: Number
  , bahtBar96 :: Number
  , gramBar99 :: Number
  , bahtBar99 :: Number
  }

emptyBalance :: Balance
emptyBalance =
  { money: 0.0
  , gramJewel: 0.0
  , bahtJewel: 0.0
  , gramBar96: 0.0
  , bahtBar96: 0.0
  , gramBar99: 0.0
  , bahtBar99: 0.0
  }

-- ============================================================================
-- BILL
-- ============================================================================

-- Use simple type alias and manual decoder
type Bill =
  { id :: Int
  , customer_id :: Int
  , date :: String

  -- Previous balances (snake_case to match database)
  , prev_balance_money :: String
  , prev_gram_jewel :: String
  , prev_baht_jewel :: String
  , prev_gram_bar96 :: String
  , prev_baht_bar96 :: String
  , prev_gram_bar99 :: String
  , prev_baht_bar99 :: String

  -- Final balances
  , final_balance_money :: Maybe String
  , final_gram_jewel :: Maybe String
  , final_baht_jewel :: Maybe String
  , final_gram_bar96 :: Maybe String
  , final_baht_bar96 :: Maybe String
  , final_gram_bar99 :: Maybe String
  , final_baht_bar99 :: Maybe String

  -- VAT
  , is_vat_deferred :: Boolean
  , vat_rate :: String
  , market_buying_price_jewel :: Maybe String
  , vat_taxable_amount :: Maybe String
  , vat_amount :: Maybe String

  -- Status
  , is_finalized :: Boolean
  , finalized_at :: Maybe String

  -- Timestamps
  , created_at :: String
  , updated_at :: String

  -- Concurrent editing
  , version :: Int
  }

decodeBill :: _ -> Either String Bill
decodeBill json = lmap printJsonDecodeError do
  obj <- decodeJson json
  id <- obj .: "id"
  customer_id <- obj .: "customer_id"
  date <- obj .: "date"
  prev_balance_money <- obj .: "prev_balance_money"
  prev_gram_jewel <- obj .: "prev_gram_jewel"
  prev_baht_jewel <- obj .: "prev_baht_jewel"
  prev_gram_bar96 <- obj .: "prev_gram_bar96"
  prev_baht_bar96 <- obj .: "prev_baht_bar96"
  prev_gram_bar99 <- obj .: "prev_gram_bar99"
  prev_baht_bar99 <- obj .: "prev_baht_bar99"
  final_balance_money <- obj .:? "final_balance_money"
  final_gram_jewel <- obj .:? "final_gram_jewel"
  final_baht_jewel <- obj .:? "final_baht_jewel"
  final_gram_bar96 <- obj .:? "final_gram_bar96"
  final_baht_bar96 <- obj .:? "final_baht_bar96"
  final_gram_bar99 <- obj .:? "final_gram_bar99"
  final_baht_bar99 <- obj .:? "final_baht_bar99"
  is_vat_deferred <- obj .: "is_vat_deferred"
  vat_rate <- obj .: "vat_rate"
  market_buying_price_jewel <- obj .:? "market_buying_price_jewel"
  vat_taxable_amount <- obj .:? "vat_taxable_amount"
  vat_amount <- obj .:? "vat_amount"
  is_finalized <- obj .: "is_finalized"
  finalized_at <- obj .:? "finalized_at"
  created_at <- obj .: "created_at"
  updated_at <- obj .: "updated_at"
  version <- obj .: "version"
  pure
    { id
    , customer_id
    , date
    , prev_balance_money
    , prev_gram_jewel
    , prev_baht_jewel
    , prev_gram_bar96
    , prev_baht_bar96
    , prev_gram_bar99
    , prev_baht_bar99
    , final_balance_money
    , final_gram_jewel
    , final_baht_jewel
    , final_gram_bar96
    , final_baht_bar96
    , final_gram_bar99
    , final_baht_bar99
    , is_vat_deferred
    , vat_rate
    , market_buying_price_jewel
    , vat_taxable_amount
    , vat_amount
    , is_finalized
    , finalized_at
    , created_at
    , updated_at
    , version
    }

encodeBill :: Bill -> _
encodeBill bill =
  "id" := bill.id
    ~> "customer_id" := bill.customer_id
    ~> "date" := bill.date
    ~> "prev_balance_money" := bill.prev_balance_money
    ~> "prev_gram_jewel" := bill.prev_gram_jewel
    ~> "prev_baht_jewel" := bill.prev_baht_jewel
    ~> "prev_gram_bar96" := bill.prev_gram_bar96
    ~> "prev_baht_bar96" := bill.prev_baht_bar96
    ~> "prev_gram_bar99" := bill.prev_gram_bar99
    ~> "prev_baht_bar99" := bill.prev_baht_bar99
    ~> "is_vat_deferred" := bill.is_vat_deferred
    ~> "vat_rate" := bill.vat_rate
    ~> "market_buying_price_jewel" := bill.market_buying_price_jewel
    ~> "is_finalized" := bill.is_finalized
    ~> "version" := bill.version
    ~> jsonEmptyObject

-- Remove old instance
{-
instance decodeJsonBill :: DecodeJson Bill where
-}

-- ============================================================================
-- BILL GROUP
-- ============================================================================

type BillGroup =
  { id :: Int
  , bill_id :: Int
  , group_type :: String -- "tray", "pack", or "transaction"
  , display_order :: Int
  , version :: Int
  , updated_by :: Maybe String
  , created_at :: String
  , updated_at :: String
  , groupData :: Maybe GroupData
  }

type GroupData =
  { "type" :: String
  , tray :: Maybe TrayData
  , pack :: Maybe PackData
  , transaction :: Maybe TransactionData
  , items :: Array ItemData
  }

type TrayData =
  { id :: Int
  , group_id :: Int
  , internal_num :: Int
  , is_return :: Boolean
  , purity :: Maybe String
  , shape :: String
  , discount :: Maybe Int
  , actual_weight_grams :: String
  , price_rate :: Maybe String
  , additional_charge_rate :: Maybe String
  , custom_weight_label :: Maybe String
  }

type PackData =
  { id :: Int
  , group_id :: Int
  , internal_id :: Int
  , user_number :: String
  }

type TransactionData =
  { id :: Int
  , group_id :: Int
  }

-- Sum type for nominal weight: either predefined or custom
-- Invariant: In database, exactly one of nominal_weight_id or nominal_weight should be set
data NominalWeightType
  = PredefinedWeight Int -- References nominal_weights.id
  | CustomWeight Number -- Custom weight in grams

-- Helper to construct NominalWeightType from ItemData
getNominalWeightType :: ItemData -> Maybe NominalWeightType
getNominalWeightType item = case item.nominal_weight_id of
  Just wid -> Just (PredefinedWeight wid)
  Nothing -> case item.nominal_weight of
    Just ws -> case Number.fromString ws of
      Just n -> Just (CustomWeight n)
      Nothing -> Nothing
    Nothing -> Nothing

-- Helper to get the actual weight value in grams
getNominalWeightValue :: ItemData -> Number
getNominalWeightValue item =
  parseNumber (fromMaybe "0" item.nominal_weight)

type ItemData =
  { id :: Int
  , display_order :: Int
  -- Tray item fields
  , tray_id :: Maybe Int
  , making_charge :: Maybe Int
  , jewelry_type_id :: Maybe Int
  , design_name :: Maybe String
  , nominal_weight :: Maybe String -- For backward compatibility and DB storage
  , nominal_weight_id :: Maybe Int -- For backward compatibility and DB storage
  , quantity :: Maybe Int
  , amount :: Maybe Int
  -- Pack item fields
  , pack_id :: Maybe Int
  , deduction_rate :: Maybe String
  , shape :: Maybe String
  , purity :: Maybe String
  , description :: Maybe String
  , weight_grams :: Maybe String
  , weight_baht :: Maybe String
  , calculation_amount :: Maybe String
  -- Transaction item fields
  , transaction_id :: Maybe Int
  , transaction_type :: Maybe String
  , balance_type :: Maybe String
  , amount_money :: Maybe String
  , amount_grams :: Maybe String
  , amount_baht :: Maybe String
  , price_rate :: Maybe String
  , conversion_charge_rate :: Maybe String
  , split_charge_rate :: Maybe String
  , block_making_charge_rate :: Maybe String
  , source_amount_grams :: Maybe String
  , source_amount_baht :: Maybe String
  , dest_amount_grams :: Maybe String
  , dest_amount_baht :: Maybe String
  }

decodeTrayData :: _ -> Either String TrayData
decodeTrayData json = lmap printJsonDecodeError do
  obj <- decodeJson json
  id <- obj .: "id"
  group_id <- obj .: "group_id"
  internal_num <- obj .: "internal_num"
  is_return <- obj .: "is_return"
  purity <- obj .:? "purity"
  shape <- obj .: "shape"
  discount <- obj .:? "discount"
  actual_weight_grams <- obj .: "actual_weight_grams"
  price_rate <- obj .:? "price_rate"
  additional_charge_rate <- obj .:? "additional_charge_rate"
  custom_weight_label <- obj .:? "custom_weight_label"
  pure { id, group_id, internal_num, is_return, purity, shape, discount, actual_weight_grams, price_rate, additional_charge_rate, custom_weight_label }

decodePackData :: _ -> Either String PackData
decodePackData json = lmap printJsonDecodeError do
  obj <- decodeJson json
  id <- obj .: "id"
  group_id <- obj .: "group_id"
  internal_id <- obj .: "internal_id"
  user_number <- obj .: "user_number"
  pure { id, group_id, internal_id, user_number }

decodeTransactionData :: _ -> Either String TransactionData
decodeTransactionData json = lmap printJsonDecodeError do
  obj <- decodeJson json
  id <- obj .: "id"
  group_id <- obj .: "group_id"
  pure { id, group_id }

decodeItemData :: _ -> Either String ItemData
decodeItemData json = lmap printJsonDecodeError do
  obj <- decodeJson json
  id <- obj .: "id"
  display_order <- obj .: "display_order"
  -- Tray fields
  tray_id <- obj .:? "tray_id"
  making_charge <- obj .:? "making_charge"
  jewelry_type_id <- obj .:? "jewelry_type_id"
  design_name <- obj .:? "design_name"
  nominal_weight <- obj .:? "nominal_weight"
  nominal_weight_id <- obj .:? "nominal_weight_id"
  quantity <- obj .:? "quantity"
  amount <- obj .:? "amount"
  -- Pack fields
  pack_id <- obj .:? "pack_id"
  deduction_rate <- obj .:? "deduction_rate"
  shape <- obj .:? "shape"
  purity <- obj .:? "purity"
  description <- obj .:? "description"
  weight_grams <- obj .:? "weight_grams"
  weight_baht <- obj .:? "weight_baht"
  calculation_amount <- obj .:? "calculation_amount"
  -- Transaction fields
  transaction_id <- obj .:? "transaction_id"
  transaction_type <- obj .:? "transaction_type"
  balance_type <- obj .:? "balance_type"
  amount_money <- obj .:? "amount_money"
  amount_grams <- obj .:? "amount_grams"
  amount_baht <- obj .:? "amount_baht"
  price_rate <- obj .:? "price_rate"
  conversion_charge_rate <- obj .:? "conversion_charge_rate"
  split_charge_rate <- obj .:? "split_charge_rate"
  block_making_charge_rate <- obj .:? "block_making_charge_rate"
  source_amount_grams <- obj .:? "source_amount_grams"
  source_amount_baht <- obj .:? "source_amount_baht"
  dest_amount_grams <- obj .:? "dest_amount_grams"
  dest_amount_baht <- obj .:? "dest_amount_baht"
  pure
    { id
    , display_order
    , tray_id
    , making_charge
    , jewelry_type_id
    , design_name
    , nominal_weight
    , nominal_weight_id
    , quantity
    , amount
    , pack_id
    , deduction_rate
    , shape
    , purity
    , description
    , weight_grams
    , weight_baht
    , calculation_amount
    , transaction_id
    , transaction_type
    , balance_type
    , amount_money
    , amount_grams
    , amount_baht
    , price_rate
    , conversion_charge_rate
    , split_charge_rate
    , block_making_charge_rate
    , source_amount_grams
    , source_amount_baht
    , dest_amount_grams
    , dest_amount_baht
    }

decodeGroupData :: _ -> Either String GroupData
decodeGroupData json = do
  obj <- lmap printJsonDecodeError $ decodeJson json
  type_ <- lmap printJsonDecodeError $ obj .: "type"
  trayJson <- lmap printJsonDecodeError $ obj .:? "tray"
  packJson <- lmap printJsonDecodeError $ obj .:? "pack"
  transactionJson <- lmap printJsonDecodeError $ obj .:? "transaction"
  itemsJson <- lmap printJsonDecodeError $ obj .: "items"

  tray <- case trayJson of
    Nothing -> pure Nothing
    Just tj -> Just <$> decodeTrayData tj

  pack <- case packJson of
    Nothing -> pure Nothing
    Just pj -> Just <$> decodePackData pj

  transaction <- case transactionJson of
    Nothing -> pure Nothing
    Just tj -> Just <$> decodeTransactionData tj

  items <- traverse decodeItemData itemsJson

  pure { "type": type_, tray, pack, transaction, items }

decodeBillGroup :: _ -> Either String BillGroup
decodeBillGroup json = do
  obj <- lmap printJsonDecodeError $ decodeJson json
  id <- lmap printJsonDecodeError $ obj .: "id"
  bill_id <- lmap printJsonDecodeError $ obj .: "bill_id"
  group_type <- lmap printJsonDecodeError $ obj .: "group_type"
  display_order <- lmap printJsonDecodeError $ obj .: "display_order"
  version <- lmap printJsonDecodeError $ obj .: "version"
  updated_by <- lmap printJsonDecodeError $ obj .:? "updated_by"
  created_at <- lmap printJsonDecodeError $ obj .: "created_at"
  updated_at <- lmap printJsonDecodeError $ obj .: "updated_at"
  dataJson <- lmap printJsonDecodeError $ obj .:? "data"

  groupData <- case dataJson of
    Nothing -> pure Nothing
    Just dj -> Just <$> decodeGroupData dj

  pure { id, bill_id, group_type, display_order, version, updated_by, created_at, updated_at, groupData }

encodeBillGroup :: BillGroup -> _
encodeBillGroup group =
  "id" := group.id
    ~> "bill_id" := group.bill_id
    ~> "group_type" := group.group_type
    ~> "display_order" := group.display_order
    ~> "version" := group.version
    ~> "updated_by" := group.updated_by
    ~> jsonEmptyObject

data BillGroupData
  = TrayGroupData Tray (Array TrayItem)
  | PackGroupData Pack (Array PackItem)
  | TransactionGroupData Transaction (Array TransactionItem)

derive instance eqBillGroupData :: Eq BillGroupData

-- ============================================================================
-- TRAY
-- ============================================================================

type Tray =
  { id :: Int
  , groupId :: Int
  , internalNum :: Int
  , isReturn :: Boolean
  , purity :: Maybe Number
  , shape :: Shape
  , discount :: Int
  , actualWeightGrams :: Number
  , priceRate :: Maybe Number
  , additionalChargeRate :: Maybe Number
  }

type TrayItem =
  { id :: Int
  , trayId :: Int
  , displayOrder :: Int
  , makingCharge :: Number
  , jewelryTypeId :: Maybe Int
  , designName :: Maybe String
  , nominalWeight :: Number
  , quantity :: Int
  , amount :: Number
  }

-- ============================================================================
-- PACK
-- ============================================================================

type Pack =
  { id :: Int
  , groupId :: Int
  , internalId :: Int
  , userNumber :: String
  }

type PackItem =
  { id :: Int
  , packId :: Int
  , displayOrder :: Int
  , deductionRate :: String
  , shape :: Shape
  , purity :: Maybe Number
  , description :: Maybe String
  , weightGrams :: Maybe Number
  , weightBaht :: Maybe Number
  , calculationAmount :: Number
  }

-- ============================================================================
-- TRANSACTION
-- ============================================================================

type Transaction =
  { id :: Int
  , groupId :: Int
  }

type TransactionItem =
  { id :: Int
  , transactionId :: Int
  , displayOrder :: Int
  , transactionType :: TransactionType

  -- Money
  , amountMoney :: Maybe Number

  -- Gold (ONE unit only)
  , amountGrams :: Maybe Number
  , amountBaht :: Maybe Number

  -- Additional fields
  , balanceType :: Maybe BalanceType
  , priceRate :: Maybe Number
  , conversionChargeRate :: Maybe Number
  , splitChargeRate :: Maybe Number
  , blockMakingChargeRate :: Maybe Number

  -- For conversions with different units
  , sourceAmountGrams :: Maybe Number
  , sourceAmountBaht :: Maybe Number
  , destAmountGrams :: Maybe Number
  , destAmountBaht :: Maybe Number
  }

-- ============================================================================
-- GOLD AMOUNT (Either grams or baht)
-- ============================================================================

data GoldAmount
  = Grams Number
  | Baht Number

derive instance eqGoldAmount :: Eq GoldAmount

instance showGoldAmount :: Show GoldAmount where
  show (Grams g) = show g <> "g"
  show (Baht b) = show b <> "บ"

-- ============================================================================
-- VAT CALCULATION
-- ============================================================================

type VATCalculation =
  { jewelryVAT :: Number -- VAT from jewelry (exclusive)
  , barVAT :: Number -- VAT from bar making charges (inclusive - extracted)
  , totalVAT :: Number -- Total VAT
  , taxableAmount :: Number -- Total taxable amount
  }
