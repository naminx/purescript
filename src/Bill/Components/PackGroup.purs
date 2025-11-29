module Bill.Components.PackGroup where

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
type Pack =
  { id :: Int
  , group_id :: Int
  , internal_id :: Int
  , user_number :: String
  }

type PackItem =
  { id :: Int
  , pack_id :: Int
  , display_order :: Int
  , deduction_rate :: String
  , shape :: String
  , purity :: Maybe String
  , description :: Maybe String
  , weight_grams :: Maybe String
  , weight_baht :: Maybe String
  , calculation_amount :: String
  }

type Slot = H.Slot Query Output

type Input =
  { pack :: Pack
  , items :: Array PackItem
  , isEditable :: Boolean
  }

type State =
  { pack :: Pack
  , items :: Array PackItem
  , isEditable :: Boolean
  , isExpanded :: Boolean
  }

data Query a = UpdatePack Pack (Array PackItem) a

data Action
  = ToggleExpand
  | EditPack
  | AddItem
  | EditItem Int
  | DeleteItem Int

data Output
  = PackUpdated Pack
  | ItemAdded
  | ItemUpdated PackItem
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
  { pack: input.pack
  , items: input.items
  , isEditable: input.isEditable
  , isExpanded: true
  }

render :: forall m. State -> H.ComponentHTML Action () m
render state =
  HH.div
    [ HP.class_ $ HH.ClassName "pack-group" ]
    [ renderPackHeader state
    , if state.isExpanded
        then renderPackContent state
        else HH.text ""
    ]

renderPackHeader :: forall m. State -> H.ComponentHTML Action () m
renderPackHeader state =
  HH.div
    [ HP.class_ $ HH.ClassName "pack-header"
    , HE.onClick \_ -> ToggleExpand
    ]
    [ HH.span
        [ HP.class_ $ HH.ClassName "pack-title" ]
        [ HH.text $ TC.packLabel <> " " <> state.pack.user_number ]
    , HH.span
        [ HP.class_ $ HH.ClassName "pack-summary" ]
        [ HH.text $ show (length state.items) <> " แท่ง" ]
    , HH.span
        [ HP.class_ $ HH.ClassName "expand-icon" ]
        [ HH.text $ if state.isExpanded then "▼" else "▶" ]
    ]

renderPackContent :: forall m. State -> H.ComponentHTML Action () m
renderPackContent state =
  HH.div
    [ HP.class_ $ HH.ClassName "pack-content" ]
    [ renderPackSettings state.pack
    , renderPackItems state
    , if state.isEditable
        then renderAddItemButton
        else HH.text ""
    ]

renderPackSettings :: forall m. Pack -> H.ComponentHTML Action () m
renderPackSettings pack =
  HH.div
    [ HP.class_ $ HH.ClassName "pack-settings" ]
    [ HH.table
        [ HP.class_ $ HH.ClassName "settings-table" ]
        [ HH.tbody_
            [ HH.tr_
                [ HH.td_ [ HH.text TC.packIdLabel ]
                , HH.td_ [ HH.text $ show pack.internal_id ]
                ]
            , HH.tr_
                [ HH.td_ [ HH.text TC.userNumberLabel ]
                , HH.td_ [ HH.text pack.user_number ]
                ]
            ]
        ]
    ]

renderPackItems :: forall m. State -> H.ComponentHTML Action () m
renderPackItems state =
  HH.div
    [ HP.class_ $ HH.ClassName "pack-items" ]
    [ if length state.items == 0
        then HH.p_ [ HH.text "ยังไม่มีแท่ง" ]
        else HH.table
          [ HP.class_ $ HH.ClassName "items-table" ]
          [ HH.thead_
              [ HH.tr_
                  [ HH.th_ [ HH.text "#" ]
                  , HH.th_ [ HH.text TC.shapeLabel ]
                  , HH.th_ [ HH.text TC.purityLabel ]
                  , HH.th_ [ HH.text TC.weightLabel ]
                  , HH.th_ [ HH.text TC.deductionRateLabel ]
                  , HH.th_ [ HH.text TC.calculationAmountLabel ]
                  , if state.isEditable
                      then HH.th_ [ HH.text TC.actions ]
                      else HH.text ""
                  ]
              ]
          , HH.tbody_ $ mapWithIndex (renderPackItemRow state) state.items
          ]
    ]

renderPackItemRow :: forall m. State -> Int -> PackItem -> H.ComponentHTML Action () m
renderPackItemRow state index item =
  HH.tr_
    [ HH.td_ [ HH.text $ show (index + 1) ]
    , HH.td_ [ HH.text item.shape ]
    , HH.td_ [ HH.text $ case item.purity of
        Nothing -> "-"
        Just p -> p <> "%"
      ]
    , HH.td_ [ HH.text $ renderWeight item ]
    , HH.td_ [ HH.text item.deduction_rate ]
    , HH.td_ [ HH.text $ item.calculation_amount <> " " <> TC.unitTHB ]
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

renderWeight :: PackItem -> String
renderWeight item = case item.weight_grams, item.weight_baht of
  Just g, _ -> g <> " " <> TC.unitGrams
  _, Just b -> b <> " " <> TC.unitBaht
  _, _ -> "-"

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

  EditPack -> do
    -- TODO: Open pack edit dialog
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
  UpdatePack pack items a -> do
    H.modify_ _ { pack = pack, items = items }
    pure $ Just a
