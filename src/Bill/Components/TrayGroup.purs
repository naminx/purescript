module Bill.Components.TrayGroup where

import Prelude

import Data.Array (length, mapWithIndex)
import Data.Maybe (Maybe(..))
import Data.Number.Format (toString) as Number
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import TextConstants.BillEditor as TC

-- Simplified types for now - will use actual Bill.Types later
type Tray =
  { id :: Int
  , group_id :: Int
  , internal_num :: Int
  , is_return :: Boolean
  , purity :: String
  , shape :: String
  , discount :: Int
  , actual_weight_grams :: String
  , price_rate :: String
  , additional_charge_rate :: Maybe String
  }

type TrayItem =
  { id :: Int
  , tray_id :: Int
  , display_order :: Int
  , making_charge :: String
  , jewelry_type_id :: Maybe Int
  , design_name :: Maybe String
  , nominal_weight :: String
  , quantity :: Int
  , amount :: String
  }

type Slot = H.Slot Query Output

type Input =
  { tray :: Tray
  , items :: Array TrayItem
  , isEditable :: Boolean
  }

type State =
  { tray :: Tray
  , items :: Array TrayItem
  , isEditable :: Boolean
  , isExpanded :: Boolean
  }

data Query a = UpdateTray Tray (Array TrayItem) a

data Action
  = ToggleExpand
  | EditTray
  | AddItem
  | EditItem Int
  | DeleteItem Int

data Output
  = TrayUpdated Tray
  | ItemAdded
  | ItemUpdated TrayItem
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
  { tray: input.tray
  , items: input.items
  , isEditable: input.isEditable
  , isExpanded: true
  }

render :: forall m. State -> H.ComponentHTML Action () m
render state =
  HH.div
    [ HP.class_ $ HH.ClassName "tray-group" ]
    [ renderTrayHeader state
    , if state.isExpanded
        then renderTrayContent state
        else HH.text ""
    ]

renderTrayHeader :: forall m. State -> H.ComponentHTML Action () m
renderTrayHeader state =
  HH.div
    [ HP.class_ $ HH.ClassName "tray-header"
    , HE.onClick \_ -> ToggleExpand
    ]
    [ HH.span
        [ HP.class_ $ HH.ClassName "tray-title" ]
        [ HH.text $ TC.trayLabel <> " #" <> show state.tray.internal_num ]
    , HH.span
        [ HP.class_ $ HH.ClassName "tray-summary" ]
        [ HH.text $ show (length state.items) <> " รายการ" ]
    , HH.span
        [ HP.class_ $ HH.ClassName "expand-icon" ]
        [ HH.text $ if state.isExpanded then "▼" else "▶" ]
    ]

renderTrayContent :: forall m. State -> H.ComponentHTML Action () m
renderTrayContent state =
  HH.div
    [ HP.class_ $ HH.ClassName "tray-content" ]
    [ renderTraySettings state.tray
    , renderTrayItems state
    , if state.isEditable
        then renderAddItemButton
        else HH.text ""
    ]

renderTraySettings :: forall m. Tray -> H.ComponentHTML Action () m
renderTraySettings tray =
  HH.div
    [ HP.class_ $ HH.ClassName "tray-settings" ]
    [ HH.table
        [ HP.class_ $ HH.ClassName "settings-table" ]
        [ HH.tbody_
            [ HH.tr_
                [ HH.td_ [ HH.text TC.purityLabel ]
                , HH.td_ [ HH.text $ tray.purity <> "%" ]
                ]
            , HH.tr_
                [ HH.td_ [ HH.text TC.shapeLabel ]
                , HH.td_ [ HH.text tray.shape ]
                ]
            , HH.tr_
                [ HH.td_ [ HH.text TC.discountLabel ]
                , HH.td_ [ HH.text $ show tray.discount <> "%" ]
                ]
            , HH.tr_
                [ HH.td_ [ HH.text TC.actualWeightLabel ]
                , HH.td_ [ HH.text $ tray.actual_weight_grams <> " " <> TC.unitGrams ]
                ]
            , HH.tr_
                [ HH.td_ [ HH.text TC.priceRateLabel ]
                , HH.td_ [ HH.text $ tray.price_rate <> " " <> TC.unitTHB ]
                ]
            ]
        ]
    ]

renderTrayItems :: forall m. State -> H.ComponentHTML Action () m
renderTrayItems state =
  HH.div
    [ HP.class_ $ HH.ClassName "tray-items" ]
    [ if length state.items == 0
        then HH.p_ [ HH.text "ยังไม่มีรายการ" ]
        else HH.table
          [ HP.class_ $ HH.ClassName "items-table" ]
          [ HH.thead_
              [ HH.tr_
                  [ HH.th_ [ HH.text "#" ]
                  , HH.th_ [ HH.text TC.nominalWeightLabel ]
                  , HH.th_ [ HH.text TC.quantityLabel ]
                  , HH.th_ [ HH.text TC.makingChargeLabel ]
                  , HH.th_ [ HH.text TC.amountLabel ]
                  , if state.isEditable
                      then HH.th_ [ HH.text TC.actions ]
                      else HH.text ""
                  ]
              ]
          , HH.tbody_ $ mapWithIndex (renderTrayItemRow state) state.items
          ]
    ]

renderTrayItemRow :: forall m. State -> Int -> TrayItem -> H.ComponentHTML Action () m
renderTrayItemRow state index item =
  HH.tr_
    [ HH.td_ [ HH.text $ show (index + 1) ]
    , HH.td_ [ HH.text $ item.nominal_weight <> " " <> TC.unitBaht ]
    , HH.td_ [ HH.text $ show item.quantity ]
    , HH.td_ [ HH.text $ item.making_charge <> " " <> TC.unitTHB ]
    , HH.td_ [ HH.text $ item.amount <> " " <> TC.unitTHB ]
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

  EditTray -> do
    -- TODO: Open tray edit dialog
    pure unit

  AddItem ->
    H.raise ItemAdded

  EditItem itemId -> do
    -- TODO: Open item edit dialog
    pure unit

  DeleteItem itemId ->
    H.raise $ ItemDeleted itemId

handleQuery :: forall m a. MonadAff m => Query a -> H.HalogenM State Action () Output m (Maybe a)
handleQuery = case _ of
  UpdateTray tray items a -> do
    H.modify_ _ { tray = tray, items = items }
    pure $ Just a
