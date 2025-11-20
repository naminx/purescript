module Component.Router where

import Prelude

import Component.CustomerList as CustomerList
import Component.POS as POS
import Data.Const (Const)
import Data.Maybe (Maybe(..))
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
  }

-- Component slots
type Slots =
  ( pos :: H.Slot (Const Void) POS.Output Unit
  , customers :: H.Slot (Const Void) Void Unit
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

-- Component definition
component :: forall query input output m. MonadAff m => DatabaseInterface m -> H.Component query input output m
component database =
  H.mkComponent
    { initialState: \_ -> { currentRoute: POSRoute, database, showMenu: false }
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
          }
          
          .app-nav-menu {
            position: relative;
            display: inline-block;
          }
          
          .app-nav-toggle {
            background: none;
            border: none;
            font-size: 24px;
            padding: 12px 20px;
            cursor: pointer;
            color: #333;
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
            [ HH.text ("☰ " <> routeName state.currentRoute) ]
        , if state.showMenu
            then renderDropdown state
            else HH.text ""
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
        [ HH.text "POS" ]
    , HH.div
        [ HP.class_ (HH.ClassName $ "app-nav-item" <> if state.currentRoute == CustomersRoute then " active" else "")
        , HE.onClick \_ -> Navigate CustomersRoute
        ]
        [ HH.text "Customers" ]
    ]

routeName :: Route -> String
routeName POSRoute = "POS"
routeName CustomersRoute = "Customers"

renderPage :: forall m. MonadAff m => State m -> H.ComponentHTML Action Slots m
renderPage state =
  case state.currentRoute of
    POSRoute ->
      HH.slot _pos unit (POS.component state.database) unit HandlePOSOutput
    CustomersRoute ->
      HH.slot_ _customers unit (CustomerList.component state.database) unit

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
