module Component.CustomerList where

import Prelude

import Component.Icons as Icons
import Data.Array (drop, filter, findIndex, length, slice, snoc, sortBy, take, (!!))
import Data.Int (floor, toNumber)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String (Pattern(..), contains, toLower)
import Database.Types (Customer, DatabaseInterface)
import Effect.Aff.Class (class MonadAff)
import Effect.Class.Console (log)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.Query.HalogenM (HalogenM)
import Effect (Effect)
import Web.Event.Event (Event, EventType(..))
import Web.Event.Event as Event
import Web.HTML.HTMLElement (HTMLElement)
import Web.HTML.HTMLElement as HTMLElement
import Web.DOM.ParentNode (QuerySelector(..), querySelector)
import Web.HTML.HTMLElement as HTMLElem
import Web.DOM.Element as Element
import Web.UIEvent.MouseEvent (MouseEvent)

data SortField = SortById | SortByName

derive instance eqSortField :: Eq SortField

data SortDirection = Ascending | Descending

derive instance eqSortDirection :: Eq SortDirection

toggleDirection :: SortDirection -> SortDirection
toggleDirection Ascending = Descending
toggleDirection Descending = Ascending

type SortState =
  { field :: Maybe SortField
  , direction :: SortDirection
  }

type State =
  { customers :: Array Customer
  , editingId :: Maybe Int
  , editingName :: String
  , newCustomerName :: String
  , sortState :: SortState
  , scrollTop :: Number
  , containerHeight :: Number
  , searchQuery :: String
  }

data Action
  = Initialize
  | LoadCustomers
  | StartEdit Int String
  | UpdateEditName String
  | SaveEdit Int
  | CancelEdit
  | UpdateNewName String
  | AddCustomer Event
  | DeleteCustomer Int
  | SortBy SortField
  | HandleScroll Event
  | ScrollToCustomer String
  | UpdateSearchQuery String

type Output = Void

type Slots :: forall k. Row k
type Slots = ()

type ComponentM m = H.HalogenM State Action Slots Output m

component :: forall q i m. MonadAff m => DatabaseInterface m -> H.Component q i Output m
component db =
  H.mkComponent
    { initialState: \_ ->
        { customers: []
        , editingId: Nothing
        , editingName: ""
        , newCustomerName: ""
        , sortState: { field: Just SortByName, direction: Ascending }
        , scrollTop: 0.0
        , containerHeight: 600.0
        , searchQuery: ""
        }
    , render: render
    , eval: H.mkEval $ H.defaultEval
        { handleAction = handleAction db
        , initialize = Just Initialize
        }
    }

-- Virtual scrolling constants
rowHeight :: Number
rowHeight = 36.0 -- Height of each customer row in pixels

overscan :: Int
overscan = 5 -- Number of extra rows to render above and below visible area

-- Calculate which rows should be rendered based on scroll position
-- Note: This should be called with already filtered and sorted customers
calculateVisibleRangeForCustomers :: Array Customer -> Number -> Number -> { start :: Int, end :: Int, totalHeight :: Number }
calculateVisibleRangeForCustomers customers scrollTop containerHeight =
  let
    totalRows = length customers
    totalHeight = toNumber totalRows * rowHeight
    
    -- Use a minimum container height to ensure initial render
    effectiveHeight = max containerHeight 600.0
    
    -- Calculate visible range
    startIndex = floor (scrollTop / rowHeight) - overscan
    visibleRows = floor (effectiveHeight / rowHeight) + 1
    endIndex = startIndex + visibleRows + (overscan * 2)
    
    -- Clamp to valid range
    start = max 0 startIndex
    end = min totalRows endIndex
  in
    { start, end, totalHeight }

calculateVisibleRange :: State -> { start :: Int, end :: Int, totalHeight :: Number }
calculateVisibleRange state =
  let
    filteredCustomers = filterCustomers state.searchQuery state.customers
    sortedCustomers = applySorting state.sortState filteredCustomers
  in
    calculateVisibleRangeForCustomers sortedCustomers state.scrollTop state.containerHeight

-- | Filter customers by search query
filterCustomers :: String -> Array Customer -> Array Customer
filterCustomers "" customers = customers
filterCustomers query customers =
  filter (\c -> contains (Pattern (toLower query)) (toLower c.name)) customers

-- | Apply sorting to customer list
applySorting :: SortState -> Array Customer -> Array Customer
applySorting { field: Nothing } customers = customers
applySorting { field: Just SortById, direction } customers =
  let
    sorted = sortBy (\a b -> compare a.id b.id) customers
  in
    case direction of
      Ascending -> sorted
      Descending -> sortBy (\a b -> compare b.id a.id) customers
applySorting { field: Just SortByName, direction } customers =
  let
    sorted = sortBy (\a b -> compare (toLower a.name) (toLower b.name)) customers
  in
    case direction of
      Ascending -> sorted
      Descending -> sortBy (\a b -> compare (toLower b.name) (toLower a.name)) customers

render :: forall m. State -> H.ComponentHTML Action Slots m
render state =
  let
    filteredCustomers = filterCustomers state.searchQuery state.customers
    sortedCustomers = applySorting state.sortState filteredCustomers
    { start, end, totalHeight } = calculateVisibleRange state
    visibleCustomers = slice start end sortedCustomers
    offsetTop = toNumber start * rowHeight
  in
    HH.div
      [ HP.class_ (HH.ClassName "customer-app") ]
      [ HH.h1
          [ HP.class_ (HH.ClassName "app-title") ] 
          [ HH.text "Customer Management"
          , HH.span 
              [ HP.class_ (HH.ClassName "customer-count") ]
              [ HH.text $ " (" <> show (length sortedCustomers) <> " customers)" ]
          ]
      , HH.div
          [ HP.class_ (HH.ClassName "customer-list-container") ]
          [ renderTableHeader state
          , HH.div
              [ HP.class_ (HH.ClassName "customer-list")
              , HE.onScroll HandleScroll
              ]
              [ HH.div
                  [ HP.class_ (HH.ClassName "scroll-spacer")
                  , HP.attr (HH.AttrName "style") $ "height: " <> show totalHeight <> "px"
                  ]
                  []
              , HH.div
                  [ HP.class_ (HH.ClassName "visible-rows")
                  , HP.attr (HH.AttrName "style") $ "transform: translateY(" <> show offsetTop <> "px)"
                  ]
                  (map (renderCustomerRow state) visibleCustomers)
              ]
          , renderTableFooter state
          ]
      , renderStyles
      ]

renderTableHeader :: forall m. State -> H.ComponentHTML Action Slots m
renderTableHeader state =
  HH.div
    [ HP.class_ (HH.ClassName "table-header") ]
    [ HH.div
        [ HP.class_ (HH.ClassName "header-cell header-id") ]
        [ HH.button
            [ HP.class_ (HH.ClassName "sort-button")
            , HE.onClick \_ -> SortBy SortById
            ]
            [ HH.text "ID "
            , renderSortIcon SortById state.sortState
            ]
        ]
    , HH.div
        [ HP.class_ (HH.ClassName "header-cell header-name") ]
        [ HH.div
            [ HP.class_ (HH.ClassName "header-name-content") ]
            [ HH.button
                [ HP.class_ (HH.ClassName "sort-button")
                , HE.onClick \_ -> SortBy SortByName
                ]
                [ HH.text "Name "
                , renderSortIcon SortByName state.sortState
                ]
            , HH.input
                [ HP.type_ HP.InputText
                , HP.class_ (HH.ClassName "search-input")
                , HP.placeholder "Search..."
                , HP.value state.searchQuery
                , HE.onValueInput UpdateSearchQuery
                ]
            ]
        ]
    , HH.div
        [ HP.class_ (HH.ClassName "header-cell header-actions") ]
        [ HH.text "Actions" ]
    ]

renderSortIcon :: forall w i. SortField -> SortState -> HH.HTML w i
renderSortIcon field { field: currentField, direction } =
  case currentField of
    Just f | f == field ->
      case direction of
        Ascending -> Icons.sortAscIcon
        Descending -> Icons.sortDescIcon
    _ -> Icons.sortNeutralIcon

renderCustomerRow :: forall m. State -> Customer -> H.ComponentHTML Action Slots m
renderCustomerRow state customer =
  let
    isEditing = state.editingId == Just customer.id
  in
    HH.div
      [ HP.class_ (HH.ClassName "customer-row") ]
      [ HH.span
          [ HP.class_ (HH.ClassName "customer-id") ]
          [ HH.text $ show customer.id ]
      , if isEditing then
          HH.input
            [ HP.type_ HP.InputText
            , HP.class_ (HH.ClassName "customer-name-input")
            , HP.value state.editingName
            , HE.onValueInput UpdateEditName
            ]
        else
          HH.span
            [ HP.class_ (HH.ClassName "customer-name") ]
            [ HH.text customer.name ]
      , HH.div
          [ HP.class_ (HH.ClassName "customer-actions") ]
          [ if isEditing then
              HH.button
                [ HP.class_ (HH.ClassName "btn btn-save")
                , HE.onClick \_ -> SaveEdit customer.id
                , HP.title "Save"
                ]
                [ Icons.saveIcon ]
            else
              HH.button
                [ HP.class_ (HH.ClassName "btn btn-edit")
                , HE.onClick \_ -> StartEdit customer.id customer.name
                , HP.title "Edit"
                ]
                [ Icons.editIcon ]
          , HH.button
              [ HP.class_ (HH.ClassName "btn btn-delete")
              , HE.onClick \_ -> DeleteCustomer customer.id
              , HP.title "Delete"
              ]
              [ Icons.deleteIcon ]
          ]
      ]

renderTableFooter :: forall m. State -> H.ComponentHTML Action Slots m
renderTableFooter state =
  HH.div
    [ HP.class_ (HH.ClassName "table-footer") ]
    [ HH.form
        [ HP.class_ (HH.ClassName "add-customer-form")
        , HE.onSubmit AddCustomer
        ]
        [ HH.input
            [ HP.type_ HP.InputText
            , HP.class_ (HH.ClassName "new-customer-input")
            , HP.placeholder "New Customer Name"
            , HP.value state.newCustomerName
            , HE.onValueInput UpdateNewName
            ]
        , HH.button
            [ HP.type_ HP.ButtonSubmit
            , HP.class_ (HH.ClassName "btn btn-add")
            , HP.title "Add Customer"
            ]
            [ Icons.addIcon ]
        ]
    ]

renderStyles :: forall w i. HH.HTML w i
renderStyles =
  HH.style_
    [ HH.text """
      * {
        box-sizing: border-box;
      }
      
      body {
        margin: 0;
        padding: 0;
        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
          'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
          sans-serif;
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
        overflow: hidden;
        height: 100vh;
      }
      
      .customer-app {
        max-width: 900px;
        margin: 0 auto;
        padding: 8px;
        height: 100vh;
        display: flex;
        flex-direction: column;
      }
      
      h1 {
        color: #333;
        margin: 0 0 8px 0;
        font-size: 20px;
      }
      
      .customer-list-container {
        border: 1px solid #ddd;
        border-radius: 4px;
        overflow: hidden;
        flex: 1;
        display: flex;
        flex-direction: column;
        min-height: 0;
      }
      
      .table-header {
        display: flex;
        align-items: center;
        padding: 6px 8px;
        background-color: #f8f9fa;
        border-bottom: 2px solid #dee2e6;
        font-weight: 600;
        color: #495057;
        gap: 8px;
        font-size: 13px;
      }
      
      .header-cell {
        display: flex;
        align-items: center;
      }
      
      .header-id {
        min-width: 50px;
      }
      
      .header-name {
        flex: 1;
      }
      
      .header-name-content {
        display: flex;
        align-items: center;
        gap: 6px;
        width: 100%;
      }
      
      .search-input {
        flex: 1;
        padding: 3px 6px;
        border: 1px solid #ced4da;
        border-radius: 3px;
        font-size: 12px;
        min-width: 100px;
      }
      
      .search-input:focus {
        outline: none;
        border-color: #007bff;
        box-shadow: 0 0 0 1px rgba(0, 123, 255, 0.2);
      }
      
      .header-actions {
        min-width: 100px;
        justify-content: center;
      }
      
      .sort-button {
        background: none;
        border: none;
        cursor: pointer;
        padding: 2px 4px;
        display: flex;
        align-items: center;
        gap: 4px;
        color: #495057;
        font-weight: 600;
        font-size: 13px;
        transition: color 0.2s;
      }
      
      .sort-button:hover {
        color: #007bff;
      }
      
      .app-title {
        display: flex;
        align-items: baseline;
        gap: 10px;
      }
      
      .customer-count {
        font-size: 14px;
        color: #666;
        font-weight: normal;
      }
      
      .customer-list {
        flex: 1;
        overflow-y: scroll;
        background-color: #fff;
        position: relative;
        min-height: 0;
      }
      
      .scroll-spacer {
        width: 100%;
        pointer-events: none;
      }
      
      .visible-rows {
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        will-change: transform;
      }
      
      .customer-row {
        display: flex;
        align-items: center;
        padding: 6px 8px;
        border-bottom: 1px solid #eee;
        gap: 8px;
        min-height: 36px;
        box-sizing: border-box;
        font-size: 13px;
      }
      
      .customer-row:last-child {
        border-bottom: none;
      }
      
      .customer-row:hover {
        background-color: #f8f9fa;
      }
      
      .customer-id {
        font-weight: bold;
        color: #666;
        min-width: 50px;
      }
      
      .customer-name {
        flex: 1;
        color: #333;
        word-wrap: break-word;
        overflow-wrap: break-word;
        hyphens: auto;
      }
      
      .customer-name-input {
        flex: 1;
        padding: 4px 6px;
        border: 2px solid #007bff;
        border-radius: 3px;
        font-size: 13px;
      }
      
      .customer-name-input:focus {
        outline: none;
        border-color: #0056b3;
      }
      
      .customer-actions {
        display: flex;
        gap: 4px;
        min-width: 100px;
        justify-content: flex-end;
      }
      
      .btn {
        padding: 4px 6px;
        border: none;
        border-radius: 3px;
        cursor: pointer;
        font-size: 13px;
        font-weight: 500;
        transition: all 0.2s;
        display: flex;
        align-items: center;
        gap: 4px;
      }
      
      .btn:hover {
        transform: translateY(-1px);
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
      }
      
      .btn-edit {
        background-color: #007bff;
        color: white;
        padding: 4px 6px;
      }
      
      .btn-edit:hover {
        background-color: #0056b3;
      }
      
      .btn-save {
        background-color: #28a745;
        color: white;
        padding: 4px 6px;
      }
      
      .btn-save:hover {
        background-color: #218838;
      }
      
      .btn-delete {
        background-color: #dc3545;
        color: white;
        padding: 4px 6px;
      }
      
      .btn-delete:hover {
        background-color: #c82333;
      }
      
      .table-footer {
        background-color: #f8f9fa;
        border-top: 2px solid #dee2e6;
      }
      
      .add-customer-form {
        display: flex;
        gap: 6px;
        padding: 6px 8px;
        align-items: center;
      }
      
      .new-customer-input {
        flex: 1;
        padding: 4px 6px;
        border: 1px solid #ddd;
        border-radius: 3px;
        font-size: 13px;
      }
      
      .new-customer-input:focus {
        outline: none;
        border-color: #007bff;
      }
      
      .btn-add {
        background-color: #28a745;
        color: white;
        padding: 4px 6px;
        min-width: 32px;
      }
      
      .btn-add:hover {
        background-color: #218838;
      }
    """ ]

handleAction :: forall m. MonadAff m => DatabaseInterface m -> Action -> ComponentM m Unit
handleAction db = case _ of
  Initialize -> do
    log "Initialize action triggered"
    handleAction db LoadCustomers
  
  LoadCustomers -> do
    log "LoadCustomers action triggered"
    customers <- H.lift $ db.getAllCustomers
    log $ "Loaded " <> show (length customers) <> " customers"
    H.modify_ _ { customers = customers }
  
  StartEdit id name -> do
    H.modify_ _ 
      { editingId = Just id
      , editingName = name
      }
  
  UpdateEditName name -> do
    H.modify_ _ { editingName = name }
  
  SaveEdit id -> do
    state <- H.get
    H.lift $ db.updateCustomerName { id, name: state.editingName }
    H.modify_ _ 
      { editingId = Nothing
      , editingName = ""
      }
    handleAction db LoadCustomers
  
  CancelEdit -> do
    H.modify_ _ 
      { editingId = Nothing
      , editingName = ""
      }
  
  UpdateNewName name -> do
    H.modify_ _ { newCustomerName = name }
  
  AddCustomer event -> do
    H.liftEffect $ Event.preventDefault event
    state <- H.get
    when (state.newCustomerName /= "") do
      let customerName = state.newCustomerName
      H.lift $ db.addNewCustomer customerName
      H.modify_ _ { newCustomerName = "" }
      handleAction db LoadCustomers
      handleAction db (ScrollToCustomer customerName)
  
  DeleteCustomer id -> do
    H.lift $ db.deleteCustomer id
    handleAction db LoadCustomers
  
  SortBy field -> do
    state <- H.get
    let
      newSortState = case state.sortState.field of
        Just currentField | currentField == field ->
          -- Same field, toggle direction
          { field: Just field, direction: toggleDirection state.sortState.direction }
        _ ->
          -- Different field or no field, start with ascending
          { field: Just field, direction: Ascending }
    H.modify_ _ { sortState = newSortState }
  
  HandleScroll event -> do
    let mbTarget = Event.target event
    case mbTarget >>= HTMLElement.fromEventTarget of
      Just element -> do
        scrollTop <- H.liftEffect $ getScrollTop element
        clientHeight <- H.liftEffect $ getClientHeight element
        H.modify_ _ 
          { scrollTop = scrollTop
          , containerHeight = clientHeight
          }
      Nothing -> pure unit
  
  ScrollToCustomer name -> do
    state <- H.get
    let filteredCustomers = filterCustomers state.searchQuery state.customers
    let sortedCustomers = applySorting state.sortState filteredCustomers
    case findIndex (\c -> c.name == name) sortedCustomers of
      Just index -> do
        -- Calculate scroll position to show customer just above footer
        let targetScrollTop = max 0.0 (toNumber index * rowHeight - state.containerHeight + rowHeight + 60.0)
        H.liftEffect $ scrollToPosition targetScrollTop
      Nothing -> pure unit
  
  UpdateSearchQuery query -> do
    H.modify_ _ { searchQuery = query }

-- FFI helpers for getting scroll properties
foreign import getScrollTop :: HTMLElement -> Effect Number
foreign import getClientHeight :: HTMLElement -> Effect Number
foreign import scrollToPosition :: Number -> Effect Unit
