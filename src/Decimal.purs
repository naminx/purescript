module Decimal
  ( Decimal
  , fromString
  , fromInt
  , fromNumber
  , unsafeFromString
  , toString
  , toNumber
  , toFixed
  , add
  , subtract
  , multiply
  , divide
  , modulo
  , negate
  , abs
  , compare
  , eq
  , lt
  , lte
  , gt
  , gte
  , isZero
  , isNegative
  , isPositive
  , round
  , floor
  , ceil
  , zero
  , one
  ) where

import Prelude hiding (compare)
import Data.Maybe (Maybe(..))
import Data.Nullable (Nullable, toMaybe)
import Data.Ordering (Ordering(LT, EQ, GT))
import Data.Argonaut.Decode (class DecodeJson, decodeJson, JsonDecodeError(..))
import Data.Argonaut.Encode (class EncodeJson, encodeJson)
import Data.Either (Either(..))

-- | Opaque type wrapping decimal.js Decimal object
-- | Provides arbitrary precision decimal arithmetic
foreign import data Decimal :: Type

-- | Construction
foreign import fromStringImpl :: String -> Nullable Decimal

fromString :: String -> Maybe Decimal
fromString = toMaybe <<< fromStringImpl
foreign import fromInt :: Int -> Decimal
foreign import fromNumber :: Number -> Decimal
foreign import unsafeFromString :: String -> Decimal

-- | Conversion
foreign import toString :: Decimal -> String
foreign import toNumber :: Decimal -> Number
foreign import toFixed :: Int -> Decimal -> String

-- | Arithmetic operations
foreign import add :: Decimal -> Decimal -> Decimal
foreign import subtract :: Decimal -> Decimal -> Decimal
foreign import multiply :: Decimal -> Decimal -> Decimal
foreign import divide :: Decimal -> Decimal -> Decimal
foreign import modulo :: Decimal -> Decimal -> Decimal
foreign import negate :: Decimal -> Decimal
foreign import abs :: Decimal -> Decimal

-- | Comparison
foreign import _compare :: Decimal -> Decimal -> Int
foreign import eq :: Decimal -> Decimal -> Boolean
foreign import lt :: Decimal -> Decimal -> Boolean
foreign import lte :: Decimal -> Decimal -> Boolean
foreign import gt :: Decimal -> Decimal -> Boolean
foreign import gte :: Decimal -> Decimal -> Boolean

-- | Predicates
foreign import isZero :: Decimal -> Boolean
foreign import isNegative :: Decimal -> Boolean
foreign import isPositive :: Decimal -> Boolean

-- | Rounding
foreign import round :: Decimal -> Decimal
foreign import floor :: Decimal -> Decimal
foreign import ceil :: Decimal -> Decimal

-- | Compare function for Ord instance
compare :: Decimal -> Decimal -> Ordering
compare a b =
  case _compare a b of
    -1 -> LT
    0 -> EQ
    1 -> GT
    _ -> EQ  -- Should never happen

-- | Eq instance
instance eqDecimal :: Eq Decimal where
  eq = eq

-- | Ord instance
instance ordDecimal :: Ord Decimal where
  compare = compare

-- | Show instance
instance showDecimal :: Show Decimal where
  show = toString

-- | DecodeJson instance - decode from JSON string
instance decodeJsonDecimal :: DecodeJson Decimal where
  decodeJson json = do
    str <- decodeJson json
    case fromString str of
      Nothing -> Left (TypeMismatch "Invalid decimal string")
      Just d -> Right d

-- | EncodeJson instance - encode to JSON string
instance encodeJsonDecimal :: EncodeJson Decimal where
  encodeJson = encodeJson <<< toString

-- | Constants
zero :: Decimal
zero = fromInt 0

one :: Decimal
one = fromInt 1
