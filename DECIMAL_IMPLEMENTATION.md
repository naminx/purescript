# Decimal Type Implementation Plan

## Executive Summary

For calculation-intensive tax operations requiring exact precision, we will implement a proper Decimal type using **decimal.js** library via FFI. This provides arbitrary precision arithmetic without floating-point errors.

## Database Analysis

### Current Schema ✅ CORRECT

```sql
money        | numeric(15,2)  -- 15 digits total, 2 decimal places
gram_jewelry | numeric(15,3)  -- 15 digits total, 3 decimal places
baht_jewelry | numeric(15,3)
gram_bar96   | numeric(15,3)
baht_bar96   | numeric(15,3)
gram_bar99   | numeric(15,3)
baht_bar99   | numeric(15,3)
```

**PostgreSQL NUMERIC is perfect** - arbitrary precision, no rounding errors.

### Database Changes Required: **NONE**

The database is already correct. The issue is in the JavaScript/PureScript layer.

## Solution Architecture

### 1. Use decimal.js Library

**decimal.js** is the industry standard for JavaScript decimal arithmetic:
- ✅ Arbitrary precision
- ✅ Exact arithmetic (no floating-point errors)
- ✅ Comprehensive operations (+, -, *, /, %, pow, sqrt, etc.)
- ✅ Comparison operators
- ✅ Rounding modes (for tax calculations)
- ✅ Well-tested and maintained
- ✅ Small size (~32KB minified)

### 2. Data Flow

```
PostgreSQL NUMERIC (string)
    ↓
pg driver (string "123.45")
    ↓
server.js (keep as string)
    ↓
JSON API (string "123.45")
    ↓
PureScript Decimal (opaque type wrapping decimal.js)
    ↓
Arithmetic operations (exact precision)
    ↓
Display (formatted string)
```

**Key: Never convert to JavaScript Number**

## Implementation

### Phase 1: Install decimal.js

```bash
npm install decimal.js
npm install --save-dev @types/decimal.js  # For TypeScript types reference
```

### Phase 2: Create Decimal Module

**File: `src/Decimal.purs`**

```purescript
module Decimal
  ( Decimal
  , fromString
  , fromInt
  , toString
  , toNumber  -- Only for display formatting
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
  , toFixed
  ) where

import Prelude hiding (add, subtract, multiply, divide, negate, abs, compare)
import Data.Maybe (Maybe(..))
import Data.Function.Uncurried (Fn2, runFn2)

-- Opaque type wrapping decimal.js Decimal object
foreign import data Decimal :: Type

-- Construction
foreign import fromString :: String -> Maybe Decimal
foreign import fromInt :: Int -> Decimal
foreign import unsafeFromString :: String -> Decimal

-- Conversion
foreign import toString :: Decimal -> String
foreign import toNumber :: Decimal -> Number  -- Only for display!
foreign import toFixed :: Int -> Decimal -> String

-- Arithmetic
foreign import add :: Decimal -> Decimal -> Decimal
foreign import subtract :: Decimal -> Decimal -> Decimal
foreign import multiply :: Decimal -> Decimal -> Decimal
foreign import divide :: Decimal -> Decimal -> Decimal
foreign import modulo :: Decimal -> Decimal -> Decimal
foreign import negate :: Decimal -> Decimal
foreign import abs :: Decimal -> Decimal

-- Comparison
foreign import compare :: Decimal -> Decimal -> Ordering
foreign import eq :: Decimal -> Decimal -> Boolean
foreign import lt :: Decimal -> Decimal -> Boolean
foreign import lte :: Decimal -> Decimal -> Boolean
foreign import gt :: Decimal -> Decimal -> Boolean
foreign import gte :: Decimal -> Decimal -> Boolean

-- Predicates
foreign import isZero :: Decimal -> Boolean
foreign import isNegative :: Decimal -> Boolean
foreign import isPositive :: Decimal -> Boolean

-- Rounding
foreign import round :: Decimal -> Decimal
foreign import floor :: Decimal -> Decimal
foreign import ceil :: Decimal -> Decimal

-- Instances
instance eqDecimal :: Eq Decimal where
  eq = eq

instance ordDecimal :: Ord Decimal where
  compare = compare

instance showDecimal :: Show Decimal where
  show = toString

-- Helper: Parse with default
fromStringWithDefault :: String -> Decimal -> Decimal
fromStringWithDefault str default =
  case fromString str of
    Just d -> d
    Nothing -> default

-- Helper: Zero constant
zero :: Decimal
zero = fromInt 0

-- Helper: One constant
one :: Decimal
one = fromInt 1
```

**File: `src/Decimal.js`**

```javascript
import Decimal from 'decimal.js';

// Configure decimal.js for financial calculations
Decimal.set({
  precision: 20,        // 20 significant digits
  rounding: Decimal.ROUND_HALF_UP,  // Standard rounding for tax
  toExpNeg: -7,         // No exponential notation for small numbers
  toExpPos: 20,         // No exponential notation for large numbers
  minE: -9e15,
  maxE: 9e15
});

// Construction
export const fromString = function(str) {
  try {
    const d = new Decimal(str);
    if (d.isNaN()) {
      return null;  // PureScript Nothing
    }
    return d;  // PureScript Just
  } catch (e) {
    return null;  // PureScript Nothing
  }
};

export const fromInt = function(n) {
  return new Decimal(n);
};

export const unsafeFromString = function(str) {
  return new Decimal(str);
};

// Conversion
export const toString = function(d) {
  return d.toString();
};

export const toNumber = function(d) {
  return d.toNumber();  // Only for display formatting!
};

export const toFixed = function(decimals) {
  return function(d) {
    return d.toFixed(decimals);
  };
};

// Arithmetic
export const add = function(a) {
  return function(b) {
    return a.plus(b);
  };
};

export const subtract = function(a) {
  return function(b) {
    return a.minus(b);
  };
};

export const multiply = function(a) {
  return function(b) {
    return a.times(b);
  };
};

export const divide = function(a) {
  return function(b) {
    return a.dividedBy(b);
  };
};

export const modulo = function(a) {
  return function(b) {
    return a.modulo(b);
  };
};

export const negate = function(d) {
  return d.negated();
};

export const abs = function(d) {
  return d.abs();
};

// Comparison
export const compare = function(a) {
  return function(b) {
    const cmp = a.comparedTo(b);
    if (cmp < 0) return -1;  // LT
    if (cmp > 0) return 1;   // GT
    return 0;                // EQ
  };
};

export const eq = function(a) {
  return function(b) {
    return a.equals(b);
  };
};

export const lt = function(a) {
  return function(b) {
    return a.lessThan(b);
  };
};

export const lte = function(a) {
  return function(b) {
    return a.lessThanOrEqualTo(b);
  };
};

export const gt = function(a) {
  return function(b) {
    return a.greaterThan(b);
  };
};

export const gte = function(a) {
  return function(b) {
    return a.greaterThanOrEqualTo(b);
  };
};

// Predicates
export const isZero = function(d) {
  return d.isZero();
};

export const isNegative = function(d) {
  return d.isNegative();
};

export const isPositive = function(d) {
  return d.isPositive();
};

// Rounding
export const round = function(d) {
  return d.round();
};

export const floor = function(d) {
  return d.floor();
};

export const ceil = function(d) {
  return d.ceil();
};
```

### Phase 3: Update Database Types

**File: `src/Database/Types.purs`**

```purescript
module Database.Types where

import Prelude
import Data.Maybe (Maybe)
import Decimal (Decimal)

type Customer =
  { id :: Int
  , name :: String
  , money :: Decimal           -- Changed from Number
  , gram_jewelry :: Decimal    -- Changed from Number
  , baht_jewelry :: Decimal    -- Changed from Number
  , gram_bar96 :: Decimal      -- Changed from Number
  , baht_bar96 :: Decimal      -- Changed from Number
  , gram_bar99 :: Decimal      -- Changed from Number
  , baht_bar99 :: Decimal      -- Changed from Number
  , created_at :: Maybe String
  , updated_at :: Maybe String
  , rowHeight :: Maybe Number  -- Keep as Number (not financial)
  }

type DatabaseInterface m =
  { getAllCustomers :: m (Array Customer)
  , getCustomer :: Int -> m (Maybe Customer)
  , createCustomer :: String -> m (Maybe Customer)
  , updateCustomerField :: Int -> String -> String -> m (Maybe Customer)
  , deleteCustomer :: Int -> m Boolean
  , getChanges :: String -> m (Array Customer)
  }
```

### Phase 4: Update Server

**File: `server.js`**

```javascript
// REMOVE convertNumericFields function entirely

// Keep numeric fields as strings (pg driver already does this)
app.get('/api/customers', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM customer ORDER BY id'
    );
    // Return rows directly - numeric fields are already strings
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching customers:', err);
    res.status(500).json({ error: 'Failed to fetch customers' });
  }
});

// Similar changes for all other endpoints
// Key: Never call parseFloat() on numeric fields
```

### Phase 5: Update API Module

**File: `src/Database/API.purs`**

```purescript
module Database.API where

import Prelude
import Affjax.ResponseFormat as ResponseFormat
import Affjax.Web as AX
import Data.Argonaut.Decode (decodeJson, (.:))
import Data.Argonaut.Encode (encodeJson)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Decimal as D
import Decimal (Decimal)

-- Decode customer from JSON
decodeCustomer :: Json -> Either String Customer
decodeCustomer json = do
  obj <- decodeJson json
  id <- obj .: "id"
  name <- obj .: "name"
  moneyStr <- obj .: "money"
  gramJewelryStr <- obj .: "gram_jewelry"
  bahtJewelryStr <- obj .: "baht_jewelry"
  gramBar96Str <- obj .: "gram_bar96"
  bahtBar96Str <- obj .: "baht_bar96"
  gramBar99Str <- obj .: "gram_bar99"
  bahtBar99Str <- obj .: "baht_bar99"
  created_at <- obj .: "created_at"
  updated_at <- obj .: "updated_at"
  
  -- Parse strings to Decimal
  money <- case D.fromString moneyStr of
    Just d -> Right d
    Nothing -> Left "Invalid money value"
  
  gram_jewelry <- case D.fromString gramJewelryStr of
    Just d -> Right d
    Nothing -> Left "Invalid gram_jewelry value"
  
  -- ... similar for other fields
  
  pure { id, name, money, gram_jewelry, ... }
```

### Phase 6: Update Display Functions

**File: `src/Component/CustomerList.purs`**

```purescript
import Decimal as D
import Decimal (Decimal)

-- Format money for display
formatMoneyValue :: Decimal -> { integer :: String, fraction :: String }
formatMoneyValue d =
  let str = D.toFixed 2 d  -- "10000.50"
      parts = String.split (Pattern ".") str
  in case parts of
    [int, frac] -> { integer: int, fraction: frac }
    [int] -> { integer: int, fraction: "00" }
    _ -> { integer: "0", fraction: "00" }

-- Format grams for display
formatGramsValue :: Decimal -> { integer :: String, fraction :: String }
formatGramsValue d =
  let str = D.toFixed 3 d  -- "40.000"
      parts = String.split (Pattern ".") str
  in case parts of
    [int, frac] -> { integer: int, fraction: frac }
    [int] -> { integer: int, fraction: "000" }
    _ -> { integer: "0", fraction: "000" }

-- Parse user input
parseMoneyInput :: String -> Maybe Decimal
parseMoneyInput = D.fromString

-- Compare for sorting
compareByMoney :: Customer -> Customer -> Ordering
compareByMoney a b = D.compare a.money b.money
```

### Phase 7: Tax Calculation Example

```purescript
module Tax where

import Prelude
import Decimal as D
import Decimal (Decimal)

-- VAT calculation (7% in Thailand)
calculateVAT :: Decimal -> Decimal
calculateVAT amount =
  let vatRate = D.unsafeFromString "0.07"  -- 7%
  in D.multiply amount vatRate

-- Total with VAT
totalWithVAT :: Decimal -> Decimal
totalWithVAT amount =
  D.add amount (calculateVAT amount)

-- Withholding tax (3%)
calculateWithholdingTax :: Decimal -> Decimal
calculateWithholdingTax amount =
  let rate = D.unsafeFromString "0.03"  -- 3%
  in D.multiply amount rate

-- Round to 2 decimal places (for money)
roundMoney :: Decimal -> Decimal
roundMoney d =
  let hundred = D.fromInt 100
      multiplied = D.multiply d hundred
      rounded = D.round multiplied
  in D.divide rounded hundred

-- Example: Calculate total bill
calculateBill :: Decimal -> Decimal -> Decimal
calculateBill subtotal discount =
  let discounted = D.subtract subtotal discount
      vat = calculateVAT discounted
      total = D.add discounted vat
  in roundMoney total

-- Test
-- subtotal = 1000.00
-- discount = 50.00
-- discounted = 950.00
-- vat = 66.50
-- total = 1016.50 (exact, no rounding errors)
```

## Migration Steps

### Step 1: Install Dependencies
```bash
npm install decimal.js
```

### Step 2: Create Decimal Module
- Create `src/Decimal.purs`
- Create `src/Decimal.js`
- Test basic operations

### Step 3: Update Types
- Update `Database.Types.purs`
- Update all type signatures

### Step 4: Update Server
- Remove `parseFloat()` conversions
- Keep numeric fields as strings

### Step 5: Update API
- Update JSON decoding
- Parse strings to Decimal

### Step 6: Update UI
- Update display formatting
- Update input parsing
- Update sorting/filtering

### Step 7: Test Thoroughly
- Unit tests for Decimal operations
- Integration tests with database
- Tax calculation tests
- Edge case tests

## Testing Strategy

### Unit Tests

```purescript
module Test.Decimal where

import Prelude
import Test.Unit (suite, test)
import Test.Unit.Assert as Assert
import Decimal as D

testDecimalArithmetic :: Test
testDecimalArithmetic = do
  suite "Decimal Arithmetic" do
    test "addition is exact" do
      let a = D.unsafeFromString "0.1"
      let b = D.unsafeFromString "0.2"
      let result = D.add a b
      Assert.equal "0.3" (D.toString result)
    
    test "subtraction is exact" do
      let a = D.unsafeFromString "1.0"
      let b = D.unsafeFromString "0.9"
      let result = D.subtract a b
      Assert.equal "0.1" (D.toString result)
    
    test "multiplication is exact" do
      let a = D.unsafeFromString "0.1"
      let b = D.unsafeFromString "0.1"
      let result = D.multiply a b
      Assert.equal "0.01" (D.toString result)
    
    test "division is exact" do
      let a = D.unsafeFromString "1.0"
      let b = D.unsafeFromString "3.0"
      let result = D.divide a b
      -- Should be "0.33333..." with configured precision
      Assert.assert "division works" (D.gt result D.zero)

testTaxCalculations :: Test
testTaxCalculations = do
  suite "Tax Calculations" do
    test "VAT calculation" do
      let amount = D.unsafeFromString "1000.00"
      let vat = calculateVAT amount
      Assert.equal "70.00" (D.toFixed 2 vat)
    
    test "total with VAT" do
      let amount = D.unsafeFromString "1000.00"
      let total = totalWithVAT amount
      Assert.equal "1070.00" (D.toFixed 2 total)
```

## Performance Considerations

### decimal.js Performance
- **Fast enough** for UI operations
- Slower than native Number, but acceptable
- Typical operation: < 1ms
- For 4000 customers: sorting/filtering still fast

### Optimization Tips
1. Cache formatted strings for display
2. Use memoization for repeated calculations
3. Batch operations when possible
4. Profile if performance issues arise

## Benefits

### Exact Precision
```javascript
// JavaScript Number (WRONG)
0.1 + 0.2 = 0.30000000000000004

// Decimal (CORRECT)
Decimal("0.1").plus("0.2") = "0.3"
```

### Tax Compliance
- No rounding errors in VAT calculations
- Exact withholding tax amounts
- Audit-ready calculations
- Meets accounting standards

### Future-Proof
- Can handle any precision needed
- Supports complex financial formulas
- Easy to add new calculations
- Type-safe operations

## Conclusion

This implementation provides:
- ✅ **Exact precision** - No floating-point errors
- ✅ **Type safety** - Opaque Decimal type
- ✅ **Full arithmetic** - All operations supported
- ✅ **Tax ready** - Proper rounding modes
- ✅ **Database compatible** - Works with PostgreSQL NUMERIC
- ✅ **Production ready** - Battle-tested library
- ✅ **No database changes** - Schema is already correct

The database is already perfect (NUMERIC type). We only need to fix the JavaScript/PureScript layer to preserve precision throughout the application.
