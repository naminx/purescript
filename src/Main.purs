module Main where

import Prelude

import Component.CustomerList as CustomerList
import Database.API as API
import Effect (Effect)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)

main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  runUI (CustomerList.component API.createAPIDatabase) unit body
