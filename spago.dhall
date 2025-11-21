{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "customer-management"
, dependencies =
  [ "aff"
  , "aff-promise"
  , "affjax"
  , "affjax-web"
  , "argonaut-codecs"
  , "argonaut-core"
  , "arrays"
  , "bifunctors"
  , "console"
  , "const"
  , "effect"
  , "either"
  , "exceptions"
  , "foldable-traversable"
  , "foreign"
  , "functions"
  , "halogen"
  , "halogen-svg-elems"
  , "http-methods"
  , "integers"
  , "maybe"
  , "nullable"
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
