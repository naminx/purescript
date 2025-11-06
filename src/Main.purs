module Main where

import Prelude

import Component.CustomerList as CustomerList
import Database.Mock as Mock
import Effect (Effect)
import Effect.Aff (launchAff_)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)

main :: Effect Unit
main = do
  -- Create the mock database
  db <- Mock.createMockDatabase
  
  -- Run the Halogen app
  HA.runHalogenAff do
    body <- HA.awaitBody
    runUI (CustomerList.component db) unit body

-- To switch to real database, uncomment and modify:
-- import Database.Database as DB
-- import Database.PostgreSQL (defaultPoolConfiguration, newPool, withConnection)
-- 
-- mainWithRealDB :: Effect Unit
-- mainWithRealDB = launchAff_ do
--   pool <- newPool defaultPoolConfiguration
--     { host = "localhost"
--     , port = 5432
--     , database = "customers_db"
--     , user = "postgres"
--     , password = "password"
--     }
--   
--   withConnection pool \conn -> do
--     let db = DB.createPostgresDatabase conn
--     HA.runHalogenAff do
--       body <- HA.awaitBody
--       runUI (CustomerList.component db) unit body
