module Main where

import Prelude

import Component.Router as Router
import Data.Maybe (Maybe(..))
import Database.API as API
import Effect (Effect)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Web.DOM.ParentNode (QuerySelector(..))

main :: Effect Unit
main = HA.runHalogenAff do
  HA.awaitLoad
  element <- HA.selectElement (QuerySelector "#app")
  case element of
    Nothing -> pure unit
    Just el -> do
      let database = API.createAPIDatabase
      void $ runUI (Router.component database) unit el
