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
  , "integers"
  , "maybe"
  , "numbers"
  , "prelude"
  , "refs"
  , "strings"
  , "web-dom"
  , "web-events"
  , "web-html"
  , "web-uievents"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
