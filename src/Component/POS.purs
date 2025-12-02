module Component.POS where

import Prelude

import Effect.Class.Console (log)
import Data.Maybe (Maybe(..))
import TextConstants (posConstants)
import Data.String.Common (toLower)
import Data.String (contains)
import Data.String.Pattern (Pattern(..))
import Data.Array (filter)
import Data.Array (length)
import Effect.Aff.Class (class MonadAff, liftAff)
import Database.Types (Customer, DatabaseInterface)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP

type Bill =
  { id :: Int
  , billNumber :: String
  , customerId :: Int
  , customerName :: String
  , createdAt :: String
  }

-- Component state
type State m =
  { view :: POSView
  , searchQuery :: String
  , searchResults :: Array Customer
  , selectedCustomer :: Maybe Customer
  , todaysBills :: Array Bill
  , customerBills :: Array Bill
  , showSearchPopup :: Boolean
  , allCustomers :: Array Customer
  , database :: DatabaseInterface m
  }

data POSView
  = TodaysBillsView
  | CustomerBillsView Customer

-- Component actions
data Action
  = Initialize
  | UpdateSearchQuery String
  | ClearSearch
  | SelectCustomer Customer
  | OpenCustomerManagement
  | DeleteBill Int
  | OpenBillEditor (Maybe Int)
  | CreateNewBill

-- Component output
data Output
  = NavigateToCustomers

-- Component definition
component :: forall query input m. MonadAff m => DatabaseInterface m -> H.Component query input Output m
component database =
  H.mkComponent
    { initialState: initialState database
    , render
    , eval: H.mkEval $ H.defaultEval
        { handleAction = handleAction
        , initialize = Just Initialize
        }
    }

initialState :: forall m input. DatabaseInterface m -> input -> State m
initialState database _ =
  { view: TodaysBillsView
  , searchQuery: ""
  , searchResults: []
  , selectedCustomer: Nothing
  , todaysBills: []
  , customerBills: []
  , showSearchPopup: false
  , allCustomers: []
  , database
  }

-- Render function
render :: forall m. State m -> H.ComponentHTML Action () m
render state =
  HH.div
    [ HP.class_ (HH.ClassName "pos-container") ]
    [ renderStyles
    , renderHeader
    , renderSearchBox state
    , renderContent state
    ]

renderStyles :: forall w i. HH.HTML w i
renderStyles =
  HH.style_
    [ HH.text """
      .pos-container {
        padding: 20px;
        max-width: 1400px;
        margin: 0 auto;
        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
      }
      
      .pos-header {
        margin-bottom: 20px;
      }
      
      .pos-header h1 {
        margin: 0;
        font-size: 24px;
        color: #333;
      }
      
      /* Search box */
      .pos-search-container {
        display: flex;
        gap: 8px;
        margin-bottom: 20px;
      }
      
      .pos-search-box {
        position: relative;
        width: 600px;
      }
      
      .pos-search-input {
        width: 100%;
        padding: 10px 40px 10px 12px;
        font-size: 16px;
        border: 1px solid #ddd;
        border-radius: 4px;
        box-sizing: border-box;
        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
      }
      
      .pos-search-input:focus {
        outline: none;
        border-color: #007bff;
      }
      
      .pos-search-clear {
        position: absolute;
        right: 8px;
        top: 50%;
        transform: translateY(-50%);
        background: none;
        border: none;
        font-size: 24px;
        cursor: pointer;
        color: #999;
        padding: 0 8px;
        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
      }
      
      .pos-search-clear:hover {
        color: #333;
      }
      

      
      /* Search popup */
      .pos-search-popup {
        position: absolute;
        top: 100%;
        left: 0;
        right: 0;
        background: white;
        border: 1px solid #ddd;
        border-top: none;
        border-radius: 0 0 4px 4px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        max-height: 300px;
        overflow-y: auto;
        z-index: 1000;
      }
      
      .pos-search-result {
        padding: 12px;
        border-bottom: 1px solid #eee;
        cursor: pointer;
      }
      
      .pos-search-result:hover {
        background: #f5f5f5;
      }
      
      .pos-search-result-name {
        font-weight: 500;
        font-size: 14px;
      }
      
      .pos-search-no-results {
        padding: 12px;
        color: #999;
        text-align: center;
      }
      
      /* Content area */
      .pos-content {
        margin-top: 20px;
      }
      
      .pos-content h2 {
        margin: 0 0 16px 0;
        font-size: 20px;
        color: #333;
      }
      
      /* Tables */
      .pos-table {
        width: 100%;
        border-collapse: collapse;
        background: white;
        border: 1px solid #ddd;
      }
      
      .pos-table th {
        background: #f8f9fa;
        padding: 12px 8px;
        text-align: left;
        font-weight: 600;
        border-bottom: 2px solid #dee2e6;
      }
      
      .pos-table td {
        padding: 12px 8px;
        border-bottom: 1px solid #eee;
        vertical-align: top;
      }
      
      .pos-table tr:hover {
        background: #f5f5f5;
      }
      
      /* Today's Bills table */
      .pos-time-col {
        text-align: right;
        width: 80px;
      }
      
      .pos-customer-name-cell {
        cursor: pointer;
      }
      
      .pos-customer-name-cell:hover {
        background: #e8f4f8 !important;
        text-decoration: underline;
      }
      
      /* Customer Bills table */
      .pos-date-col {
        text-align: right;
        width: 100px;
      }
      
      .pos-gold-label {
        text-align: left;
        width: 120px;
        line-height: 1.6;
      }
      
      .pos-gold-value {
        text-align: right;
        width: 100px;
        line-height: 1.6;
      }
      
      .pos-money-label {
        text-align: left;
        width: 80px;
      }
      
      .pos-money-value {
        text-align: right;
        width: 100px;
      }
      
      .pos-actions-col {
        text-align: center;
        width: 60px;
      }
      
      /* Clickable cells */
      .pos-clickable-gold,
      .pos-clickable-money {
        cursor: pointer;
      }
      
      .pos-gold-label:hover,
      .pos-gold-label:hover + .pos-gold-value {
        background: #e8f4f8 !important;
      }
      
      .pos-gold-value:hover {
        background: #e8f4f8 !important;
      }
      
      .pos-money-label:hover,
      .pos-money-label:hover + .pos-money-value {
        background: #e8f4f8 !important;
      }
      
      .pos-money-value:hover {
        background: #e8f4f8 !important;
      }
      
      /* Settlement row */
      .pos-settlement-row {
        background: #e3f2fd !important;
        font-weight: 500;
      }
      
      .pos-settlement-row .pos-clickable-gold:hover,
      .pos-settlement-row .pos-clickable-money:hover {
        background: #bbdefb !important;
      }
      
      /* New bill row */
      .pos-new-bill-row {
        background: #fff9c4 !important;
        text-align: center;
        cursor: pointer;
      }
      
      .pos-new-bill-row:hover {
        background: #fff59d !important;
      }
      
      .pos-new-bill-row td {
        padding: 20px;
        font-size: 24px;
      }
      
      /* Icon buttons */
      .pos-icon-btn {
        background: none;
        border: none;
        font-size: 20px;
        cursor: pointer;
        padding: 4px 8px;
        color: #666;
        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
      }
      
      .pos-icon-btn:hover {
        color: #333;
      }
      
      .pos-delete-btn:hover {
        color: #dc3545;
      }
    """
    ]

renderHeader :: forall w i. HH.HTML w i
renderHeader =
  HH.text ""

renderSearchBox :: forall m. State m -> H.ComponentHTML Action () m
renderSearchBox state =
  HH.div
    [ HP.class_ (HH.ClassName "pos-search-container") ]
    [ HH.div
        [ HP.class_ (HH.ClassName "pos-search-box") ]
        [ HH.input
            [ HP.type_ HP.InputText
            , HP.class_ (HH.ClassName "pos-search-input")
            , HP.placeholder posConstants.searchPlaceholder
            , HP.value state.searchQuery
            , HE.onValueInput UpdateSearchQuery
            ]
        , if state.searchQuery /= ""
            then HH.button
              [ HP.class_ (HH.ClassName "pos-search-clear")
              , HE.onClick \_ -> ClearSearch
              ]
              [ HH.text "×" ]
            else HH.text ""
        , if state.showSearchPopup
            then renderSearchPopup state
            else HH.text ""
        ]
    ]

renderSearchPopup :: forall m. State m -> H.ComponentHTML Action () m
renderSearchPopup state =
  HH.div
    [ HP.class_ (HH.ClassName "pos-search-popup") ]
    ( if length state.searchResults == 0
        then [ HH.div
                [ HP.class_ (HH.ClassName "pos-search-no-results") ]
                [ HH.text posConstants.noCustomersFound ]
             ]
        else map renderSearchResult state.searchResults
    )

renderSearchResult :: forall m. Customer -> H.ComponentHTML Action () m
renderSearchResult customer =
  HH.div
    [ HP.class_ (HH.ClassName "pos-search-result")
    , HE.onClick \_ -> SelectCustomer customer
    ]
    [ HH.div
        [ HP.class_ (HH.ClassName "pos-search-result-name") ]
        [ HH.text $ customer.name <> " (ID: " <> show customer.id <> ")" ]
    ]

renderContent :: forall m. State m -> H.ComponentHTML Action () m
renderContent state =
  case state.view of
    TodaysBillsView -> renderTodaysBills state
    CustomerBillsView customer -> renderCustomerBills state customer

renderTodaysBills :: forall m. State m -> H.ComponentHTML Action () m
renderTodaysBills state =
  HH.div
    [ HP.class_ (HH.ClassName "pos-content") ]
    [ HH.h2_ [ HH.text $ posConstants.todaysBillsTitle (length state.todaysBills) ]
    , HH.table
        [ HP.class_ (HH.ClassName "pos-table pos-todays-bills-table") ]
        [ HH.thead_
            [ HH.tr_
                [ HH.th_ [ HH.text posConstants.columnTime ]
                , HH.th_ [ HH.text posConstants.columnCustomerName ]
                , HH.th_ [ HH.text "" ]
                ]
            ]
        , HH.tbody_ (map renderTodaysBillRow state.todaysBills)
        ]
    ]

renderTodaysBillRow :: forall m. Bill -> H.ComponentHTML Action () m
renderTodaysBillRow bill =
  HH.tr_
    [ HH.td
        [ HP.class_ (HH.ClassName "pos-time-col") ]
        [ HH.text $ formatTime bill.createdAt ]
    , HH.td
        [ HP.class_ (HH.ClassName "pos-customer-name-cell")
        , HE.onClick \_ -> OpenBillEditor (Just bill.id)
        ]
        [ HH.text bill.customerName ]
    , HH.td
        [ HP.class_ (HH.ClassName "pos-actions-col") ]
        [ HH.button
            [ HP.class_ (HH.ClassName "pos-icon-btn pos-delete-btn")
            , HE.onClick \_ -> DeleteBill bill.id
            , HP.title "Delete bill"
            ]
            [ HH.text "🗑️" ]
        ]
    ]

renderCustomerBills :: forall m. State m -> Customer -> H.ComponentHTML Action () m
renderCustomerBills state customer =
  HH.div
    [ HP.class_ (HH.ClassName "pos-content") ]
    [ HH.h2_ [ HH.text $ customer.name <> " (ID: " <> show customer.id <> ")" ]
    , HH.table
        [ HP.class_ (HH.ClassName "pos-table pos-customer-bills-table") ]
        [ HH.thead_
            [ HH.tr_
                [ HH.th [ HP.class_ (HH.ClassName "pos-date-col") ] [ HH.text "Date" ]
                , HH.th [ HP.class_ (HH.ClassName "pos-gold-label") ] [ HH.text "Gold Label" ]
                , HH.th [ HP.class_ (HH.ClassName "pos-gold-value") ] [ HH.text "Gold Value" ]
                , HH.th [ HP.class_ (HH.ClassName "pos-money-label") ] [ HH.text "Money Label" ]
                , HH.th [ HP.class_ (HH.ClassName "pos-money-value") ] [ HH.text "Money Value" ]
                , HH.th [ HP.class_ (HH.ClassName "pos-actions-col") ] [ HH.text "×" ]
                ]
            ]
        , HH.tbody_
            [ renderSettlementRow customer
            , renderNewBillRow
            ]
        ]
    ]

renderSettlementRow :: forall m. Customer -> H.ComponentHTML Action () m
renderSettlementRow customer =
  HH.tr
    [ HP.class_ (HH.ClassName "pos-settlement-row") ]
    [ HH.td
        [ HP.class_ (HH.ClassName "pos-date-col") ]
        [ HH.text "2024-11-18" ]  -- Placeholder
    , HH.td
        [ HP.class_ (HH.ClassName "pos-gold-label pos-clickable-gold")
        , HE.onClick \_ -> OpenBillEditor Nothing
        ]
        [ HH.text "เหลือทอง" ]  -- Placeholder
    , HH.td
        [ HP.class_ (HH.ClassName "pos-gold-value pos-clickable-gold")
        , HE.onClick \_ -> OpenBillEditor Nothing
        ]
        [ HH.text "10.500g" ]  -- Placeholder
    , HH.td
        [ HP.class_ (HH.ClassName "pos-money-label pos-clickable-money")
        , HE.onClick \_ -> OpenBillEditor Nothing
        ]
        [ HH.text "เหลือเงิน" ]  -- Placeholder
    , HH.td
        [ HP.class_ (HH.ClassName "pos-money-value pos-clickable-money")
        , HE.onClick \_ -> OpenBillEditor Nothing
        ]
        [ HH.text "5,000" ]  -- Placeholder
    , HH.td
        [ HP.class_ (HH.ClassName "pos-actions-col") ]
        [ HH.text "" ]
    ]

renderNewBillRow :: forall m. H.ComponentHTML Action () m
renderNewBillRow =
  HH.tr
    [ HP.class_ (HH.ClassName "pos-new-bill-row")
    , HE.onClick \_ -> CreateNewBill
    ]
    [ HH.td
        [ HP.colSpan 6 ]
        [ HH.text "➕" ]
    ]

-- Helper functions
formatTime :: String -> String
formatTime timestamp =
  -- Extract HH:MM from ISO timestamp
  -- Placeholder implementation
  "09:15"

filterCustomers :: String -> Array Customer -> Array Customer
filterCustomers query customers =
  if query == ""
    then []
    else 
      let 
        lowerQuery = toLower query
        matchesQuery customer =
          contains (Pattern lowerQuery) (toLower customer.name) ||
          contains (Pattern query) (show customer.id)
        results = filter matchesQuery customers
      in results

-- Action handler
handleAction :: forall m. MonadAff m => Action -> H.HalogenM (State m) Action () Output m Unit
handleAction = case _ of
  Initialize -> do
    -- Load all customers for search
    state <- H.get
    customers <- H.lift state.database.getAllCustomers
    H.lift $ log $ "POS: Loaded " <> show (length customers) <> " customers"
    H.modify_ _ { allCustomers = customers }
    -- TODO: Load today's bills from API
    pure unit

  UpdateSearchQuery query -> do
    state <- H.get
    H.lift $ log $ "Search query: " <> query
    H.lift $ log $ "Total customers: " <> show (length state.allCustomers)
    let searchResults = filterCustomers query state.allCustomers
    H.lift $ log $ "Search results: " <> show (length searchResults)
    H.lift $ log $ "Show popup: " <> show (query /= "")
    H.modify_ _ 
      { searchQuery = query
      , showSearchPopup = query /= ""
      , searchResults = searchResults
      }

  ClearSearch -> do
    H.modify_ _ 
      { searchQuery = ""
      , showSearchPopup = false
      , selectedCustomer = Nothing
      , view = TodaysBillsView
      }

  SelectCustomer customer -> do
    H.modify_ _ 
      { selectedCustomer = Just customer
      , searchQuery = customer.name
      , showSearchPopup = false
      , view = CustomerBillsView customer
      }
    -- TODO: Load customer's bills from API
    pure unit

  OpenCustomerManagement -> do
    H.raise NavigateToCustomers

  DeleteBill billId -> do
    -- TODO: Show confirmation dialog and delete bill
    pure unit

  OpenBillEditor maybeBillId -> do
    -- TODO: Navigate to bill editor
    pure unit

  CreateNewBill -> do
    -- TODO: Create new bill for selected customer
    pure unit
