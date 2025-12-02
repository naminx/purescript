module Bill.Constants where

import Prelude

-- ============================================================================
-- GOLD CONVERSION RATES
-- ============================================================================

-- Grams per baht for each gold type
gramsPerBahtJewelry :: Number
gramsPerBahtJewelry = 15.200

gramsPerBahtBar96 :: Number
gramsPerBahtBar96 = 15.244

gramsPerBahtBar99 :: Number
gramsPerBahtBar99 = 15.244

-- Baht per gram (inverse) - consolidated for all gold types
bahtPerGram :: Number
bahtPerGram = 0.0656

-- ============================================================================
-- VAT
-- ============================================================================

defaultVATRate :: Number
defaultVATRate = 7.0

-- ============================================================================
-- DISCOUNT RATES
-- ============================================================================

validDiscounts :: Array Int
validDiscounts = [ 0, 5, 10 ]

-- ============================================================================
-- PURITY VALUES
-- ============================================================================

purity965 :: Number
purity965 = 96.5

purity9999 :: Number
purity9999 = 100.0

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Convert grams to baht for jewelry
gramsToBahtJewelry :: Number -> Number
gramsToBahtJewelry grams = grams * bahtPerGram

-- Convert baht to grams for jewelry
bahtToGramsJewelry :: Number -> Number
bahtToGramsJewelry baht = baht * gramsPerBahtJewelry

-- Convert grams to baht for 96.5% bar
gramsToBahtBar96 :: Number -> Number
gramsToBahtBar96 grams = grams * bahtPerGram

-- Convert baht to grams for 96.5% bar
bahtToGramsBar96 :: Number -> Number
bahtToGramsBar96 baht = baht * gramsPerBahtBar96

-- Convert grams to baht for 99.99% bar
gramsToBahtBar99 :: Number -> Number
gramsToBahtBar99 grams = grams * bahtPerGram

-- Convert baht to grams for 99.99% bar
bahtToGramsBar99 :: Number -> Number
bahtToGramsBar99 baht = baht * gramsPerBahtBar99

-- Round to 2 decimal places (simplified - no actual rounding for now)
round2 :: Number -> Number
round2 n = n

-- Round to 3 decimal places (simplified - no actual rounding for now)
round3 :: Number -> Number
round3 n = n
