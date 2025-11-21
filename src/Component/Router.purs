module Component.Router where

import Prelude

import Component.CustomerList as CustomerList
import Component.POS as POS
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

derive instance eqRoute :: Eq Route

-- Component state
type State m =
  { currentRoute :: Route
  , database :: DatabaseInterface m
  , showMenu :: Boolean
  , customerCount :: Int
  }

-- Component slots
type Slots =
  ( pos :: H.Slot (Const Void) POS.Output Unit
  , customers :: H.Slot (Const Void) CustomerList.Output Unit
  )

_pos :: Proxy "pos"
_pos = Proxy

_customers :: Proxy "customers"
_customers = Proxy

-- Component actions
data Action
  = Navigate Route
  | ToggleMenu
  | HandlePOSOutput POS.Output
  | HandleCustomerListOutput CustomerList.Output

-- Component definition
component :: forall query input output m. MonadAff m => DatabaseInterface m -> H.Component query input output m
component database =
  H.mkComponent
    { initialState: \_ -> { currentRoute: POSRoute, database, showMenu: false, customerCount: 0 }
    , render
    , eval: H.mkEval $ H.defaultEval { handleAction = handleAction }
    }

-- Render function
render :: forall m. MonadAff m => State m -> H.ComponentHTML Action Slots m
render state =
  HH.div_
    [ renderNav state
    , renderPage state
    ]

renderNav :: forall m. State m -> H.ComponentHTML Action Slots m
renderNav state =
  HH.div
    [ HP.class_ (HH.ClassName "app-nav") ]
    [ HH.style_
        [ HH.text """
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
            background: #f8f9fa;
          }
          
          .app-nav-item.active {
            background: #e3f2fd;
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
        , if state.showMenu
            then renderDropdown state
            else HH.text ""
        ]
    , HH.span
        [ HP.class_ (HH.ClassName "app-nav-title") ]
        [ HH.text $ case state.currentRoute of
            POSRoute -> routerConstants.routePOS
            CustomersRoute -> routerConstants.routeCustomers <> " (" <> show state.customerCount <> " ราย)"
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
    ]

routeName :: Route -> String
routeName POSRoute = routerConstants.routePOS
routeName CustomersRoute = routerConstants.routeCustomers

renderPage :: forall m. MonadAff m => State m -> H.ComponentHTML Action Slots m
renderPage state =
  case state.currentRoute of
    POSRoute ->
      HH.slot _pos unit (POS.component state.database) unit HandlePOSOutput
    CustomersRoute ->
      HH.slot _customers unit (CustomerList.component state.database) unit HandleCustomerListOutput

-- Action handler
handleAction :: forall output m. MonadAff m => Action -> H.HalogenM (State m) Action Slots output m Unit
handleAction = case _ of
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
