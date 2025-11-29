module Bill.Components.GroupList where

import Prelude

import Bill.Types (BillGroup)
import Data.Array (length, mapWithIndex)
import Data.Maybe (Maybe(..))
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import TextConstants.BillEditor as TC

type Slot = H.Slot Query Output

type Input = 
  { groups :: Array BillGroup
  , isEditable :: Boolean
  }

type State =
  { groups :: Array BillGroup
  , isEditable :: Boolean
  , selectedGroupId :: Maybe Int
  }

data Query a = UpdateGroups (Array BillGroup) a

data Action
  = SelectGroup Int
  | DeleteGroup Int
  | MoveGroupUp Int
  | MoveGroupDown Int

data Output
  = GroupSelected Int
  | GroupDeleted Int
  | GroupsReordered (Array BillGroup)

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
  { groups: input.groups
  , isEditable: input.isEditable
  , selectedGroupId: Nothing
  }

render :: forall m. State -> H.ComponentHTML Action () m
render state =
  HH.div
    [ HP.class_ $ HH.ClassName "group-list" ]
    [ if length state.groups == 0
        then renderEmpty
        else renderGroups state
    ]

renderEmpty :: forall m. H.ComponentHTML Action () m
renderEmpty =
  HH.div
    [ HP.class_ $ HH.ClassName "group-list-empty" ]
    [ HH.p_ [ HH.text "ยังไม่มีกลุ่ม" ]
    , HH.p_ [ HH.text "กดปุ่ม + เพิ่มถาด, + เพิ่มแพ็ค, หรือ + เพิ่มรายการ เพื่อเริ่มต้น" ]
    ]

renderGroups :: forall m. State -> H.ComponentHTML Action () m
renderGroups state =
  HH.div
    [ HP.class_ $ HH.ClassName "group-list-items" ]
    (mapWithIndex (renderGroupCard state) state.groups)

renderGroupCard :: forall m. State -> Int -> BillGroup -> H.ComponentHTML Action () m
renderGroupCard state index group =
  HH.div
    [ HP.class_ $ HH.ClassName $ "group-card" <> selectedClass
    , HE.onClick \_ -> SelectGroup group.id
    ]
    [ renderGroupHeader state index group
    , renderGroupSummary group
    ]
  where
    selectedClass = 
      if Just group.id == state.selectedGroupId 
        then " selected" 
        else ""

renderGroupHeader :: forall m. State -> Int -> BillGroup -> H.ComponentHTML Action () m
renderGroupHeader state index group =
  HH.div
    [ HP.class_ $ HH.ClassName "group-header" ]
    [ HH.span
        [ HP.class_ $ HH.ClassName "group-type" ]
        [ HH.text $ getGroupTypeLabel group.group_type ]
    , HH.span
        [ HP.class_ $ HH.ClassName "group-order" ]
        [ HH.text $ "#" <> show (index + 1) ]
    , if state.isEditable
        then renderGroupActions state index group
        else HH.text ""
    ]

renderGroupActions :: forall m. State -> Int -> BillGroup -> H.ComponentHTML Action () m
renderGroupActions state index group =
  HH.div
    [ HP.class_ $ HH.ClassName "group-actions" ]
    [ if index > 0
        then HH.button
          [ HP.class_ $ HH.ClassName "btn btn-sm"
          , HE.onClick \_ -> MoveGroupUp group.id
          , HP.title "ย้ายขึ้น"
          ]
          [ HH.text "↑" ]
        else HH.text ""
    , if index < length state.groups - 1
        then HH.button
          [ HP.class_ $ HH.ClassName "btn btn-sm"
          , HE.onClick \_ -> MoveGroupDown group.id
          , HP.title "ย้ายลง"
          ]
          [ HH.text "↓" ]
        else HH.text ""
    , HH.button
        [ HP.class_ $ HH.ClassName "btn btn-sm btn-danger"
        , HE.onClick \_ -> DeleteGroup group.id
        , HP.title TC.deleteButton
        ]
        [ HH.text "×" ]
    ]

renderGroupSummary :: forall m. BillGroup -> H.ComponentHTML Action () m
renderGroupSummary group =
  HH.div
    [ HP.class_ $ HH.ClassName "group-summary" ]
    [ HH.text $ "Group ID: " <> show group.id ]

getGroupTypeLabel :: String -> String
getGroupTypeLabel groupType = case groupType of
  "tray" -> TC.trayLabel
  "pack" -> TC.packLabel
  "transaction" -> TC.transactionLabel
  _ -> groupType

handleAction :: forall m. MonadAff m => Action -> H.HalogenM State Action () Output m Unit
handleAction = case _ of
  SelectGroup groupId -> do
    H.modify_ _ { selectedGroupId = Just groupId }
    H.raise $ GroupSelected groupId

  DeleteGroup groupId ->
    H.raise $ GroupDeleted groupId

  MoveGroupUp groupId -> do
    -- TODO: Implement reordering logic
    pure unit

  MoveGroupDown groupId -> do
    -- TODO: Implement reordering logic
    pure unit

handleQuery :: forall m a. MonadAff m => Query a -> H.HalogenM State Action () Output m (Maybe a)
handleQuery = case _ of
  UpdateGroups groups a -> do
    H.modify_ _ { groups = groups }
    pure $ Just a
