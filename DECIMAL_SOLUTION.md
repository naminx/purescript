# Decimal Type Solution for Financial Data

## Problem Statement

Currently, the application uses JavaScript `Number` (IEEE 754 double) for money and gold balances, which causes rounding errors in financial calculations. PostgreSQL stores these as `NUMERIC` (arbitrary precision), but they get converted to JavaScript numbers via `parseFloat()`, losing precision.

## Current Data Flow

```
PostgreSQL NUMERIC → pg driver (string) → parseFloat() → JavaScript Number → PureScript Number
                                          ↑ PRECISION LOSS HERE
```

## Proposed Solutions

### Solution 1: String-Based Decimal (Recommended)

**Keep values as strings throughout the application, only format for display.**

#### Advantages
- ✅ Zero precision loss
- ✅ Simple implementation
- ✅ No external dependencies
- ✅ Works with existing PostgreSQL NUMERIC
- ✅ Easy to validate and format

#### Implementation

```purescript
-- src/Database/Types.purs
type Decimal = String  -- "123.45" format

type Customer =
  { id :: Int
  , name :: String
  , money :: Decimal           -- "10000.50"
  , gram_jewelry :: Decimal    -- "40.000"
  , baht_jewelry :: Decimal    -- "3.500"
  , gram_bar96 :: Decimal      -- "0.000"
  , baht_bar96 :: Decimal      -- "0.000"
  , gram_bar99 :: Decimal      -- "0.000"
  , baht_bar99 :: Decimal      -- "0.000"
  , created_at :: Maybe String
  , updated_at :: Maybe String
  , rowHeight :: Maybe Number  -- Keep as Number (not financial)
  }
```

#### Changes Required

**1. Server (server.js)**
```javascript
// REMOVE convertNumericFields - keep as strings
function prepareCustomerRow(row) {
  return {
    ...row,
    // Keep NUMERIC fields as strings (pg driver already does this)
    money: row.money,
    gram_jewelry: row.gram_jewelry,
    baht_jewelry: row.baht_jewelry,
    gram_bar96: row.gram_bar96,
    baht_bar96: row.baht_bar96,
    gram_bar99: row.gram_bar99,
    baht_bar99: row.baht_bar99
  };
}
```

**2. PureScript Types**
```purescript
-- src/Decimal.purs (NEW MODULE)
module Decimal where

import Prelude
import Data.Maybe (Maybe(..))
import Data.String as String
import Data.String.Regex as Regex
import Data.String.Regex.Flags as RegexFlags

type Decimal = String

-- Validate decimal string format
isValidDecimal :: String -> Boolean
isValidDecimal str =
  case Regex.regex "^-?\\d+(\\.\\d+)?$" RegexFlags.noFlags of
    Right re -> Regex.test re str
    Left _ -> false

-- Parse user input to decimal
parseDecimal :: String -> Int -> Maybe Decimal
parseDecimal input maxDecimals =
  let trimmed = String.trim input
  in if isValidDecimal trimmed
     then Just $ formatDecimal trimmed maxDecimals
     else Nothing

-- Format decimal to fixed decimals
formatDecimal :: Decimal -> Int -> Decimal
formatDecimal value decimals =
  -- Implementation using string manipulation
  -- to avoid Number conversion
  value  -- Simplified for now

-- Compare decimals
compareDecimal :: Decimal -> Decimal -> Ordering
compareDecimal a b =
  -- String-based comparison
  -- Handle negative numbers, different lengths, etc.
  compare a b  -- Simplified

-- Check if decimal is zero
isZero :: Decimal -> Boolean
isZero d = d == "0" || d == "0.0" || d == "0.00" || d == "0.000"

-- Check if decimal is negative
isNegative :: Decimal -> Boolean
isNegative d = String.take 1 d == "-"

-- Format for display (with thousands separators)
formatForDisplay :: Decimal -> String
formatForDisplay d =
  -- Add thousands separators, keep decimal part
  d  -- Simplified
```

**3. Display Formatting (FFI)**
```javascript
// src/Decimal.js
export const formatMoneyDisplay = function(decimalStr) {
  // Use Intl.NumberFormat for display only
  // Input: "10000.50" -> Output: "10,000.50"
  const num = parseFloat(decimalStr);
  return new Intl.NumberFormat('en-US', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(num);
};

export const formatGramsDisplay = function(decimalStr) {
  const num = parseFloat(decimalStr);
  return new Intl.NumberFormat('en-US', {
    minimumFractionDigits: 3,
    maximumFractionDigits: 3
  }).format(num);
};

// Note: parseFloat is ONLY for display formatting
// The actual value remains as string
```

**4. Calculations (if needed)**
```purescript
-- For calculations, use a library or implement string-based arithmetic
-- Example: Converting grams to baht

-- Option A: Use decimal.js library via FFI
foreign import decimalMultiply :: Decimal -> Decimal -> Decimal
foreign import decimalDivide :: Decimal -> Decimal -> Decimal

-- Option B: Send calculations to server
-- Let PostgreSQL do the math (most reliable)
```

#### Migration Steps

1. **Update Database Types** (already correct - PostgreSQL NUMERIC)
2. **Update server.js** - Remove `parseFloat()` conversions
3. **Update PureScript Types** - Change `Number` to `String` (or `type Decimal = String`)
4. **Create Decimal module** - Validation, parsing, formatting
5. **Update CustomerList** - Use string-based operations
6. **Update display functions** - Format strings for display
7. **Test thoroughly** - Verify no precision loss

### Solution 2: decimal.js Library (Alternative)

Use the `decimal.js` JavaScript library via FFI.

#### Advantages
- ✅ Full arithmetic operations
- ✅ Well-tested library
- ✅ Handles edge cases

#### Disadvantages
- ❌ Adds dependency
- ❌ More complex FFI
- ❌ Still need to avoid Number conversion
- ❌ Larger bundle size

#### Implementation
```purescript
-- FFI to decimal.js
foreign import data DecimalJS :: Type

foreign import decimalFromString :: String -> DecimalJS
foreign import decimalToString :: DecimalJS -> String
foreign import decimalAdd :: DecimalJS -> DecimalJS -> DecimalJS
foreign import decimalMultiply :: DecimalJS -> DecimalJS -> DecimalJS
```

### Solution 3: PureScript Decimal Library

Use a pure PureScript decimal library (if available).

#### Status
- No mature PureScript decimal library found in ecosystem
- Would need to implement from scratch
- Significant development effort

## Recommendation

**Use Solution 1: String-Based Decimal**

### Why?
1. **Simplest** - No external dependencies
2. **Most reliable** - Zero conversion = zero precision loss
3. **PostgreSQL compatible** - pg driver already returns strings
4. **Sufficient** - We don't need complex arithmetic in the frontend
5. **Performant** - String operations are fast

### What About Calculations?

For the gold shop application:
- **Display**: Format strings for display (use Intl.NumberFormat)
- **Input**: Validate and store as strings
- **Sorting**: String comparison works for decimals (with proper formatting)
- **Arithmetic**: If needed, send to server (PostgreSQL does it)

### Key Principle

**"Never convert NUMERIC to Number, keep as String until display"**

```
PostgreSQL NUMERIC → pg driver (string) → Keep as String → Format for display
                                          ↑ NO CONVERSION
```

## Implementation Priority

### Phase 1: Core Changes (High Priority)
1. Update `Database.Types` - Change `Number` to `String`
2. Update `server.js` - Remove `parseFloat()` conversions
3. Create `Decimal` module - Basic validation and parsing
4. Update `CustomerList` - Use string values

### Phase 2: Display Formatting (Medium Priority)
1. Create display formatting functions
2. Update all display code to format strings
3. Test with various decimal values

### Phase 3: Calculations (Low Priority - if needed)
1. Implement string-based arithmetic OR
2. Add decimal.js library OR
3. Send calculations to server

## Testing Strategy

### Test Cases
```purescript
-- Precision tests
"0.01" + "0.02" = "0.03"  -- Not "0.030000000000000004"
"10000.50" - "0.01" = "10000.49"  -- Exact

-- Edge cases
"0.000" is zero
"-123.45" is negative
"999999999.999" large number
"0.001" small number

-- Display formatting
"10000.50" displays as "10,000.50"
"123.456" displays as "123.456"
"-50.00" displays as "-50.00"
```

## Migration Checklist

- [ ] Update `Database.Types.purs` - Change Number to String
- [ ] Create `src/Decimal.purs` module
- [ ] Update `server.js` - Remove parseFloat conversions
- [ ] Update `CustomerList.purs` - Handle string values
- [ ] Update display functions - Format strings
- [ ] Update input parsing - Validate strings
- [ ] Update sorting logic - String comparison
- [ ] Test with real data
- [ ] Verify no precision loss
- [ ] Update documentation

## Conclusion

The string-based approach is the most pragmatic solution for this application. It:
- Eliminates precision loss completely
- Requires minimal code changes
- Has no external dependencies
- Works seamlessly with PostgreSQL NUMERIC
- Is easy to understand and maintain

The key insight is: **We don't need to do arithmetic in JavaScript - we just need to store and display values accurately.**
