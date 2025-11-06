module Database.Database where

import Prelude

-- import Data.Either (Either(..))
-- import Data.Maybe (Maybe(..))
-- import Database.PostgreSQL (Connection, Query(..), execute, query)
-- import Database.PostgreSQL.Row (Row0(..), Row1(..), Row2(..))
-- import Database.Types (Customer, DatabaseInterface)
-- import Effect.Aff (Aff, throwError, error)
-- import Effect.Aff.Class (class MonadAff, liftAff)

-- NOTE: This module is commented out because purescript-node-postgres is not available
-- in the standard package set. To use this, you'll need to add it to your packages.dhall:
--
-- let additions =
--   { node-postgres =
--     { dependencies =
--       [ "aff"
--       , "arrays"
--       , "bifunctors"
--       , "bytestrings"
--       , "datetime"
--       , "decimals"
--       , "effect"
--       , "either"
--       , "exceptions"
--       , "foldable-traversable"
--       , "foreign"
--       , "foreign-generic"
--       , "foreign-object"
--       , "js-date"
--       , "lists"
--       , "maybe"
--       , "newtype"
--       , "nullable"
--       , "prelude"
--       , "transformers"
--       ]
--     , repo = "https://github.com/rightfold/purescript-node-postgres.git"
--     , version = "v5.0.1"
--     }
--   }
--
-- in  upstream // additions

-- | Create a real database interface using PostgreSQL
-- createPostgresDatabase :: forall m. MonadAff m => Connection -> DatabaseInterface m
-- createPostgresDatabase conn =
--   { getAllCustomers: liftAff do
--       result <- query conn (Query "SELECT id, name FROM customer ORDER BY id") Row0
--       case result of
--         Left err -> throwError $ error $ "Database error: " <> show err
--         Right rows -> pure $ map (\(Row2 id name) -> { id, name }) rows
--   
--   , addNewCustomer: \name -> liftAff do
--       result <- execute conn (Query "INSERT INTO customer (name) VALUES ($1)") (Row1 name)
--       case result of
--         Left err -> throwError $ error $ "Database error: " <> show err
--         Right _ -> pure unit
--   
--   , updateCustomerName: \{ id, name } -> liftAff do
--       result <- execute conn (Query "UPDATE customer SET name = $1 WHERE id = $2") (Row2 name id)
--       case result of
--         Left err -> throwError $ error $ "Database error: " <> show err
--         Right _ -> pure unit
--   
--   , deleteCustomer: \id -> liftAff do
--       result <- execute conn (Query "DELETE FROM customer WHERE id = $1") (Row1 id)
--       case result of
--         Left err -> throwError $ error $ "Database error: " <> show err
--         Right _ -> pure unit
--   }

-- | SQL to create the customer table
createTableSQL :: String
createTableSQL = """
  CREATE TABLE IF NOT EXISTS customer (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL
  );
"""
