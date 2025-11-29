module Bill.Components.BillEditor where

import Prelude

import Bill.API as BillAPI
import Bill.Types (Bill, BillGroup, GroupData, TrayData, PackData, TransactionData, ItemData)
import Data.Array (length, filter, take, drop, reverse, foldl, any)
import Data.Either (Either(..))
import Data.Tuple (Tuple(..))
import Data.Maybe (Maybe(..), fromMaybe, isJust, maybe)
import Data.Number as Number
import Data.Number.Format as Number
import Data.Int (floor, round, toNumber, fromString)
import Data.String as String
import Data.String.Common (joinWith, split, replace)
import Data.String.Pattern (Pattern(..), Replacement(..))
import Data.Int (rem) as Int
import Effect.Aff.Class (class MonadAff)
import Effect.Console (log)
import Halogen as H
import Web.Event.Event as Event
import Web.UIEvent.KeyboardEvent (KeyboardEvent)
import Web.UIEvent.KeyboardEvent as KE
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import TextConstants.BillEditor as TC

type Slot = H.Slot Query Output

type Input = 
  { billId :: Maybe Int
  , customerId :: Int
  , customerName :: String
  , jewelryTypes :: Array JewelryType
  , nominalWeights :: Array NominalWeight
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
  , editingTrayItem :: Maybe { groupId :: Int, itemId :: Int }
  , editItemData :: EditItemData
  , jewelryTypes :: Array JewelryType
  , nominalWeights :: Array NominalWeight
  , isSavingItem :: Boolean
  , deleteConfirmation :: Maybe { trayId :: Int, itemId :: Int }
  , editingTrayPrice :: Maybe { trayId :: Int, value :: String }
  , editingTrayPurity :: Maybe { trayId :: Int, value :: String }
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
  | Reload
  | Save
  | Cancel
  | Finalize
  | AddTray
  | AddPack
  | AddTransaction
  | StartEditTrayItem Int Int -- groupId, itemId (use -1 for new item)
  | CancelEditTrayItem
  | SaveTrayItem Int -- groupId
  | ShowDeleteConfirmation Int Int -- trayId, itemId
  | ConfirmDeleteTrayItem
  | CancelDeleteTrayItem
  | UpdateTrayItemField TrayItemField String
  | HandleTrayItemKeyDown Int KeyboardEvent -- groupId, event
  | StartEditTrayPrice Int -- trayId
  | UpdateTrayPrice String
  | SaveTrayPrice
  | CancelEditTrayPrice
  | StartEditTrayPurity Int -- trayId
  | UpdateTrayPurity String
  | SaveTrayPurity
  | CancelEditTrayPurity
  | UpdateTrayDiscount Int String -- trayId, discount value
  | NoOp

data TrayItemField
  = MakingChargeField
  | JewelryTypeField
  | DesignNameField
  | NominalWeightField
  | QuantityField

data Output
  = BillSaved Bill
  | BillCancelled
  | BillFinalized Bill

component :: forall m. MonadAff m => H.Component Query Input Output m
component =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval $ H.defaultEval
        { handleAction = handleAction
        , handleQuery = handleQuery
        , initialize = Just Initialize
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
            , HH.span_ [ HH.text $ " | " <> TC.status <> ": " <> 
                if bill.is_finalized then TC.finalized else TC.draft ]
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
    if length goldBalances == 0 && not moneyBalance.hasBalance
      then HH.text ""
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
                    [ if moneyBalance.hasBalance
                        then HH.text moneyBalance.description
                        else HH.text ""
                    ]
                , -- Column 4: Money value
                  HH.td [ HP.class_ $ HH.ClassName "balance-value-col" ]
                    [ if moneyBalance.hasBalance
                        then renderMoneyValue moneyBalance.value
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
    if money == 0.0
      then { hasBalance: false, description: "", value: "" }
      else
        { hasBalance: true
        , description: if money > 0.0 then "เก่าเหลือเงิน" else "เก่าค้างเงิน"
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
    
    -- Jewelry (gram first)
    rows' = if gramJewel /= 0.0
      then rows <> [ { description: if gramJewel > 0.0 then "เก่าเหลือทอง" else "เก่าค้างทอง"
                     , value: formatGrams gramJewel
                     } ]
      else rows
    
    rows'' = if bahtJewel /= 0.0
      then rows' <> [ { description: if bahtJewel > 0.0 then "เก่าเหลือทอง" else "เก่าค้างทอง"
                      , value: formatBaht bahtJewel
                      } ]
      else rows'
    
    -- Bar 96.5% (baht first)
    rows''' = if bahtBar96 /= 0.0
      then rows'' <> [ { description: if bahtBar96 > 0.0 then "เก่าเหลือแท่ง ⁹⁶⋅₅﹪" else "เก่าค้างแท่ง ⁹⁶⋅₅﹪"
                       , value: formatBaht bahtBar96
                       } ]
      else rows''
    
    rows'''' = if gramBar96 /= 0.0
      then rows''' <> [ { description: if gramBar96 > 0.0 then "เก่าเหลือแท่ง ⁹⁶⋅₅﹪" else "เก่าค้างแท่ง ⁹⁶⋅₅﹪"
                        , value: formatGrams gramBar96
                        } ]
      else rows'''
    
    -- Bar 99.99% (baht first)
    rows''''' = if bahtBar99 /= 0.0
      then rows'''' <> [ { description: if bahtBar99 > 0.0 then "เก่าเหลือแท่ง ⁹⁹⋅₉₉﹪" else "เก่าค้างแท่ง ⁹⁹⋅₉₉﹪"
                         , value: formatBaht bahtBar99
                         } ]
      else rows''''
    
    rows'''''' = if gramBar99 /= 0.0
      then rows''''' <> [ { description: if gramBar99 > 0.0 then "เก่าเหลือแท่ง ⁹⁹⋅₉₉﹪" else "เก่าค้างแท่ง ⁹⁹⋅₉₉﹪"
                          , value: formatGrams gramBar99
                          } ]
      else rows'''''
  in
    rows''''''

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
    formatted <> "g"

formatBaht :: Number -> String
formatBaht n =
  let
    absN = abs n
    -- Format to 3 decimals then strip trailing zeros
    formatted = Number.toStringWith (Number.fixed 3) absN
    -- Remove .000, .00, .0 patterns
    cleaned = if String.contains (Pattern ".000") formatted
                then replace (Pattern ".000") (Replacement "") formatted
                else if String.contains (Pattern ".00") formatted
                  then replace (Pattern ".00") (Replacement "") formatted
                  else if String.contains (Pattern ".0") formatted
                    then replace (Pattern ".0") (Replacement "") formatted
                    else formatted
  in
    cleaned <> "บ"

formatMoneyString :: Number -> String
formatMoneyString n =
  let
    intPart = floor n
    decPart = round ((n - toNumber intPart) * 100.0)
    intStr = formatWithCommas intPart
  in
    if decPart == 0
      then intStr <> ".₀₀"
      else intStr <> "." <> toSubscript decPart

formatWithCommas :: Int -> String
formatWithCommas n =
  let
    str = show (if n < 0 then -n else n)
    len = String.length str
  in
    if len <= 3
      then str
      else addCommasToString str

addCommasToString :: String -> String
addCommasToString str =
  let
    len = String.length str
    -- Process from right to left
    result = go (len - 1) 0 ""
    
    go :: Int -> Int -> String -> String
    go idx count acc =
      if idx < 0
        then acc
        else
          let
            char = String.take 1 (String.drop idx str)
            newAcc = if count > 0 && Int.rem count 3 == 0
                      then char <> "," <> acc
                      else char <> acc
          in go (idx - 1) (count + 1) newAcc
  in result

renderGoldValue :: forall m. String -> H.ComponentHTML Action () m
renderGoldValue str =
  -- Parse "123.456g" or "12.5บ" into number only (no unit)
  let
    hasG = String.contains (Pattern "g") str
    hasBaht = String.contains (Pattern "บ") str
  in
    if hasG
      then
        let
          numPart = replace (Pattern "g") (Replacement "") str
        in
          HH.span [ HP.class_ $ HH.ClassName "num" ] [ HH.text numPart ]
      else if hasBaht
        then
          let
            numPart = replace (Pattern "บ") (Replacement "") str
          in
            HH.span [ HP.class_ $ HH.ClassName "num" ] [ HH.text numPart ]
        else HH.text str

renderMoneyValue :: forall m. String -> H.ComponentHTML Action () m
renderMoneyValue str =
  -- Parse "1,000.₀₀" - hide both "." and "₀₀"
  if String.contains (Pattern ".") str
    then
      let
        parts = split (Pattern ".") str
      in case parts of
        [intPart, decPart] ->
          let
            isZeroDecimal = decPart == "₀₀"
          in
            if isZeroDecimal
              then HH.span_
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
  if num == "-"
    then HH.text "-"
    else HH.span_
      [ HH.span [ HP.class_ $ HH.ClassName "num" ] [ HH.text $ formatNumberString num ]
      , HH.text $ " " <> unit
      ]

renderMoneyWithUnit :: forall m. String -> String -> H.ComponentHTML Action () m
renderMoneyWithUnit num unit =
  if num == "-"
    then HH.text "-"
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
        if decPart == 0.0
          then formatWithCommas intPart
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
        if decPart == 0
          then HH.span_
            [ HH.span [ HP.class_ $ HH.ClassName "num" ] [ HH.text intStr ]
            , HH.text "."
            , HH.span [ HP.class_ $ HH.ClassName "num-subscript-hidden" ] [ HH.text "₀₀" ]
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
  "0" -> "₀"
  "1" -> "₁"
  "2" -> "₂"
  "3" -> "₃"
  "4" -> "₄"
  "5" -> "₅"
  "6" -> "₆"
  "7" -> "₇"
  "8" -> "₈"
  "9" -> "₉"
  _ -> d

renderGroups :: forall m. State -> Array BillGroup -> H.ComponentHTML Action () m
renderGroups state groups =
  HH.div
    [ HP.class_ $ HH.ClassName "bill-groups" ]
    [ if length groups == 0
        then HH.p_ [ HH.text "ยังไม่มีกลุ่ม - กดปุ่มด้านล่างเพื่อเพิ่ม" ]
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
          [ renderTraySubtotal tray.id (Just tray.actual_weight_grams) totalWeight totalMakingCharge discountPercent discountAmount netMakingCharge ]
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
          , if not isEditingPrice
              then HE.onClick \_ -> StartEditTrayPrice tray.id
              else HP.attr (HH.AttrName "data-editing") "true"
          ]
          [ renderTrayPrice state tray ]
      , HH.div [ HP.class_ $ HH.ClassName "tray-header-col tray-title" ]
          [ HH.text $ (if tray.is_return then "ของคืน" else "ทองรูปพรรณ") <> " (ถาดที่ " <> show tray.internal_num <> ")"
          , HH.span [ HP.class_ $ HH.ClassName "tray-summary" ]
              [ HH.text $ " • " <> show itemCount <> " รายการ" ]
          ]
      , HH.div 
          [ HP.class_ $ HH.ClassName "tray-header-col tray-purity"
          , if not isEditingPurity
              then HE.onClick \_ -> StartEditTrayPurity tray.id
              else HP.attr (HH.AttrName "data-editing") "true"
          ]
          [ renderTrayPurity state tray ]
      ]

renderTrayPrice :: forall m. State -> TrayData -> H.ComponentHTML Action () m
renderTrayPrice state tray =
  case state.editingTrayPrice of
    Just editing | editing.trayId == tray.id ->
      HH.input
        [ HP.type_ HP.InputNumber
        , HP.class_ $ HH.ClassName "edit-input num"
        , HP.value editing.value
        , HP.placeholder "ราคาทอง"
        , HE.onValueInput UpdateTrayPrice
        , HE.onBlur \_ -> SaveTrayPrice
        , HE.onKeyDown \e -> case KE.key e of
            "Enter" -> SaveTrayPrice
            "Escape" -> CancelEditTrayPrice
            _ -> NoOp
        ]
    _ ->
      case tray.price_rate of
        Just price | price /= "" ->
          let formattedPrice = case fromString price of
                Just priceInt -> formatWithCommas priceInt
                Nothing -> price
          in HH.div
            [ HP.class_ $ HH.ClassName "editable-field" ]
            [ HH.text $ formattedPrice <> " ฿/บาท" ]
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
        [ HH.option [ HP.value "", HP.selected (editing.value == "") ] [ HH.text "96.5%" ]
        , HH.option [ HP.value "42.5", HP.selected (editing.value == "42.5") ] [ HH.text "42.5%" ]
        , HH.option [ HP.value "53.125", HP.selected (editing.value == "53.125") ] [ HH.text "53.125%" ]
        , HH.option [ HP.value "80", HP.selected (editing.value == "80") ] [ HH.text "80%" ]
        , HH.option [ HP.value "90", HP.selected (editing.value == "90") ] [ HH.text "90%" ]
        , HH.option [ HP.value "100", HP.selected (editing.value == "100") ] [ HH.text "99.99%" ]
        ]
    _ ->
      case tray.purity of
        Just purity | purity /= "" && purity /= "96.5" ->
          HH.div
            [ HP.class_ $ HH.ClassName "editable-field" ]
            [ HH.text $ purity <> "%" ]
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
    hasBaht = String.contains (Pattern "บ") trimmed || String.contains (Pattern "บาท") trimmed
    -- Check for สลึง (salung)
    hasSalung = String.contains (Pattern "ส") trimmed || String.contains (Pattern "สลึง") trimmed
    -- Remove Thai characters and parse number
    cleaned = replace (Pattern "บาท") (Replacement "") $ replace (Pattern "บ") (Replacement "") $ 
              replace (Pattern "สลึง") (Replacement "") $ replace (Pattern "ส") (Replacement "") trimmed
    numValue = parseNumber cleaned
  in
    if hasBaht then numValue * 15.200  -- 1 baht = 15.200 grams
    else if hasSalung then numValue * 3.800  -- 1 salung = 3.800 grams
    else numValue  -- Already in grams

calculateTrayTotalWeight :: Array ItemData -> Number -> Number
calculateTrayTotalWeight items purity =
  let
    totalGrams = foldl (\acc item -> 
      let
        weight = parseNumber (fromMaybe "0" item.nominal_weight)  -- Expect grams
        qty = fromMaybe 1 item.quantity
      in acc + (weight * toNumber qty)
    ) 0.0 items
    -- Round to nearest 0.05
    rounded = (toNumber (round (totalGrams * 20.0))) / 20.0
  in rounded

calculateTrayTotalMakingCharge :: Array ItemData -> Int
calculateTrayTotalMakingCharge items =
  foldl (\acc item ->
    let
      charge = fromMaybe 0 item.making_charge
      qty = fromMaybe 1 item.quantity
    in acc + (charge * qty)
  ) 0 items

renderTrayItemsTable :: forall m. State -> Int -> Array ItemData -> H.ComponentHTML Action () m
renderTrayItemsTable state groupId items =
  let
    editingItemId = case state.editingTrayItem of
      Just { groupId: gid, itemId } | gid == groupId -> Just itemId
      _ -> Nothing
    isEditingNew = editingItemId == Just (-1)
    rows = map (\item ->
      if Just item.id == editingItemId
        then renderTrayItemEditRow state groupId
        else renderTrayItemRow state state.jewelryTypes item
    ) items
    editRow = if isEditingNew
      then [ renderTrayItemEditRow state groupId ]
      else []
    addButton = if editingItemId == Nothing
      then [ HH.tr_
              [ HH.td [ HP.colSpan 7, HP.class_ $ HH.ClassName "add-item-cell" ]
                  [ HH.button
                      [ HP.class_ $ HH.ClassName "btn-add-item"
                      , HE.onClick \_ -> StartEditTrayItem groupId (-1)
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
          [jt] -> jt.name
          _ -> "-"
      Nothing -> "-"
    -- Display nominal weight: show label for predefined, grams for custom
    nominalWeightDisplay = case item.nominal_weight_id of
      Just wid ->
        -- Predefined weight - show label
        case filter (\nw -> nw.id == wid) state.nominalWeights of
          [nw] -> nw.label
          _ -> show weight <> "g"
      Nothing ->
        -- Custom weight - show value in grams
        Number.toStringWith (Number.fixed 3) weight <> "g"
    -- Find groupId from trayId
    groupId = case filter (\g -> case g.groupData of
                                    Just gd -> case gd.tray of
                                      Just tray -> tray.id == trayId
                                      Nothing -> false
                                    Nothing -> false) state.groups of
      [g] -> g.id
      _ -> 0
  in
    HH.tr_
      [ HH.td
          [ HP.class_ $ HH.ClassName "editable-cell"
          , HE.onClick \_ -> StartEditTrayItem groupId item.id
          ]
          [ renderMoneyInt charge ]
      , HH.td
          [ HP.class_ $ HH.ClassName "editable-cell"
          , HE.onClick \_ -> StartEditTrayItem groupId item.id
          ]
          [ HH.text jewelryTypeName ]
      , HH.td
          [ HP.class_ $ HH.ClassName "editable-cell"
          , HE.onClick \_ -> StartEditTrayItem groupId item.id
          ]
          [ HH.text $ fromMaybe "-" item.design_name ]
      , HH.td
          [ HP.class_ $ HH.ClassName "editable-cell"
          , HE.onClick \_ -> StartEditTrayItem groupId item.id
          ]
          [ HH.text nominalWeightDisplay ]
      , HH.td
          [ HP.class_ $ HH.ClassName "editable-cell"
          , HE.onClick \_ -> StartEditTrayItem groupId item.id
          ]
          [ HH.span [ HP.class_ $ HH.ClassName "num" ] [ HH.text $ show qty ] ]
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
    charge = parseNumber data_.makingCharge
    qty = parseNumber data_.quantity
    totalCharge = round (charge * qty)
  in
    HH.tr [ HP.class_ $ HH.ClassName "edit-row" ]
      [ HH.td_
          [ HH.input
              [ HP.type_ HP.InputNumber
              , HP.class_ $ HH.ClassName "edit-input num"
              , HP.value data_.makingCharge
              , HP.placeholder "ค่าแรง/ชิ้น"
              , HE.onValueInput \v -> UpdateTrayItemField MakingChargeField v
              , HE.onKeyDown \e -> HandleTrayItemKeyDown groupId e
              ]
          ]
      , HH.td_
          [ HH.select
              [ HP.class_ $ HH.ClassName "edit-select"
              , HE.onValueChange \v -> UpdateTrayItemField JewelryTypeField v
              , HE.onKeyDown \e -> HandleTrayItemKeyDown groupId e
              ]
              ([ HH.option [ HP.value "", HP.selected (data_.jewelryType == "") ] [ HH.text "เลือกประเภท" ] ] <>
               map (\jt -> HH.option [ HP.value (show jt.id), HP.selected (data_.jewelryType == show jt.id) ] [ HH.text jt.name ]) state.jewelryTypes)
          ]
      , HH.td_
          [ HH.input
              [ HP.type_ HP.InputText
              , HP.class_ $ HH.ClassName "edit-input"
              , HP.value data_.designName
              , HP.placeholder "ชื่อลาย"
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
              , HP.attr (HH.AttrName "list") ("weight-list-" <> show groupId)
              , HE.onValueInput \v -> UpdateTrayItemField NominalWeightField v
              , HE.onKeyDown \e -> HandleTrayItemKeyDown groupId e
              ]
          , HH.datalist
              [ HP.id ("weight-list-" <> show groupId) ]
              -- Show all options with their labels
              (map (\nw -> HH.option [ HP.value nw.label ] []) state.nominalWeights <>
               -- Add aliases for common fractions and decimals
               [ HH.option [ HP.value "1/2ส" ] []  -- Alias for ½ส
               , HH.option [ HP.value "1.5บ" ] []  -- Alias for 6ส
               ])
          ]
      , HH.td_
          [ HH.input
              [ HP.type_ HP.InputNumber
              , HP.class_ $ HH.ClassName "edit-input num"
              , HP.value data_.quantity
              , HP.placeholder "จำนวน"
              , HE.onValueInput \v -> UpdateTrayItemField QuantityField v
              , HE.onKeyDown \e -> HandleTrayItemKeyDown groupId e
              , HE.onBlur \_ -> 
                  if state.isSavingItem
                    then NoOp
                    else case state.editingTrayItem of
                      Just { itemId: -1 } -> 
                        -- Only auto-save for new items
                        if data_.makingCharge /= "" && data_.nominalWeight /= "" && data_.quantity /= ""
                          then SaveTrayItem groupId
                          else CancelEditTrayItem
                      _ -> 
                        -- For existing items, just cancel on blur
                        CancelEditTrayItem
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

renderTraySubtotal :: forall m. Int -> Maybe String -> Number -> Int -> Int -> Int -> Int -> H.ComponentHTML Action () m
renderTraySubtotal trayId actualWeight totalWeight totalCharge discountPercent discountAmount netCharge =
  let
    displayWeight = case actualWeight of
      Just w | w /= "" && w /= "0" -> w
      _ -> Number.toStringWith (Number.fixed 3) totalWeight
  in
    HH.table
      [ HP.class_ $ HH.ClassName "tray-subtotal-table" ]
      [ HH.tbody_
          [ HH.tr_
              [ HH.td_ [ HH.text "ทองหนัก" ]
              , HH.td_
                  [ HH.span [ HP.class_ $ HH.ClassName "num editable-weight" ]
                      [ HH.text displayWeight ]
                  , HH.text "g"
                  ]
              , HH.td_ [ HH.text "ค่าแรง" ]
              , HH.td_ [ renderMoneyInt totalCharge ]
              ]
        , HH.tr
            [ HP.class_ $ HH.ClassName $ if discountPercent == 0 then "discount-row hidden-discount" else "discount-row" ]
            [ HH.td_ []
            , HH.td_ []
            , HH.td_
                [ HH.text $ TC.discountAmountLabel <> " "
                , HH.select
                    [ HP.class_ $ HH.ClassName "discount-select"
                    , HE.onValueChange \v -> UpdateTrayDiscount trayId v
                    ]
                    [ HH.option [ HP.value "0", HP.selected (discountPercent == 0) ] [ HH.text "ไม่ลด" ]
                    , HH.option [ HP.value "5", HP.selected (discountPercent == 5) ] [ HH.text "5%" ]
                    , HH.option [ HP.value "10", HP.selected (discountPercent == 10) ] [ HH.text "10%" ]
                    ]
                ]
            , HH.td_ [ renderMoneyInt discountAmount ]
            ]
        , HH.tr [ HP.class_ $ HH.ClassName "subtotal-row" ]
            [ HH.td_ [ HH.text TC.owedGoldLabel ]
            , HH.td_ [ HH.text $ formatGramsRounded totalWeight ]
            , HH.td_ [ HH.text TC.owedMoneyLabel ]
            , HH.td_ [ renderMoneyInt netCharge ]
            ]
        ]
    ]

formatGramsRounded :: Number -> String
formatGramsRounded n =
  let
    rounded = (toNumber (round (n * 20.0))) / 20.0
    formatted = Number.toStringWith (Number.fixed 3) rounded
  in formatted <> "g"

renderWeightBaht :: forall m. Number -> H.ComponentHTML Action () m
renderWeightBaht n =
  let
    formatted = stripTrailingZerosFromNumber n
  in HH.span_
    [ HH.span [ HP.class_ $ HH.ClassName "num" ] [ HH.text formatted ]
    , HH.text "บ"
    ]

stripTrailingZerosFromNumber :: Number -> String
stripTrailingZerosFromNumber n =
  let
    str = Number.toStringWith (Number.fixed 3) n
    cleaned = if String.contains (Pattern ".000") str
                then replace (Pattern ".000") (Replacement "") str
                else if String.contains (Pattern "00") str
                  then replace (Pattern "00") (Replacement "") str
                  else if String.contains (Pattern "0") str && String.contains (Pattern ".") str
                    then String.take (String.length str - 1) str
                    else str
  in cleaned

renderMoneyInt :: forall m. Int -> H.ComponentHTML Action () m
renderMoneyInt n =
  HH.span [ HP.class_ $ HH.ClassName "num" ] [ HH.text $ formatWithCommas n ]

renderPackGroup :: forall m. BillGroup -> PackData -> Array ItemData -> H.ComponentHTML Action () m
renderPackGroup group pack items =
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
  if length items == 0
    then HH.p_ [ HH.text "ยังไม่มีแท่ง" ]
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
renderTransactionGroup group transaction items =
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
  if length items == 0
    then HH.p_ [ HH.text "ยังไม่มีรายการ" ]
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
renderGrandTotal bill =
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
      Just billId -> do
        -- Load existing bill
        handleAction Reload

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

  StartEditTrayItem groupId itemId -> do
    state <- H.get
    if itemId == -1
      then
        -- New item
        H.modify_ _ { editingTrayItem = Just { groupId, itemId }, editItemData = emptyEditItemData }
      else do
        -- Edit existing item - find and populate data
        let maybeGroup = filter (\g -> g.id == groupId) state.groups
        case maybeGroup of
          [group] -> case group.groupData of
            Just gd -> do
              let maybeItem = filter (\i -> i.id == itemId) gd.items
              case maybeItem of
                [item] -> do
                  let 
                    nominalWeightStr = fromMaybe "" item.nominal_weight
                    -- Check if this is a predefined weight (has nominal_weight_id)
                    displayWeight = case item.nominal_weight_id of
                      Just wid -> 
                        -- Predefined: find and show label
                        case filter (\nw -> nw.id == wid) state.nominalWeights of
                          [nw] -> nw.label
                          _ -> nominalWeightStr <> "g"
                      Nothing -> 
                        -- Custom: show as grams
                        nominalWeightStr <> "g"
                    editData =
                      { makingCharge: maybe "" show item.making_charge
                      , jewelryType: maybe "" show item.jewelry_type_id
                      , designName: fromMaybe "" item.design_name
                      , nominalWeight: displayWeight
                      , quantity: maybe "1" show item.quantity
                      }
                  H.modify_ _ { editingTrayItem = Just { groupId, itemId }, editItemData = editData }
                _ -> H.modify_ _ { editingTrayItem = Just { groupId, itemId }, editItemData = emptyEditItemData }
            Nothing -> H.modify_ _ { editingTrayItem = Just { groupId, itemId }, editItemData = emptyEditItemData }
          _ -> H.modify_ _ { editingTrayItem = Just { groupId, itemId }, editItemData = emptyEditItemData }

  CancelEditTrayItem -> do
    H.modify_ _ { editingTrayItem = Nothing, editItemData = emptyEditItemData }

  SaveTrayItem groupId -> do
    state <- H.get
    let data_ = state.editItemData
    -- Prevent double save
    if state.isSavingItem
      then H.liftEffect $ log "Already saving, skipping..."
      else do
        H.modify_ _ { isSavingItem = true }
        -- Check if we're editing an existing item or creating a new one
        let isEditing = case state.editingTrayItem of
              Just { itemId } -> itemId /= -1
              Nothing -> false
        let editingItemId = case state.editingTrayItem of
              Just { itemId } -> itemId
              Nothing -> -1
        H.liftEffect $ log $ "SaveTrayItem called for group: " <> show groupId <> ", editing: " <> show isEditing <> ", itemId: " <> show editingItemId
        H.liftEffect $ log $ "Edit data: " <> show data_.makingCharge <> ", " <> show data_.jewelryType <> ", " <> show data_.nominalWeight <> ", " <> show data_.quantity
        -- Find the tray in the group
        let maybeGroup = filter (\g -> g.id == groupId) state.groups
        case maybeGroup of
          [group] -> case group.groupData of
            Just gd -> case gd.tray of
              Just tray -> do
                H.liftEffect $ log $ "Found tray with id: " <> show tray.id
                -- Create item for API
                let jewelryTypeId = if data_.jewelryType == "" then Nothing else fromString data_.jewelryType
                H.liftEffect $ log $ "Jewelry type: " <> data_.jewelryType <> " -> " <> show jewelryTypeId
                -- Normalize input (convert aliases to standard labels)
                let normalizedInput = case data_.nominalWeight of
                      "1/2ส" -> "½ส"
                      "1.5บ" -> "6ส"
                      other -> other
                -- Check if input matches a predefined weight label
                let matchingWeight = filter (\nw -> nw.label == normalizedInput) state.nominalWeights
                let Tuple finalWeight weightId = case matchingWeight of
                      [nw] -> Tuple (show nw.weight_grams) (Just nw.id)  -- Predefined: store grams and ID
                      _ -> Tuple (show (parseThaiWeight normalizedInput)) Nothing  -- Custom: parse and store grams only
                H.liftEffect $ log $ "Final weight: " <> finalWeight <> " (input: " <> data_.nominalWeight <> ", id: " <> show weightId <> ")"
                let makingChargeInt = fromString data_.makingCharge
                let quantityInt = if data_.quantity == "" then Just 1 else fromString data_.quantity
                let amountInt = case makingChargeInt, quantityInt of
                      Just mc, Just qty -> Just (mc * qty)
                      _, _ -> Nothing
                let newItem =
                      { id: -1
                      , display_order: 0
                      , tray_id: Just tray.id
                      , making_charge: makingChargeInt
                      , jewelry_type_id: jewelryTypeId
                      , design_name: if data_.designName == "" then Nothing else Just data_.designName
                      , nominal_weight: Just finalWeight
                      , nominal_weight_id: weightId  -- Set ID for predefined, Nothing for custom
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
                if isEditing
                  then do
                    -- Update existing item
                    H.liftEffect $ log $ "Updating existing item: " <> show editingItemId
                    savedItem <- H.lift $ BillAPI.updateTrayItem editingItemId newItem
                    H.liftEffect $ log $ "Item updated with id: " <> show savedItem.id
                    -- Update item in local state
                    let updatedGroups = map (\g -> 
                          if g.id == groupId
                            then case g.groupData of
                              Just gd' -> g { groupData = Just (gd' { items = map (\i -> if i.id == editingItemId then savedItem else i) gd'.items }) }
                              Nothing -> g
                            else g
                        ) state.groups
                    H.modify_ _ { groups = updatedGroups, editingTrayItem = Nothing, editItemData = emptyEditItemData, isDirty = true, isSavingItem = false }
                  else do
                    -- Create new item
                    H.liftEffect $ log "Creating new item..."
                    savedItem <- H.lift $ BillAPI.addTrayItem tray.id newItem
                    H.liftEffect $ log $ "Item created with id: " <> show savedItem.id
                    -- Add item to local state
                    let updatedGroups = map (\g -> 
                          if g.id == groupId
                            then case g.groupData of
                              Just gd' -> g { groupData = Just (gd' { items = gd'.items <> [savedItem] }) }
                              Nothing -> g
                            else g
                        ) state.groups
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
        let updatedGroups = map (\g -> 
              case g.groupData of
                Just gd -> case gd.tray of
                  Just tray | tray.id == trayId ->
                    g { groupData = Just (gd { items = filter (\i -> i.id /= itemId) gd.items }) }
                  _ -> g
                Nothing -> g
            ) state.groups
        H.modify_ _ { groups = updatedGroups, isDirty = true, deleteConfirmation = Nothing }
      Nothing -> pure unit

  CancelDeleteTrayItem -> do
    H.modify_ _ { deleteConfirmation = Nothing }

  UpdateTrayItemField field value -> do
    state <- H.get
    let newData = case field of
          MakingChargeField -> state.editItemData { makingCharge = value }
          JewelryTypeField -> state.editItemData { jewelryType = value }
          DesignNameField -> state.editItemData { designName = value }
          NominalWeightField -> 
            -- Normalize aliases to standard labels
            let normalized = case value of
                  "1/2ส" -> "½ส"
                  "1.5บ" -> "6ส"
                  other -> other
            in state.editItemData { nominalWeight = normalized }
          QuantityField -> state.editItemData { quantity = value }
    H.modify_ _ { editItemData = newData }

  HandleTrayItemKeyDown groupId kbEvent -> do
    state <- H.get
    let data_ = state.editItemData
    let allFieldsFilled = data_.makingCharge /= "" && data_.nominalWeight /= "" && data_.quantity /= ""
    case KE.key kbEvent of
      "Enter" | allFieldsFilled -> do
        H.liftEffect $ Event.preventDefault (KE.toEvent kbEvent)
        handleAction $ SaveTrayItem groupId
      "Escape" -> do
        H.liftEffect $ Event.preventDefault (KE.toEvent kbEvent)
        handleAction CancelEditTrayItem
      _ -> pure unit

  StartEditTrayPrice trayId -> do
    state <- H.get
    -- Find the tray to get current price
    let maybeGroup = filter (\g -> case g.groupData of
                                      Just gd -> case gd.tray of
                                        Just tray -> tray.id == trayId
                                        Nothing -> false
                                      Nothing -> false) state.groups
    case maybeGroup of
      [group] -> case group.groupData of
        Just gd -> case gd.tray of
          Just tray -> H.modify_ _ { editingTrayPrice = Just { trayId, value: fromMaybe "" tray.price_rate } }
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
        let maybeGroup = filter (\g -> case g.groupData of
                                        Just gd -> case gd.tray of
                                          Just tray -> tray.id == editing.trayId
                                          Nothing -> false
                                        Nothing -> false) state.groups
        case maybeGroup of
          [group] -> case group.groupData of
            Just gd -> case gd.tray of
              Just tray -> do
                let newPrice = if editing.value == "" then Nothing else Just editing.value
                -- Update in database
                H.lift $ BillAPI.updateTray editing.trayId 
                  { price_rate: newPrice
                  , purity: tray.purity
                  , discount: tray.discount
                  }
                -- Update local state
                let updatedTray = tray { price_rate = newPrice }
                    updatedGroups = map (\g -> case g.groupData of
                          Just gd' -> case gd'.tray of
                            Just t | t.id == editing.trayId ->
                              g { groupData = Just (gd' { tray = Just updatedTray }) }
                            _ -> g
                          Nothing -> g
                        ) state.groups
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
    let maybeGroup = filter (\g -> case g.groupData of
                                      Just gd -> case gd.tray of
                                        Just tray -> tray.id == trayId
                                        Nothing -> false
                                      Nothing -> false) state.groups
    case maybeGroup of
      [group] -> case group.groupData of
        Just gd -> case gd.tray of
          Just tray -> H.modify_ _ { editingTrayPurity = Just { trayId, value: fromMaybe "" tray.purity } }
          Nothing -> pure unit
        Nothing -> pure unit
      _ -> pure unit

  UpdateTrayPurity value -> do
    state <- H.get
    case state.editingTrayPurity of
      Just editing -> H.modify_ _ { editingTrayPurity = Just (editing { value = value }) }
      Nothing -> pure unit

  SaveTrayPurity -> do
    state <- H.get
    case state.editingTrayPurity of
      Just editing -> do
        -- Find the tray to get current values
        let maybeGroup = filter (\g -> case g.groupData of
                                        Just gd -> case gd.tray of
                                          Just tray -> tray.id == editing.trayId
                                          Nothing -> false
                                        Nothing -> false) state.groups
        case maybeGroup of
          [group] -> case group.groupData of
            Just gd -> case gd.tray of
              Just tray -> do
                let newPurity = if editing.value == "" then Nothing else Just editing.value
                -- Update in database
                H.lift $ BillAPI.updateTray editing.trayId 
                  { price_rate: tray.price_rate
                  , purity: newPurity
                  , discount: tray.discount
                  }
                -- Update local state
                let updatedTray = tray { purity = newPurity }
                    updatedGroups = map (\g -> case g.groupData of
                          Just gd' -> case gd'.tray of
                            Just t | t.id == editing.trayId ->
                              g { groupData = Just (gd' { tray = Just updatedTray }) }
                            _ -> g
                          Nothing -> g
                        ) state.groups
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
        let maybeGroup = filter (\g -> case g.groupData of
                                        Just gd -> case gd.tray of
                                          Just tray -> tray.id == trayId
                                          Nothing -> false
                                        Nothing -> false) state.groups
        case maybeGroup of
          [group] -> case group.groupData of
            Just gd -> case gd.tray of
              Just tray -> do
                -- Update in database
                H.lift $ BillAPI.updateTray trayId 
                  { price_rate: tray.price_rate
                  , purity: tray.purity
                  , discount: Just newDiscount
                  }
                -- Update local state
                let updatedTray = tray { discount = Just newDiscount }
                    updatedGroups = map (\g -> case g.groupData of
                          Just gd' -> case gd'.tray of
                            Just t | t.id == trayId ->
                              g { groupData = Just (gd' { tray = Just updatedTray }) }
                            _ -> g
                          Nothing -> g
                        ) state.groups
                H.modify_ _ { groups = updatedGroups, isDirty = true }
              Nothing -> pure unit
            Nothing -> pure unit
          _ -> pure unit
      Nothing -> pure unit

  NoOp -> pure unit

handleQuery :: forall m a. MonadAff m => Query a -> H.HalogenM State Action () Output m (Maybe a)
handleQuery = case _ of
  LoadBill billId a -> do
    H.modify_ _ { billId = Just billId }
    handleAction Reload
    pure $ Just a
