module Bill.Components.TransactionGroup where

import Prelude

import Data.Array (length, mapWithIndex)
import Data.Maybe (Maybe(..))
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import TextConstants.BillEditor as TC

-- Simplified types
type Transaction =
  { id :: Int
  , group_id :: Int
  }

type TransactionItem =
  { id :: Int
  , transaction_id :: Int
  , display_order :: Int
  , transaction_type :: String
  , amount_money :: Maybe String
  , amount_grams :: Maybe String
  , amount_baht :: Maybe String
  , balance_type :: Maybe String
  , price_rate :: Maybe String
  , conversion_charge_rate :: Maybe String
  , split_charge_rate :: Maybe String
  , block_making_charge_rate :: Maybe String
  , source_amount_grams :: Maybe String
  , source_amount_baht :: Maybe String
  , dest_amount_grams :: Maybe String
  , dest_amount_baht :: Maybe String
  }

type Slot = H.Slot Query Output

type Input =
  { transaction :: Transaction
  , items :: Array TransactionItem
  , isEditable :: Boolean
  }

type State =
  { transaction :: Transaction
  , items :: Array TransactionItem
  , isEditable :: Boolean
  , isExpanded :: Boolean
  }

data Query a = UpdateTransaction Transaction (Array TransactionItem) a

data Action
  = ToggleExpand
  | AddItem
  | EditItem Int
  | DeleteItem Int

data Output
  = TransactionUpdated Transaction
  | ItemAdded
  | ItemUpdated TransactionItem
  | ItemDeleted Int

component :: forall m. MonadAff m => H.Component Query Input Output m
component =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval $ H.defaultEval
        { handleAction = handleAction
        , handleQuery = handleQuery
        }
    }

initialState :: Input -> State
initialState input =
  { transaction: input.transaction
  , items: input.items
  , isEditable: input.isEditable
  , isExpanded: true
  }

render :: forall m. State -> H.ComponentHTML Action () m
render state =
  HH.div
    [ HP.class_ $ HH.ClassName "transaction-group" ]
    [ renderTransactionHeader state
    , if state.isExpanded
        then renderTransactionContent state
        else HH.text ""
    ]

renderTransactionHeader :: forall m. State -> H.ComponentHTML Action () m
renderTransactionHeader state =
  HH.div
    [ HP.class_ $ HH.ClassName "transaction-header"
    , HE.onClick \_ -> ToggleExpand
    ]
    [ HH.span
        [ HP.class_ $ HH.ClassName "transaction-title" ]
        [ HH.text TC.transactionLabel ]
    , HH.span
        [ HP.class_ $ HH.ClassName "transaction-summary" ]
        [ HH.text $ show (length state.items) <> " รายการ" ]
    , HH.span
        [ HP.class_ $ HH.ClassName "expand-icon" ]
        [ HH.text $ if state.isExpanded then "▼" else "▶" ]
    ]

renderTransactionContent :: forall m. State -> H.ComponentHTML Action () m
renderTransactionContent state =
  HH.div
    [ HP.class_ $ HH.ClassName "transaction-content" ]
    [ renderTransactionItems state
    , if state.isEditable
        then renderAddItemButton
        else HH.text ""
    ]

renderTransactionItems :: forall m. State -> H.ComponentHTML Action () m
renderTransactionItems state =
  HH.div
    [ HP.class_ $ HH.ClassName "transaction-items" ]
    [ if length state.items == 0
        then HH.p_ [ HH.text "ยังไม่มีรายการ" ]
        else HH.table
          [ HP.class_ $ HH.ClassName "items-table" ]
          [ HH.thead_
              [ HH.tr_
                  [ HH.th_ [ HH.text "#" ]
                  , HH.th_ [ HH.text "ประเภท" ]
                  , HH.th_ [ HH.text "รายละเอียด" ]
                  , if state.isEditable
                      then HH.th_ [ HH.text TC.actions ]
                      else HH.text ""
                  ]
              ]
          , HH.tbody_ $ mapWithIndex (renderTransactionItemRow state) state.items
          ]
    ]

renderTransactionItemRow :: forall m. State -> Int -> TransactionItem -> H.ComponentHTML Action () m
renderTransactionItemRow state index item =
  HH.tr_
    [ HH.td_ [ HH.text $ show (index + 1) ]
    , HH.td_ [ HH.text $ getTransactionTypeLabel item.transaction_type ]
    , HH.td_ [ HH.text $ renderTransactionDetails item ]
    , if state.isEditable
        then HH.td_
          [ HH.button
              [ HP.class_ $ HH.ClassName "btn btn-sm"
              , HE.onClick \_ -> EditItem item.id
              ]
              [ HH.text TC.edit ]
          , HH.button
              [ HP.class_ $ HH.ClassName "btn btn-sm btn-danger"
              , HE.onClick \_ -> DeleteItem item.id
              ]
              [ HH.text TC.deleteButton ]
          ]
        else HH.text ""
    ]

renderTransactionDetails :: TransactionItem -> String
renderTransactionDetails item =
  case item.amount_money of
    Just money -> money <> " " <> TC.unitTHB
    Nothing -> case item.amount_grams of
      Just grams -> grams <> " " <> TC.unitGrams
      Nothing -> case item.amount_baht of
        Just baht -> baht <> " " <> TC.unitBaht
        Nothing -> "-"

getTransactionTypeLabel :: String -> String
getTransactionTypeLabel txType = case txType of
  "prev_debit_money" -> TC.prevDebitMoney
  "prev_credit_money" -> TC.prevCreditMoney
  "prev_debit_jewel" -> TC.prevDebitJewel
  "prev_credit_jewel" -> TC.prevCreditJewel
  "prev_debit_bar96" -> TC.prevDebitBar96
  "prev_credit_bar96" -> TC.prevCreditBar96
  "prev_debit_bar99" -> TC.prevDebitBar99
  "prev_credit_bar99" -> TC.prevCreditBar99
  "money_in" -> TC.moneyIn
  "money_out" -> TC.moneyOut
  "jewel_in" -> TC.jewelIn
  "jewel_out" -> TC.jewelOut
  "bar96_in" -> TC.bar96In
  "bar96_out" -> TC.bar96Out
  "bar99_in" -> TC.bar99In
  "bar99_out" -> TC.bar99Out
  "buy_jewel" -> TC.buyJewel
  "sell_jewel" -> TC.sellJewel
  "buy_bar96" -> TC.buyBar96
  "sell_bar96" -> TC.sellBar96
  "buy_bar99" -> TC.buyBar99
  "sell_bar99" -> TC.sellBar99
  "convert_jewel_to_bar96" -> TC.convertJewelToBar96
  "convert_bar96_to_jewel" -> TC.convertBar96ToJewel
  "convert_grams_to_baht" -> TC.convertGramsToBaht
  "convert_baht_to_grams" -> TC.convertBahtToGrams
  "split_bar" -> TC.splitBar
  _ -> txType

renderAddItemButton :: forall m. H.ComponentHTML Action () m
renderAddItemButton =
  HH.div
    [ HP.class_ $ HH.ClassName "add-item-button" ]
    [ HH.button
        [ HP.class_ $ HH.ClassName "btn btn-primary"
        , HE.onClick \_ -> AddItem
        ]
        [ HH.text TC.addItemButton ]
    ]

handleAction :: forall m. MonadAff m => Action -> H.HalogenM State Action () Output m Unit
handleAction = case _ of
  ToggleExpand ->
    H.modify_ \s -> s { isExpanded = not s.isExpanded }

  AddItem ->
    H.raise ItemAdded

  EditItem itemId -> do
    -- TODO: Open item edit dialog
    pure unit

  DeleteItem itemId ->
    H.raise $ ItemDeleted itemId

handleQuery :: forall m a. MonadAff m => Query a -> H.HalogenM State Action () Output m (Maybe a)
handleQuery = case _ of
  UpdateTransaction transaction items a -> do
    H.modify_ _ { transaction = transaction, items = items }
    pure $ Just a
