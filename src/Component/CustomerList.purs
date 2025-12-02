module Component.CustomerList where

import Prelude
import TextConstants (customerListConstants)

import Component.Icons as Icons
import Data.Array (drop, filter, find, findIndex, length, slice, snoc, sortBy, take, (!!), replicate, foldl, last, catMaybes, (..))
import Data.Foldable (for_)
import Data.Functor (void)
import Data.Int (ceil, floor, toNumber)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Either (Either(..))
import Data.Nullable (Nullable, toMaybe)
import Data.String (Pattern(..), contains, toLower, length, split) as String
import Data.String (Pattern(..), contains, toLower)
import Data.Number as Number
import Data.Number (abs)
import Data.String.CodeUnits (dropRight, takeRight, length) as SCU
import Database.Types (Customer, DatabaseInterface)

import Effect.Aff (Milliseconds(..), delay)
import Effect.Aff.Class (class MonadAff)
import Control.Promise (Promise, toAff)

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
import Web.UIEvent.KeyboardEvent (KeyboardEvent)
import Web.UIEvent.KeyboardEvent as KE
import Web.UIEvent.MouseEvent (MouseEvent)
import Web.UIEvent.MouseEvent as ME
import Web.Event.EventTarget (EventTarget)

-- Helper functions for Number operations
isNegative :: Number -> Boolean
isNegative n = n < 0.0

isPositive :: Number -> Boolean
isPositive n = n > 0.0

isZero :: Number -> Boolean
isZero n = n == 0.0

data SortField
  = SortById
  | SortByName
  | SortByMoneyDebit
  | SortByMoneyCredit
  | SortByGoldJewelryDebit
  | SortByGoldJewelryCredit
  | SortByGoldBar96Debit
  | SortByGoldBar96Credit
  | SortByGoldBar99Debit
  | SortByGoldBar99Credit
  | SortByUpdated

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

-- Field types for click-to-edit functionality
data EditableField
  = FieldName
  | FieldMoney
  | FieldGoldJewelryGrams
  | FieldGoldJewelryBaht
  | FieldGoldBar96Grams
  | FieldGoldBar96Baht
  | FieldGoldBar99Grams
  | FieldGoldBar99Baht

derive instance eqEditableField :: Eq EditableField

type EditState =
  { customerId :: Int
  , field :: EditableField
  , value :: String
  , originalValue :: String
  , isDebitSide :: Boolean -- For money/gold fields: true if editing from debit column
  }

-- Get current value from customer for a field
getFieldValue :: EditableField -> Customer -> String
getFieldValue FieldName c = c.name
getFieldValue FieldMoney c = formatNumberForEdit c.money
getFieldValue FieldGoldJewelryGrams c = formatNumberForEdit c.gram_jewelry
getFieldValue FieldGoldJewelryBaht c = formatNumberForEdit c.baht_jewelry
getFieldValue FieldGoldBar96Grams c = formatNumberForEdit c.gram_bar96
getFieldValue FieldGoldBar96Baht c = formatNumberForEdit c.baht_bar96
getFieldValue FieldGoldBar99Grams c = formatNumberForEdit c.gram_bar99
getFieldValue FieldGoldBar99Baht c = formatNumberForEdit c.baht_bar99

-- Get database field name for update
getDbFieldName :: EditableField -> String
getDbFieldName FieldName = "name"
getDbFieldName FieldMoney = "money"
getDbFieldName FieldGoldJewelryGrams = "gram_jewelry"
getDbFieldName FieldGoldJewelryBaht = "baht_jewelry"
getDbFieldName FieldGoldBar96Grams = "gram_bar96"
getDbFieldName FieldGoldBar96Baht = "baht_bar96"
getDbFieldName FieldGoldBar99Grams = "gram_bar99"
getDbFieldName FieldGoldBar99Baht = "baht_bar99"

-- Parse and validate field value
parseFieldValue :: EditableField -> String -> Maybe String
parseFieldValue FieldName value =
  if value == "" then Nothing else Just value
parseFieldValue FieldMoney value = parseNumber value 2
parseFieldValue FieldGoldJewelryGrams value = parseNumber value 3
parseFieldValue FieldGoldJewelryBaht value = parseNumber value 3
parseFieldValue FieldGoldBar96Grams value = parseNumber value 3
parseFieldValue FieldGoldBar96Baht value = parseNumber value 3
parseFieldValue FieldGoldBar99Grams value = parseNumber value 3
parseFieldValue FieldGoldBar99Baht value = parseNumber value 3

-- Parse a number with max decimal places
parseNumber :: String -> Int -> Maybe String
parseNumber value maxDecimals =
  case Number.fromString value of
    Nothing -> Nothing
    Just d ->
      if isNegative d then Nothing
      else
        let
          parts = String.split (Pattern ".") value
        in
          case parts of
            [ _ ] -> Just value -- No decimal point
            [ _, decimals ] ->
              if String.length decimals <= maxDecimals then Just value
              else Nothing
            _ -> Nothing

-- Extract date part from ISO timestamp (YYYY-MM-DD)
-- Input: "2024-11-18T15:30:45.123Z" -> Output: "2024-11-18"
extractDatePart :: Maybe String -> String
extractDatePart Nothing = ""
extractDatePart (Just timestamp) =
  case String.split (Pattern "T") timestamp of
    [ datePart, _ ] -> datePart
    _ -> timestamp -- Fallback to full timestamp if format is unexpected

-- Gold conversion rates (grams per baht)
gramsPerBahtJewelry :: Number
gramsPerBahtJewelry = 15.200

gramsPerBahtBar96 :: Number
gramsPerBahtBar96 = 15.244

gramsPerBahtBar99 :: Number
gramsPerBahtBar99 = 15.244

-- ============================================================================
-- CUSTOMER LIST COMPONENT WITH VIRTUAL SCROLLING
-- ============================================================================
--
-- This component manages a large list of customers with the following features:
-- 1. Virtual scrolling for performance with large datasets
-- 2. Real-time updates via polling (every 3 seconds)
-- 3. Optimistic updates for add/edit/delete operations
-- 4. Sorting by ID or Name (ascending/descending)
-- 5. Search/filter functionality
-- 6. Automatic scrolling to newly added or edited customers
--
-- KEY IMPLEMENTATION DECISIONS:
--
-- Virtual Scrolling:
-- - Only renders rows visible in the viewport plus a small overscan
-- - Maintains a height cache to calculate scroll positions accurately
-- - Handles variable row heights (e.g., multi-line text wrapping)
--
-- Scroll-to-Customer:
-- - Uses a two-phase approach: rough scroll then precise scroll
-- - Waits for row height to stabilize using requestAnimationFrame callbacks
-- - This is more reliable than fixed delays which fail with slow text wrapping
-- - Measures actual DOM heights rather than estimates
--
-- Height Cache Management:
-- - Each customer stores its own rowHeight in the record
-- - Cache is preserved across add/delete operations (stored per customer, not per index)
-- - Cache is cleared only when customer name changes (may affect text wrapping)
-- - Cache is rebuilt on-demand as rows are rendered and measured
--
-- Real-time Updates:
-- - Polls server every 3 seconds for changes
-- - Merges changes by comparing updated_at timestamps
-- - Preserves local optimistic updates until server confirms
--
-- ============================================================================

-- Text constants for internationalization
type TextConstants =
  { appTitle :: String
  , customersCount :: Int -> String
  , columnId :: String
  , columnName :: String
  , columnMoney :: String
  , columnGoldJewelry :: String
  , columnGoldBar96 :: String
  , columnGoldBar99 :: String
  , columnUpdated :: String
  , columnActions :: String
  , headerDebit :: String
  , headerCredit :: String
  , newCustomerPlaceholder :: String
  , searchPlaceholder :: String
  , deleteConfirmTitle :: String
  , deleteConfirmPrompt :: String
  , buttonConfirm :: String
  , buttonCancel :: String
  , unitGrams :: String
  , unitBaht :: String
  }

textConstants :: TextConstants
textConstants = customerListConstants

type State =
  { customers :: Array Customer
  , editing :: Maybe EditState
  , newCustomerName :: String
  , sortState :: SortState
  , scrollTop :: Number
  , containerHeight :: Number
  , searchQuery :: String
  , renderedRange :: { start :: Int, end :: Int }
  , topSpacerHeight :: Number
  , lastSyncTime :: Maybe String
  , pollingEnabled :: Boolean
  , forceRenderRange :: Boolean
  , highlightedCustomerId :: Maybe Int
  , deleteConfirmation :: Maybe { customerId :: Int, confirmCode :: Int, inputValue :: String }
  }

data Action
  = Initialize
  | LoadCustomers
  | PollForChanges
  | ApplyChanges (Array Customer)
  | StartEditField Int EditableField String Boolean
  | StartEditFieldWithEvent Int EditableField String Boolean MouseEvent
  | UpdateEditValue String
  | SaveEditField
  | SaveEditOnEnter KeyboardEvent
  | CancelEdit
  | CancelEditOnClickOutside MouseEvent
  | UpdateNewName String
  | AddCustomer Event
  | ShowDeleteConfirmation Int
  | UpdateDeleteConfirmInput String
  | ConfirmDelete Int
  | CancelDelete
  | FocusDeleteInput
  | FocusEditInput
  | SortBy SortField
  | HandleScroll Event
  | ScrollToCustomer String
  | ScrollToCustomerId Int
  | UpdateSearchQuery String
  | MeasureRenderedRows
  | UpdateRenderedRange Int Int
  | RenderAroundAndScrollTo Int

data Output = CustomerCountChanged Int

type Slots :: forall k. Row k
type Slots = ()

type ComponentM m = H.HalogenM State Action Slots Output m

component :: forall q i m. MonadAff m => DatabaseInterface m -> H.Component q i Output m
component db =
  H.mkComponent
    { initialState: \_ ->
        { customers: []
        , editing: Nothing
        , newCustomerName: ""
        , sortState: { field: Just SortByName, direction: Ascending }
        , scrollTop: 0.0
        , containerHeight: 600.0
        , searchQuery: ""
        , renderedRange: { start: 0, end: 20 }
        , topSpacerHeight: 0.0
        , lastSyncTime: Nothing
        , pollingEnabled: true
        , forceRenderRange: false
        , highlightedCustomerId: Nothing
        , deleteConfirmation: Nothing
        }
    , render: render
    , eval: H.mkEval $ H.defaultEval
        { handleAction = handleAction db
        , initialize = Just Initialize
        }
    }

-- Virtual scrolling constants
defaultRowHeight :: Number
defaultRowHeight = 37.0 -- Default height estimate for unmeasured rows (measured actual height)

overscan :: Int
overscan = 10 -- Number of extra rows to render above and below visible area

-- Helper function to merge changes into existing customers
mergeCustomers :: Array Customer -> Array Customer -> Array Customer
mergeCustomers existing changes =
  let
    -- Update existing customers or keep them as is
    -- Preserve rowHeight from existing customer unless name changed
    updated = map
      ( \c ->
          case findIndex (\ch -> ch.id == c.id) changes of
            Just idx -> case changes !! idx of
              Just changed ->
                -- If name changed, use new rowHeight (Nothing from server)
                -- Otherwise preserve existing rowHeight
                if changed.name /= c.name then changed
                else changed { rowHeight = c.rowHeight }
              Nothing -> c
            Nothing -> c
      )
      existing

    -- Add new customers that don't exist yet
    newCustomers = filter
      ( \ch ->
          case findIndex (\c -> c.id == ch.id) existing of
            Just _ -> false
            Nothing -> true
      )
      changes
  in
    updated <> newCustomers

-- Get the latest timestamp from an array of customers
getLatestTimestamp :: Array Customer -> Maybe String
getLatestTimestamp customers =
  case customers of
    [] -> Nothing
    _ ->
      let
        timestamps = catMaybes (map _.updated_at customers)
      in
        case sortBy compare timestamps of
          [] -> Nothing
          sorted -> last sorted

-- Get customer's cached height or default
getCustomerHeight :: Customer -> Number
getCustomerHeight customer =
  case customer.rowHeight of
    Just h -> h
    Nothing -> defaultRowHeight

-- Calculate total height of customers from start to end index
calculateHeightRange :: Array Customer -> Int -> Int -> Number
calculateHeightRange customers start end =
  let
    slice' = slice start end customers
  in
    foldl (\acc c -> acc + getCustomerHeight c) 0.0 slice'

-- Calculate which rows should be rendered based on scroll position
calculateVisibleRange :: State -> Array Customer -> { start :: Int, end :: Int, topSpacerHeight :: Number }
calculateVisibleRange state customers =
  let
    totalRows = length customers

    -- Find the first row that should be visible
    findStartRow :: Int -> Number -> Int
    findStartRow idx accHeight =
      if idx >= totalRows then totalRows
      else
        case customers !! idx of
          Just customer ->
            let
              rowHeight = getCustomerHeight customer
              nextHeight = accHeight + rowHeight
            in
              if nextHeight > state.scrollTop then idx
              else findStartRow (idx + 1) nextHeight
          Nothing -> totalRows

    start = max 0 (findStartRow 0 0.0 - overscan)

    -- Calculate how many rows fit in the viewport
    findEndRow :: Int -> Number -> Int
    findEndRow idx accHeight =
      if idx >= totalRows then totalRows
      else
        case customers !! idx of
          Just customer ->
            let
              rowHeight = getCustomerHeight customer
              nextHeight = accHeight + rowHeight
            in
              if nextHeight > state.containerHeight then idx + 1
              else findEndRow (idx + 1) nextHeight
          Nothing -> totalRows

    end = min totalRows (findEndRow start 0.0 + overscan)

    -- Calculate top spacer height (sum of heights before start)
    topSpacerHeight = calculateHeightRange customers 0 start
  in
    { start, end, topSpacerHeight }

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
-- Money sorting: Debit shows negative values, Credit shows positive values
-- For intuitive sorting, we compare absolute values but keep sign context
applySorting { field: Just SortByMoneyDebit, direction } customers =
  let
    -- For debit: more negative = larger debit (e.g., -30 > -20 in debit terms)
    debitValue c = if isNegative c.money then negate c.money else 0.0
    sorted = sortBy (\a b -> compare (debitValue a) (debitValue b)) customers
  in
    case direction of
      Ascending -> sorted -- Smallest debit first
      Descending -> sortBy (\a b -> compare (debitValue b) (debitValue a)) customers -- Largest debit first
applySorting { field: Just SortByMoneyCredit, direction } customers =
  let
    creditValue c = if isPositive c.money then c.money else 0.0
    sorted = sortBy (\a b -> compare (creditValue a) (creditValue b)) customers
  in
    case direction of
      Ascending -> sorted -- Smallest credit first
      Descending -> sortBy (\a b -> compare (creditValue b) (creditValue a)) customers -- Largest credit first
-- Gold Jewelry sorting
applySorting { field: Just SortByGoldJewelryDebit, direction } customers =
  let
    netWeight c = add c.gram_jewelry (mul c.baht_jewelry gramsPerBahtJewelry)
    debitValue c = if isNegative (netWeight c) then negate (netWeight c) else 0.0
    sorted = sortBy (\a b -> compare (debitValue a) (debitValue b)) customers
  in
    case direction of
      Ascending -> sorted
      Descending -> sortBy (\a b -> compare (debitValue b) (debitValue a)) customers
applySorting { field: Just SortByGoldJewelryCredit, direction } customers =
  let
    netWeight c = add c.gram_jewelry (mul c.baht_jewelry gramsPerBahtJewelry)
    creditValue c = if isPositive (netWeight c) then netWeight c else 0.0
    sorted = sortBy (\a b -> compare (creditValue a) (creditValue b)) customers
  in
    case direction of
      Ascending -> sorted
      Descending -> sortBy (\a b -> compare (creditValue b) (creditValue a)) customers
-- 96.5% Gold Bar sorting
applySorting { field: Just SortByGoldBar96Debit, direction } customers =
  let
    netWeight c = add c.gram_bar96 (mul c.baht_bar96 gramsPerBahtBar96)
    debitValue c = if isNegative (netWeight c) then negate (netWeight c) else 0.0
    sorted = sortBy (\a b -> compare (debitValue a) (debitValue b)) customers
  in
    case direction of
      Ascending -> sorted
      Descending -> sortBy (\a b -> compare (debitValue b) (debitValue a)) customers
applySorting { field: Just SortByGoldBar96Credit, direction } customers =
  let
    netWeight c = add c.gram_bar96 (mul c.baht_bar96 gramsPerBahtBar96)
    creditValue c = if isPositive (netWeight c) then netWeight c else 0.0
    sorted = sortBy (\a b -> compare (creditValue a) (creditValue b)) customers
  in
    case direction of
      Ascending -> sorted
      Descending -> sortBy (\a b -> compare (creditValue b) (creditValue a)) customers
-- 99.99% Gold Bar sorting
applySorting { field: Just SortByGoldBar99Debit, direction } customers =
  let
    netWeight c = add c.gram_bar99 (mul c.baht_bar99 gramsPerBahtBar99)
    debitValue c = if isNegative (netWeight c) then negate (netWeight c) else 0.0
    sorted = sortBy (\a b -> compare (debitValue a) (debitValue b)) customers
  in
    case direction of
      Ascending -> sorted
      Descending -> sortBy (\a b -> compare (debitValue b) (debitValue a)) customers
applySorting { field: Just SortByGoldBar99Credit, direction } customers =
  let
    netWeight c = add c.gram_bar99 (mul c.baht_bar99 gramsPerBahtBar99)
    creditValue c = if isPositive (netWeight c) then netWeight c else 0.0
    sorted = sortBy (\a b -> compare (creditValue a) (creditValue b)) customers
  in
    case direction of
      Ascending -> sorted
      Descending -> sortBy (\a b -> compare (creditValue b) (creditValue a)) customers
applySorting { field: Just SortByUpdated, direction } customers =
  let
    -- Compare only date part (YYYY-MM-DD), ignoring time
    dateOnly c = extractDatePart c.updated_at
    sorted = sortBy (\a b -> compare (dateOnly a) (dateOnly b)) customers
  in
    case direction of
      Ascending -> sorted
      Descending -> sortBy (\a b -> compare (dateOnly b) (dateOnly a)) customers

render :: forall m. State -> H.ComponentHTML Action Slots m
render state =
  let
    filteredCustomers = filterCustomers state.searchQuery state.customers
    sortedCustomers = applySorting state.sortState filteredCustomers
    totalRows = length sortedCustomers

    { start, end, topSpacerHeight } =
      if state.forceRenderRange then
        { start: state.renderedRange.start
        , end: state.renderedRange.end
        , topSpacerHeight: calculateHeightRange sortedCustomers 0 state.renderedRange.start
        }
      else
        calculateVisibleRange state sortedCustomers
    visibleCustomers = slice start end sortedCustomers

    -- Calculate total height for scroll spacer
    totalHeight = calculateHeightRange sortedCustomers 0 totalRows
  in
    HH.div
      [ HP.class_ (HH.ClassName "app-wrapper")
      , HE.onClick CancelEditOnClickOutside
      ]
      [ HH.div
          [ HP.class_ (HH.ClassName "customer-app") ]
          [ HH.div
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
                      , HP.attr (HH.AttrName "style") $ "transform: translateY(" <> show topSpacerHeight <> "px)"
                      , HP.id "visible-rows-container"
                      ]
                      (map (\c -> renderCustomerRow state c start) (visibleCustomers))
                  ]
              , renderTableFooter state
              ]
          , renderDeleteConfirmationDialog state
          , renderStyles
          ]
      ]

renderTableHeader :: forall m. State -> H.ComponentHTML Action Slots m
renderTableHeader state =
  HH.div [ HP.class_ (HH.ClassName "table-header-container") ]
    [ -- Row 1: Category headers with merged columns
      HH.div [ HP.class_ (HH.ClassName "table-header-row1") ]
        [ HH.div [ HP.class_ (HH.ClassName "header-cell header-id-row1") ] []
        , HH.div [ HP.class_ (HH.ClassName "header-cell header-name-row1") ]
            [ HH.button [ HP.class_ (HH.ClassName "sort-button"), HE.onClick \_ -> SortBy SortByName ]
                [ HH.text $ textConstants.columnName <> " ", renderSortIcon SortByName state.sortState ]
            ]
        , HH.div [ HP.class_ (HH.ClassName "header-cell header-money-merged") ]
            [ HH.text textConstants.columnMoney ]
        , HH.div [ HP.class_ (HH.ClassName "header-cell header-gold-acc-merged") ]
            [ HH.text textConstants.columnGoldJewelry ]
        , HH.div [ HP.class_ (HH.ClassName "header-cell header-gold-965-merged") ]
            [ HH.text textConstants.columnGoldBar96 ]
        , HH.div [ HP.class_ (HH.ClassName "header-cell header-gold-9999-merged") ]
            [ HH.text textConstants.columnGoldBar99 ]
        , HH.div [ HP.class_ (HH.ClassName "header-cell header-updated-row1") ] []
        , HH.div [ HP.class_ (HH.ClassName "header-cell header-actions-row1") ]
            [ HH.text textConstants.columnActions ]
        ]
    , -- Row 2: Debit/Credit sub-headers with search
      HH.div [ HP.class_ (HH.ClassName "table-header-row2") ]
        [ HH.div [ HP.class_ (HH.ClassName "header-cell header-id-row2") ]
            [ HH.button [ HP.class_ (HH.ClassName "sort-button"), HE.onClick \_ -> SortBy SortById ]
                [ HH.text $ textConstants.columnId <> " ", renderSortIcon SortById state.sortState ]
            ]
        , HH.div [ HP.class_ (HH.ClassName "header-cell header-name-row2") ]
            [ HH.input
                [ HP.type_ HP.InputText
                , HP.class_ (HH.ClassName "search-input")
                , HP.placeholder textConstants.searchPlaceholder
                , HP.value state.searchQuery
                , HE.onValueInput UpdateSearchQuery
                ]
            ]
        , HH.button [ HP.class_ (HH.ClassName "header-cell header-debit sort-button"), HE.onClick \_ -> SortBy SortByMoneyDebit ]
            [ HH.text (textConstants.headerDebit <> " "), renderSortIcon SortByMoneyDebit state.sortState ]
        , HH.button [ HP.class_ (HH.ClassName "header-cell header-credit sort-button"), HE.onClick \_ -> SortBy SortByMoneyCredit ]
            [ HH.text (textConstants.headerCredit <> " "), renderSortIcon SortByMoneyCredit state.sortState ]
        , HH.button [ HP.class_ (HH.ClassName "header-cell header-debit sort-button"), HE.onClick \_ -> SortBy SortByGoldJewelryDebit ]
            [ HH.text (textConstants.headerDebit <> " "), renderSortIcon SortByGoldJewelryDebit state.sortState ]
        , HH.button [ HP.class_ (HH.ClassName "header-cell header-credit sort-button"), HE.onClick \_ -> SortBy SortByGoldJewelryCredit ]
            [ HH.text (textConstants.headerCredit <> " "), renderSortIcon SortByGoldJewelryCredit state.sortState ]
        , HH.button [ HP.class_ (HH.ClassName "header-cell header-debit sort-button"), HE.onClick \_ -> SortBy SortByGoldBar96Debit ]
            [ HH.text (textConstants.headerDebit <> " "), renderSortIcon SortByGoldBar96Debit state.sortState ]
        , HH.button [ HP.class_ (HH.ClassName "header-cell header-credit sort-button"), HE.onClick \_ -> SortBy SortByGoldBar96Credit ]
            [ HH.text (textConstants.headerCredit <> " "), renderSortIcon SortByGoldBar96Credit state.sortState ]
        , HH.button [ HP.class_ (HH.ClassName "header-cell header-debit sort-button"), HE.onClick \_ -> SortBy SortByGoldBar99Debit ]
            [ HH.text (textConstants.headerDebit <> " "), renderSortIcon SortByGoldBar99Debit state.sortState ]
        , HH.button [ HP.class_ (HH.ClassName "header-cell header-credit sort-button"), HE.onClick \_ -> SortBy SortByGoldBar99Credit ]
            [ HH.text (textConstants.headerCredit <> " "), renderSortIcon SortByGoldBar99Credit state.sortState ]
        , HH.button
            [ HP.class_ (HH.ClassName "header-cell sort-button")
            , HE.onClick \_ -> SortBy SortByUpdated
            ]
            [ HH.text textConstants.columnUpdated, renderSortIcon SortByUpdated state.sortState ]
        , HH.div [ HP.class_ (HH.ClassName "header-cell header-actions-row2") ] []
        ]
    ]

renderSortIcon :: forall w i. SortField -> SortState -> HH.HTML w i
renderSortIcon field { field: currentField, direction } =
  case currentField of
    Just f | f == field ->
      case direction of
        Ascending -> Icons.sortAscIcon
        Descending -> Icons.sortDescIcon
    _ -> Icons.sortNeutralIcon

-- Helper to render money with smaller fraction
renderMoney :: forall w i. Number -> HH.HTML w i
renderMoney n =
  let
    absN = abs n
    formatted = formatMoneyValue absN
    isInteger = formatted.fraction == "00"
    decimalClass =
      if isInteger then "money-decimal money-decimal-zero"
      else "money-decimal"
    fractionClass =
      if isInteger then "money-fraction money-fraction-zero"
      else "money-fraction"
  in
    HH.span [ HP.class_ (HH.ClassName "money-value") ]
      [ HH.span [ HP.class_ (HH.ClassName "money-integer") ] [ HH.text formatted.integer ]
      , HH.span [ HP.class_ (HH.ClassName decimalClass) ] [ HH.text "." ]
      , HH.span [ HP.class_ (HH.ClassName fractionClass) ] [ HH.text formatted.fraction ]
      ]

-- Helper to render grams weight with smaller fraction
renderGrams :: forall w i. Number -> HH.HTML w i
renderGrams n =
  let
    absN = abs n
    formatted = formatGramsValue absN
  in
    if formatted.integer == "" then HH.text ""
    else HH.span [ HP.class_ (HH.ClassName "grams-value") ]
      [ HH.span [ HP.class_ (HH.ClassName "grams-integer") ] [ HH.text formatted.integer ]
      , HH.span [ HP.class_ (HH.ClassName "grams-decimal") ] [ HH.text "." ]
      , HH.span [ HP.class_ (HH.ClassName "grams-fraction") ] [ HH.text formatted.fraction ]
      , HH.span [ HP.class_ (HH.ClassName "grams-unit") ] [ HH.text textConstants.unitGrams ]
      ]

-- Helper to render baht weight with smaller fraction
renderBaht :: forall w i. Number -> HH.HTML w i
renderBaht n =
  let
    absN = abs n
    formatted = formatBahtValue absN
  in
    if formatted.integer == "" then HH.text ""
    else HH.span [ HP.class_ (HH.ClassName "baht-value") ]
      [ HH.span [ HP.class_ (HH.ClassName "baht-integer") ] [ HH.text formatted.integer ]
      , if formatted.hasFraction then HH.span [ HP.class_ (HH.ClassName "baht-fraction") ] [ HH.text formatted.fraction ]
        else HH.text ""
      , HH.span [ HP.class_ (HH.ClassName "baht-unit") ] [ HH.text textConstants.unitBaht ]
      ]

-- Helper to trim trailing zeros from string
trimTrailingZeros :: String -> String
trimTrailingZeros s =
  let
    len = SCU.length s
  in
    if len == 0 then s
    else if SCU.takeRight 1 s == "0" then trimTrailingZeros (SCU.dropRight 1 s)
    else s

-- Format Number for editing (remove trailing zeros and decimal point if integer)
formatNumberForEdit :: Number -> String
formatNumberForEdit n =
  let
    str = show n
    trimmed = trimTrailingZeros str
  in
    if SCU.takeRight 1 trimmed == "." then SCU.dropRight 1 trimmed
    else trimmed

-- Render an editable field (text or number)
renderEditableField :: forall m. State -> Customer -> EditableField -> String -> String -> H.ComponentHTML Action Slots m
renderEditableField state customer field displayClass inputClass =
  let
    isEditing = case state.editing of
      Just edit -> edit.customerId == customer.id && edit.field == field
      Nothing -> false
    currentValue = getFieldValue field customer
    editValue = case state.editing of
      Just edit | edit.customerId == customer.id && edit.field == field -> edit.value
      _ -> currentValue
  in
    if isEditing then
      HH.input
        [ HP.type_ HP.InputText
        , HP.class_ (HH.ClassName inputClass)
        , HP.value editValue
        , HE.onValueInput UpdateEditValue
        , HE.onBlur \_ -> CancelEdit
        , HE.onKeyDown SaveEditOnEnter
        ]
    else
      HH.span
        [ HP.class_ (HH.ClassName displayClass)
        , HE.onClick \e -> StartEditFieldWithEvent customer.id field currentValue false e
        ]
        [ HH.text currentValue ]

-- Render gold field (grams or baht) with debit/credit display
renderGoldField :: forall m. State -> Customer -> EditableField -> Boolean -> String -> (Number -> H.ComponentHTML Action Slots m) -> Number -> H.ComponentHTML Action Slots m
renderGoldField state customer field isDebit unit renderer value =
  let
    -- Check if THIS specific side is being edited
    isEditingThisSide = case state.editing of
      Just edit -> edit.customerId == customer.id && edit.field == field && edit.isDebitSide == isDebit
      Nothing -> false
    -- Check if the OPPOSITE side is being edited (for warning highlight)
    isEditingOppositeSide = case state.editing of
      Just edit -> edit.customerId == customer.id && edit.field == field && edit.isDebitSide /= isDebit
      Nothing -> false
    absValue = abs value
    -- Only show value if it's on the correct side, otherwise blank
    shouldShowValue = if isDebit then (<=) value 0.0 else (>=) value 0.0
    displayValue = if shouldShowValue && (>) absValue 0.0 then formatNumberForEdit absValue else ""
    editValue = case state.editing of
      Just edit | edit.customerId == customer.id && edit.field == field && edit.isDebitSide == isDebit -> edit.value
      _ -> displayValue
    baseClassName = if isDebit then "customer-gold-debit" else "customer-gold-credit"
    -- Add warning class if opposite side is being edited and this side has a value on the correct side
    className =
      if isEditingOppositeSide && shouldShowValue && (>) absValue 0.0 then baseClassName <> " field-warning"
      else baseClassName
  in
    if isEditingThisSide then
      HH.div [ HP.class_ (HH.ClassName (baseClassName <> " gold-input-container")) ]
        [ HH.input
            [ HP.type_ HP.InputText
            , HP.class_ (HH.ClassName "gold-input")
            , HP.value editValue
            , HE.onValueInput UpdateEditValue
            , HE.onBlur \_ -> CancelEdit
            , HE.onKeyDown SaveEditOnEnter
            ]
        , HH.span [ HP.class_ (HH.ClassName "gold-unit") ] [ HH.text unit ]
        ]
    else
      HH.div
        [ HP.class_ (HH.ClassName (className <> " editable-field"))
        , HE.onClick \e -> StartEditFieldWithEvent customer.id field displayValue isDebit e
        ]
        [ if shouldShowValue && (>) absValue 0.0 then renderer value
          else HH.text " " -- Space to make cell clickable
        ]

-- Render money field with debit/credit display
-- User always enters positive numbers, we handle the sign based on column
renderMoneyField :: forall m. State -> Customer -> Boolean -> H.ComponentHTML Action Slots m
renderMoneyField state customer isDebit =
  let
    -- Check if THIS specific side is being edited
    isEditingThisSide = case state.editing of
      Just edit -> edit.customerId == customer.id && edit.field == FieldMoney && edit.isDebitSide == isDebit
      Nothing -> false
    -- Check if the OPPOSITE side is being edited (for warning highlight)
    isEditingOppositeSide = case state.editing of
      Just edit -> edit.customerId == customer.id && edit.field == FieldMoney && edit.isDebitSide /= isDebit
      Nothing -> false
    value = customer.money
    absValue = abs value
    -- Only show value if it's on the correct side, otherwise blank
    shouldShowValue = if isDebit then (<=) value 0.0 else (>=) value 0.0
    displayValue = if shouldShowValue && (>) absValue 0.0 then formatNumberForEdit absValue else ""
    editValue = case state.editing of
      Just edit | edit.customerId == customer.id && edit.field == FieldMoney && edit.isDebitSide == isDebit -> edit.value
      _ -> displayValue
    baseClassName = if isDebit then "customer-money-debit" else "customer-money-credit"
    -- Add warning class if opposite side is being edited and this side has a value on the correct side
    className =
      if isEditingOppositeSide && shouldShowValue && (>) absValue 0.0 then baseClassName <> " field-warning"
      else baseClassName
  in
    if isEditingThisSide then
      HH.span [ HP.class_ (HH.ClassName baseClassName) ]
        [ HH.input
            [ HP.type_ HP.InputText
            , HP.class_ (HH.ClassName "money-input")
            , HP.value editValue
            , HE.onValueInput UpdateEditValue
            , HE.onBlur \_ -> CancelEdit
            , HE.onKeyDown SaveEditOnEnter
            ]
        ]
    else
      HH.span
        [ HP.class_ (HH.ClassName (className <> " editable-field"))
        , HE.onClick \e -> StartEditFieldWithEvent customer.id FieldMoney displayValue isDebit e
        ]
        [ if shouldShowValue && (>) absValue 0.0 then renderMoney value
          else HH.text " " -- Space to make cell clickable
        ]

renderCustomerRow :: forall m. State -> Customer -> Int -> H.ComponentHTML Action Slots m
renderCustomerRow state customer startIdx =
  let
    isEditingField field = case state.editing of
      Just edit -> edit.customerId == customer.id && edit.field == field
      Nothing -> false
    isHighlighted = state.highlightedCustomerId == Just customer.id
    isPendingDelete = case state.deleteConfirmation of
      Just conf -> conf.customerId == customer.id
      Nothing -> false
    -- Find the actual index of this customer in the sorted list
    filteredCustomers = filterCustomers state.searchQuery state.customers
    sortedCustomers = applySorting state.sortState filteredCustomers
    customerIndex = case findIndex (\c -> c.id == customer.id) sortedCustomers of
      Just idx -> idx
      Nothing -> 0
    isEvenRow = (customerIndex `mod` 2) == 0
    rowClasses =
      if isPendingDelete then "customer-row customer-row-pending-delete"
      else if isHighlighted then "customer-row customer-row-highlighted"
      else if isEvenRow then "customer-row customer-row-even"
      else "customer-row customer-row-odd"
  in
    HH.div
      [ HP.class_ (HH.ClassName rowClasses)
      , HP.attr (HH.AttrName "data-row-index") (show customerIndex)
      , HP.attr (HH.AttrName "data-customer-id") (show customer.id)
      ]
      [ -- ID column
        HH.span [ HP.class_ (HH.ClassName "customer-id") ]
          [ HH.text $ show customer.id ]
      , -- Name column
        renderEditableField state customer FieldName "customer-name" "customer-name-input"
      , -- Money Debit column
        renderMoneyField state customer true
      , -- Money Credit column
        renderMoneyField state customer false
      , -- Gold Jewelry Debit column
        HH.div [ HP.class_ (HH.ClassName "customer-gold-debit") ]
          [ HH.div_
              [ HH.div [ HP.class_ (HH.ClassName "gold-grams") ]
                  [ renderGoldField state customer FieldGoldJewelryGrams true textConstants.unitGrams renderGrams customer.gram_jewelry ]
              , HH.div [ HP.class_ (HH.ClassName "gold-baht") ]
                  [ renderGoldField state customer FieldGoldJewelryBaht true textConstants.unitBaht renderBaht customer.baht_jewelry ]
              ]
          ]
      , -- Gold Jewelry Credit column
        HH.div [ HP.class_ (HH.ClassName "customer-gold-credit") ]
          [ HH.div_
              [ HH.div [ HP.class_ (HH.ClassName "gold-grams") ]
                  [ renderGoldField state customer FieldGoldJewelryGrams false textConstants.unitGrams renderGrams customer.gram_jewelry ]
              , HH.div [ HP.class_ (HH.ClassName "gold-baht") ]
                  [ renderGoldField state customer FieldGoldJewelryBaht false textConstants.unitBaht renderBaht customer.baht_jewelry ]
              ]
          ]
      , -- 96.5% Gold Bar Debit column
        HH.div [ HP.class_ (HH.ClassName "customer-gold-debit") ]
          [ HH.div_
              [ HH.div [ HP.class_ (HH.ClassName "gold-grams") ]
                  [ renderGoldField state customer FieldGoldBar96Grams true textConstants.unitGrams renderGrams customer.gram_bar96 ]
              , HH.div [ HP.class_ (HH.ClassName "gold-baht") ]
                  [ renderGoldField state customer FieldGoldBar96Baht true textConstants.unitBaht renderBaht customer.baht_bar96 ]
              ]
          ]
      , -- 96.5% Gold Bar Credit column
        HH.div [ HP.class_ (HH.ClassName "customer-gold-credit") ]
          [ HH.div_
              [ HH.div [ HP.class_ (HH.ClassName "gold-grams") ]
                  [ renderGoldField state customer FieldGoldBar96Grams false textConstants.unitGrams renderGrams customer.gram_bar96 ]
              , HH.div [ HP.class_ (HH.ClassName "gold-baht") ]
                  [ renderGoldField state customer FieldGoldBar96Baht false textConstants.unitBaht renderBaht customer.baht_bar96 ]
              ]
          ]
      , -- 99.99% Gold Bar Debit column
        HH.div [ HP.class_ (HH.ClassName "customer-gold-debit") ]
          [ HH.div_
              [ HH.div [ HP.class_ (HH.ClassName "gold-grams") ]
                  [ renderGoldField state customer FieldGoldBar99Grams true textConstants.unitGrams renderGrams customer.gram_bar99 ]
              , HH.div [ HP.class_ (HH.ClassName "gold-baht") ]
                  [ renderGoldField state customer FieldGoldBar99Baht true textConstants.unitBaht renderBaht customer.baht_bar99 ]
              ]
          ]
      , -- 99.99% Gold Bar Credit column
        HH.div [ HP.class_ (HH.ClassName "customer-gold-credit") ]
          [ HH.div_
              [ HH.div [ HP.class_ (HH.ClassName "gold-grams") ]
                  [ renderGoldField state customer FieldGoldBar99Grams false textConstants.unitGrams renderGrams customer.gram_bar99 ]
              , HH.div [ HP.class_ (HH.ClassName "gold-baht") ]
                  [ renderGoldField state customer FieldGoldBar99Baht false textConstants.unitBaht renderBaht customer.baht_bar99 ]
              ]
          ]
      , -- Updated column
        HH.span [ HP.class_ (HH.ClassName "customer-updated") ]
          [ HH.text $ case customer.updated_at of
              Just dateStr -> formatDateString dateStr
              Nothing -> ""
          ]
      , -- Actions column
        HH.div [ HP.class_ (HH.ClassName "customer-actions") ]
          [ HH.button [ HP.class_ (HH.ClassName "btn btn-delete"), HE.onClick \_ -> ShowDeleteConfirmation customer.id, HP.title "Delete" ]
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
            , HP.placeholder textConstants.newCustomerPlaceholder
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

renderDeleteConfirmationDialog :: forall m. State -> H.ComponentHTML Action Slots m
renderDeleteConfirmationDialog state =
  case state.deleteConfirmation of
    Nothing -> HH.text ""
    Just confirmation ->
      HH.div
        [ HP.class_ (HH.ClassName "modal-overlay") ]
        [ HH.div
            [ HP.class_ (HH.ClassName "modal-dialog") ]
            [ HH.h2
                [ HP.class_ (HH.ClassName "modal-title") ]
                [ HH.text textConstants.deleteConfirmTitle ]
            , HH.p
                [ HP.class_ (HH.ClassName "modal-message") ]
                [ HH.text $ textConstants.deleteConfirmPrompt ]
            , HH.div
                [ HP.class_ (HH.ClassName "modal-code") ]
                [ HH.text $ show confirmation.confirmCode ]
            , HH.input
                [ HP.type_ HP.InputText
                , HP.class_ (HH.ClassName "modal-input")
                , HP.placeholder textConstants.deleteConfirmPrompt
                , HP.value confirmation.inputValue
                , HE.onValueInput UpdateDeleteConfirmInput
                , HE.onKeyDown \e ->
                    if KE.key e == "Enter" then
                      ConfirmDelete confirmation.customerId
                    else if KE.key e == "Escape" then
                      CancelDelete
                    else
                      UpdateDeleteConfirmInput confirmation.inputValue -- No-op for other keys
                ]
            , HH.div
                [ HP.class_ (HH.ClassName "modal-buttons") ]
                [ HH.button
                    [ HP.class_ (HH.ClassName "btn btn-confirm")
                    , HE.onClick \_ -> ConfirmDelete confirmation.customerId
                    ]
                    [ HH.text textConstants.buttonConfirm ]
                , HH.button
                    [ HP.class_ (HH.ClassName "btn btn-cancel")
                    , HE.onClick \_ -> CancelDelete
                    ]
                    [ HH.text textConstants.buttonCancel ]
                ]
            ]
        ]

renderStyles :: forall w i. HH.HTML w i
renderStyles =
  HH.style_
    [ HH.text
        """
      * {
        box-sizing: border-box;
      }
      
      body {
        margin: 0;
        padding: 0;
        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
          'Ubuntu', 'Cantarell', 'Fira Sans', 'DroidSans', 'Helvetica Neue',
          sans-serif;
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
        overflow: hidden;
        height: 100vh;
      }
      
      .app-wrapper {
        width: 100%;
        height: 100vh;
        overflow: hidden;
      }
      
      .customer-app {
        width: 100%;
        padding: 8px;
        height: calc(100vh - 38px);
        display: flex;
        flex-direction: column;
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
      
      .table-header-container {
        background-color: #f8f9fa;
        border-bottom: 2px solid #dee2e6;
      }
      
      .table-header-row1,
      .table-header-row2 {
        display: grid;
        grid-template-columns: 50px 200px 90px 90px 100px 100px 100px 100px 100px 100px 90px 100px;
        align-items: center;
        padding: 4px 8px;
        font-weight: 600;
        color: #495057;
        gap: 8px;
        font-size: 12px;
        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
      }
      
      .table-header-row1 {
        border-bottom: 1px solid #dee2e6;
      }
      
      .table-header-row1 .header-cell {
        justify-content: center;
      }
      
      .header-money-merged {
        grid-column: span 2;
        text-align: center;
      }
      
      .header-gold-acc-merged {
        grid-column: span 2;
        text-align: center;
      }
      
      .header-gold-965-merged {
        grid-column: span 2;
        text-align: center;
      }
      
      .header-gold-9999-merged {
        grid-column: span 2;
        text-align: center;
      }
      
      .header-cell {
        display: flex;
        align-items: center;
        padding: 2px;
        border-right: 1px solid #dee2e6;
      }
      
      .header-cell:last-child {
        border-right: none;
      }
      
      .header-debit,
      .header-credit {
        justify-content: flex-end;
      }
      
      .header-id {
        min-width: 50px;
      }
      
      .header-name {
        min-width: 150px;
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
        min-width: 80px;
        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
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
        font-size: 12px;
        transition: color 0.2s;
        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
      }
      
      .sort-button:hover {
        color: #007bff;
      }
      
      .customer-list {
        flex: 1;
        overflow-y: scroll;
        overflow-x: auto;
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
        display: grid;
        grid-template-columns: 50px 200px 90px 90px 100px 100px 100px 100px 100px 100px 90px 100px;
        align-items: center;
        padding: 6px 8px;
        border-bottom: 1px solid #eee;
        gap: 8px;
        min-height: 36px;
        box-sizing: border-box;
        font-size: 12px;
      }
      
      .customer-row > * {
        border-right: 1px solid #eee;
        padding-right: 8px;
      }
      
      .customer-row > *:last-child {
        border-right: none;
      }
      
      .customer-row:last-child {
        border-bottom: none;
      }
      
      .customer-row-even {
        background-color: #ffffff;
      }
      
      .customer-row-odd {
        background-color: #f9f9f9;
      }
      
      .customer-row:hover {
        background-color: #f0f0f0 !important;
      }
      
      .customer-row-highlighted {
        background-color: #f5e6d3 !important;
        transition: background-color 0.3s ease;
      }
      
      .customer-row-highlighted:hover {
        background-color: #ead5bb !important;
      }
      
      .customer-row-pending-delete {
        background-color: #d4a59a !important;
        transition: background-color 0.3s ease;
      }
      
      .customer-row-pending-delete:hover {
        background-color: #c99388 !important;
      }
      
      .customer-id {
        font-weight: bold;
        color: #666;
        padding: 2px;
        text-align: right;
      }
      
      .customer-name {
        color: #333;
        word-wrap: break-word;
        overflow-wrap: break-word;
        hyphens: auto;
        padding: 2px;
        cursor: pointer;
        border-radius: 3px;
        transition: background-color 0.2s ease;
      }
      
      .customer-name:hover {
        background-color: #e3f2fd;
        box-shadow: 0 0 0 1px #90caf9;
      }
      
      .editable-field {
        cursor: pointer;
        border-radius: 3px;
        transition: background-color 0.2s ease;
        padding: 2px 4px;
        min-height: 20px;
        display: inline-block;
      }
      
      .editable-field:hover {
        background-color: #e3f2fd;
        box-shadow: 0 0 0 1px #90caf9;
      }
      
      .gold-grams .editable-field,
      .gold-baht .editable-field {
        display: block;
        width: 100%;
        box-sizing: border-box;
      }
      
      .field-warning {
        background-color: #d4a59a !important;
        animation: pulse-warning 1s ease-in-out infinite;
      }
      
      @keyframes pulse-warning {
        0%, 100% {
          background-color: #d4a59a;
        }
        50% {
          background-color: #c99388;
        }
      }
      
      .money-input {
        width: 80px;
        padding: 2px 4px;
        border: 2px solid #007bff;
        border-radius: 3px;
        font-size: 12px;
        text-align: right;
        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
      }
      
      .gold-input-container {
        display: flex;
        align-items: center;
        gap: 4px;
      }
      
      .gold-input {
        width: 70px;
        padding: 2px 4px;
        border: 2px solid #007bff;
        border-radius: 3px;
        font-size: 12px;
        text-align: right;
        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
      }
      
      .gold-unit {
        font-size: 12px;
        color: #666;
        font-weight: 500;
      }
      
      .customer-name-input {
        width: 100%;
        padding: 4px 6px;
        border: 2px solid #007bff;
        border-radius: 3px;
        font-size: 12px;
        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
      }
      
      .customer-name-input:focus {
        outline: none;
        border-color: #0056b3;
      }
      
      .customer-money-debit,
      .customer-money-credit {
        text-align: right;
        padding: 2px 4px;
        color: #333;
      }
      
      .customer-money-debit {
        color: #dc3545;
      }
      
      .customer-money-credit {
        color: #28a745;
      }
      
      .money-value {
        white-space: nowrap;
      }
      
      .money-integer {
        font-size: 12px;
      }
      
      .money-decimal,
      .money-fraction {
        font-size: 9px;
        vertical-align: baseline;
      }
      
      /* Make .00 fraction and decimal point blend with background for right alignment */
      .money-decimal-zero,
      .money-fraction-zero {
        color: transparent;
      }
      
      /* Default row backgrounds */
      .customer-row-even .money-decimal-zero,
      .customer-row-even .money-fraction-zero {
        color: #ffffff;
      }
      
      .customer-row-odd .money-decimal-zero,
      .customer-row-odd .money-fraction-zero {
        color: #f9f9f9;
      }
      
      /* Hover state */
      .customer-row:hover .money-decimal-zero,
      .customer-row:hover .money-fraction-zero {
        color: #f0f0f0;
      }
      
      /* Highlighted row (newly added/edited) */
      .customer-row-highlighted .money-decimal-zero,
      .customer-row-highlighted .money-fraction-zero {
        color: #f5e6d3;
      }
      
      .customer-row-highlighted:hover .money-decimal-zero,
      .customer-row-highlighted:hover .money-fraction-zero {
        color: #ead5bb;
      }
      
      /* Pending delete row */
      .customer-row-pending-delete .money-decimal-zero,
      .customer-row-pending-delete .money-fraction-zero {
        color: #d4a59a;
      }
      
      .customer-row-pending-delete:hover .money-decimal-zero,
      .customer-row-pending-delete:hover .money-fraction-zero {
        color: #c99388;
      }
      
      /* Warning field (opposite side being edited) */
      .field-warning .money-decimal-zero,
      .field-warning .money-fraction-zero {
        color: #d4a59a;
        animation: pulse-warning-text 1s ease-in-out infinite;
      }
      
      @keyframes pulse-warning-text {
        0%, 100% {
          color: #d4a59a;
        }
        50% {
          color: #c99388;
        }
      }
      
      .customer-gold-debit,
      .customer-gold-credit {
        text-align: right;
        padding: 2px 4px;
        font-size: 12px;
        line-height: 1.3;
      }
      
      .customer-gold-debit {
        color: #dc3545;
      }
      
      .customer-gold-credit {
        color: #28a745;
      }
      
      .gold-grams {
        font-weight: 500;
      }
      
      .gold-baht {
        font-size: 12px;
      }
      
      .customer-gold-debit .gold-baht {
        color: #dc3545;
      }
      
      .customer-gold-credit .gold-baht {
        color: #28a745;
      }
      
      .baht-value {
        white-space: nowrap;
        font-size: 12px;
      }
      
      .baht-integer,
      .baht-unit {
        font-size: 12px;
      }
      
      .baht-fraction {
        font-size: 12px;
        vertical-align: baseline;
      }
      
      .grams-value {
        white-space: nowrap;
      }
      
      .grams-integer,
      .grams-unit {
        font-size: 12px;
      }
      
      .grams-decimal,
      .grams-fraction {
        font-size: 12px;
        vertical-align: baseline;
      }
      
      .customer-updated {
        font-size: 12px;
        color: #666;
        padding: 2px;
        text-align: center;
      }
      
      .customer-actions {
        display: flex;
        gap: 4px;
        justify-content: center;
      }
      
      .btn {
        padding: 4px 6px;
        border: none;
        border-radius: 3px;
        cursor: pointer;
        font-size: 12px;
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
        font-size: 12px;
        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
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
      
      /* Modal Dialog Styles */
      .modal-overlay {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: rgba(0, 0, 0, 0.5);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 1000;
      }
      
      .modal-dialog {
        background: white;
        border-radius: 8px;
        padding: 24px;
        max-width: 400px;
        width: 90%;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
      }
      
      .modal-title {
        margin: 0 0 16px 0;
        font-size: 20px;
        font-weight: 600;
        color: #333;
      }
      
      .modal-message {
        margin: 0 0 16px 0;
        color: #666;
        line-height: 1.5;
      }
      
      .modal-code {
        background: #f8f9fa;
        border: 2px solid #dee2e6;
        border-radius: 4px;
        padding: 16px;
        text-align: center;
        font-size: 24px;
        font-weight: 700;
        color: #dc3545;
        margin-bottom: 16px;
        letter-spacing: 2px;
        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
      }
      
      .modal-input {
        width: 100%;
        padding: 12px;
        border: 2px solid #dee2e6;
        border-radius: 4px;
        font-size: 16px;
        margin-bottom: 16px;
        text-align: center;
        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
        letter-spacing: 1px;
      }
      
      .modal-input:focus {
        outline: none;
        border-color: #0056b3;
      }
      
      .modal-buttons {
        display: flex;
        gap: 12px;
        justify-content: flex-end;
      }
      
      .btn-confirm {
        background-color: #dc3545;
        color: white;
        padding: 10px 20px;
        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
      }
      
      .btn-confirm:hover {
        background-color: #c82333;
      }
      
      .btn-cancel {
        background-color: #6c757d;
        color: white;
        padding: 10px 20px;
        font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
      }
      
      .btn-cancel:hover {
        background-color: #5a6268;
      }
    """
    ]

handleAction :: forall m. MonadAff m => DatabaseInterface m -> Action -> ComponentM m Unit
handleAction db = case _ of
  Initialize -> do
    handleAction db LoadCustomers

  LoadCustomers -> do
    customers <- H.lift $ db.getAllCustomers
    let latestTime = getLatestTimestamp customers
    H.modify_ _
      { customers = customers
      , lastSyncTime = latestTime
      }
    H.raise $ CustomerCountChanged (length customers)
    handleAction db PollForChanges

  PollForChanges -> do
    state <- H.get
    when state.pollingEnabled do
      case state.lastSyncTime of
        Just since -> do
          changes <- H.lift $ db.getChangesSince since
          when (length changes > 0) do
            handleAction db (ApplyChanges changes)
        Nothing -> pure unit

      -- Schedule next poll in 3 seconds (intentional throttling)
      void $ H.fork do
        H.liftAff $ delay (Milliseconds 3000.0)
        handleAction db PollForChanges

  ApplyChanges changes -> do
    state <- H.get
    let mergedCustomers = mergeCustomers state.customers changes
    let latestTime = getLatestTimestamp changes
    H.modify_ _
      { customers = mergedCustomers
      , lastSyncTime = latestTime
      }
    -- Trigger measurement for any new/updated rows after next frame
    void $ H.fork do
      promise <- H.liftEffect $ requestAnimationFrameAction unit
      void $ H.liftAff $ toAff promise
      handleAction db MeasureRenderedRows

  StartEditFieldWithEvent customerId field value isDebitSide mouseEvent -> do
    -- Stop event propagation to prevent CancelEditOnClickOutside from firing
    H.liftEffect $ Event.stopPropagation (ME.toEvent mouseEvent)
    handleAction db (StartEditField customerId field value isDebitSide)

  StartEditField customerId field value isDebitSide -> do
    state <- H.get
    -- If already editing, save it first
    case state.editing of
      Just edit | edit.customerId /= customerId || edit.field /= field -> do
        handleAction db SaveEditField
      _ -> pure unit
    -- Start editing the new field
    H.modify_ _
      { editing = Just { customerId, field, value, originalValue: value, isDebitSide }
      }
    -- Focus the input (uses requestAnimationFrame internally)
    handleAction db FocusEditInput

  UpdateEditValue value -> do
    state <- H.get
    case state.editing of
      Just edit -> H.modify_ _ { editing = Just (edit { value = value }) }
      Nothing -> pure unit

  SaveEditField -> do
    state <- H.get
    case state.editing of
      Nothing -> pure unit
      Just edit -> do
        let valueChanged = edit.value /= edit.originalValue
        -- Validate the value
        case parseFieldValue edit.field edit.value of
          Nothing -> do
            -- Invalid value, cancel edit
            handleAction db CancelEdit
          Just validValue -> do
            -- For money field, apply sign based on debit/credit side
            let
              finalValue = case edit.field of
                FieldMoney ->
                  if edit.isDebitSide then "-" <> validValue -- Debit is negative
                  else validValue -- Credit is positive
                _ ->
                  if edit.isDebitSide then "-" <> validValue -- Gold debit is negative
                  else validValue -- Gold credit is positive
            -- Update the database
            updatedCustomer <- H.lift $ db.updateCustomerField
              { id: edit.customerId
              , field: getDbFieldName edit.field
              , value: finalValue
              }
            H.modify_ _
              { editing = Nothing
              , searchQuery = "" -- Clear search to ensure edited customer is visible
              , customers = map (\c -> if c.id == edit.customerId then updatedCustomer else c) state.customers
              , lastSyncTime = updatedCustomer.updated_at
              , highlightedCustomerId = if valueChanged then Just edit.customerId else Nothing
              }
            when valueChanged do
              handleAction db (RenderAroundAndScrollTo edit.customerId)

  SaveEditOnEnter kbEvent -> do
    case KE.key kbEvent of
      "Enter" -> handleAction db SaveEditField
      "Escape" -> handleAction db CancelEdit
      _ -> pure unit

  CancelEdit -> do
    H.modify_ _ { editing = Nothing }

  CancelEditOnClickOutside mouseEvent -> do
    state <- H.get
    case state.editing of
      Just _ -> do
        -- Check if click target is outside the input
        let eventTarget = ME.toEvent mouseEvent
        case Event.target eventTarget of
          Just target -> do
            isOutside <- H.liftEffect $ checkClickOutsideInput target
            when isOutside do
              handleAction db SaveEditField
          Nothing -> pure unit
      Nothing -> pure unit

  UpdateNewName name -> do
    H.modify_ _ { newCustomerName = name }

  AddCustomer event -> do
    H.liftEffect $ Event.preventDefault event
    state <- H.get
    when (state.newCustomerName /= "") do
      let customerName = state.newCustomerName
      newCustomer <- H.lift $ db.addNewCustomer customerName
      H.modify_ _
        { newCustomerName = ""
        , searchQuery = "" -- Clear search to ensure new customer is visible
        , customers = snoc state.customers newCustomer
        , lastSyncTime = newCustomer.updated_at
        , highlightedCustomerId = Just newCustomer.id
        }
      handleAction db (RenderAroundAndScrollTo newCustomer.id)

  ShowDeleteConfirmation id -> do
    -- Generate random 6-digit number (100000 to 999999)
    randomCode <- H.liftEffect generateRandomCode
    H.modify_ _ { deleteConfirmation = Just { customerId: id, confirmCode: randomCode, inputValue: "" } }
    -- Focus the input (uses requestAnimationFrame internally)
    handleAction db FocusDeleteInput

  UpdateDeleteConfirmInput value -> do
    state <- H.get
    case state.deleteConfirmation of
      Just confirmation ->
        H.modify_ _ { deleteConfirmation = Just (confirmation { inputValue = value }) }
      Nothing -> pure unit

  ConfirmDelete id -> do
    state <- H.get
    case state.deleteConfirmation of
      Just confirmation | confirmation.customerId == id ->
        if confirmation.inputValue == show confirmation.confirmCode then do
          -- Correct code, proceed with deletion
          H.lift $ db.deleteCustomer id
          let newCustomers = filter (\c -> c.id /= id) state.customers
          H.modify_ _
            { customers = newCustomers
            , highlightedCustomerId = Nothing
            , deleteConfirmation = Nothing
            }
          -- Trigger a scroll event to recalculate visible range and fill viewport
          void $ H.fork do
            mbContainer <- H.liftEffect getCustomerListElement
            case mbContainer of
              Just element -> do
                scrollTop <- H.liftEffect $ getScrollTop element
                clientHeight <- H.liftEffect $ getClientHeight element
                H.modify_ _
                  { scrollTop = scrollTop
                  , containerHeight = clientHeight
                  }
                handleAction db MeasureRenderedRows
              Nothing -> pure unit
        else
          -- Wrong code, do nothing (keep dialog open)
          pure unit
      _ -> pure unit

  CancelDelete -> do
    H.modify_ _ { deleteConfirmation = Nothing }

  FocusDeleteInput -> do
    H.liftEffect focusDeleteConfirmInput

  FocusEditInput -> do
    H.liftEffect focusEditInput

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
        handleAction db MeasureRenderedRows
      Nothing -> pure unit

  MeasureRenderedRows -> do
    measurements <- H.liftEffect measureRowHeights
    state <- H.get
    let
      -- Update customer rowHeight by ID
      updateCustomer :: Customer -> Customer
      updateCustomer customer =
        case find (\m -> m.customerId == customer.id) measurements of
          Just measurement -> customer { rowHeight = Just measurement.height }
          Nothing -> customer

      updatedCustomers = map updateCustomer state.customers

    H.modify_ _ { customers = updatedCustomers }

  UpdateRenderedRange start end -> do
    H.modify_ _ { renderedRange = { start, end } }

  -- Scroll to a specific customer by ID
  -- This action is called after adding or editing a customer to ensure it's visible
  -- 
  -- Implementation notes:
  -- - We use a two-phase scroll approach: rough scroll then precise scroll
  -- - The rough scroll gets the row into the viewport so it can be measured
  -- - We use waitForRowAndMeasureImpl which waits for the row height to stabilize
  --   across multiple animation frames (important for multi-line text wrapping)
  -- - Once stable, we scroll to the exact position
  --
  -- Why this approach:
  -- - Initial attempts used delays (100ms, 300ms) but these were unreliable
  -- - Text wrapping takes variable time depending on content length and viewport width
  -- - The callback-based approach with stability checking is deterministic
  -- - We measure actual DOM heights rather than relying on cached estimates
  RenderAroundAndScrollTo customerId -> do
    void $ H.fork do
      state <- H.get
      let filteredCustomers = filterCustomers state.searchQuery state.customers
      let sortedCustomers = applySorting state.sortState filteredCustomers

      case findIndex (\c -> c.id == customerId) sortedCustomers of
        Just targetIndex -> do
          -- Get actual container height from DOM (may differ from initial state)
          mbContainer <- H.liftEffect $ getCustomerListElement
          actualHeight <- case mbContainer of
            Just element -> H.liftEffect $ getClientHeight element
            Nothing -> pure state.containerHeight

          when (actualHeight /= state.containerHeight) do
            H.modify_ _ { containerHeight = actualHeight }

          -- Phase 1: Rough scroll to get row into viewport
          let roughYPosition = calculateHeightRange sortedCustomers 0 targetIndex
          let roughScrollTop = max 0.0 (roughYPosition - actualHeight + 100.0)
          H.liftEffect $ scrollToPosition roughScrollTop

          -- Phase 2: Wait for row to render and height to stabilize
          promise <- H.liftEffect $ waitForRowAndMeasureImpl targetIndex
          result <- H.liftAff $ toAff promise

          -- Update cache with all rendered rows
          handleAction db MeasureRenderedRows

          -- Phase 3: Scroll to exact position using measured height
          let targetScrollTop = max 0.0 (result.offsetTop + result.height - actualHeight)
          H.liftEffect $ scrollToPosition targetScrollTop

        Nothing -> pure unit

  ScrollToCustomer name -> do
    state <- H.get
    let filteredCustomers = filterCustomers state.searchQuery state.customers
    let sortedCustomers = applySorting state.sortState filteredCustomers
    case find (\c -> c.name == name) sortedCustomers of
      Just customer -> handleAction db (RenderAroundAndScrollTo customer.id)
      Nothing -> pure unit

  ScrollToCustomerId id -> do
    handleAction db (RenderAroundAndScrollTo id)

  UpdateSearchQuery query -> do
    H.modify_ _ { searchQuery = query }

-- FFI helpers for DOM manipulation, measurements, and formatting
foreign import getScrollTop :: HTMLElement -> Effect Number
foreign import getClientHeight :: HTMLElement -> Effect Number
foreign import scrollToPosition :: Number -> Effect Unit
foreign import measureRowHeights :: Effect (Array { index :: Int, customerId :: Int, height :: Number })
foreign import waitForRowAndMeasureImpl :: Int -> Effect (Promise { offsetTop :: Number, height :: Number })
foreign import getCustomerListElementImpl :: Effect (Nullable HTMLElement)
foreign import checkClickOutsideInput :: EventTarget -> Effect Boolean
foreign import generateRandomCode :: Effect Int
foreign import focusDeleteConfirmInput :: Effect Unit
foreign import focusEditInput :: Effect Unit
foreign import requestAnimationFrameAction :: Unit -> Effect (Promise Unit)
foreign import formatDateString :: String -> String
foreign import formatMoneyValue :: Number -> { integer :: String, fraction :: String }
foreign import formatGramsValue :: Number -> { integer :: String, fraction :: String }
foreign import formatBahtValue :: Number -> { integer :: String, fraction :: String, hasFraction :: Boolean }

getCustomerListElement :: Effect (Maybe HTMLElement)
getCustomerListElement = do
  nullable <- getCustomerListElementImpl
  pure $ toMaybe nullable
