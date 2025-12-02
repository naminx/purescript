module Component.Router where

import Prelude

import Component.CustomerList as CustomerList
import Component.POS as POS
import Bill.Components.BillList as BillList
import Bill.Components.BillEditor as BillEditor
import Bill.API as BillAPI
import Data.Const (Const)
import Data.Maybe (Maybe(..))
import TextConstants (routerConstants)
import Database.Types (DatabaseInterface)
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Type.Proxy (Proxy(..))

-- Routes
data Route
  = POSRoute
  | CustomersRoute
  | BillsRoute Int -- Customer ID
  | BillEditorRoute (Maybe Int) Int -- Bill ID (optional), Customer ID

derive instance eqRoute :: Eq Route

-- Component state
type JewelryType =
  { id :: Int
  , name :: String
  }

type NominalWeight =
  { id :: Int
  , label :: String
  , weight_grams :: Number
  }

type PredefinedPurity =
  { id :: Int
  , purity :: Maybe Number
  , metal_type :: String
  , display_val :: Number
  }

type State m =
  { currentRoute :: Route
  , database :: DatabaseInterface m
  , showMenu :: Boolean
  , customerCount :: Int
  , jewelryTypes :: Array JewelryType
  , nominalWeights :: Array NominalWeight
  , predefinedPurities :: Array PredefinedPurity
  }

-- Component slots
type Slots =
  ( pos :: H.Slot (Const Void) POS.Output Unit
  , customers :: H.Slot (Const Void) CustomerList.Output Unit
  , billList :: BillList.Slot Unit
  , billEditor :: BillEditor.Slot Unit
  )

_pos :: Proxy "pos"
_pos = Proxy

_customers :: Proxy "customers"
_customers = Proxy

_billList :: Proxy "billList"
_billList = Proxy

_billEditor :: Proxy "billEditor"
_billEditor = Proxy

-- Component actions
data Action
  = Initialize
  | Navigate Route
  | ToggleMenu
  | HandlePOSOutput POS.Output
  | HandleCustomerListOutput CustomerList.Output
  | HandleBillListOutput BillList.Output
  | HandleBillEditorOutput BillEditor.Output

-- Component definition
component :: forall query input output m. MonadAff m => DatabaseInterface m -> H.Component query input output m
component database =
  H.mkComponent
    { initialState: \_ -> { currentRoute: POSRoute, database, showMenu: false, customerCount: 0, jewelryTypes: [], nominalWeights: [], predefinedPurities: [] }
    , render
    , eval: H.mkEval $ H.defaultEval
        { handleAction = handleAction
        , initialize = Just Initialize
        }
    }

-- Render function
render :: forall m. MonadAff m => State m -> H.ComponentHTML Action Slots m
render state =
  HH.div
    [ HP.style "display: flex; flex-direction: column; height: 100vh;" ]
    [ renderNav state
    , HH.div
        [ HP.style "flex: 1; overflow-y: auto; overflow-x: hidden;" ]
        [ renderPage state ]
    ]

renderNav :: forall m. State m -> H.ComponentHTML Action Slots m
renderNav state =
  HH.div
    [ HP.class_ (HH.ClassName "app-nav") ]
    [ HH.style_
        [ HH.text
            """
          .app-nav {
            background: #f8f9fa;
            border-bottom: 1px solid #dee2e6;
            padding: 0;
            margin: 0;
            display: flex;
            align-items: center;
            height: 38px;
          }
          
          .app-nav-menu {
            position: relative;
            display: inline-block;
          }
          
          .app-nav-title {
            font-size: 20px;
            color: #333;
            padding: 0 16px;
            font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
          }
          
          .app-nav-toggle {
            background: none;
            border: none;
            font-size: 20px;
            padding: 8px 16px;
            cursor: pointer;
            color: #333;
            height: 38px;
            display: flex;
            align-items: center;
            font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
          }
          
          .app-nav-toggle:hover {
            background: #e9ecef;
          }
          
          .app-nav-dropdown {
            position: absolute;
            top: 100%;
            left: 0;
            background: white;
            border: 1px solid #dee2e6;
            border-radius: 0 0 4px 4px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            min-width: 200px;
            z-index: 1000;
          }
          
          .app-nav-item {
            padding: 12px 20px;
            cursor: pointer;
            border-bottom: 1px solid #eee;
            font-family: 'Google Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
          }
          
          .app-nav-item:last-child {
            border-bottom: none;
          }
          
          .app-nav-item:hover {
            background: #e3f2fd;
            color: #1976d2;
          }
          
          .app-nav-item.active {
            background: #1976d2;
            color: white;
            font-weight: 600;
          }
        """
        ]
    , HH.div
        [ HP.class_ (HH.ClassName "app-nav-menu") ]
        [ HH.button
            [ HP.class_ (HH.ClassName "app-nav-toggle")
            , HP.title "Menu"
            , HE.onClick \_ -> ToggleMenu
            ]
            [ HH.text "☰" ]
        , if state.showMenu then renderDropdown state
          else HH.text ""
        ]
    , HH.span
        [ HP.class_ (HH.ClassName "app-nav-title") ]
        [ HH.text $ case state.currentRoute of
            POSRoute -> routerConstants.routePOS
            CustomersRoute -> routerConstants.routeCustomers <> " (" <> show state.customerCount <> " ราย)"
            BillsRoute customerId -> "บิลของลูกค้า #" <> show customerId
            BillEditorRoute _ customerId -> "แก้ไขบิล - ลูกค้า #" <> show customerId
        ]
    ]

renderDropdown :: forall m. State m -> H.ComponentHTML Action Slots m
renderDropdown state =
  HH.div
    [ HP.class_ (HH.ClassName "app-nav-dropdown") ]
    [ HH.div
        [ HP.class_ (HH.ClassName $ "app-nav-item" <> if state.currentRoute == POSRoute then " active" else "")
        , HE.onClick \_ -> Navigate POSRoute
        ]
        [ HH.text routerConstants.routePOS ]
    , HH.div
        [ HP.class_ (HH.ClassName $ "app-nav-item" <> if state.currentRoute == CustomersRoute then " active" else "")
        , HE.onClick \_ -> Navigate CustomersRoute
        ]
        [ HH.text routerConstants.routeCustomers ]
    , HH.div
        [ HP.class_ (HH.ClassName "app-nav-item")
        , HE.onClick \_ -> Navigate (BillsRoute 1)
        ]
        [ HH.text "บิล (ทดสอบ)" ]
    ]

routeName :: Route -> String
routeName POSRoute = routerConstants.routePOS
routeName CustomersRoute = routerConstants.routeCustomers
routeName (BillsRoute _) = "บิล"
routeName (BillEditorRoute _ _) = "แก้ไขบิล"

renderPage :: forall m. MonadAff m => State m -> H.ComponentHTML Action Slots m
renderPage state =
  case state.currentRoute of
    POSRoute ->
      HH.slot _pos unit (POS.component state.database) unit HandlePOSOutput
    CustomersRoute ->
      HH.slot _customers unit (CustomerList.component state.database) unit HandleCustomerListOutput
    BillsRoute customerId ->
      HH.slot _billList unit BillList.component { customerId, customerName: "Customer #" <> show customerId } HandleBillListOutput
    BillEditorRoute billId customerId ->
      HH.slot _billEditor unit BillEditor.component
        { billId
        , customerId
        , customerName: "Customer #" <> show customerId
        , jewelryTypes: state.jewelryTypes
        , nominalWeights: state.nominalWeights
        , predefinedPurities: state.predefinedPurities
        }
        HandleBillEditorOutput

-- Action handler
handleAction :: forall output m. MonadAff m => Action -> H.HalogenM (State m) Action Slots output m Unit
handleAction = case _ of
  Initialize -> do
    -- Load jewelry types and nominal weights once on app startup
    jewelryTypes <- H.lift BillAPI.getJewelryTypes
    nominalWeights <- H.lift BillAPI.getNominalWeights
    predefinedPurities <- H.lift BillAPI.getPredefinedPurities
    H.modify_ _ { jewelryTypes = jewelryTypes, nominalWeights = nominalWeights, predefinedPurities = predefinedPurities }

  Navigate route -> do
    H.modify_ _ { currentRoute = route, showMenu = false }

  ToggleMenu -> do
    H.modify_ \s -> s { showMenu = not s.showMenu }

  HandlePOSOutput output -> do
    case output of
      POS.NavigateToCustomers -> do
        H.modify_ _ { currentRoute = CustomersRoute }

  HandleCustomerListOutput output -> do
    case output of
      CustomerList.CustomerCountChanged count -> do
        H.modify_ _ { customerCount = count }

  HandleBillListOutput output -> do
    case output of
      BillList.BillSelected billId -> do
        state <- H.get
        case state.currentRoute of
          BillsRoute customerId -> H.modify_ _ { currentRoute = BillEditorRoute (Just billId) customerId }
          _ -> pure unit
      BillList.NewBillRequested -> do
        state <- H.get
        case state.currentRoute of
          BillsRoute customerId -> H.modify_ _ { currentRoute = BillEditorRoute Nothing customerId }
          _ -> pure unit

  HandleBillEditorOutput output -> do
    case output of
      BillEditor.BillSaved _ -> pure unit
      BillEditor.BillCancelled -> do
        state <- H.get
        case state.currentRoute of
          BillEditorRoute _ customerId -> H.modify_ _ { currentRoute = BillsRoute customerId }
          _ -> pure unit
      BillEditor.BillFinalized _ -> pure unit
