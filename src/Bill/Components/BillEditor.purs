module Bill.Components.BillEditor where

import Prelude

import Bill.API as BillAPI
import Bill.API (PredefinedPurity)
import Bill.Constants as Constants
import Bill.Types (Bill, BillGroup, ItemData, PackData, TransactionData, TrayData)
import Data.Array (filter, foldl, length, find, (!!))
import Data.Array.NonEmpty (head) as NEArray
import Data.Either (Either(..))
import Data.Tuple (Tuple(..))
import Data.Maybe (Maybe(..), fromMaybe, maybe)
import Data.Number (fromString) as Number
import Data.Number.Format (fixed, toStringWith) as Number
import Data.Int (floor, round, toNumber, fromString)
import Data.String as String
import Data.String.Common (replace, split)
import Data.String.Pattern (Pattern(..), Replacement(..))
import Data.String.CodeUnits (takeRight) as String
import Data.String (length, contains) as String
import Data.String.Regex (Regex, replace, match, test) as Regex
import Data.String.Regex.Flags (noFlags)
import Data.String.Regex.Unsafe (unsafeRegex)
import Data.Int (rem, round, toNumber) as Int
import Data.Number (fromString) as Number
import Effect.Aff.Class (class MonadAff)
import Effect.Console (log)
import Effect (Effect)
import Halogen as H
import Web.Event.Event as Event
import Web.UIEvent.KeyboardEvent (KeyboardEvent)
import Web.UIEvent.KeyboardEvent as KE
import Web.UIEvent.FocusEvent (FocusEvent)
import Web.UIEvent.FocusEvent as FE
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import TextConstants.BillEditor as TC
import TextConstants as TextConstants

-- Foreign function to check if focus left the edit row
foreign import checkFocusLeftEditRow :: FocusEvent -> Effect Boolean
foreign import forceInputValue :: String -> String -> Effect Unit

type Slot = H.Slot Query Output

type Input =
  { billId :: Maybe Int
  , customerId :: Int
  , customerName :: String
  , jewelryTypes :: Array JewelryType
  , nominalWeights :: Array NominalWeight
  , predefinedPurities :: Array PredefinedPurity
  }

type State =
  { billId :: Maybe Int
  , customerId :: Int
  , customerName :: String
  , bill :: Maybe Bill
  , groups :: Array BillGroup
  , isLoading :: Boolean
  , isSaving :: Boolean
  , error :: Maybe String
  , isDirty :: Boolean
  , editingTrayItem :: Maybe { groupId :: Int, itemId :: Int, focusedField :: Maybe TrayItemField }
  , editItemData :: EditItemData
  , jewelryTypes :: Array JewelryType
  , nominalWeights :: Array NominalWeight
  , isSavingItem :: Boolean
  , deleteConfirmation :: Maybe { trayId :: Int, itemId :: Int }
  , editingTrayPrice :: Maybe { trayId :: Int, value :: String }
  , editingTrayPurity :: Maybe { trayId :: Int, value :: String }
  , editingTrayWeight :: Maybe { trayId :: Int, value :: String }
  , editingWeightLabel :: Maybe { trayId :: Int, value :: String }
  , editingExtraCharge :: Maybe { trayId :: Int, value :: String }
  , predefinedPurities :: Array PredefinedPurity
  }

type JewelryType =
  { id :: Int
  , name :: String
  }

type NominalWeight =
  { id :: Int
  , label :: String
  , weight_grams :: Number
  }

type EditItemData =
  { makingCharge :: String
  , jewelryType :: String
  , designName :: String
  , nominalWeight :: String
  , quantity :: String
  }

data Query a = LoadBill Int a

data Action
  = Initialize
  | Receive Input
  | Reload
  | Save
  | Cancel
  | Finalize
  | AddTray
  | AddPack
  | AddTransaction
  | StartEditTrayItem Int Int (Maybe TrayItemField) -- groupId, itemId (use -1 for new item), field
  | CancelEditTrayItem
  | SaveTrayItem Int -- groupId
  | ShowDeleteConfirmation Int Int -- trayId, itemId
  | ConfirmDeleteTrayItem
  | CancelDeleteTrayItem
  | UpdateTrayItemField TrayItemField String
  | UpdateTrayItemFieldValidated TrayItemField String -- For weight field with validation
  | HandleTrayItemKeyDown Int KeyboardEvent -- groupId, event
  | CheckTrayItemRowBlur FocusEvent -- Check if focus left the edit row
  | ValidateTrayItemField TrayItemField -- Validate field when moving to another field
  | StartEditTrayPrice Int -- trayId
  | UpdateTrayPrice String
  | SaveTrayPrice
  | CancelEditTrayPrice
  | StartEditTrayPurity Int -- trayId
  | UpdateTrayPurity String
  | SaveTrayPurity
  | CancelEditTrayPurity
  | UpdateTrayDiscount Int String -- trayId, discount value
  | StartEditTrayWeight Int -- trayId
  | UpdateTrayWeight String
  | SaveTrayWeight
  | CancelEditTrayWeight
  | StartEditWeightLabel Int -- trayId
  | UpdateWeightLabel String
  | SaveWeightLabel
  | CancelEditWeightLabel
  | StartEditExtraCharge Int -- trayId
  | UpdateExtraCharge String
  | SaveExtraCharge
  | CancelEditExtraCharge
  | NoOp

data TrayItemField
  = MakingChargeField
  | JewelryTypeField
  | DesignNameField
  | NominalWeightField
  | QuantityField

derive instance eqTrayItemField :: Eq TrayItemField

data Output
  = BillSaved Bill
  | BillCancelled
  | BillFinalized Bill

trimZerosRegex :: Regex.Regex
trimZerosRegex = unsafeRegex "(\\.?)0{1,3}$" noFlags

-- Format number to fixed decimals, then trim trailing zeros
-- This prevents bugs like "2200" being trimmed to "22"
formatAndTrimNumber :: String -> Int -> String
formatAndTrimNumber str decimals =
  case Number.fromString str of
    Just n ->
      let
        formatted = Number.toStringWith (Number.fixed decimals) n
      in
        Regex.replace trimZerosRegex "" formatted
    Nothing -> str

-- Validate numeric input by extracting valid numeric prefix
-- Keeps digits, decimal point, and leading minus sign
validateNumeric :: String -> String
validateNumeric str =
  let
    numericRegex = unsafeRegex "^-?[0-9]*\\.?[0-9]*" noFlags
  in
    fromMaybe "" $ do
      matches <- Regex.match numericRegex str
      NEArray.head matches

-- Advanced weight validation with fraction support and real-time conversion
-- Blocks illegal characters immediately (like making_charge field)
-- Auto-converts: 1/2→½, 1/4→¼, 3/4→¾
validateWeightInput :: String -> String -> String
validateWeightInput oldValue newValue =
  let
    oldLen = String.length oldValue
    newLen = String.length newValue
    isLonger = newLen > oldLen
    -- Check if newValue starts with oldValue (true addition vs replacement/deletion)
    isAddition = isLonger && (String.take oldLen newValue == oldValue)
    isReplacement = newLen == oldLen && oldValue /= newValue
  in
    if isAddition then
      -- Multiple characters might be added at once (fast typing)
      -- Validate character by character
      let
        charsAdded = newLen - oldLen
      in
        if charsAdded == 1 then
          -- Single character addition - use fast path
          validateWeightAddition oldValue newValue
        else
          -- Multiple characters - validate one by one
          validateMultipleChars oldValue newValue oldLen
    else if isReplacement then
      -- User selected and replaced text - validate from empty
      validateFromEmpty newValue
    else
      newValue -- Allow deletion/no change

-- Validate multiple characters added at once (fast typing)
validateMultipleChars :: String -> String -> Int -> String
validateMultipleChars oldValue newValue oldLen =
  let
    -- Get the characters that were added
    addedChars = String.drop oldLen newValue
    -- Validate each character one by one
    validateEachChar acc remaining =
      case String.take 1 remaining of
        "" -> acc -- No more characters to validate
        nextChar ->
          let
            proposed = acc <> nextChar
            validated = validateWeightAddition acc proposed
            rest = String.drop 1 remaining
          in
            if validated == acc then
              acc -- Character was blocked, stop processing
            else
              validateEachChar validated rest -- Character accepted, continue
  in
    validateEachChar oldValue addedChars

-- Validate when user adds a character
validateWeightAddition :: String -> String -> String
validateWeightAddition oldValue newValue =
  let
    lastChar = String.takeRight 1 newValue
    -- Check for Unicode fractions
    isFraction = oldValue == "½" || oldValue == "¼" || oldValue == "¾"
  in
    case oldValue of
      "" -> validateFromEmpty newValue
      "1" -> validateAfterOne newValue
      "3" -> validateAfterThree newValue
      "1/" -> validateAfterOneSlash newValue
      "3/" -> validateAfterThreeSlash newValue
      _ | isFraction -> validateAfterFraction oldValue newValue
      _ -> validateDefault oldValue newValue

-- Validate from empty: only allow digits
validateFromEmpty :: String -> String
validateFromEmpty str =
  if Regex.test (unsafeRegex "^[0-9]$" noFlags) str then str
  else ""

-- Validate after fraction: only allow units
validateAfterFraction :: String -> String -> String
validateAfterFraction oldValue newValue =
  let
    lastChar = String.takeRight 1 newValue
  in
    case lastChar of
      "ส" -> oldValue <> "ส"
      "บ" -> oldValue <> "บ"
      "g" -> oldValue <> "g"
      _ -> oldValue -- Block everything else

-- After "1": allow digits, /, decimal, or units
validateAfterOne :: String -> String
validateAfterOne newValue =
  let
    lastChar = String.takeRight 1 newValue
  in
    case lastChar of
      "/" -> "1/" -- Allow fraction
      "." -> "1." -- Allow decimal
      "ส" -> "1ส" -- Allow unit
      "บ" -> "1บ"
      "g" -> "1g"
      c | Regex.test (unsafeRegex "^[0-9]$" noFlags) c -> newValue -- Allow digit
      _ -> "1" -- Block illegal char

-- After "3": allow digits, /, decimal, or units  
validateAfterThree :: String -> String
validateAfterThree newValue =
  let
    lastChar = String.takeRight 1 newValue
  in
    case lastChar of
      "/" -> "3/" -- Allow fraction
      "." -> "3." -- Allow decimal
      "ส" -> "3ส"
      "บ" -> "3บ"
      "g" -> "3g"
      c | Regex.test (unsafeRegex "^[0-9]$" noFlags) c -> newValue
      _ -> "3"

-- After "1/": only allow 2 or 4
validateAfterOneSlash :: String -> String
validateAfterOneSlash newValue =
  case String.takeRight 1 newValue of
    "2" -> "½" -- Auto-convert to Unicode
    "4" -> "¼" -- Auto-convert to Unicode
    _ -> "1/" -- Block other chars

-- After "3/": only allow 4
validateAfterThreeSlash :: String -> String
validateAfterThreeSlash newValue =
  case String.takeRight 1 newValue of
    "4" -> "¾" -- Auto-convert to Unicode
    _ -> "3/" -- Block other chars

-- Default validation for other cases (multi-digit numbers, decimals, etc.)
validateDefault :: String -> String -> String
validateDefault oldValue newValue =
  let
    lastChar = String.takeRight 1 newValue
    hasUnit = String.contains (Pattern "ส") oldValue
      || String.contains (Pattern "บ") oldValue
      ||
        String.contains (Pattern "g") oldValue
    hasDecimal = String.contains (Pattern ".") oldValue
  in
    if hasUnit then
      oldValue -- Block everything after unit
    else
      -- Before unit: allow digits, one decimal, and units
      case lastChar of
        "." | not hasDecimal -> newValue -- Allow one decimal point
        "ส" -> newValue -- Allow unit
        "บ" -> newValue
        "g" -> newValue
        "/" -> oldValue -- Block slash (only valid at start: ^1/ or ^3/)
        c | Regex.test (unsafeRegex "^[0-9]$" noFlags) c -> newValue -- Allow digits
        _ -> oldValue -- Block everything else (letters, symbols, etc.)

-- Parse weight value from string with fraction support
-- "½บ" -> { value: 0.5, unit: "บ" }
-- "3/4บ" -> { value: 0.75, unit: "บ" }  (shouldn't happen with validation, but handle it)
-- "2.5ส" -> { value: 2.5, unit: "ส" }
parseWeightValue :: String -> { value :: Number, unit :: String }
parseWeightValue str =
  let
    -- Convert Unicode fractions to decimal
    withDecimal = case str of
      s | String.contains (Pattern "½") s -> replace (Pattern "½") (Replacement "0.5") s
      s | String.contains (Pattern "¼") s -> replace (Pattern "¼") (Replacement "0.25") s
      s | String.contains (Pattern "¾") s -> replace (Pattern "¾") (Replacement "0.75") s
      s -> s

    -- Extract unit (last character if it's ส, บ, or g)
    unit = case String.takeRight 1 withDecimal of
      "ส" -> "ส"
      "บ" -> "บ"
      "g" -> "g"
      _ -> "g" -- Default to grams

    -- Extract numeric value (everything except the unit)
    valueStr =
      if unit /= "g" && String.contains (Pattern unit) withDecimal then String.take (String.length withDecimal - 1) withDecimal
      else withDecimal

    -- Parse to number
    value = parseNumber valueStr
  in
    { value, unit }

-- Convert weight to grams
convertToGrams :: { value :: Number, unit :: String } -> Number
convertToGrams { value, unit } =
  case unit of
    "บ" -> value * Constants.gramsPerBahtJewelry -- 15.2 g per baht
    "ส" -> value * (Constants.gramsPerBahtJewelry / 4.0) -- 3.8 g per salueng (quarter baht)
    "g" -> value
    _ -> value

-- Format number to fixed 3 decimals for safe comparison
-- Avoids floating-point representation errors
formatFixed3 :: Number -> String
formatFixed3 n =
  let
    -- Multiply by 1000, round to int, convert back to number, divide by 1000
    rounded = (Int.toNumber (Int.round (n * 1000.0))) / 1000.0
  in
    -- Format with exactly 3 decimals
    show rounded

-- Normalize weight to predefined weight if there's a match
-- Uses safe string comparison of fixed-3-decimal grams
normalizeWeight :: String -> Array NominalWeight -> String
normalizeWeight input predefinedWeights =
  let
    parsed = parseWeightValue input
    grams = convertToGrams parsed
    gramsStr = formatFixed3 grams

    -- Find matching predefined weight
    match = find (\nw -> formatFixed3 nw.weight_grams == gramsStr) predefinedWeights
  in
    case match of
      Just nw -> nw.label -- Use predefined label (e.g., "3ส")
      Nothing -> input -- Keep original if no match

component :: forall m. MonadAff m => H.Component Query Input Output m
component =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval $ H.defaultEval
        { handleAction = handleAction
        , handleQuery = handleQuery
        , initialize = Just Initialize
        , receive = Just <<< Receive
        }
    }

initialState :: Input -> State
initialState input =
  { billId: input.billId
  , customerId: input.customerId
  , customerName: input.customerName
  , bill: Nothing
  , groups: []
  , isLoading: false
  , isSaving: false
  , error: Nothing
  , isDirty: false
  , editingTrayItem: Nothing
  , editItemData: emptyEditItemData
  , jewelryTypes: input.jewelryTypes
  , nominalWeights: input.nominalWeights
  , isSavingItem: false
  , deleteConfirmation: Nothing
  , editingTrayPrice: Nothing
  , editingTrayPurity: Nothing
  , editingTrayWeight: Nothing
  , editingWeightLabel: Nothing
  , editingExtraCharge: Nothing
  , predefinedPurities: input.predefinedPurities
  }

emptyEditItemData :: EditItemData
emptyEditItemData =
  { makingCharge: ""
  , jewelryType: ""
  , designName: ""
  , nominalWeight: ""
  , quantity: "1"
  }

render :: forall m. State -> H.ComponentHTML Action () m
render state =
  HH.div
    [ HP.class_ $ HH.ClassName "bill-editor" ]
    [ renderHeader state
    , renderContent state
    , renderFooter state
    , case state.deleteConfirmation of
        Just _ -> renderDeleteConfirmation
        Nothing -> HH.text ""
    ]

renderHeader :: forall m. State -> H.ComponentHTML Action () m
renderHeader state =
  HH.div
    [ HP.class_ $ HH.ClassName "bill-editor-header" ]
    [ HH.h2_
        [ HH.text $ TC.billEditor <> " - " <> state.customerName ]
    , case state.bill of
        Nothing -> HH.text ""
        Just bill ->
          HH.div
            [ HP.class_ $ HH.ClassName "bill-info" ]
            [ HH.span_ [ HH.text $ TC.billId <> ": " <> show bill.id ]
            , HH.span_ [ HH.text $ " | " <> TC.date <> ": " <> bill.date ]
            , HH.span_
                [ HH.text $ " | " <> TC.status <> ": " <>
                    if bill.is_finalized then TC.finalized else TC.draft
                ]
            ]
    ]

renderContent :: forall m. State -> H.ComponentHTML Action () m
renderContent state
  | state.isLoading = renderLoading
  | Just err <- state.error = renderError err
  | Nothing <- state.bill = renderNoBill
  | otherwise = renderBillContent state

renderLoading :: forall m. H.ComponentHTML Action () m
renderLoading =
  HH.div
    [ HP.class_ $ HH.ClassName "bill-editor-loading" ]
    [ HH.text TC.loading ]

renderError :: forall m. String -> H.ComponentHTML Action () m
renderError err =
  HH.div
    [ HP.class_ $ HH.ClassName "bill-editor-error" ]
    [ HH.text $ TC.errorPrefix <> err ]

renderNoBill :: forall m. H.ComponentHTML Action () m
renderNoBill =
  HH.div
    [ HP.class_ $ HH.ClassName "bill-editor-empty" ]
    [ HH.text "No bill loaded" ]

renderBillContent :: forall m. State -> H.ComponentHTML Action () m
renderBillContent state =
  case state.bill of
    Nothing -> HH.text ""
    Just bill ->
      HH.div
        [ HP.class_ $ HH.ClassName "bill-editor-content" ]
        [ renderPreviousBalance bill
        , renderGroups state state.groups
        , renderAddGroupButtons
        , renderGrandTotal bill
        ]

renderPreviousBalance :: forall m. Bill -> H.ComponentHTML Action () m
renderPreviousBalance bill =
  let
    goldBalances = getGoldBalances bill
    moneyBalance = getMoneyBalance bill
  in
    if length goldBalances == 0 && not moneyBalance.hasBalance then HH.text ""
    else HH.table
      [ HP.class_ $ HH.ClassName "balance-table-compact" ]
      [ HH.tbody_
          [ HH.tr_
              [ -- Column 1: Gold descriptions
                HH.td [ HP.class_ $ HH.ClassName "balance-desc-col" ]
                  (map (\b -> HH.div_ [ HH.text b.description ]) goldBalances)
              , -- Column 2: Gold values
                HH.td [ HP.class_ $ HH.ClassName "balance-value-col" ]
                  (map (\b -> HH.div_ [ renderGoldValue b.value ]) goldBalances)
              , -- Column 3: Money description
                HH.td [ HP.class_ $ HH.ClassName "balance-desc-col" ]
                  [ if moneyBalance.hasBalance then HH.text moneyBalance.description
                    else HH.text ""
                  ]
              , -- Column 4: Money value
                HH.td [ HP.class_ $ HH.ClassName "balance-value-col" ]
                  [ if moneyBalance.hasBalance then renderMoneyValue moneyBalance.value
                    else HH.text ""
                  ]
              ]
          ]
      ]

type BalanceRow = { description :: String, value :: String }
type MoneyBalanceRow = { hasBalance :: Boolean, description :: String, value :: String }

getMoneyBalance :: Bill -> MoneyBalanceRow
getMoneyBalance bill =
  let
    money = parseNumber bill.prev_balance_money
  in
    if money == 0.0 then { hasBalance: false, description: "", value: "" }
    else
      { hasBalance: true
      , description: TextConstants.balanceConstants.prefixPrevious <> (if money > 0.0 then TextConstants.balanceConstants.statusCredit else TextConstants.balanceConstants.statusDebit) <> TextConstants.balanceConstants.typeMoney
      , value: formatMoneyString (abs money)
      }

getGoldBalances :: Bill -> Array BalanceRow
getGoldBalances bill =
  let
    gramJewel = parseNumber bill.prev_gram_jewel
    bahtJewel = parseNumber bill.prev_baht_jewel
    bahtBar96 = parseNumber bill.prev_baht_bar96
    gramBar96 = parseNumber bill.prev_gram_bar96
    bahtBar99 = parseNumber bill.prev_baht_bar99
    gramBar99 = parseNumber bill.prev_gram_bar99

    rows = []
    rows1 = addBalanceRow rows gramJewel TextConstants.balanceConstants.typeGoldJewelry formatGrams
    rows2 = addBalanceRow rows1 bahtJewel TextConstants.balanceConstants.typeGoldJewelry formatBaht
    rows3 = addBalanceRow rows2 bahtBar96 TextConstants.balanceConstants.typeGoldBar96 formatBaht
    rows4 = addBalanceRow rows3 gramBar96 TextConstants.balanceConstants.typeGoldBar96 formatGrams
    rows5 = addBalanceRow rows4 bahtBar99 TextConstants.balanceConstants.typeGoldBar99 formatBaht
    rows6 = addBalanceRow rows5 gramBar99 TextConstants.balanceConstants.typeGoldBar99 formatGrams
  in
    rows6

parseNumber :: String -> Number
parseNumber str = case Number.fromString str of
  Just n -> n
  Nothing -> 0.0

abs :: Number -> Number
abs n = if n < 0.0 then -n else n

formatGrams :: Number -> String
formatGrams n =
  let
    absN = abs n
    formatted = Number.toStringWith (Number.fixed 3) absN
  in
    formatted <> TextConstants.formatConstants.unitGrams

formatBaht :: Number -> String
formatBaht n =
  let
    absN = abs n
    -- Format to 3 decimals then strip trailing zeros
    formatted = Number.toStringWith (Number.fixed 3) absN
    -- Remove .000, .00, .0 patterns using regex
    cleaned = Regex.replace trimZerosRegex "" formatted
  in
    cleaned <> TextConstants.formatConstants.unitBaht

formatMoneyString :: Number -> String
formatMoneyString n =
  let
    intPart = floor n
    decPart = round ((n - toNumber intPart) * 100.0)
    intStr = formatWithCommas intPart
  in
    if decPart == 0 then intStr <> "." <> TextConstants.formatConstants.subscript00
    else intStr <> "." <> toSubscript decPart

formatWithCommas :: Int -> String
formatWithCommas n =
  let
    str = show (if n < 0 then -n else n)
    len = String.length str
  in
    if len <= 3 then str
    else addCommasToString str

addCommasToString :: String -> String
addCommasToString str =
  let
    len = String.length str
    -- Process from right to left
    result = go (len - 1) 0 ""

    go :: Int -> Int -> String -> String
    go idx count acc =
      if idx < 0 then acc
      else
        let
          char = String.take 1 (String.drop idx str)
          newAcc =
            if count > 0 && Int.rem count 3 == 0 then char <> "," <> acc
            else char <> acc
        in
          go (idx - 1) (count + 1) newAcc
  in
    result

renderGoldValue :: forall m. String -> H.ComponentHTML Action () m
renderGoldValue str =
  -- Parse "123.456g" or "12.5บ" into number only (no unit)
  let
    hasG = String.contains (Pattern TextConstants.formatConstants.unitGrams) str
    hasBaht = String.contains (Pattern TextConstants.formatConstants.unitBaht) str
  in
    if hasG then
      let
        numPart = replace (Pattern TextConstants.formatConstants.unitGrams) (Replacement "") str
      in
        HH.span [ HP.class_ $ HH.ClassName "num" ] [ HH.text numPart ]
    else if hasBaht then
      let
        numPart = replace (Pattern TextConstants.formatConstants.unitBaht) (Replacement "") str
      in
        HH.span [ HP.class_ $ HH.ClassName "num" ] [ HH.text numPart ]
    else HH.text str

renderMoneyValue :: forall m. String -> H.ComponentHTML Action () m
renderMoneyValue str =
  -- Parse "1,000.₀₀" - hide both "." and "₀₀"
  if String.contains (Pattern ".") str then
    let
      parts = split (Pattern ".") str
    in
      case parts of
        [ intPart, decPart ] ->
          let
            isZeroDecimal = decPart == TextConstants.formatConstants.subscript00
          in
            if isZeroDecimal then HH.span_
              [ HH.span [ HP.class_ $ HH.ClassName "num" ] [ HH.text intPart ]
              , HH.span [ HP.class_ $ HH.ClassName "num-subscript-hidden" ] [ HH.text $ "." <> decPart ]
              ]
            else HH.span_
              [ HH.span [ HP.class_ $ HH.ClassName "num" ] [ HH.text intPart ]
              , HH.text "."
              , HH.span [ HP.class_ $ HH.ClassName "num-subscript" ] [ HH.text decPart ]
              ]
        _ -> HH.text str
  else HH.text str

renderNumberWithUnit :: forall m. String -> String -> H.ComponentHTML Action () m
renderNumberWithUnit num unit =
  if num == "-" then HH.text "-"
  else HH.span_
    [ HH.span [ HP.class_ $ HH.ClassName "num" ] [ HH.text $ formatNumberString num ]
    , HH.text $ " " <> unit
    ]

renderMoneyWithUnit :: forall m. String -> String -> H.ComponentHTML Action () m
renderMoneyWithUnit num unit =
  if num == "-" then HH.text "-"
  else
    let
      formatted = formatMoneyDisplay num
    in
      HH.span_
        [ formatted
        , HH.text $ " " <> unit
        ]

formatNumberString :: String -> String
formatNumberString str =
  -- Add commas to integer part
  case Number.fromString str of
    Just n ->
      let
        intPart = floor n
        decPart = n - toNumber intPart
      in
        if decPart == 0.0 then formatWithCommas intPart
        else formatWithCommas intPart <> String.drop (String.length (show intPart)) str
    Nothing -> str

formatMoneyDisplay :: String -> forall m. H.ComponentHTML Action () m
formatMoneyDisplay str =
  case Number.fromString str of
    Just n ->
      let
        intPart = floor n
        decPart = round ((n - toNumber intPart) * 100.0)
        intStr = formatWithCommas intPart
      in
        if decPart == 0 then HH.span_
          [ HH.span [ HP.class_ $ HH.ClassName "num" ] [ HH.text intStr ]
          , HH.text "."
          , HH.span [ HP.class_ $ HH.ClassName "num-subscript-hidden" ] [ HH.text TextConstants.formatConstants.subscript00 ]
          ]
        else HH.span_
          [ HH.span [ HP.class_ $ HH.ClassName "num" ] [ HH.text intStr ]
          , HH.text "."
          , HH.span [ HP.class_ $ HH.ClassName "num-subscript" ] [ HH.text $ toSubscript decPart ]
          ]
    Nothing -> HH.text str

toSubscript :: Int -> String
toSubscript n =
  let
    digits = String.split (String.Pattern "") (show n)
    subscriptDigits = map digitToSubscript digits
  in
    String.joinWith "" subscriptDigits

digitToSubscript :: String -> String
digitToSubscript d = case d of
  "0" -> TextConstants.formatConstants.subscript0
  "1" -> TextConstants.formatConstants.subscript1
  "2" -> TextConstants.formatConstants.subscript2
  "3" -> TextConstants.formatConstants.subscript3
  "4" -> TextConstants.formatConstants.subscript4
  "5" -> TextConstants.formatConstants.subscript5
  "6" -> TextConstants.formatConstants.subscript6
  "7" -> TextConstants.formatConstants.subscript7
  "8" -> TextConstants.formatConstants.subscript8
  "9" -> TextConstants.formatConstants.subscript9
  _ -> d

renderGroups :: forall m. State -> Array BillGroup -> H.ComponentHTML Action () m
renderGroups state groups =
  HH.div
    [ HP.class_ $ HH.ClassName "bill-groups" ]
    [ if length groups == 0 then HH.p_ [ HH.text "ยังไม่มีกลุ่ม - กดปุ่มด้านล่างเพื่อเพิ่ม" ]
      else HH.div_ (map (renderGroup state) groups)
    ]

renderGroup :: forall m. State -> BillGroup -> H.ComponentHTML Action () m
renderGroup state group = case group.groupData of
  Nothing -> renderEmptyGroup group
  Just groupData -> case groupData."type" of
    "tray" -> case groupData.tray of
      Just tray -> renderTrayGroup state group tray groupData.items
      Nothing -> renderEmptyGroup group
    "pack" -> case groupData.pack of
      Just pack -> renderPackGroup group pack groupData.items
      Nothing -> renderEmptyGroup group
    "transaction" -> case groupData.transaction of
      Just transaction -> renderTransactionGroup group transaction groupData.items
      Nothing -> renderEmptyGroup group
    _ -> renderEmptyGroup group

renderEmptyGroup :: forall m. BillGroup -> H.ComponentHTML Action () m
renderEmptyGroup group =
  HH.div
    [ HP.class_ $ HH.ClassName "bill-group-item" ]
    [ HH.div
        [ HP.class_ $ HH.ClassName "group-header" ]
        [ HH.span_ [ HH.text $ getGroupTypeLabel group.group_type ]
        , HH.span_ [ HH.text $ " #" <> show group.display_order ]
        ]
    , HH.div
        [ HP.class_ $ HH.ClassName "group-content" ]
        [ HH.text "No data" ]
    ]

renderTrayGroup :: forall m. State -> BillGroup -> TrayData -> Array ItemData -> H.ComponentHTML Action () m
renderTrayGroup state group tray items =
  let
    purityNum = parseNumber (fromMaybe "96.5" tray.purity)
    totalWeight = calculateTrayTotalWeight items purityNum
    totalMakingCharge = calculateTrayTotalMakingCharge items
    discountPercent = fromMaybe 0 tray.discount
    discountAmount = round (toNumber totalMakingCharge * toNumber discountPercent / 100.0)
    netMakingCharge = totalMakingCharge - discountAmount
  in
    HH.div
      [ HP.class_ $ HH.ClassName "tray-group" ]
      [ renderTrayHeader state tray (length items)
      , HH.div
          [ HP.class_ $ HH.ClassName "tray-body" ]
          [ renderTrayItemsTable state group.id items ]
      , HH.div
          [ HP.class_ $ HH.ClassName "tray-footer" ]
          [ renderTraySubtotal state tray items ]
      ]

renderTrayHeader :: forall m. State -> TrayData -> Int -> H.ComponentHTML Action () m
renderTrayHeader state tray itemCount =
  let
    isEditingPrice = case state.editingTrayPrice of
      Just editing -> editing.trayId == tray.id
      Nothing -> false
    isEditingPurity = case state.editingTrayPurity of
      Just editing -> editing.trayId == tray.id
      Nothing -> false
  in
    HH.div
      [ HP.class_ $ HH.ClassName "tray-header" ]
      [ HH.div
          [ HP.class_ $ HH.ClassName "tray-header-col tray-price"
          , if not isEditingPrice then HE.onClick \_ -> StartEditTrayPrice tray.id
            else HP.attr (HH.AttrName "data-editing") "true"
          ]
          [ renderTrayPrice state tray ]
      , HH.div
          [ HP.class_ $ HH.ClassName "tray-header-col tray-title"
          ]
          [ HH.text $ (if tray.is_return then "ของคืน" else "ทองรูปพรรณ") <> " (ถาดที่ " <> show tray.internal_num <> ")"
          , HH.span [ HP.class_ $ HH.ClassName "tray-summary" ]
              [ HH.text $ " • " <> show itemCount <> " รายการ" ]
          ]
      , HH.div
          [ HP.class_ $ HH.ClassName "tray-header-col tray-purity"
          , if not isEditingPurity then HE.onClick \_ -> StartEditTrayPurity tray.id
            else HP.attr (HH.AttrName "data-editing") "true"
          ]
          [ renderTrayPurity state tray ]
      ]

renderTrayPrice :: forall m. State -> TrayData -> H.ComponentHTML Action () m
renderTrayPrice state tray =
  case state.editingTrayPrice of
    Just editing | editing.trayId == tray.id ->
      HH.div
        [ HP.class_ $ HH.ClassName "tray-price-edit-container" ]
        [ HH.input
            [ HP.type_ HP.InputNumber
            , HP.class_ $ HH.ClassName "edit-input num tray-price-input"
            , HP.value editing.value
            , HP.placeholder "ราคาทอง"
            , HP.autofocus true
            , HE.onValueInput UpdateTrayPrice
            , HE.onBlur \_ -> SaveTrayPrice
            , HE.onKeyDown \e -> case KE.key e of
                "Enter" -> SaveTrayPrice
                "Escape" -> CancelEditTrayPrice
                _ -> NoOp
            ]
        , HH.text TextConstants.formatConstants.unitPrice
        ]
    _ ->
      case tray.price_rate of
        Just price | price /= "" ->
          let
            formattedPrice = case Number.fromString price of
              Just priceNum -> formatWithCommas (floor priceNum)
              Nothing -> price
          in
            HH.div
              [ HP.class_ $ HH.ClassName "editable-field" ]
              [ HH.span [ HP.class_ $ HH.ClassName "num" ] [ HH.text formattedPrice ]
              , HH.text $ " " <> TextConstants.formatConstants.unitPrice
              ]
        _ ->
          HH.div
            [ HP.class_ $ HH.ClassName "editable-field empty"
            , HP.title "คลิกเพื่อตั้งราคาทอง"
            ]
            [ HH.text "" ]

renderTrayPurity :: forall m. State -> TrayData -> H.ComponentHTML Action () m
renderTrayPurity state tray =
  case state.editingTrayPurity of
    Just editing | editing.trayId == tray.id ->
      HH.select
        [ HP.class_ $ HH.ClassName "edit-select"
        , HE.onValueChange UpdateTrayPurity
        , HE.onBlur \_ -> SaveTrayPurity
        ]
        ( map
            ( \p ->
                let
                  val = case p.purity of
                    Nothing -> ""
                    Just n -> show n

                  display =
                    let
                      s = show p.display_val
                    in
                      Regex.replace trimZerosRegex "" s
                in
                  HH.option
                    [ HP.value val
                    , HP.selected (editing.value == val || (Number.fromString editing.value == p.purity))
                    ]
                    [ HH.text $ display <> TextConstants.formatConstants.unitPercent ]
            )
            state.predefinedPurities
        )
    _ ->
      case tray.purity of
        Just purity | purity /= "" && purity /= "96.5" ->
          let
            -- Check if this purity matches a predefined one
            matchedPredefined = filter
              ( \p ->
                  case p.purity of
                    Just val -> show val == purity || (String.contains (Pattern ".") purity && Number.fromString purity == Just val)
                    Nothing -> false
              )
              state.predefinedPurities

            formattedPurity =
              let
                formatNum n =
                  let
                    s = show n
                  in
                    Regex.replace trimZerosRegex "" s
              in
                case matchedPredefined of
                  [ p ] -> formatNum p.display_val
                  _ ->
                    -- Elegant trailing zero removal
                    case Number.fromString purity of
                      Just num -> formatNum num
                      Nothing -> purity
          in
            HH.div
              [ HP.class_ $ HH.ClassName "editable-field" ]
              [ HH.span [ HP.class_ $ HH.ClassName "num" ] [ HH.text formattedPurity ]
              , HH.text TextConstants.formatConstants.unitPercent
              ]
        _ ->
          HH.div
            [ HP.class_ $ HH.ClassName "editable-field empty"
            , HP.title "คลิกเพื่อตั้งความบริสุทธิ์"
            ]
            [ HH.text "" ]

-- Parse Thai weight units (บาท, สลึง) and convert to grams
parseThaiWeight :: String -> Number
parseThaiWeight input =
  let
    trimmed = String.trim input
    -- Check for บาท (baht)
    hasBaht = String.contains (Pattern TextConstants.formatConstants.unitBaht) trimmed || String.contains (Pattern TextConstants.formatConstants.unitBahtFull) trimmed
    -- Check for สลึง (salung)
    hasSalung = String.contains (Pattern TextConstants.formatConstants.unitSalungShort) trimmed || String.contains (Pattern TextConstants.formatConstants.unitSalung) trimmed
    -- Remove Thai characters and parse number
    cleaned = replace (Pattern TextConstants.formatConstants.unitBahtFull) (Replacement "") $ replace (Pattern TextConstants.formatConstants.unitBaht) (Replacement "")
      $ replace (Pattern TextConstants.formatConstants.unitSalung) (Replacement "")
      $ replace (Pattern TextConstants.formatConstants.unitSalungShort) (Replacement "") trimmed
    numValue = parseNumber cleaned
  in
    if hasBaht then numValue * TextConstants.formatConstants.gramsPerBaht -- 1 baht = 15.200 grams
    else if hasSalung then numValue * TextConstants.formatConstants.gramsPerSalung -- 1 salung = 3.800 grams
    else numValue -- Already in grams

calculateTrayTotalWeight :: Array ItemData -> Number -> Number
calculateTrayTotalWeight items _ =
  let
    totalGrams = foldl
      ( \acc item ->
          let
            weight = parseNumber (fromMaybe "0" item.nominal_weight) -- Expect grams
            qty = fromMaybe 1 item.quantity
          in
            acc + (weight * toNumber qty)
      )
      0.0
      items
    -- Round to nearest 0.05
    rounded = (toNumber (round (totalGrams * 20.0))) / 20.0
  in
    rounded

calculateTrayTotalMakingCharge :: Array ItemData -> Int
calculateTrayTotalMakingCharge items =
  foldl
    ( \acc item ->
        let
          charge = fromMaybe 0 item.making_charge
          qty = fromMaybe 1 item.quantity
        in
          acc + (charge * qty)
    )
    0
    items

renderTrayItemsTable :: forall m. State -> Int -> Array ItemData -> H.ComponentHTML Action () m
renderTrayItemsTable state groupId items =
  let
    editingItemId = case state.editingTrayItem of
      Just { groupId: gid, itemId } | gid == groupId -> Just itemId
      _ -> Nothing
    isEditingNew = editingItemId == Just (-1)
    rows = map
      ( \item ->
          if Just item.id == editingItemId then renderTrayItemEditRow state groupId
          else renderTrayItemRow state state.jewelryTypes item
      )
      items
    editRow =
      if isEditingNew then [ renderTrayItemEditRow state groupId ]
      else []
    addButton =
      if editingItemId == Nothing then
        [ HH.tr_
            [ HH.td [ HP.colSpan 7, HP.class_ $ HH.ClassName "add-item-cell" ]
                [ HH.button
                    [ HP.class_ $ HH.ClassName "btn-add-item"
                    , HE.onClick \_ -> StartEditTrayItem groupId (-1) (Just MakingChargeField)
                    ]
                    [ HH.text "+ เพิ่มรายการ" ]
                ]
            ]
        ]
      else []
  in
    HH.table
      [ HP.class_ $ HH.ClassName "tray-items-table" ]
      [ HH.tbody_ $ rows <> editRow <> addButton
      ]

renderTrayItemRow :: forall m. State -> Array JewelryType -> ItemData -> H.ComponentHTML Action () m
renderTrayItemRow state jewelryTypes item =
  let
    weight = parseNumber (fromMaybe "0" item.nominal_weight)
    qty = fromMaybe 1 item.quantity
    charge = fromMaybe 0 item.making_charge
    totalCharge = charge * qty
    trayId = fromMaybe 0 item.tray_id
    jewelryTypeName = case item.jewelry_type_id of
      Just typeId ->
        case filter (\jt -> jt.id == typeId) jewelryTypes of
          [ jt ] -> jt.name
          _ -> "-"
      Nothing -> "-"
    -- Display nominal weight: show label for predefined, grams for custom
    -- Display nominal weight: show label for predefined, grams for custom
    nominalWeightDisplay = case item.nominal_weight_id of
      Just wid ->
        -- Predefined weight - show label
        case filter (\nw -> nw.id == wid) state.nominalWeights of
          [ nw ] -> HH.text nw.label
          _ -> renderNumberWithUnit (show weight) "g"
      Nothing ->
        -- Custom weight - show value in grams
        let
          formattedWeight = Number.toStringWith (Number.fixed 3) weight
        in
          HH.span_
            [ HH.span [ HP.class_ $ HH.ClassName "num" ] [ HH.text formattedWeight ]
            , HH.text "g"
            ]
    -- Find groupId from trayId
    groupId =
      case
        filter
          ( \g -> case g.groupData of
              Just gd -> case gd.tray of
                Just tray -> tray.id == trayId
                Nothing -> false
              Nothing -> false
          )
          state.groups
        of
        [ g ] -> g.id
        _ -> 0
  in
    HH.tr_
      [ renderEditableCell groupId item.id MakingChargeField (renderMoneyInt charge)
      , renderEditableCell groupId item.id JewelryTypeField (HH.text jewelryTypeName)
      , renderEditableCell groupId item.id DesignNameField (HH.text $ fromMaybe "-" item.design_name)
      , renderEditableCell groupId item.id NominalWeightField nominalWeightDisplay
      , renderEditableCell groupId item.id QuantityField (HH.span [ HP.class_ $ HH.ClassName "num" ] [ HH.text $ show qty ])
      , HH.td_ [ renderMoneyInt totalCharge ]
      , HH.td_
          [ HH.button
              [ HP.type_ HP.ButtonButton
              , HP.class_ $ HH.ClassName "btn-delete-item"
              , HE.onClick \_ -> ShowDeleteConfirmation trayId item.id
              , HP.title "ลบรายการ"
              ]
              [ HH.text "🗑" ]
          ]
      ]

renderTrayItemEditRow :: forall m. State -> Int -> H.ComponentHTML Action () m
renderTrayItemEditRow state groupId =
  let
    data_ = state.editItemData
    focusedField = case state.editingTrayItem of
      Just { focusedField: f } -> f
      _ -> Nothing
  in
    HH.tr
      [ HP.class_ $ HH.ClassName "edit-row"
      , HE.onFocusOut CheckTrayItemRowBlur
      ]
      [ HH.td_
          [ HH.input
              [ HP.type_ HP.InputNumber
              , HP.class_ $ HH.ClassName "edit-input num"
              , HP.value data_.makingCharge
              , HP.placeholder "ค่าแรง/ชิ้น"
              , HP.autofocus (focusedField == Just MakingChargeField)
              , HE.onValueInput \v -> UpdateTrayItemField MakingChargeField v
              , HE.onBlur \_ -> ValidateTrayItemField MakingChargeField
              , HE.onKeyDown \e -> HandleTrayItemKeyDown groupId e
              ]
          ]
      , HH.td_
          [ HH.select
              [ HP.class_ $ HH.ClassName "edit-select"
              , HP.autofocus (focusedField == Just JewelryTypeField)
              , HE.onValueChange \v -> UpdateTrayItemField JewelryTypeField v
              , HE.onKeyDown \e -> HandleTrayItemKeyDown groupId e
              ]
              ( [ HH.option [ HP.value "", HP.selected (data_.jewelryType == "") ] [ HH.text "เลือกประเภท" ] ] <>
                  map (\jt -> HH.option [ HP.value (show jt.id), HP.selected (data_.jewelryType == show jt.id) ] [ HH.text jt.name ]) state.jewelryTypes
              )
          ]
      , HH.td_
          [ HH.input
              [ HP.type_ HP.InputText
              , HP.class_ $ HH.ClassName "edit-input"
              , HP.value data_.designName
              , HP.placeholder "ชื่อลาย"
              , HP.autofocus (focusedField == Just DesignNameField)
              , HE.onValueInput \v -> UpdateTrayItemField DesignNameField v
              , HE.onKeyDown \e -> HandleTrayItemKeyDown groupId e
              ]
          ]
      , HH.td_
          [ HH.input
              [ HP.type_ HP.InputText
              , HP.class_ $ HH.ClassName "edit-input num"
              , HP.value data_.nominalWeight
              , HP.placeholder "น้ำหนัก (เลือกหรือพิมพ์)"
              , HP.autofocus (focusedField == Just NominalWeightField)
              , HP.attr (HH.AttrName "list") ("weight-list-" <> show groupId)
              , HE.onValueInput \v -> UpdateTrayItemFieldValidated NominalWeightField v
              , HE.onKeyDown \e -> HandleTrayItemKeyDown groupId e
              ]
          , HH.datalist
              [ HP.id ("weight-list-" <> show groupId) ]
              -- Show all options with their labels
              ( map (\nw -> HH.option [ HP.value nw.label ] []) state.nominalWeights <>
                  -- Add aliases for common fractions and decimals
                  [ HH.option [ HP.value "1/2ส" ] [] -- Alias for ½ส
                  , HH.option [ HP.value "1.5บ" ] [] -- Alias for 6ส
                  ]
              )
          ]
      , HH.td_
          [ HH.input
              [ HP.type_ HP.InputNumber
              , HP.class_ $ HH.ClassName "edit-input num"
              , HP.value data_.quantity
              , HP.placeholder "จำนวน"
              , HP.autofocus (focusedField == Just QuantityField)
              , HE.onValueInput \v -> UpdateTrayItemField QuantityField v
              , HE.onBlur \_ -> ValidateTrayItemField QuantityField
              , HE.onKeyDown \e -> HandleTrayItemKeyDown groupId e
              ]
          ]
      , HH.td_
          [ HH.input
              [ HP.type_ HP.InputNumber
              , HP.class_ $ HH.ClassName "edit-input num"
              , HP.value $ fromMaybe "" $ ado
                  quantity <- fromString data_.quantity
                  makingCharge <- fromString data_.makingCharge
                  in formatWithCommas $ quantity * makingCharge
              , HP.placeholder "เป็นเงิน"
              , HP.disabled true
              ]
          ]
      , HH.td_
          [ HH.button
              [ HP.type_ HP.ButtonButton
              , HP.class_ $ HH.ClassName "btn-save-item"
              , HE.onClick \_ -> SaveTrayItem groupId
              , HP.title "บันทึก"
              ]
              [ HH.text "✓" ]
          ]
      ]

renderWeightBaht :: forall m. Number -> H.ComponentHTML Action () m
renderWeightBaht n =
  let
    formatted = stripTrailingZerosFromNumber n
  in
    HH.span_
      [ HH.span [ HP.class_ $ HH.ClassName "num" ] [ HH.text formatted ]
      , HH.text "บ"
      ]

stripTrailingZerosFromNumber :: Number -> String
stripTrailingZerosFromNumber n =
  let
    str = Number.toStringWith (Number.fixed 3) n
    cleaned = Regex.replace trimZerosRegex "" str
  in
    cleaned

renderMoneyInt :: forall m. Int -> H.ComponentHTML Action () m
renderMoneyInt n =
  HH.span [ HP.class_ $ HH.ClassName "num" ] [ HH.text $ formatWithCommas n ]

renderPackGroup :: forall m. BillGroup -> PackData -> Array ItemData -> H.ComponentHTML Action () m
renderPackGroup _ pack items =
  HH.div
    [ HP.class_ $ HH.ClassName "pack-group" ]
    [ HH.div
        [ HP.class_ $ HH.ClassName "pack-header" ]
        [ HH.div_
            [ HH.span [ HP.class_ $ HH.ClassName "pack-title" ]
                [ HH.text $ TC.packLabel <> " " <> pack.user_number ]
            , HH.span [ HP.class_ $ HH.ClassName "pack-summary" ]
                [ HH.text $ show (length items) <> " แท่ง" ]
            ]
        ]
    , HH.div
        [ HP.class_ $ HH.ClassName "pack-content" ]
        [ renderPackSettings pack
        , renderPackItems items
        ]
    ]

renderPackSettings :: forall m. PackData -> H.ComponentHTML Action () m
renderPackSettings pack =
  HH.table
    [ HP.class_ $ HH.ClassName "settings-table" ]
    [ HH.tbody_
        [ HH.tr_
            [ HH.td_ [ HH.text TC.packIdLabel ]
            , HH.td_ [ HH.span [ HP.class_ $ HH.ClassName "num" ] [ HH.text $ show pack.internal_id ] ]
            ]
        , HH.tr_
            [ HH.td_ [ HH.text TC.userNumberLabel ]
            , HH.td_ [ HH.text pack.user_number ]
            ]
        ]
    ]

renderPackItems :: forall m. Array ItemData -> H.ComponentHTML Action () m
renderPackItems items =
  if length items == 0 then HH.p_ [ HH.text "ยังไม่มีแท่ง" ]
  else HH.table
    [ HP.class_ $ HH.ClassName "items-table" ]
    [ HH.thead_
        [ HH.tr_
            [ HH.th_ [ HH.text "#" ]
            , HH.th_ [ HH.text TC.shapeLabel ]
            , HH.th_ [ HH.text TC.purityLabel ]
            , HH.th_ [ HH.text TC.weightLabel ]
            , HH.th_ [ HH.text TC.deductionRateLabel ]
            , HH.th_ [ HH.text TC.calculationAmountLabel ]
            ]
        ]
    , HH.tbody_ $ map renderPackItem items
    ]

renderPackItem :: forall m. ItemData -> H.ComponentHTML Action () m
renderPackItem item =
  HH.tr_
    [ HH.td_ [ HH.text $ show item.display_order ]
    , HH.td_ [ HH.text $ fromMaybe "-" item.shape ]
    , HH.td_ [ renderNumberWithUnit (maybe "-" identity item.purity) "%" ]
    , HH.td_ [ renderPackWeight item ]
    , HH.td_ [ HH.span [ HP.class_ $ HH.ClassName "num" ] [ HH.text $ fromMaybe "-" item.deduction_rate ] ]
    , HH.td_ [ renderMoneyWithUnit (fromMaybe "-" item.calculation_amount) TC.unitTHB ]
    ]

renderPackWeight :: forall m. ItemData -> H.ComponentHTML Action () m
renderPackWeight item = case item.weight_grams, item.weight_baht of
  Just g, _ -> renderNumberWithUnit g TC.unitGrams
  _, Just b -> renderNumberWithUnit b TC.unitBaht
  _, _ -> HH.text "-"

renderTransactionGroup :: forall m. BillGroup -> TransactionData -> Array ItemData -> H.ComponentHTML Action () m
renderTransactionGroup _ _ items =
  HH.div
    [ HP.class_ $ HH.ClassName "transaction-group" ]
    [ HH.div
        [ HP.class_ $ HH.ClassName "transaction-header" ]
        [ HH.div_
            [ HH.span [ HP.class_ $ HH.ClassName "transaction-title" ]
                [ HH.text TC.transactionLabel ]
            , HH.span [ HP.class_ $ HH.ClassName "transaction-summary" ]
                [ HH.text $ show (length items) <> " รายการ" ]
            ]
        ]
    , HH.div
        [ HP.class_ $ HH.ClassName "transaction-content" ]
        [ renderTransactionItems items ]
    ]

renderTransactionItems :: forall m. Array ItemData -> H.ComponentHTML Action () m
renderTransactionItems items =
  if length items == 0 then HH.p_ [ HH.text "ยังไม่มีรายการ" ]
  else HH.table
    [ HP.class_ $ HH.ClassName "items-table" ]
    [ HH.thead_
        [ HH.tr_
            [ HH.th_ [ HH.text "#" ]
            , HH.th_ [ HH.text "ประเภท" ]
            , HH.th_ [ HH.text "รายละเอียด" ]
            ]
        ]
    , HH.tbody_ $ map renderTransactionItem items
    ]

renderTransactionItem :: forall m. ItemData -> H.ComponentHTML Action () m
renderTransactionItem item =
  HH.tr_
    [ HH.td_ [ HH.text $ show item.display_order ]
    , HH.td_ [ HH.text $ fromMaybe "-" item.transaction_type ]
    , HH.td_ [ renderTransactionDetails item ]
    ]

renderTransactionDetails :: forall m. ItemData -> H.ComponentHTML Action () m
renderTransactionDetails item = case item.amount_money of
  Just money -> renderMoneyWithUnit money TC.unitTHB
  Nothing -> case item.amount_grams of
    Just grams -> renderNumberWithUnit grams TC.unitGrams
    Nothing -> case item.amount_baht of
      Just baht -> renderNumberWithUnit baht TC.unitBaht
      Nothing -> HH.text "-"

getGroupTypeLabel :: String -> String
getGroupTypeLabel groupType = case groupType of
  "tray" -> TC.trayLabel
  "pack" -> TC.packLabel
  "transaction" -> TC.transactionLabel
  _ -> groupType

renderAddGroupButtons :: forall m. H.ComponentHTML Action () m
renderAddGroupButtons =
  HH.div
    [ HP.class_ $ HH.ClassName "add-group-buttons" ]
    [ HH.button
        [ HP.class_ $ HH.ClassName "btn btn-primary"
        , HE.onClick \_ -> AddTray
        ]
        [ HH.text TC.addTrayButton ]
    , HH.button
        [ HP.class_ $ HH.ClassName "btn btn-primary"
        , HE.onClick \_ -> AddPack
        ]
        [ HH.text TC.addPackButton ]
    , HH.button
        [ HP.class_ $ HH.ClassName "btn btn-primary"
        , HE.onClick \_ -> AddTransaction
        ]
        [ HH.text TC.addTransactionButton ]
    ]

renderGrandTotal :: forall m. Bill -> H.ComponentHTML Action () m
renderGrandTotal _ =
  HH.div
    [ HP.class_ $ HH.ClassName "grand-total" ]
    [ HH.h3_ [ HH.text TC.grandTotalLabel ]
    , HH.p_ [ HH.text "Calculation not yet implemented" ]
    ]

renderDeleteConfirmation :: forall m. H.ComponentHTML Action () m
renderDeleteConfirmation =
  HH.div
    [ HP.class_ $ HH.ClassName "modal-overlay" ]
    [ HH.div
        [ HP.class_ $ HH.ClassName "modal-dialog" ]
        [ HH.div
            [ HP.class_ $ HH.ClassName "modal-header" ]
            [ HH.text "ยืนยันการลบ" ]
        , HH.div
            [ HP.class_ $ HH.ClassName "modal-body" ]
            [ HH.text "คุณต้องการลบรายการนี้หรือไม่?" ]
        , HH.div
            [ HP.class_ $ HH.ClassName "modal-footer" ]
            [ HH.button
                [ HP.class_ $ HH.ClassName "btn btn-danger"
                , HE.onClick \_ -> ConfirmDeleteTrayItem
                ]
                [ HH.text "ตกลง" ]
            , HH.button
                [ HP.class_ $ HH.ClassName "btn btn-secondary"
                , HE.onClick \_ -> CancelDeleteTrayItem
                ]
                [ HH.text "ยกเลิก" ]
            ]
        ]
    ]

renderFooter :: forall m. State -> H.ComponentHTML Action () m
renderFooter state =
  HH.div
    [ HP.class_ $ HH.ClassName "bill-editor-footer" ]
    [ HH.button
        [ HP.class_ $ HH.ClassName "btn btn-primary"
        , HE.onClick \_ -> Save
        , HP.disabled state.isSaving
        ]
        [ HH.text $ if state.isSaving then TC.savingMessage else TC.saveButton ]
    , HH.button
        [ HP.class_ $ HH.ClassName "btn btn-secondary"
        , HE.onClick \_ -> Cancel
        ]
        [ HH.text TC.cancelButton ]
    , case state.bill of
        Just bill | not bill.is_finalized ->
          HH.button
            [ HP.class_ $ HH.ClassName "btn btn-success"
            , HE.onClick \_ -> Finalize
            ]
            [ HH.text TC.finalizeButton ]
        _ -> HH.text ""
    ]

handleAction :: forall m. MonadAff m => Action -> H.HalogenM State Action () Output m Unit
handleAction = case _ of
  Initialize -> do
    state <- H.get
    case state.billId of
      Nothing -> do
        -- Create new bill
        result <- H.lift $ BillAPI.createBill state.customerId
        case result of
          Left err ->
            H.modify_ _ { error = Just err }
          Right bill ->
            H.modify_ _ { bill = Just bill, billId = Just bill.id }
      Just _ -> do
        -- Load existing bill
        handleAction Reload

  Receive input -> do
    state <- H.get
    -- Only reload if billId changed
    if state.billId /= input.billId then do
      H.modify_ _
        { billId = input.billId
        , customerId = input.customerId
        , customerName = input.customerName
        , jewelryTypes = input.jewelryTypes
        , nominalWeights = input.nominalWeights
        , predefinedPurities = input.predefinedPurities
        , bill = Nothing -- Clear current bill
        }
      handleAction Initialize
    else
      -- Update other props without reloading bill
      H.modify_ _
        { customerId = input.customerId
        , customerName = input.customerName
        , jewelryTypes = input.jewelryTypes
        , nominalWeights = input.nominalWeights
        , predefinedPurities = input.predefinedPurities
        }

  Reload -> do
    state <- H.get
    case state.billId of
      Nothing -> pure unit
      Just billId -> do
        H.modify_ _ { isLoading = true, error = Nothing }
        result <- H.lift $ BillAPI.getBillWithGroups billId
        case result of
          Left err ->
            H.modify_ _ { isLoading = false, error = Just err }
          Right { bill, groups } ->
            H.modify_ _ { isLoading = false, bill = Just bill, groups = groups }

  Save -> do
    state <- H.get
    case state.bill of
      Nothing -> pure unit
      Just bill -> do
        H.modify_ _ { isSaving = true }
        result <- H.lift $ BillAPI.updateBill bill
        case result of
          Left err ->
            H.modify_ _ { isSaving = false, error = Just err }
          Right updatedBill -> do
            H.modify_ _ { isSaving = false, bill = Just updatedBill, isDirty = false }
            H.raise $ BillSaved updatedBill

  Cancel ->
    H.raise BillCancelled

  Finalize -> do
    state <- H.get
    case state.bill of
      Nothing -> pure unit
      Just bill -> do
        -- TODO: Implement finalize API call
        H.raise $ BillFinalized bill

  AddTray -> do
    -- TODO: Implement add tray
    pure unit

  AddPack -> do
    -- TODO: Implement add pack
    pure unit

  AddTransaction -> do
    -- TODO: Implement add transaction
    pure unit

  StartEditTrayItem groupId itemId field -> do
    state <- H.get
    if itemId == -1 then do
      -- New item
      H.modify_ _ { editingTrayItem = Just { groupId, itemId, focusedField: field }, editItemData = emptyEditItemData }
      H.liftEffect focusInput
    else do
      -- Edit existing item - find and populate data
      let maybeGroup = filter (\g -> g.id == groupId) state.groups
      case maybeGroup of
        [ group ] -> case group.groupData of
          Just gd -> do
            let maybeItem = filter (\i -> i.id == itemId) gd.items
            case maybeItem of
              [ item ] -> do
                let
                  nominalWeightStr = fromMaybe "" item.nominal_weight
                  -- Check if this is a predefined weight (has nominal_weight_id)
                  displayWeight = case item.nominal_weight_id of
                    Just wid ->
                      -- Predefined: find and show label
                      case filter (\nw -> nw.id == wid) state.nominalWeights of
                        [ nw ] -> nw.label
                        _ -> nominalWeightStr
                    Nothing ->
                      -- Custom: show as number, remove trailing zeros
                      let
                        s = nominalWeightStr
                        trimmed = case Number.fromString s of
                          Just n ->
                            let
                              fixed = Number.toStringWith (Number.fixed 3) n
                            in
                              Regex.replace trimZerosRegex "" fixed
                          Nothing -> s
                      in
                        trimmed
                  editData =
                    { makingCharge: maybe "" show item.making_charge
                    , jewelryType: maybe "" show item.jewelry_type_id
                    , designName: fromMaybe "" item.design_name
                    , nominalWeight: displayWeight
                    , quantity: maybe "1" show item.quantity
                    }
                H.modify_ _ { editingTrayItem = Just { groupId, itemId, focusedField: field }, editItemData = editData }
                H.liftEffect focusInput
              _ -> H.modify_ _ { editingTrayItem = Just { groupId, itemId, focusedField: field }, editItemData = emptyEditItemData }
          Nothing -> H.modify_ _ { editingTrayItem = Just { groupId, itemId, focusedField: field }, editItemData = emptyEditItemData }
        _ -> H.modify_ _ { editingTrayItem = Just { groupId, itemId, focusedField: field }, editItemData = emptyEditItemData }

  CancelEditTrayItem -> do
    H.modify_ _ { editingTrayItem = Nothing, editItemData = emptyEditItemData }

  SaveTrayItem groupId -> do
    state <- H.get
    let data_ = state.editItemData

    -- Normalize weight to predefined if possible (e.g., "3/4บ" -> "3ส")
    let normalizedWeight = normalizeWeight data_.nominalWeight state.nominalWeights

    -- Parse the weight to get the correct grams value
    let parsed = parseWeightValue normalizedWeight
    if state.isSavingItem then H.liftEffect $ log "Already saving, skipping..."
    else do
      H.modify_ _ { isSavingItem = true }
      -- Check if we're editing an existing item or creating a new one
      let
        isEditing = case state.editingTrayItem of
          Just { itemId } -> itemId /= -1
          Nothing -> false
      let
        editingItemId = case state.editingTrayItem of
          Just { itemId } -> itemId
          Nothing -> -1
      H.liftEffect $ log $ "SaveTrayItem called for group: " <> show groupId <> ", editing: " <> show isEditing <> ", itemId: " <> show editingItemId
      H.liftEffect $ log $ "Edit data: " <> show data_.makingCharge <> ", " <> show data_.jewelryType <> ", " <> show data_.nominalWeight <> ", " <> show data_.quantity
      -- Find the tray in the group
      let maybeGroup = filter (\g -> g.id == groupId) state.groups
      case maybeGroup of
        [ group ] -> case group.groupData of
          Just gd -> case gd.tray of
            Just tray -> do
              H.liftEffect $ log $ "Found tray with id: " <> show tray.id
              -- Create item for API
              let jewelryTypeId = if data_.jewelryType == "" then Nothing else fromString data_.jewelryType
              H.liftEffect $ log $ "Jewelry type: " <> data_.jewelryType <> " -> " <> show jewelryTypeId

              -- Check if normalized weight matches a predefined weight label
              let matchingWeight = filter (\nw -> nw.label == normalizedWeight) state.nominalWeights
              let
                Tuple finalWeight weightId = case matchingWeight of
                  [ nw ] -> Tuple (show nw.weight_grams) (Just nw.id) -- Predefined: use stored grams and ID
                  _ ->
                    -- Custom weight: calculate grams from our parsed value
                    let
                      parsedWeight = parseWeightValue normalizedWeight
                      grams = convertToGrams parsedWeight
                    in
                      Tuple (show grams) Nothing
              H.liftEffect $ log $ "Final weight: " <> finalWeight <> " (input: " <> data_.nominalWeight <> ", id: " <> show weightId <> ")"
              let makingChargeInt = fromString data_.makingCharge
              let quantityInt = if data_.quantity == "" then Just 1 else fromString data_.quantity
              let
                amountInt = case makingChargeInt, quantityInt of
                  Just mc, Just qty -> Just (mc * qty)
                  _, _ -> Nothing
              let
                newItem =
                  { id: -1
                  , display_order: 0
                  , tray_id: Just tray.id
                  , making_charge: makingChargeInt
                  , jewelry_type_id: jewelryTypeId
                  , design_name: if data_.designName == "" then Nothing else Just data_.designName
                  , nominal_weight: Just finalWeight
                  , nominal_weight_id: weightId -- Set ID for predefined, Nothing for custom
                  , quantity: quantityInt
                  , amount: amountInt
                  , pack_id: Nothing
                  , deduction_rate: Nothing
                  , shape: Nothing
                  , purity: Nothing
                  , description: Nothing
                  , weight_grams: Nothing
                  , weight_baht: Nothing
                  , calculation_amount: Nothing
                  , transaction_id: Nothing
                  , transaction_type: Nothing
                  , balance_type: Nothing
                  , amount_money: Nothing
                  , amount_grams: Nothing
                  , amount_baht: Nothing
                  , price_rate: Nothing
                  , conversion_charge_rate: Nothing
                  , split_charge_rate: Nothing
                  , block_making_charge_rate: Nothing
                  , source_amount_grams: Nothing
                  , source_amount_baht: Nothing
                  , dest_amount_grams: Nothing
                  , dest_amount_baht: Nothing
                  }
              -- Save to database and update local state
              if isEditing then do
                -- Update existing item
                H.liftEffect $ log $ "Updating existing item: " <> show editingItemId
                savedItem <- H.lift $ BillAPI.updateTrayItem editingItemId newItem
                H.liftEffect $ log $ "Item updated with id: " <> show savedItem.id
                -- Update item in local state
                let
                  updatedGroups = map
                    ( \g ->
                        if g.id == groupId then case g.groupData of
                          Just gd' -> g { groupData = Just (gd' { items = map (\i -> if i.id == editingItemId then savedItem else i) gd'.items }) }
                          Nothing -> g
                        else g
                    )
                    state.groups
                H.modify_ _ { groups = updatedGroups, editingTrayItem = Nothing, editItemData = emptyEditItemData, isDirty = true, isSavingItem = false }
              else do
                -- Create new item
                H.liftEffect $ log "Creating new item..."
                savedItem <- H.lift $ BillAPI.addTrayItem tray.id newItem
                H.liftEffect $ log $ "Item created with id: " <> show savedItem.id
                -- Add item to local state
                let
                  updatedGroups = map
                    ( \g ->
                        if g.id == groupId then case g.groupData of
                          Just gd' -> g { groupData = Just (gd' { items = gd'.items <> [ savedItem ] }) }
                          Nothing -> g
                        else g
                    )
                    state.groups
                H.modify_ _ { groups = updatedGroups, editingTrayItem = Nothing, editItemData = emptyEditItemData, isDirty = true, isSavingItem = false }
            Nothing -> do
              H.liftEffect $ log "No tray found in group data"
              H.modify_ _ { editingTrayItem = Nothing, editItemData = emptyEditItemData, isSavingItem = false }
          Nothing -> do
            H.liftEffect $ log "No group data found"
            H.modify_ _ { editingTrayItem = Nothing, editItemData = emptyEditItemData, isSavingItem = false }
        _ -> do
          H.liftEffect $ log $ "Group not found or multiple groups with id: " <> show groupId
          H.modify_ _ { editingTrayItem = Nothing, editItemData = emptyEditItemData, isSavingItem = false }

  ShowDeleteConfirmation trayId itemId -> do
    H.modify_ _ { deleteConfirmation = Just { trayId, itemId } }

  ConfirmDeleteTrayItem -> do
    state <- H.get
    case state.deleteConfirmation of
      Just { trayId, itemId } -> do
        H.liftEffect $ log $ "Deleting item: " <> show itemId
        -- Delete from database
        H.lift $ BillAPI.deleteTrayItem itemId
        -- Remove from local state
        let
          updatedGroups = map
            ( \g ->
                case g.groupData of
                  Just gd -> case gd.tray of
                    Just tray | tray.id == trayId ->
                      g { groupData = Just (gd { items = filter (\i -> i.id /= itemId) gd.items }) }
                    _ -> g
                  Nothing -> g
            )
            state.groups
        H.modify_ _ { groups = updatedGroups, isDirty = true, deleteConfirmation = Nothing }
      Nothing -> pure unit

  CancelDeleteTrayItem -> do
    H.modify_ _ { deleteConfirmation = Nothing }

  UpdateTrayItemFieldValidated field newValue -> do
    state <- H.get
    let
      oldValue = case field of
        NominalWeightField -> state.editItemData.nominalWeight
        _ -> newValue
    case field of
      NominalWeightField -> do
        let validated = validateWeightInput oldValue newValue
        H.liftEffect $ log $ "Weight validation: '" <> oldValue <> "' -> '" <> newValue <> "' => '" <> validated <> "'"
        H.modify_ _ { editItemData = state.editItemData { nominalWeight = validated } }
        -- Force input value if validation blocked characters
        when (validated /= newValue)
          $ H.liftEffect
          $ forceInputValue ".edit-row .edit-input.num[placeholder='น้ำหนัก (เลือกหรือพิมพ์)']" validated
      _ ->
        -- For other fields, just update directly
        handleAction $ UpdateTrayItemField field newValue

  UpdateTrayItemField field value -> do
    state <- H.get
    let
      updatedData = case field of
        MakingChargeField -> state.editItemData { makingCharge = value }
        JewelryTypeField -> state.editItemData { jewelryType = value }
        DesignNameField -> state.editItemData { designName = value }
        NominalWeightField -> state.editItemData { nominalWeight = value }
        QuantityField -> state.editItemData { quantity = value }
    H.modify_ _ { editItemData = updatedData }

  HandleTrayItemKeyDown groupId kbEvent -> do
    state <- H.get
    let data_ = state.editItemData
    case KE.key kbEvent of
      "Enter" -> do
        H.liftEffect $ Event.preventDefault (KE.toEvent kbEvent)
        -- Validate all required fields and focus first blank one
        let
          requiredFields =
            [ { field: MakingChargeField, value: data_.makingCharge, label: "ค่าแรง/ชิ้น" }
            , { field: JewelryTypeField, value: data_.jewelryType, label: "ประเภท" }
            , { field: NominalWeightField, value: data_.nominalWeight, label: "น้ำหนัก" }
            , { field: QuantityField, value: data_.quantity, label: "จำนวน" }
            ]
          firstBlankField = find (\f -> f.value == "") requiredFields
        case firstBlankField of
          Just blankField -> do
            -- Focus the first blank field instead of saving
            H.modify_ _ { editingTrayItem = map (_ { focusedField = Just blankField.field }) state.editingTrayItem }
            H.liftEffect focusInput
          Nothing -> do
            -- All required fields filled, save the item
            handleAction $ SaveTrayItem groupId
      "Escape" -> do
        H.liftEffect $ Event.stopPropagation (KE.toEvent kbEvent)
        handleAction CancelEditTrayItem
      _ -> pure unit

  CheckTrayItemRowBlur focusEvent -> do
    -- Check if focus actually left the edit row (not just moved to another field within the row)
    leftRow <- H.liftEffect $ checkFocusLeftEditRow focusEvent
    when leftRow $ handleAction CancelEditTrayItem

  ValidateTrayItemField field -> do
    state <- H.get
    let data_ = state.editItemData
    -- Validate numeric fields by removing invalid characters
    case field of
      MakingChargeField -> do
        let validated = validateNumeric data_.makingCharge
        when (validated /= data_.makingCharge) $
          H.modify_ _ { editItemData = data_ { makingCharge = validated } }
      QuantityField -> do
        let validated = validateNumeric data_.quantity
        when (validated /= data_.quantity) $
          H.modify_ _ { editItemData = data_ { quantity = validated } }
      NominalWeightField -> do
        let validated = validateNumeric data_.nominalWeight
        when (validated /= data_.nominalWeight) $
          H.modify_ _ { editItemData = data_ { nominalWeight = validated } }
      _ -> pure unit -- Non-numeric fields don't need validation

  StartEditTrayPrice trayId -> do
    state <- H.get
    -- Find the tray to get current price
    let
      maybeGroup = filter
        ( \g -> case g.groupData of
            Just gd -> case gd.tray of
              Just tray -> tray.id == trayId
              Nothing -> false
            Nothing -> false
        )
        state.groups
    case maybeGroup of
      [ group ] -> case group.groupData of
        Just gd -> case gd.tray of
          Just tray ->
            let
              priceVal = fromMaybe "" tray.price_rate
              formattedVal = case Number.fromString priceVal of
                Just n -> show (floor n)
                Nothing -> priceVal
            in
              do
                H.modify_ _ { editingTrayPrice = Just { trayId, value: formattedVal } }
                H.liftEffect focusInput
          Nothing -> pure unit
        Nothing -> pure unit
      _ -> pure unit

  UpdateTrayPrice value -> do
    state <- H.get
    case state.editingTrayPrice of
      Just editing -> H.modify_ _ { editingTrayPrice = Just (editing { value = value }) }
      Nothing -> pure unit

  SaveTrayPrice -> do
    state <- H.get
    case state.editingTrayPrice of
      Just editing -> do
        -- Find the tray to get current values
        let
          maybeGroup = filter
            ( \g -> case g.groupData of
                Just gd -> case gd.tray of
                  Just tray -> tray.id == editing.trayId
                  Nothing -> false
                Nothing -> false
            )
            state.groups
        case maybeGroup of
          [ group ] -> case group.groupData of
            Just gd -> case gd.tray of
              Just tray -> do
                let newPrice = if editing.value == "" then Nothing else Just editing.value
                -- Update in database
                H.lift $ BillAPI.updateTray editing.trayId
                  { price_rate: newPrice
                  , purity: tray.purity
                  , discount: tray.discount
                  , actual_weight_grams: Just tray.actual_weight_grams
                  , additional_charge_rate: tray.additional_charge_rate
                  }
                -- Update local state
                let
                  updatedTray = tray { price_rate = newPrice }
                  updatedGroups = map
                    ( \g -> case g.groupData of
                        Just gd' -> case gd'.tray of
                          Just t | t.id == editing.trayId ->
                            g { groupData = Just (gd' { tray = Just updatedTray }) }
                          _ -> g
                        Nothing -> g
                    )
                    state.groups
                H.modify_ _ { groups = updatedGroups, editingTrayPrice = Nothing, isDirty = true }
              Nothing -> pure unit
            Nothing -> pure unit
          _ -> pure unit
      Nothing -> pure unit

  CancelEditTrayPrice -> do
    H.modify_ _ { editingTrayPrice = Nothing }

  StartEditTrayPurity trayId -> do
    state <- H.get
    -- Find the tray to get current purity
    let
      maybeGroup = filter
        ( \g -> case g.groupData of
            Just gd -> case gd.tray of
              Just tray -> tray.id == trayId
              Nothing -> false
            Nothing -> false
        )
        state.groups
    case maybeGroup of
      [ group ] -> case group.groupData of
        Just gd -> case gd.tray of
          Just tray -> do
            H.modify_ _ { editingTrayPurity = Just { trayId, value: fromMaybe "" tray.purity } }
            H.liftEffect focusInput
          Nothing -> pure unit
        Nothing -> pure unit
      _ -> pure unit

  UpdateTrayPurity value -> do
    state <- H.get
    case state.editingTrayPurity of
      Just editing -> do
        H.modify_ _ { editingTrayPurity = Just (editing { value = value }) }
        -- Immediately save
        handleAction SaveTrayPurity
      Nothing -> pure unit

  SaveTrayPurity -> do
    state <- H.get
    case state.editingTrayPurity of
      Just editing -> do
        -- Find the tray to get current values
        let
          maybeGroup = filter
            ( \g -> case g.groupData of
                Just gd -> case gd.tray of
                  Just tray -> tray.id == editing.trayId
                  Nothing -> false
                Nothing -> false
            )
            state.groups
        case maybeGroup of
          [ group ] -> case group.groupData of
            Just gd -> case gd.tray of
              Just tray -> do
                let
                  newPurity = if editing.value == "" then Nothing else Just editing.value
                  -- Clear additional_charge_rate if changing from 99.99% to another value
                  oldPurityIs9999 = tray.purity == Just "99.99"
                  newPurityIsNot9999 = newPurity /= Just "99.99"
                  shouldClearCharge = oldPurityIs9999 && newPurityIsNot9999
                  newAdditionalCharge = if shouldClearCharge then Nothing else tray.additional_charge_rate
                -- Update in database
                H.lift $ BillAPI.updateTray editing.trayId
                  { price_rate: tray.price_rate
                  , purity: newPurity
                  , discount: tray.discount
                  , actual_weight_grams: Just tray.actual_weight_grams
                  , additional_charge_rate: newAdditionalCharge
                  }
                -- Update local state
                let
                  updatedTray = tray { purity = newPurity, additional_charge_rate = newAdditionalCharge }
                  updatedGroups = map
                    ( \g -> case g.groupData of
                        Just gd' -> case gd'.tray of
                          Just t | t.id == editing.trayId ->
                            g { groupData = Just (gd' { tray = Just updatedTray }) }
                          _ -> g
                        Nothing -> g
                    )
                    state.groups
                H.modify_ _ { groups = updatedGroups, editingTrayPurity = Nothing, isDirty = true }
              Nothing -> pure unit
            Nothing -> pure unit
          _ -> pure unit
      Nothing -> pure unit

  CancelEditTrayPurity -> do
    H.modify_ _ { editingTrayPurity = Nothing }

  UpdateTrayDiscount trayId discountStr -> do
    state <- H.get
    case fromString discountStr of
      Just newDiscount -> do
        -- Find the tray to get current values
        let
          maybeGroup = filter
            ( \g -> case g.groupData of
                Just gd -> case gd.tray of
                  Just tray -> tray.id == trayId
                  Nothing -> false
                Nothing -> false
            )
            state.groups
        case maybeGroup of
          [ group ] -> case group.groupData of
            Just gd -> case gd.tray of
              Just tray -> do
                -- Update in database
                H.lift $ BillAPI.updateTray trayId
                  { price_rate: tray.price_rate
                  , purity: tray.purity
                  , discount: Just newDiscount
                  , actual_weight_grams: Just tray.actual_weight_grams
                  , additional_charge_rate: tray.additional_charge_rate
                  }
                -- Update local state
                let
                  updatedTray = tray { discount = Just newDiscount }
                  updatedGroups = map
                    ( \g -> case g.groupData of
                        Just gd' -> case gd'.tray of
                          Just t | t.id == trayId ->
                            g { groupData = Just (gd' { tray = Just updatedTray }) }
                          _ -> g
                        Nothing -> g
                    )
                    state.groups
                H.modify_ _ { groups = updatedGroups, isDirty = true }
              Nothing -> pure unit
            Nothing -> pure unit
          _ -> pure unit
      Nothing -> pure unit

  StartEditTrayWeight trayId -> do
    state <- H.get
    let
      maybeGroup = filter
        ( \g -> case g.groupData of
            Just gd -> case gd.tray of
              Just tray -> tray.id == trayId
              Nothing -> false
            Nothing -> false
        )
        state.groups
    case maybeGroup of
      [ group ] -> case group.groupData of
        Just gd -> case gd.tray of
          Just tray -> do
            let trimmedValue = formatAndTrimNumber tray.actual_weight_grams 3
            H.modify_ _ { editingTrayWeight = Just { trayId, value: trimmedValue } }
            H.liftEffect focusInput
          Nothing -> pure unit
        Nothing -> pure unit
      _ -> pure unit

  UpdateTrayWeight value ->
    H.modify_ \st -> st { editingTrayWeight = map (_ { value = value }) st.editingTrayWeight }

  SaveTrayWeight -> do
    state <- H.get
    case state.editingTrayWeight of
      Just { trayId, value } -> do
        -- Find the tray to get current values
        let
          maybeGroup = filter
            ( \g -> case g.groupData of
                Just gd -> case gd.tray of
                  Just tray -> tray.id == trayId
                  Nothing -> false
                Nothing -> false
            )
            state.groups
        case maybeGroup of
          [ group ] -> case group.groupData of
            Just gd -> case gd.tray of
              Just tray -> do
                -- Update in database
                H.lift $ BillAPI.updateTray trayId
                  { price_rate: tray.price_rate
                  , purity: tray.purity
                  , discount: tray.discount
                  , actual_weight_grams: Just value
                  , additional_charge_rate: tray.additional_charge_rate
                  }
                -- Update local state
                let
                  updatedGroups = map
                    ( \g -> case g.groupData of
                        Just gd' -> case gd'.tray of
                          Just t | t.id == trayId ->
                            g { groupData = Just (gd' { tray = Just (t { actual_weight_grams = value }) }) }
                          _ -> g
                        Nothing -> g
                    )
                    state.groups
                H.modify_ _ { groups = updatedGroups, editingTrayWeight = Nothing, isDirty = true }
              Nothing -> pure unit
            Nothing -> pure unit
          _ -> pure unit
      Nothing -> pure unit

  CancelEditTrayWeight ->
    H.modify_ _ { editingTrayWeight = Nothing }

  StartEditWeightLabel trayId -> do
    state <- H.get
    let
      maybeGroup = filter
        ( \g -> case g.groupData of
            Just gd -> case gd.tray of
              Just tray -> tray.id == trayId
              Nothing -> false
            Nothing -> false
        )
        state.groups
    case maybeGroup of
      [ group ] -> case group.groupData of
        Just gd -> case gd.tray of
          Just tray ->
            H.modify_ _ { editingWeightLabel = Just { trayId, value: fromMaybe "" tray.custom_weight_label } }
          Nothing -> pure unit
        Nothing -> pure unit
      _ -> pure unit

  UpdateWeightLabel value ->
    H.modify_ \st -> st { editingWeightLabel = map (_ { value = value }) st.editingWeightLabel }

  SaveWeightLabel -> do
    state <- H.get
    case state.editingWeightLabel of
      Just { trayId, value } -> do
        -- Update via API (will need to add this endpoint)
        -- For now, just update local state
        let
          updatedGroups = map
            ( \g -> case g.groupData of
                Just gd -> case gd.tray of
                  Just tray | tray.id == trayId ->
                    g { groupData = Just (gd { tray = Just (tray { custom_weight_label = Just value }) }) }
                  _ -> g
                Nothing -> g
            )
            state.groups
        H.modify_ _ { groups = updatedGroups, editingWeightLabel = Nothing, isDirty = true }
      Nothing -> pure unit

  CancelEditWeightLabel ->
    H.modify_ _ { editingWeightLabel = Nothing }

  StartEditExtraCharge trayId -> do
    state <- H.get
    let
      maybeGroup = filter
        ( \g -> case g.groupData of
            Just gd -> case gd.tray of
              Just tray -> tray.id == trayId
              Nothing -> false
            Nothing -> false
        )
        state.groups
    case maybeGroup of
      [ group ] -> case group.groupData of
        Just gd -> case gd.tray of
          Just tray -> do
            let
              chargeValue = fromMaybe "" tray.additional_charge_rate
              trimmedValue = if chargeValue == "" then "" else formatAndTrimNumber chargeValue 2
            H.modify_ _ { editingExtraCharge = Just { trayId, value: trimmedValue } }
            H.liftEffect focusInput
          Nothing -> pure unit
        Nothing -> pure unit
      _ -> pure unit

  UpdateExtraCharge value ->
    H.modify_ \st -> st { editingExtraCharge = map (_ { value = value }) st.editingExtraCharge }

  SaveExtraCharge -> do
    state <- H.get
    case state.editingExtraCharge of
      Just { trayId, value } -> do
        -- Find the tray to get current values
        let
          maybeGroup = filter
            ( \g -> case g.groupData of
                Just gd -> case gd.tray of
                  Just tray -> tray.id == trayId
                  Nothing -> false
                Nothing -> false
            )
            state.groups
        case maybeGroup of
          [ group ] -> case group.groupData of
            Just gd -> case gd.tray of
              Just tray -> do
                let newChargeRate = if value == "" then Nothing else Just value
                -- Update in database
                H.lift $ BillAPI.updateTray trayId
                  { price_rate: tray.price_rate
                  , purity: tray.purity
                  , discount: tray.discount
                  , actual_weight_grams: Just tray.actual_weight_grams
                  , additional_charge_rate: newChargeRate
                  }
                -- Update local state
                let
                  updatedGroups = map
                    ( \g -> case g.groupData of
                        Just gd' -> case gd'.tray of
                          Just t | t.id == trayId ->
                            g { groupData = Just (gd' { tray = Just (t { additional_charge_rate = newChargeRate }) }) }
                          _ -> g
                        Nothing -> g
                    )
                    state.groups
                H.modify_ _ { groups = updatedGroups, editingExtraCharge = Nothing, isDirty = true }
              Nothing -> pure unit
            Nothing -> pure unit
          _ -> pure unit
      Nothing -> pure unit

  CancelEditExtraCharge ->
    -- Don't allow cancelling if the value is empty (required field)
    H.get >>= \state ->
      case state.editingExtraCharge of
        Just { value } | value /= "" ->
          H.modify_ _ { editingExtraCharge = Nothing }
        _ -> pure unit

  NoOp -> pure unit

handleQuery :: forall m a. MonadAff m => Query a -> H.HalogenM State Action () Output m (Maybe a)
handleQuery = case _ of
  LoadBill billId a -> do
    H.modify_ _ { billId = Just billId }
    handleAction Reload
    pure $ Just a

foreign import focusInput :: Effect Unit

renderEditInput
  :: forall m
   . { field :: TrayItemField
     , value :: String
     , placeholder :: String
     , inputType :: HP.InputType
     , isNum :: Boolean
     , focusedField :: Maybe TrayItemField
     , groupId :: Int
     , onBlur :: Maybe Action
     , listId :: Maybe String
     }
  -> H.ComponentHTML Action () m
renderEditInput props =
  HH.input
    ( [ HP.type_ props.inputType
      , HP.class_ $ HH.ClassName $ "edit-input" <> if props.isNum then " num" else ""
      , HP.value props.value
      , HP.placeholder props.placeholder
      , HP.autofocus (props.focusedField == Just props.field)
      , HE.onValueInput \v -> UpdateTrayItemField props.field v
      , HE.onKeyDown \e -> HandleTrayItemKeyDown props.groupId e
      ]
        <>
          ( case props.listId of
              Just id -> [ HP.attr (HH.AttrName "list") id ]
              Nothing -> []
          )
        <>
          ( case props.onBlur of
              Just action -> [ HE.onBlur \_ -> action ]
              Nothing -> []
          )
    )

renderEditableCell :: forall m. Int -> Int -> TrayItemField -> H.ComponentHTML Action () m -> H.ComponentHTML Action () m
renderEditableCell groupId itemId field content =
  HH.td
    [ HP.class_ $ HH.ClassName "editable-field"
    , HE.onClick \_ -> StartEditTrayItem groupId itemId (Just field)
    ]
    [ content ]

addBalanceRow :: Array BalanceRow -> Number -> String -> (Number -> String) -> Array BalanceRow
addBalanceRow rows amount typeLabel formatter =
  if amount /= 0.0 then
    rows <>
      [ { description: TextConstants.balanceConstants.prefixPrevious <> (if amount > 0.0 then TextConstants.balanceConstants.statusCredit else TextConstants.balanceConstants.statusDebit) <> typeLabel
        , value: formatter amount
        }
      ]
  else rows

-- ============================================================================
-- TRAY FOOTER HELPERS
-- ============================================================================

getPurityValue :: TrayData -> Maybe Number
getPurityValue tray =
  case tray.purity of
    Nothing -> Just 96.5
    Just purityStr -> Number.fromString purityStr

getPurityInfo :: Array PredefinedPurity -> Maybe Number -> { metalType :: String, displayVal :: Number }
getPurityInfo purities purityMaybe =
  case filter (\p -> p.purity == purityMaybe) purities of
    [ p ] -> { metalType: p.metal_type, displayVal: p.display_val }
    _ -> { metalType: "ทอง", displayVal: fromMaybe 96.5 purityMaybe }

formatPurityDisplay :: Number -> String
formatPurityDisplay purity =
  let
    digitToSuperscript d = case d of
      "0" -> TextConstants.formatConstants.superscript0
      "1" -> TextConstants.formatConstants.superscript1
      "2" -> TextConstants.formatConstants.superscript2
      "3" -> TextConstants.formatConstants.superscript3
      "4" -> TextConstants.formatConstants.superscript4
      "5" -> TextConstants.formatConstants.superscript5
      "6" -> TextConstants.formatConstants.superscript6
      "7" -> TextConstants.formatConstants.superscript7
      "8" -> TextConstants.formatConstants.superscript8
      "9" -> TextConstants.formatConstants.superscript9
      _ -> d
    digitToSubscript d = case d of
      "0" -> TextConstants.formatConstants.subscript0
      "1" -> TextConstants.formatConstants.subscript1
      "2" -> TextConstants.formatConstants.subscript2
      "3" -> TextConstants.formatConstants.subscript3
      "4" -> TextConstants.formatConstants.subscript4
      "5" -> TextConstants.formatConstants.subscript5
      "6" -> TextConstants.formatConstants.subscript6
      "7" -> TextConstants.formatConstants.subscript7
      "8" -> TextConstants.formatConstants.subscript8
      "9" -> TextConstants.formatConstants.subscript9
      _ -> d
    str = show purity
    parts = split (Pattern ".") str
  in
    case parts of
      [ intPart, decPart ] ->
        let
          intSuper = String.joinWith "" $ map digitToSuperscript $ String.split (Pattern "") intPart
          decSub = String.joinWith "" $ map digitToSubscript $ String.split (Pattern "") decPart
        in
          intSuper <> "⋅" <> decSub <> "﹪"
      _ -> str <> "﹪"

calculateEffectiveWeight :: Number -> Number -> Number
calculateEffectiveWeight actualWeight purityPercent =
  let
    converted = actualWeight * Constants.bahtPerGram * (purityPercent / 100.0)
    rounded = (toNumber (round (converted * 20.0))) / 20.0
  in
    rounded

calculateExtraCharge :: Number -> Number -> Int
calculateExtraCharge actualWeight extraChargeRate =
  round (actualWeight * Constants.bahtPerGram * extraChargeRate)

calculateMoneyFromWeight :: Number -> Number -> Number -> Int
calculateMoneyFromWeight actualWeight purityPercent goldPrice =
  round (actualWeight * Constants.bahtPerGram * (purityPercent / 100.0) * goldPrice)

-- ============================================================================
-- TRAY SUBTOTAL RENDERING
-- ============================================================================

renderTraySubtotal :: forall m. State -> TrayData -> Array ItemData -> H.ComponentHTML Action () m
renderTraySubtotal state tray items =
  let
    purityValue = getPurityValue tray
    purityInfo = getPurityInfo state.predefinedPurities purityValue
    actualWeight = parseNumber tray.actual_weight_grams
    isWeightEmpty = actualWeight == 0.0 || tray.actual_weight_grams == "" || tray.actual_weight_grams == "0"
    totalMakingCharge = foldl (\acc item -> acc + (fromMaybe 0 item.making_charge) * (fromMaybe 0 item.quantity)) 0 items
    isMoneySettlement = tray.price_rate /= Nothing
    goldPrice = parseNumber (fromMaybe "0" tray.price_rate)
    extraChargeRate = parseNumber (fromMaybe "0" tray.additional_charge_rate)
    showSecondLine = not (purityValue == Just 96.5 && not isMoneySettlement)
  in
    HH.table
      [ HP.class_ $ HH.ClassName "tray-subtotal-table"
      , HP.attr (HH.AttrName "style") "width: 100%"
      ]
      [ HH.tbody_
          ( [ renderFirstLine state tray purityValue purityInfo isMoneySettlement isWeightEmpty actualWeight totalMakingCharge showSecondLine ] <>
              if showSecondLine then [ renderSecondLine state tray purityValue purityInfo actualWeight isMoneySettlement goldPrice extraChargeRate isWeightEmpty ]
              else []
          )
      ]

renderFirstLine
  :: forall m
   . State
  -> TrayData
  -> Maybe Number
  -> { metalType :: String, displayVal :: Number }
  -> Boolean
  -> Boolean
  -> Number
  -> Int
  -> Boolean
  -> H.ComponentHTML Action () m
renderFirstLine state tray purityValue purityInfo isMoneySettlement isWeightEmpty actualWeight totalMakingCharge showSecondLine =
  let
    col1 = renderFirstLineCol1 state tray purityValue isMoneySettlement
    col2 = if showSecondLine then HH.text "" else renderWeightCell state tray.id isWeightEmpty actualWeight
    col3 = if tray.is_return then "คืนค่าแรง" else "ค่าแรง"
    col4 = formatWithCommas totalMakingCharge
  in
    HH.tr_
      [ HH.td [ HP.class_ $ HH.ClassName "text-left" ] [ col1 ]
      , HH.td [ HP.class_ $ HH.ClassName "text-right" ] [ col2 ]
      , HH.td [ HP.class_ $ HH.ClassName "text-left" ] [ HH.text col3 ]
      , HH.td [ HP.class_ $ HH.ClassName "text-right num" ] [ HH.text col4 ]
      ]

renderFirstLineCol1 :: forall m. State -> TrayData -> Maybe Number -> Boolean -> H.ComponentHTML Action () m
renderFirstLineCol1 state tray purityValue isMoneySettlement =
  if isMoneySettlement then HH.text ""
  else case purityValue of
    Just 96.5 -> case state.editingWeightLabel of
      Just editing | editing.trayId == tray.id ->
        HH.input
          [ HP.type_ HP.InputText
          , HP.class_ $ HH.ClassName "edit-input"
          , HP.value editing.value
          , HP.autofocus true
          , HE.onValueInput UpdateWeightLabel
          , HE.onBlur \_ -> SaveWeightLabel
          , HE.onKeyDown \e ->
              if KE.key e == "Escape" then CancelEditWeightLabel
              else if KE.key e == "Enter" then SaveWeightLabel
              else NoOp
          ]
      _ ->
        let
          defaultLabel = if tray.is_return then "คืนทองหนัก" else "ทองหนัก"
          label = fromMaybe defaultLabel tray.custom_weight_label
        in
          HH.span [ HP.class_ $ HH.ClassName "editable-field", HE.onClick \_ -> StartEditWeightLabel tray.id ] [ HH.text label ]
    _ -> HH.text ""

renderWeightCell :: forall m. State -> Int -> Boolean -> Number -> H.ComponentHTML Action () m
renderWeightCell state trayId isWeightEmpty actualWeight =
  case state.editingTrayWeight of
    Just editing | editing.trayId == trayId ->
      HH.div
        [ HP.class_ $ HH.ClassName "input-with-unit" ]
        [ HH.input
            [ HP.type_ HP.InputText
            , HP.class_ $ HH.ClassName "edit-input-subtotal num"
            , HP.value editing.value
            , HP.autofocus true
            , HE.onValueInput UpdateTrayWeight
            , HE.onBlur \_ -> CancelEditTrayWeight
            , HE.onKeyDown \e ->
                if KE.key e == "Escape" then CancelEditTrayWeight
                else if KE.key e == "Enter" then SaveTrayWeight
                else NoOp
            ]
        , HH.text " g"
        ]
    _ ->
      if isWeightEmpty then HH.input
        [ HP.type_ HP.InputText
        , HP.class_ $ HH.ClassName "edit-input-subtotal num"
        , HP.value ""
        , HP.placeholder "น้ำหนัก"
        , HP.autofocus true
        , HE.onValueInput UpdateTrayWeight
        , HE.onFocus \_ -> StartEditTrayWeight trayId
        , HE.onBlur \_ -> CancelEditTrayWeight
        ]
      else
        HH.div
          [ HP.class_ $ HH.ClassName "editable-field" ]
          [ HH.span
              [ HP.class_ $ HH.ClassName "num"
              , HE.onClick \_ -> StartEditTrayWeight trayId
              ]
              [ HH.text $ formatGrams actualWeight ]
          ]

renderSecondLine
  :: forall m
   . State
  -> TrayData
  -> Maybe Number
  -> { metalType :: String, displayVal :: Number }
  -> Number
  -> Boolean
  -> Number
  -> Number
  -> Boolean
  -> H.ComponentHTML Action () m
renderSecondLine state tray purityValue purityInfo actualWeight isMoneySettlement goldPrice extraChargeRate isWeightEmpty =
  let
    col1 = renderSecondLineCol1 tray purityValue purityInfo
    col2 = renderWeightCell state tray.id isWeightEmpty (abs actualWeight)
    { col3Html, col4Html } = renderSecondLineCalculation state tray purityValue actualWeight isMoneySettlement goldPrice extraChargeRate
  in
    HH.tr_
      [ HH.td [ HP.class_ $ HH.ClassName "text-left" ] [ col1 ]
      , HH.td [ HP.class_ $ HH.ClassName "text-right" ] [ col2 ]
      , HH.td [ HP.class_ $ HH.ClassName "text-left" ] [ col3Html ]
      , HH.td [ HP.class_ $ HH.ClassName "text-right num" ] [ col4Html ]
      ]

renderSecondLineCol1 :: forall m. TrayData -> Maybe Number -> { metalType :: String, displayVal :: Number } -> H.ComponentHTML Action () m
renderSecondLineCol1 tray purityValue purityInfo =
  let
    metalType = purityInfo.metalType
    purityDisplay = formatPurityDisplay purityInfo.displayVal
    prefix = if tray.is_return then "คืน" <> metalType else metalType
  in
    HH.text $ prefix <> " " <> purityDisplay <> " หนัก"

renderSecondLineCalculation :: forall m. State -> TrayData -> Maybe Number -> Number -> Boolean -> Number -> Number -> { col3Html :: H.ComponentHTML Action () m, col4Html :: H.ComponentHTML Action () m }
renderSecondLineCalculation state tray purityValue actualWeight isMoneySettlement goldPrice extraChargeRate =
  case purityValue of
    Just 100.0 ->
      if isMoneySettlement then
        { col3Html: HH.text $ "× " <> show (round goldPrice) <> " ="
        , col4Html: HH.text $ formatWithCommas $ calculateMoneyFromWeight actualWeight 100.0 goldPrice
        }
      else
        let
          label = if tray.is_return then "เหลือบาทละ " else "เพิ่มบาทละ "
          chargeValue = fromMaybe "" tray.additional_charge_rate
          isEditingThis = case state.editingExtraCharge of
            Just editing -> editing.trayId == tray.id
            Nothing -> false
          -- Auto-edit mode: if charge rate is NULL, show input immediately
          shouldAutoEdit = chargeValue == "" && not isEditingThis
        in
          if isEditingThis || shouldAutoEdit then
            { col3Html: HH.div
                [ HP.class_ $ HH.ClassName "input-with-unit" ]
                [ HH.text label
                , HH.input
                    [ HP.type_ HP.InputText
                    , HP.class_ $ HH.ClassName "edit-input-subtotal num"
                    , HP.value $ case state.editingExtraCharge of
                        Just editing | editing.trayId == tray.id -> editing.value
                        _ -> ""
                    , HP.autofocus true
                    , HP.placeholder "ต้องระบุ"
                    , HE.onValueInput UpdateExtraCharge
                    , HE.onFocus \_ -> if shouldAutoEdit then StartEditExtraCharge tray.id else NoOp
                    , HE.onBlur \_ -> CancelEditExtraCharge
                    , HE.onKeyDown \e ->
                        if KE.key e == "Enter" then SaveExtraCharge
                        else if KE.key e == "Escape" && chargeValue /= "" then CancelEditExtraCharge
                        else NoOp
                    ]
                ]
            , col4Html: HH.text $ if chargeValue == "" then "-" else formatWithCommas $ calculateExtraCharge actualWeight extraChargeRate
            }
          else
            let
              chargeStr = if chargeValue == "" then "" else formatWithCommas (round extraChargeRate)
            in
              { col3Html: HH.div_
                  [ HH.text label
                  , HH.span
                      [ HP.class_ $ HH.ClassName "num editable-field"
                      , HE.onClick \_ -> StartEditExtraCharge tray.id
                      ]
                      [ HH.text $ if chargeStr == "" then "-" else chargeStr ]
                  ]
              , col4Html: HH.text $ if chargeValue == "" then "-" else formatWithCommas $ calculateExtraCharge actualWeight extraChargeRate
              }
    Just p ->
      if isMoneySettlement then
        { col3Html: HH.text $ "× " <> show (round goldPrice) <> " ="
        , col4Html: HH.text $ formatWithCommas $ calculateMoneyFromWeight actualWeight p goldPrice
        }
      else
        { col3Html: HH.text $ "× " <> show p <> "% ="
        , col4Html: HH.text $ formatGrams $ calculateEffectiveWeight actualWeight p
        }
    _ ->
      { col3Html: HH.text ""
      , col4Html: HH.text ""
      }
