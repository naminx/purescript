module Bill.Components.BillList where

import Prelude

import Bill.API as BillAPI
import Bill.Types (Bill)
import Data.Array (length)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import TextConstants.BillEditor as TC

type Slot = H.Slot Query Output

type Input = 
  { customerId :: Int
  , customerName :: String
  }

type State =
  { customerId :: Int
  , customerName :: String
  , bills :: Array Bill
  , isLoading :: Boolean
  , error :: Maybe String
  }

data Query a = LoadBills a

data Action
  = Initialize
  | Reload
  | SelectBill Int
  | CreateNewBill

data Output
  = BillSelected Int
  | NewBillRequested

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
  { customerId: input.customerId
  , customerName: input.customerName
  , bills: []
  , isLoading: false
  , error: Nothing
  }

render :: forall m. State -> H.ComponentHTML Action () m
render state =
  HH.div
    [ HP.class_ $ HH.ClassName "bill-list" ]
    [ renderHeader state
    , renderContent state
    ]

renderHeader :: forall m. State -> H.ComponentHTML Action () m
renderHeader state =
  HH.div
    [ HP.class_ $ HH.ClassName "bill-list-header" ]
    [ HH.h2_ [ HH.text $ TC.billsFor <> " " <> state.customerName ]
    , HH.button
        [ HP.class_ $ HH.ClassName "btn btn-primary"
        , HE.onClick \_ -> CreateNewBill
        ]
        [ HH.text TC.newBill ]
    , HH.button
        [ HP.class_ $ HH.ClassName "btn btn-secondary"
        , HE.onClick \_ -> Reload
        ]
        [ HH.text TC.reload ]
    ]

renderContent :: forall m. State -> H.ComponentHTML Action () m
renderContent state
  | state.isLoading = renderLoading
  | Just err <- state.error = renderError err
  | length state.bills == 0 = renderEmpty
  | otherwise = renderBills state.bills

renderLoading :: forall m. H.ComponentHTML Action () m
renderLoading =
  HH.div
    [ HP.class_ $ HH.ClassName "bill-list-loading" ]
    [ HH.text TC.loading ]

renderError :: forall m. String -> H.ComponentHTML Action () m
renderError err =
  HH.div
    [ HP.class_ $ HH.ClassName "bill-list-error" ]
    [ HH.text $ TC.errorPrefix <> err ]

renderEmpty :: forall m. H.ComponentHTML Action () m
renderEmpty =
  HH.div
    [ HP.class_ $ HH.ClassName "bill-list-empty" ]
    [ HH.text TC.noBillsFound ]

renderBills :: forall m. Array Bill -> H.ComponentHTML Action () m
renderBills bills =
  HH.div
    [ HP.class_ $ HH.ClassName "bill-list-items" ]
    [ HH.table
        [ HP.class_ $ HH.ClassName "bill-table" ]
        [ HH.thead_
            [ HH.tr_
                [ HH.th_ [ HH.text TC.billId ]
                , HH.th_ [ HH.text TC.date ]
                , HH.th_ [ HH.text TC.status ]
                , HH.th_ [ HH.text TC.actions ]
                ]
            ]
        , HH.tbody_ $ map renderBillRow bills
        ]
    ]

renderBillRow :: forall m. Bill -> H.ComponentHTML Action () m
renderBillRow bill =
  HH.tr_
    [ HH.td_ [ HH.text $ show bill.id ]
    , HH.td_ [ HH.text bill.date ]
    , HH.td_ [ HH.text $ if bill.is_finalized then TC.finalized else TC.draft ]
    , HH.td_
        [ HH.button
            [ HP.class_ $ HH.ClassName "btn btn-sm btn-primary"
            , HE.onClick \_ -> SelectBill bill.id
            ]
            [ HH.text TC.edit ]
        ]
    ]

handleAction :: forall m. MonadAff m => Action -> H.HalogenM State Action () Output m Unit
handleAction = case _ of
  Initialize -> do
    handleAction Reload

  Reload -> do
    H.modify_ _ { isLoading = true, error = Nothing }
    state <- H.get
    result <- H.lift $ BillAPI.getCustomerBills state.customerId
    case result of
      Left err -> 
        H.modify_ _ { isLoading = false, error = Just err }
      Right bills ->
        H.modify_ _ { isLoading = false, bills = bills }

  SelectBill billId ->
    H.raise $ BillSelected billId

  CreateNewBill ->
    H.raise NewBillRequested

handleQuery :: forall m a. MonadAff m => Query a -> H.HalogenM State Action () Output m (Maybe a)
handleQuery = case _ of
  LoadBills a -> do
    handleAction Reload
    pure $ Just a
