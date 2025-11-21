module Test where

import Prelude
import Effect (Effect)
import Effect.Console (log)
import Data.Argonaut.Core (stringify)
import Data.Argonaut.Parser (jsonParser)
import Data.Either (Either(..))
import Database.Codecs (decodeCustomer)

main :: Effect Unit
main = do
  let jsonStr = """{"id":1,"name":"test","money":"0.00","gram_jewelry":"0.000","baht_jewelry":"0.000","gram_bar96":"0.000","baht_bar96":"0.000","gram_bar99":"0.000","baht_bar99":"0.000","created_at":"2025-11-20T15:38:54.145Z","updated_at":"2012-12-28T12:13:59.000Z","row_height":null}"""
  case jsonParser jsonStr of
    Left err -> log $ "Parse error: " <> err
    Right json -> case decodeCustomer json of
      Left err -> log $ "Decode error: " <> err
      Right customer -> log $ "Success: " <> show customer.name
