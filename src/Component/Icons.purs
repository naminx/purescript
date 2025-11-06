module Component.Icons where

import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Halogen.Svg.Attributes as SA
import Halogen.Svg.Elements as SE

-- | Edit icon (pencil)
editIcon :: forall w i. HH.HTML w i
editIcon =
  SE.svg
    [ SA.viewBox 0.0 0.0 24.0 24.0
    , SA.width 16.0
    , SA.height 16.0
    , HP.attr (HH.AttrName "fill") "none"
    , HP.attr (HH.AttrName "stroke") "currentColor"
    , HP.attr (HH.AttrName "stroke-width") "2"
    , HP.attr (HH.AttrName "stroke-linecap") "round"
    , HP.attr (HH.AttrName "stroke-linejoin") "round"
    ]
    [ SE.path
        [ HP.attr (HH.AttrName "d") "M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" ]
    , SE.path
        [ HP.attr (HH.AttrName "d") "M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" ]
    ]

-- | Delete icon (trash can)
deleteIcon :: forall w i. HH.HTML w i
deleteIcon =
  SE.svg
    [ SA.viewBox 0.0 0.0 24.0 24.0
    , SA.width 16.0
    , SA.height 16.0
    , HP.attr (HH.AttrName "fill") "none"
    , HP.attr (HH.AttrName "stroke") "currentColor"
    , HP.attr (HH.AttrName "stroke-width") "2"
    , HP.attr (HH.AttrName "stroke-linecap") "round"
    , HP.attr (HH.AttrName "stroke-linejoin") "round"
    ]
    [ SE.polyline
        [ HP.attr (HH.AttrName "points") "3 6 5 6 21 6" ]
    , SE.path
        [ HP.attr (HH.AttrName "d") "M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" ]
    , SE.line
        [ HP.attr (HH.AttrName "x1") "10"
        , HP.attr (HH.AttrName "y1") "11"
        , HP.attr (HH.AttrName "x2") "10"
        , HP.attr (HH.AttrName "y2") "17"
        ]
    , SE.line
        [ HP.attr (HH.AttrName "x1") "14"
        , HP.attr (HH.AttrName "y1") "11"
        , HP.attr (HH.AttrName "x2") "14"
        , HP.attr (HH.AttrName "y2") "17"
        ]
    ]

-- | Save icon (check mark)
saveIcon :: forall w i. HH.HTML w i
saveIcon =
  SE.svg
    [ SA.viewBox 0.0 0.0 24.0 24.0
    , SA.width 16.0
    , SA.height 16.0
    , HP.attr (HH.AttrName "fill") "none"
    , HP.attr (HH.AttrName "stroke") "currentColor"
    , HP.attr (HH.AttrName "stroke-width") "2"
    , HP.attr (HH.AttrName "stroke-linecap") "round"
    , HP.attr (HH.AttrName "stroke-linejoin") "round"
    ]
    [ SE.polyline
        [ HP.attr (HH.AttrName "points") "20 6 9 17 4 12" ]
    ]

-- | Add icon (plus sign)
addIcon :: forall w i. HH.HTML w i
addIcon =
  SE.svg
    [ SA.viewBox 0.0 0.0 24.0 24.0
    , SA.width 16.0
    , SA.height 16.0
    , HP.attr (HH.AttrName "fill") "none"
    , HP.attr (HH.AttrName "stroke") "currentColor"
    , HP.attr (HH.AttrName "stroke-width") "2"
    , HP.attr (HH.AttrName "stroke-linecap") "round"
    , HP.attr (HH.AttrName "stroke-linejoin") "round"
    ]
    [ SE.line
        [ HP.attr (HH.AttrName "x1") "12"
        , HP.attr (HH.AttrName "y1") "5"
        , HP.attr (HH.AttrName "x2") "12"
        , HP.attr (HH.AttrName "y2") "19"
        ]
    , SE.line
        [ HP.attr (HH.AttrName "x1") "5"
        , HP.attr (HH.AttrName "y1") "12"
        , HP.attr (HH.AttrName "x2") "19"
        , HP.attr (HH.AttrName "y2") "12"
        ]
    ]

-- | Sort ascending icon (arrow up)
sortAscIcon :: forall w i. HH.HTML w i
sortAscIcon =
  SE.svg
    [ SA.viewBox 0.0 0.0 24.0 24.0
    , SA.width 14.0
    , SA.height 14.0
    , HP.attr (HH.AttrName "fill") "none"
    , HP.attr (HH.AttrName "stroke") "currentColor"
    , HP.attr (HH.AttrName "stroke-width") "2"
    , HP.attr (HH.AttrName "stroke-linecap") "round"
    , HP.attr (HH.AttrName "stroke-linejoin") "round"
    ]
    [ SE.line
        [ HP.attr (HH.AttrName "x1") "12"
        , HP.attr (HH.AttrName "y1") "19"
        , HP.attr (HH.AttrName "x2") "12"
        , HP.attr (HH.AttrName "y2") "5"
        ]
    , SE.polyline
        [ HP.attr (HH.AttrName "points") "5 12 12 5 19 12" ]
    ]

-- | Sort descending icon (arrow down)
sortDescIcon :: forall w i. HH.HTML w i
sortDescIcon =
  SE.svg
    [ SA.viewBox 0.0 0.0 24.0 24.0
    , SA.width 14.0
    , SA.height 14.0
    , HP.attr (HH.AttrName "fill") "none"
    , HP.attr (HH.AttrName "stroke") "currentColor"
    , HP.attr (HH.AttrName "stroke-width") "2"
    , HP.attr (HH.AttrName "stroke-linecap") "round"
    , HP.attr (HH.AttrName "stroke-linejoin") "round"
    ]
    [ SE.line
        [ HP.attr (HH.AttrName "x1") "12"
        , HP.attr (HH.AttrName "y1") "5"
        , HP.attr (HH.AttrName "x2") "12"
        , HP.attr (HH.AttrName "y2") "19"
        ]
    , SE.polyline
        [ HP.attr (HH.AttrName "points") "19 12 12 19 5 12" ]
    ]

-- | Unsorted icon (both arrows)
sortNeutralIcon :: forall w i. HH.HTML w i
sortNeutralIcon =
  SE.svg
    [ SA.viewBox 0.0 0.0 24.0 24.0
    , SA.width 14.0
    , SA.height 14.0
    , HP.attr (HH.AttrName "fill") "none"
    , HP.attr (HH.AttrName "stroke") "currentColor"
    , HP.attr (HH.AttrName "stroke-width") "2"
    , HP.attr (HH.AttrName "stroke-linecap") "round"
    , HP.attr (HH.AttrName "stroke-linejoin") "round"
    ]
    [ SE.polyline
        [ HP.attr (HH.AttrName "points") "7 15 12 20 17 15" ]
    , SE.polyline
        [ HP.attr (HH.AttrName "points") "7 9 12 4 17 9" ]
    ]

-- | Search icon (magnifying glass)
searchIcon :: forall w i. HH.HTML w i
searchIcon =
  SE.svg
    [ SA.viewBox 0.0 0.0 24.0 24.0
    , SA.width 16.0
    , SA.height 16.0
    , HP.attr (HH.AttrName "fill") "none"
    , HP.attr (HH.AttrName "stroke") "currentColor"
    , HP.attr (HH.AttrName "stroke-width") "2"
    , HP.attr (HH.AttrName "stroke-linecap") "round"
    , HP.attr (HH.AttrName "stroke-linejoin") "round"
    ]
    [ SE.circle
        [ HP.attr (HH.AttrName "cx") "11"
        , HP.attr (HH.AttrName "cy") "11"
        , HP.attr (HH.AttrName "r") "8"
        ]
    , SE.line
        [ HP.attr (HH.AttrName "x1") "21"
        , HP.attr (HH.AttrName "y1") "21"
        , HP.attr (HH.AttrName "x2") "16.65"
        , HP.attr (HH.AttrName "y2") "16.65"
        ]
    ]
