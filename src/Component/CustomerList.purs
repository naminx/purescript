module Component.CustomerList where

import Prelude

import Component.Icons as Icons
import Data.Array (drop, findIndex, length, slice, snoc, sortBy, take, (!!))
import Data.Int (floor, toNumber)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String (toLower)
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
        }
    , render: render
    , eval: H.mkEval $ H.defaultEval
        { handleAction = handleAction db
        , initialize = Just Initialize
        }
    }

-- Virtual scrolling constants
rowHeight :: Number
rowHeight = 57.0 -- Height of each customer row in pixels

overscan :: Int
overscan = 5 -- Number of extra rows to render above and below visible area

-- Calculate which rows should be rendered based on scroll position
calculateVisibleRange :: State -> { start :: Int, end :: Int, totalHeight :: Number }
calculateVisibleRange state =
  let
    sortedCustomers = applySorting state.sortState state.customers
    totalRows = length sortedCustomers
    totalHeight = toNumber totalRows * rowHeight
    
    -- Use a minimum container height to ensure initial render
    effectiveHeight = max state.containerHeight 600.0
    
    -- Calculate visible range
    startIndex = floor (state.scrollTop / rowHeight) - overscan
    visibleRows = floor (effectiveHeight / rowHeight) + 1
    endIndex = startIndex + visibleRows + (overscan * 2)
    
    -- Clamp to valid range
    start = max 0 startIndex
    end = min totalRows endIndex
  in
    { start, end, totalHeight }

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
    sortedCustomers = applySorting state.sortState state.customers
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
          [ renderTableHeader state.sortState
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

renderTableHeader :: forall m. SortState -> H.ComponentHTML Action Slots m
renderTableHeader sortState =
  HH.div
    [ HP.class_ (HH.ClassName "table-header") ]
    [ HH.div
        [ HP.class_ (HH.ClassName "header-cell header-id") ]
        [ HH.button
            [ HP.class_ (HH.ClassName "sort-button")
            , HE.onClick \_ -> SortBy SortById
            ]
            [ HH.text "ID "
            , renderSortIcon SortById sortState
            ]
        ]
    , HH.div
        [ HP.class_ (HH.ClassName "header-cell header-name") ]
        [ HH.button
            [ HP.class_ (HH.ClassName "sort-button")
            , HE.onClick \_ -> SortBy SortByName
            ]
            [ HH.text "Name "
            , renderSortIcon SortByName sortState
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
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
          'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
          sans-serif;
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
      }
      
      .customer-app {
        max-width: 900px;
        margin: 0 auto;
        padding: 20px;
      }
      
      h1 {
        color: #333;
        margin-bottom: 20px;
      }
      
      .customer-list-container {
        border: 1px solid #ddd;
        border-radius: 8px;
        overflow: hidden;
        margin-bottom: 20px;
      }
      
      .table-header {
        display: flex;
        align-items: center;
        padding: 12px 15px;
        background-color: #f8f9fa;
        border-bottom: 2px solid #dee2e6;
        font-weight: 600;
        color: #495057;
        gap: 15px;
      }
      
      .header-cell {
        display: flex;
        align-items: center;
      }
      
      .header-id {
        min-width: 60px;
      }
      
      .header-name {
        flex: 1;
      }
      
      .header-actions {
        min-width: 120px;
        justify-content: center;
      }
      
      .sort-button {
        background: none;
        border: none;
        cursor: pointer;
        padding: 4px 8px;
        display: flex;
        align-items: center;
        gap: 6px;
        color: #495057;
        font-weight: 600;
        font-size: 14px;
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
        font-size: 16px;
        color: #666;
        font-weight: normal;
      }
      
      .customer-list {
        max-height: calc(80vh - 120px);
        min-height: 400px;
        overflow-y: auto;
        background-color: #fff;
        position: relative;
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
        padding: 15px;
        border-bottom: 1px solid #eee;
        gap: 15px;
        min-height: 57px;
        box-sizing: border-box;
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
        min-width: 60px;
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
        padding: 8px 12px;
        border: 2px solid #007bff;
        border-radius: 4px;
        font-size: 14px;
      }
      
      .customer-name-input:focus {
        outline: none;
        border-color: #0056b3;
      }
      
      .customer-actions {
        display: flex;
        gap: 8px;
        min-width: 120px;
        justify-content: flex-end;
      }
      
      .btn {
        padding: 8px 12px;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-size: 14px;
        font-weight: 500;
        transition: all 0.2s;
        display: flex;
        align-items: center;
        gap: 6px;
      }
      
      .btn:hover {
        transform: translateY(-1px);
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
      }
      
      .btn-edit {
        background-color: #007bff;
        color: white;
        padding: 6px 10px;
      }
      
      .btn-edit:hover {
        background-color: #0056b3;
      }
      
      .btn-save {
        background-color: #28a745;
        color: white;
        padding: 6px 10px;
      }
      
      .btn-save:hover {
        background-color: #218838;
      }
      
      .btn-delete {
        background-color: #dc3545;
        color: white;
        padding: 6px 10px;
      }
      
      .btn-delete:hover {
        background-color: #c82333;
      }
      
      .table-footer {
        background-color: #f8f9fa;
        border-top: 2px solid #dee2e6;
        position: sticky;
        bottom: 0;
        z-index: 10;
      }
      
      .add-customer-form {
        display: flex;
        gap: 10px;
        padding: 15px;
        align-items: center;
      }
      
      .new-customer-input {
        flex: 1;
        padding: 10px 15px;
        border: 2px solid #ddd;
        border-radius: 4px;
        font-size: 14px;
      }
      
      .new-customer-input:focus {
        outline: none;
        border-color: #007bff;
      }
      
      .btn-add {
        background-color: #28a745;
        color: white;
        padding: 10px 12px;
        min-width: 44px;
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
    let sortedCustomers = applySorting state.sortState state.customers
    case findIndex (\c -> c.name == name) sortedCustomers of
      Just index -> do
        -- Calculate scroll position to show customer just above footer
        let targetScrollTop = max 0.0 (toNumber index * rowHeight - state.containerHeight + rowHeight + 60.0)
        H.liftEffect $ scrollToPosition targetScrollTop
      Nothing -> pure unit

-- FFI helpers for getting scroll properties
foreign import getScrollTop :: HTMLElement -> Effect Number
foreign import getClientHeight :: HTMLElement -> Effect Number
foreign import scrollToPosition :: Number -> Effect Unit
