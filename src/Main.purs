module Main where

import Prelude

import Component.Router as Router
import Database.API as API
import Effect (Effect)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)

main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  let database = API.createAPIDatabase
  runUI (Router.component database) unit body
