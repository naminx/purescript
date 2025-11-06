{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "customer-management"
, dependencies =
  [ "aff"
  , "arrays"
  , "console"
  , "effect"
  , "either"
  , "halogen"
  , "halogen-svg-elems"
  , "maybe"
  , "prelude"
  , "refs"
  , "strings"
  , "web-events"
  , "web-uievents"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
