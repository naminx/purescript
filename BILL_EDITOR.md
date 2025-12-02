# Bill Editor Module - Complete Specification

## Project Context

You are building a **Bill Editor Module** (บิลลูกค้า) for a Gold Jewelry Shop system using **PureScript**, **Halogen**, and **PostgreSQL**. This is an addition to an existing system that already has:

1. **"Today's Bills" page** - implemented and live
2. **"Customer Management" page** - implemented and live with virtual scrolling

**Module Name:** "Bill Editor" - Clear, concise, matches "Today's Bills" naming pattern.

## Technology Stack

- **Backend**: PureScript with HTTPure
- **Frontend**: PureScript with Halogen
- **Database**: PostgreSQL 14+
- **Real-time**: WebSocket for multi-clerk collaboration
- **Virtual Scrolling**: Custom implementation (already available)
- **Drag-and-Drop**: FFI to JavaScript libraries

## Critical Requirements Summary

### ⚠️ MOST IMPORTANT RULES (Read First!)

1. **NEVER automatically convert between grams and baht**
   - Clerk must explicitly choose ONE unit (grams OR baht, never both)
   - If customer gives 10g → Add ONLY to gram_jewel, leave baht_jewel untouched
   - If customer gives 5 baht → Add ONLY to baht_jewel, leave gram_jewel untouched

2. **Price rate is ALWAYS in THB/baht**
   - If transaction is in grams, multiply by 0.0656 to get baht equivalent for charge calculation
   - Example: 10g at 40,000 THB/baht → 10 × 0.0656 × 40,000 = 26,240 THB

3. **Conversion between gold types** (Jewelry ↔ Bar96)
   - Clerk specifies BOTH source unit AND destination unit independently
   - Source can be 10g, destination can be 2 baht (different amounts, different units)
   - Charge is calculated based on destination amount

4. **Split Bar** - Always in baht unit
   - Net weight change is zero (only charge applies)
   - Example: Split 5 baht → Debit 5 baht, Credit 5 baht, Charge = 5 × split_rate

5. **Dual-unit system purpose**
   - Prevents rounding errors
   - Customer can have credit grams but debit baht (or vice versa)
   - Only explicit "Convert Grams to Baht" / "Convert Baht to Grams" transactions do unit conversion

### 0. VAT (Value Added Tax) Calculation

**CRITICAL: VAT applies ONLY to customer buying gold jewelry (non-return trays)**

#### What Gets Taxed?
1. **Jewelry making charges** (after discount) - YES, VAT EXCLUSIVE
2. **99.99% premium** - YES, VAT EXCLUSIVE (MUST be set if purity > 96.5%)
3. **Spread** (difference between selling price and market buying price) - YES, VAT EXCLUSIVE
4. **Gold bar making charges** (block mold cost for 1-2 baht bars) - YES, VAT INCLUSIVE
5. **Conversion charges** - NO (between shop and customer only)
6. **Split bar charges** - NO (between shop and customer only)
7. **Gold bars (weight)** - NO (exempted from VAT in Thailand)
8. **Customer selling to us** - NO (only buying is taxed)
9. **Return trays** - NO (if bill has returns, VAT is deferred)

#### VAT Rate
- **Current:** 7% flat for all items
- **Adjustable:** Government may change rate in future
- **Applied:** Per bill total (not per item)

#### VAT Calculation Formula

**For Jewelry (Trays):**
```
For each non-return tray:
  Total gold weight = actual_weight_grams × 0.0656 baht
  
  Making charge after discount = sum(tray_items.amount) × (100 - discount) / 100
  
  99.99% premium = IF purity == 100.0 THEN
                     total_weight × additional_charge_rate
                   ELSE
                     0
  
  Total charges = making_charge_after_discount + premium

Net amount = total_weight × selling_price + total_charges

Market buying price = (input by clerk, announced by Gold Traders Association)
Deduction = total_weight × market_buying_price

Taxable amount (VAT EXCLUSIVE) = net_amount - deduction

VAT amount = ROUND(taxable_amount × vat_rate / 100, 2)

Grand total = net_amount + vat_amount
```

**For Gold Bars (Transactions - Buy Bar96/Bar99):**
```
For each "Buy Bar96" or "Buy Bar99" transaction:
  Gold weight = amount_grams × 0.0656 OR amount_baht (whichever is set)
  
  Gold cost = gold_weight × price_rate
  
  Block making charge = gold_weight × block_making_charge_rate (VAT INCLUSIVE)
  
  VAT amount (extracted from making charge) = ROUND(block_making_charge × vat_rate / (100 + vat_rate), 2)
  
  Net amount = gold_cost + block_making_charge

Note: Block making charge is VAT INCLUSIVE (already contains VAT)
      VAT is extracted, not added: VAT = charge × 7/107
```

**Combined Bill VAT:**
```
Total VAT = Jewelry VAT (exclusive) + Bar Making Charge VAT (extracted from inclusive)
```

#### VAT Display Format

```
Total gold weight: aaa grams (bbb baht)
Total making charge + premium (after discount): ccc THB
Selling price: ddd THB/baht
Net amount = bbb × ddd + ccc = eee THB

Market buying price (announced): fff THB/baht
Deduction amount: bbb × fff = ggg THB

Taxable amount: eee - ggg = hhh THB
VAT rate: iii %
Tax amount: ROUND(hhh × iii / 100, 2) = jjj THB

Grand total: eee + jjj = kkk THB
```

#### VAT Determination

**Bill is VAT taxable IF:**
- Clerk unchecks "VAT Deferred" checkbox (default is checked)
- Bill contains ONLY non-return trays (no return trays)
- Bill settles in money only (no gold balance change)
- Market buying price is set

**Bill is VAT deferred IF:**
- Clerk checks "VAT Deferred" checkbox
- Bill contains return trays
- Bill settles with gold balance change (mixed settlement)

#### VAT Validation Rules

1. **If purity > 96.5%** → `additional_charge_rate` MUST be set (not NULL)
   - Error: "99.99% premium rate must be set for high purity gold"
   
2. **If VAT not deferred** → `market_buying_price_jewel` MUST be set
   - Error: "Market buying price must be set for VAT calculation"

3. **If bill has return trays** → VAT MUST be deferred
   - Warning: "Bill contains returns, VAT is automatically deferred"

4. **For Buy Bar96/Bar99 transactions** → `block_making_charge_rate` is optional
   - If set: Making charge is VAT INCLUSIVE, VAT extracted using formula: VAT = charge × 7/107
   - If not set: No making charge, only gold cost
   - Note: Typically used for small bars (1-2 baht) where block mold cost applies

#### VAT Examples

**Example 1: Jewelry Only (VAT Exclusive)**

**Tray 1:** Customer buys 99.99% jewelry
- Making charge: 5,000 THB
- Discount: 10%
- After discount: 4,500 THB
- Gold weight: 10g (0.656 baht)
- Selling price: 40,000 THB/baht
- 99.99% premium rate: 1,400 THB/baht

**Calculation:**
```
Total weight: 10g × 0.0656 = 0.656 baht
Making charge: 4,500 THB
Premium: 0.656 × 1,400 = 918.4 THB
Total charges: 4,500 + 918.4 = 5,418.4 THB

Net amount: 0.656 × 40,000 + 5,418.4 = 26,240 + 5,418.4 = 31,658.4 THB

Market buying price: 39,500 THB/baht
Deduction: 0.656 × 39,500 = 25,912 THB

Taxable amount (VAT EXCLUSIVE): 31,658.4 - 25,912 = 5,746.4 THB
VAT (7%): ROUND(5,746.4 × 0.07, 2) = 402.25 THB

Grand total: 31,658.4 + 402.25 = 32,060.65 THB
```

**Example 2: Gold Bars Only (VAT Inclusive)**

**Transaction 1:** Buy Gold Bar 96.5%
- Quantity: 1 baht × 3 pcs = 3 baht
- Selling price: 41,000 THB/baht
- Block making charge rate: 150 THB/baht (VAT INCLUSIVE)

**Transaction 2:** Buy Gold Bar 96.5%
- Quantity: 2 baht × 2 pcs = 4 baht
- Selling price: 41,000 THB/baht
- Block making charge rate: 120 THB/baht (VAT INCLUSIVE)

**Calculation:**
```
Gold cost:
  Transaction 1: 3 baht × 41,000 = 123,000 THB
  Transaction 2: 4 baht × 41,000 = 164,000 THB
  Total gold cost: 287,000 THB

Making charges (VAT INCLUSIVE):
  Transaction 1: 3 baht × 150 = 450 THB
  Transaction 2: 4 baht × 120 = 480 THB
  Total making charge: 930 THB

VAT (extracted from inclusive making charge):
  VAT = ROUND(930 × 7 / 107, 2) = 60.84 THB

Customer net payable: 287,000 + 930 = 287,930 THB
(VAT of 60.84 THB is already included in the 930 THB)
```

**Example 3: Combined Bill (Jewelry + Bars)**

**Tray 1:** Customer buys jewelry
- Making charge after discount: 4,500 THB
- Gold weight: 0.656 baht
- Selling price: 40,000 THB/baht
- Market buying price: 39,500 THB/baht
- Taxable amount: 5,746.4 THB (VAT EXCLUSIVE)
- VAT: 402.25 THB

**Transaction 1:** Buy Gold Bar 96.5%
- 3 baht × 41,000 = 123,000 THB
- Making charge: 450 THB (VAT INCLUSIVE)
- VAT extracted: 29.44 THB

**Transaction 2:** Buy Gold Bar 96.5%
- 4 baht × 41,000 = 164,000 THB
- Making charge: 480 THB (VAT INCLUSIVE)
- VAT extracted: 31.40 THB

**Pack 1:** Customer brings used gold (NOT taxed)
- Credit: 12,972.4 THB

**Transaction 3:** Money In
- Credit: 20,000 THB

**Bill Total:**
```
Debits:
  Jewelry: 31,658.4 + 402.25 (VAT) = 32,060.65 THB
  Bar 1: 123,000 + 450 (incl VAT) = 123,450 THB
  Bar 2: 164,000 + 480 (incl VAT) = 164,480 THB
  Total debit: 319,990.65 THB

Credits:
  Pack: 12,972.4 THB
  Money: 20,000 THB
  Total credit: 32,972.4 THB

Balance: 287,018.25 THB debit (customer owes us)

Total VAT collected:
  Jewelry VAT (exclusive): 402.25 THB
  Bar 1 VAT (extracted): 29.44 THB
  Bar 2 VAT (extracted): 31.40 THB
  Total VAT: 463.09 THB
```

**Note:** 
- Jewelry making charges → VAT is ADDED (exclusive)
- Bar making charges → VAT is EXTRACTED (inclusive)
- Packs do NOT contribute to taxable amount

### 1. Gold Price Management

**IMPORTANT**: Announced gold price is input on the **"Today's Bills" page**, NOT in individual bills.

- Today's Bills page has a global gold price input field
- All bills created today use this announced price as reference
- Individual transactions (buy/sell gold) can use custom prices (with validation against announced price)

### 2. Customer Balance Structure

Each customer has **THREE types of gold**, each tracked in **DUAL UNITS**:

| Gold Type                     | Grams Balance | Baht Balance |
| ----------------------------- | ------------- | ------------ |
| Gold Jewelry (รูปพรรณ)        | `gram_jewel`  | `baht_jewel` |
| Gold Bar 96.5% (แท่ง 96.5%)   | `gram_bar96`  | `baht_bar96` |
| Gold Bar 99.99% (แท่ง 99.99%) | `gram_bar99`  | `baht_bar99` |

Plus: `balance_money` (NUMERIC(12,2))

**Purpose of dual units**: Prevent rounding errors. Customer can have credit grams but debit baht (or vice versa).

### 3. Gold Shape and Purity

**IMPORTANT**: Gold is defined by two attributes:

**Shape**:

- `Jewelry` (รูปพรรณ) - ornamental gold jewelry
- `Bar` (แท่ง) - gold bars

**Purity**:

- `Nothing` (NULL in database) = 96.5% (standard)
- `Just 100.0` = 99.99% (pure)
- `Just x` = custom percentage (42.5%, 53.125%, 80%, 90%, etc.)

**Balance Storage Rules**:

- Only 3 balance types stored: `jewel` (96.5%), `bar96` (96.5%), `bar99` (99.99%)
- Jewelry with purity ≠ 96.5% converts to equivalent 96.5% jewelry
  - Example: 10g of 42.5% jewelry → 4.4g of 96.5% jewelry (10 × 42.5% / 96.5%)

```purescript
-- Types
data Shape = Jewelry | Bar
derive instance eqShape :: Eq Shapetype Purity = Maybe Number
-- Nothing = 96.5%, Just 100.0 = 99.99%, Just x = x%type GoldType = { shape :: Shape, purity :: Purity }-- Balance types (only 3)
data BalanceType = Jewel | Bar96 | Bar99-- Convert GoldType to BalanceType
toBalanceType :: GoldType -> BalanceType
toBalanceType { shape: Bar, purity: Just 100.0 } = Bar99
toBalanceType { shape: Bar, purity: _ } = Bar96
toBalanceType { shape: Jewelry, purity: _ } = Jewel
```

### 4. Data Type Precision

| Field  | Type          | Range                        |
| ------ | ------------- | ---------------------------- |
| Money  | NUMERIC(12,2) | Up to 9,999,999,999.99 THB   |
| Weight | NUMERIC(10,3) | Up to 1,000,000.000g (1 ton) |

### 5. Purity Representation (Database Trick)

**CRITICAL**: Use this encoding for `purity` column:

| Database Value       | Meaning          | Display | SQL Calculation                  |
| -------------------- | ---------------- | ------- | -------------------------------- |
| `NULL`               | 96.5% (standard) | 96.5%   | `COALESCE(purity, 100) * weight` |
| `100`                | 99.99% (pure)    | 99.99%  | `COALESCE(purity, 100) * weight` |
| Literal (e.g., 42.5) | Custom %         | 42.5%   | `COALESCE(purity, 100) * weight` |

**Why**: In Thailand, both 96.5% and 99.99% are treated as "100%" for weight calculations. 96.5% is standard (default NULL). 99.99% gets extra premium charge but weight is not adjusted.

### 6. Constants Module

**All constants must be in a record** (no hard-coded strings/numbers in code):

```purescript
-- Numeric constants
constants ::
  { gramsPerBaht :: D.Decimal              -- 15.244
  , gramsToBahtConversion :: D.Decimal     -- 0.0656 (≈ 1/15.244)
  , priceValidationThreshold :: Money      -- 500 THB/baht
  , typicalSpread :: Money                 -- 100 THB/baht
  , vipSpreadMin :: Money                  -- 80 THB/baht
  , vipSpreadMax :: Money                  -- 90 THB/baht
  , weightRoundingIncrement :: D.Decimal   -- 0.05g
  , pollingIntervalMs :: Int               -- 3000
  , highlightTransitionMs :: Int           -- 300
  , standardPurity :: Number               -- 96.5
  , purePurity :: Number                   -- 99.99
  }

-- Text constants (Thai language)
textConstants ::
  { app :: { title :: String, subtitle :: String }
  , customer :: { ... }
  , bill :: { ... }
  , group :: { tray :: String, pack :: String, transaction :: String, ... }
  , tray :: { new :: String, return :: String, ... }
  , pack :: { ... }
  , transaction ::
      { prevDebitMoney :: String           -- "เก่าค้างเงิน"
      , prevCreditMoney :: String          -- "เก่าเหลือเงิน"
      , prevDebitJewel :: String           -- "เก่าค้างทอง"
      , prevCreditJewel :: String          -- "เก่าเหลือทอง"
      , prevDebitBar96 :: String           -- "เก่าค้างแท่ง 96.5%"
      , prevCreditBar96 :: String          -- "เก่าเหลือแท่ง 96.5%"
      , prevDebitBar99 :: String           -- "เก่าค้างแท่ง 99.99%"
      , prevCreditBar99 :: String          -- "เก่าเหลือแท่ง 99.99%"
      , inMoney :: String                  -- "มาเงิน"
      , outMoney :: String                 -- "ไปเงิน"
      , inJewel :: String                  -- "มาทอง"
      , outJewel :: String                 -- "ไปทอง"
      , inBar96 :: String                  -- "มาแท่ง 96.5%"
      , outBar96 :: String                 -- "ไปแท่ง 96.5%"
      , inBar99 :: String                  -- "มาแท่ง 99.99%"
      , outBar99 :: String                 -- "ไปแท่ง 99.99%"
      , buyJewel :: String                 -- "ตัดซื้อทอง"
      , sellJewel :: String                -- "ตัดขายทอง"
      , buyBar96 :: String                 -- "ซื้อแท่ง 96.5%"
      , sellBar96 :: String                -- "ขายแท่ง 96.5%"
      , buyBar99 :: String                 -- "ซื้อแท่ง 99.99%"
      , sellBar99 :: String                -- "ขายแท่ง 99.99%"
      , convertJewelryToBar96 :: String    -- "แปลงรูปพรรณเป็นแท่ง"
      , convertGramsToBaht :: String       -- "แปลงกรัมเป็นบาท"
      , convertBahtToGrams :: String       -- "แปลงบาทเป็นกรัม"
      , splitBar :: String                 -- "แบ่งแท่ง"
      }
  , shape ::
      { jewelry :: String                  -- "รูปพรรณ"
      , bar :: String                      -- "แท่ง"
      }
  , balanceType ::
      { jewel :: String                    -- "ทอง"
      , bar96 :: String                    -- "แท่ง 96.5%"
      , bar99 :: String                    -- "แท่ง 99.99%"
      }
  , validation :: { ... }
  , actions :: { ... }
  , messages :: { ... }
  }
```

### 7. Quarter Baht Symbol

Use **"ส"** (NOT "สล") for quarter baht (สลึง).

Example: `½ส`, `1ส`, `2ส`, `3ส`, `6ส`

### 8. Virtual Scrolling

**NOT NEEDED** for billing statement module. Bills typically have a few dozen items, so render all items without virtual scrolling. Virtual scrolling is only used in Customer Management module where there are thousands of customers.

## Bill Structure

### Overview

A bill contains **three types of groups** (all drag-and-drop reorderable):

1. **Trays** - New jewelry purchases or returns
2. **Packs** - Used gold buyback
3. **Transactions** - Payments, withdrawals, gold conversions

### Group Type A: Trays (New/Return Gold Jewelry)

#### Tray Settings (All fields editable by clerk)

| Field                  | Type                | Notes                                                            |
| ---------------------- | ------------------- | ---------------------------------------------------------------- |
| Type                   | New / Return        | Return = opposite sign                                           |
| Shape                  | Jewelry / Bar       | Always Jewelry for trays                                         |
| Purity                 | NULL / 100 / custom | NULL=96.5%, 100=99.99%                                           |
| Actual Weight          | grams               | Measured                                                         |
| Price Rate             | THB/baht or NULL    | NULL = Money & Gold settlement<br>Number = Money Only settlement |
| Discount               | 0% / 5% / 10%       | On making charges only                                           |
| Additional Charge Rate | THB/baht            | For 99.99% purity only                                           |

**Note**: No explicit "Settlement" field. If `price_rate` is NULL → settle in Money & Gold. If `price_rate` is a number → settle in Money Only.

#### Tray Items (editable by clerk)

| Field          | Editable | Notes                                                   |
| -------------- | -------- | ------------------------------------------------------- |
| Making Charge  | Yes      | THB per piece                                           |
| Jewelry Type   | No       | Dropdown from database                                  |
| Design Name    | Yes      | Free text                                               |
| Nominal Weight | Yes      | Dropdown: ½ส, 1ส, 2ส, 3ส, 1บ, 6ส, 2บ, 3บ, 4บ, 5บ, Other |
| Quantity       | Yes      | Integer                                                 |
| Amount         | No       | Auto: Quantity × Making Charge                          |

#### Tray Calculations

```
Total Nominal Weight = Sum(item.nominalWeight × item.quantity)
Total Making Charge = Sum(item.amount) × (1 - discount/100)

If purity < 96.5%:
  Effective Weight = ROUND(actualWeight × purity / 100, 0.050g)
Else:
  Effective Weight = actualWeight

If purity > 96.5%:
  Additional Charge = ROUND(effectiveWeight × 0.0656 × additionalChargeRate)

If price_rate is NULL (Money & Gold):
  -- Convert non-standard purity to 96.5% equivalent
  If purity < 96.5%:
    -- Example: 10g of 42.5% jewelry → 4.25g of 96.5% jewelry
    -- This is not a mistake. 96.5% is considered default.
    equivalentWeight = ROUND(effectiveWeight × purity / 100, 0.050g)
    Debit gram_jewel: equivalentWeight
  Else:
    Debit appropriate balance type (jewel/bar96/bar99)

  Money Debit = totalMakingCharge + additionalCharge

Else if price_rate is a Number (Money Only):
  Money Debit = ROUND(effectiveWeight × 0.0656 × price_rate) + totalMakingCharge + additionalCharge
  No gold debit

If isReturn:
  Negate all values (credit instead of debit)
```

### Group Type B: Packs (Used Gold Buyback)

#### Pack Settings

| Field       | Type    | Notes                   |
| ----------- | ------- | ----------------------- |
| Internal ID | Integer | Auto-generated          |
| User Number | String  | Clerk inputs pack label |

#### Pack Items (all fields editable by clerk)

| Field          | Notes                                |
| -------------- | ------------------------------------ |
| Deduction Rate | "500", "42.5%", "+300", "+3%"        |
| Shape          | Jewelry / Bar                        |
| Purity         | NULL (96.5%) / 100 (99.99%) / custom |
| Description    | Free text or auto-filled             |
| Weight         | "10g" or "5บ"                        |

#### Pack Item Calculations

```
If deductionRate contains "%":
  If starts with "+":
    // Higher purity than 96.5%: Addition (money credit only)
    percentage = parse(deductionRate)
    effectiveWeight = weight × (100 + percentage) / 100
    goldCredit = effectiveWeight
    moneyCredit = 0
  Else:
    // Lower purity: Adjust weight
    percentage = parse(deductionRate)
    effectiveWeight = ROUND(weight × percentage / 100, 0.050g)
    goldCredit = effectiveWeight
    moneyDebit = 0
Else:
  // Per-baht deduction
  rate = parse(deductionRate)
  If starts with "+":
    // Addition
    moneyCredit = ROUND(weight × 0.0656 × rate)
    goldCredit = weight
  Else:
    // Deduction
    moneyDebit = ROUND(weight × 0.0656 × rate)
    goldCredit = weight

// Credit to appropriate balance type
balanceType = toBalanceType({ shape, purity })

If balanceType = Jewel:
  If purity ≠ 96.5%:
    -- Convert to 96.5% equivalent
    equivalentWeight = ROUND(goldCredit × purity / 96.5, 0.050g)
    gram_jewel += equivalentWeight
  Else:
    gram_jewel += goldCredit

Else if balanceType = Bar96:
  gram_bar96 += goldCredit

Else if balanceType = Bar99:
  gram_bar99 += goldCredit
```

### Group Type C: Transactions

#### Transaction Types

| Type                            | Thai               | Effect                               | Fields                                          |
| ------------------------------- | ------------------ | ------------------------------------ | ----------------------------------------------- |
| Previous Balance (Debit/Credit) | เก่าค้าง/เก่าเหลือ | Load from customer                   | Non-deletable, non-editable                     |
| Money In                        | มาเงิน             | Money credit                         | amount_money                                    |
| Money Out                       | ไปเงิน             | Money debit                          | amount_money                                    |
| Jewel In                        | มาทอง              | Jewel credit (grams OR baht)         | amount_gold: Either grams baht (ONE unit only)  |
| Jewel Out                       | ไปทอง              | Jewel debit (grams OR baht)          | amount_gold: Either grams baht (ONE unit only)  |
| Bar96 In                        | มาแท่ง 96.5%       | Bar96 credit (grams OR baht)         | amount_gold: Either grams baht (ONE unit only)  |
| Bar96 Out                       | ไปแท่ง 96.5%       | Bar96 debit (grams OR baht)          | amount_gold: Either grams baht (ONE unit only)  |
| Bar99 In                        | มาแท่ง 99.99%      | Bar99 credit (grams OR baht)         | amount_gold: Either grams baht (ONE unit only)  |
| Bar99 Out                       | ไปแท่ง 99.99%      | Bar99 debit (grams OR baht)          | amount_gold: Either grams baht (ONE unit only)  |
| Buy Jewel                       | ตัดซื้อทอง         | Jewel credit, Money debit            | amount_gold: Either grams baht (ONE unit), price_rate (THB/baht) |
| Sell Jewel                      | ตัดขายทอง          | Jewel debit, Money credit            | amount_gold: Either grams baht (ONE unit), price_rate (THB/baht) |
| Buy Bar96                       | ซื้อแท่ง 96.5%     | Bar96 credit, Money debit            | amount_gold: Either grams baht (ONE unit), price_rate (THB/baht), block_making_charge_rate (THB/baht, VAT INCLUSIVE) |
| Sell Bar96                      | ขายแท่ง 96.5%      | Bar96 debit, Money credit            | amount_gold: Either grams baht (ONE unit), price_rate (THB/baht) |
| Buy Bar99                       | ซื้อแท่ง 99.99%    | Bar99 credit, Money debit            | amount_gold: Either grams baht (ONE unit), price_rate (THB/baht), block_making_charge_rate (THB/baht, VAT INCLUSIVE) |
| Sell Bar99                      | ขายแท่ง 99.99%     | Bar99 debit, Money credit            | amount_gold: Either grams baht (ONE unit), price_rate (THB/baht) |
| Convert Jewelry to Bar96        | แปลงรูปพรรณเป็นแท่ง | Debit jewel, Credit bar96, Debit money (charge) | source_unit: Either grams baht, dest_unit: Either grams baht, conversion_charge_rate (THB/baht) |
| Convert Grams to Baht           | แปลงกรัมเป็นบาท    | Debit grams, Credit baht (same type) | balance_type, amount_grams                      |
| Convert Baht to Grams           | แปลงบาทเป็นกรัม    | Debit baht, Credit grams (same type) | balance_type, amount_baht                       |
| Split Bar                       | แบ่งแท่ง           | Debit/Credit baht (net zero), Debit money (charge) | balance_type, amount_baht, split_charge_rate (THB/baht) |

**Note**: Previous Balance has 8 variants (Debit/Credit × Money/Jewel/Bar96/Bar99)

**CRITICAL RULES:**
1. **Never automatically convert between grams and baht** - clerk must explicitly choose ONE unit
2. **If customer gives 10g** → Add ONLY to gram_jewel, leave baht_jewel untouched
3. **If customer gives 5 baht** → Add ONLY to baht_jewel, leave gram_jewel untouched
4. **Conversion between types** (Jewelry ↔ Bar96) - clerk specifies both source and destination units independently
5. **Split Bar** - Always in baht unit, net weight change is zero (only charge applies)
6. **Price rate is always in THB/baht** - if transaction is in grams, multiply by 0.0656 to get baht equivalent for charge calculation

#### Transaction Examples (Detailed)

**Example 1: Customer gives us 10g of jewelry**
```
Transaction: Jewel In, 10g

Before: gram_jewel = 5g, baht_jewel = 2 baht
After:  gram_jewel = 15g, baht_jewel = 2 baht (unchanged)
```

**Example 2: Customer gives us 3 baht of jewelry**
```
Transaction: Jewel In, 3 baht

Before: gram_jewel = 5g, baht_jewel = 2 baht
After:  gram_jewel = 5g (unchanged), baht_jewel = 5 baht
```

**Example 3: Customer takes out 7g of bar96**
```
Transaction: Bar96 Out, 7g

Before: gram_bar96 = 20g, baht_bar96 = 10 baht
After:  gram_bar96 = 13g, baht_bar96 = 10 baht (unchanged)
```

**Example 4: Buy 10g of jewelry at 40,000 THB/baht**
```
Transaction: Buy Jewel, 10g, price_rate = 40,000 THB/baht

Before: gram_jewel = 5g, baht_jewel = 2 baht, money = 100,000 THB
After:  gram_jewel = 15g, baht_jewel = 2 baht (unchanged), money = 73,760 THB

Calculation:
  Gold credit: +10g to gram_jewel only
  Money debit: 10g × 0.0656 baht/g × 40,000 THB/baht = 26,240 THB
```

**Example 5: Sell 5 baht of bar99 at 41,000 THB/baht**
```
Transaction: Sell Bar99, 5 baht, price_rate = 41,000 THB/baht

Before: gram_bar99 = 50g, baht_bar99 = 8 baht, money = 50,000 THB
After:  gram_bar99 = 50g (unchanged), baht_bar99 = 3 baht, money = 255,000 THB

Calculation:
  Gold debit: -5 baht from baht_bar99 only
  Money credit: 5 baht × 41,000 THB/baht = 205,000 THB
```

**Example 6: Convert 15g jewelry to 2 baht bar96, charge 200 THB/baht**
```
Transaction: Convert Jewelry to Bar96
  Source: 15g jewelry
  Destination: 2 baht bar96
  Charge rate: 200 THB/baht

Before: gram_jewel = 20g, baht_jewel = 5 baht, gram_bar96 = 0g, baht_bar96 = 0 baht, money = 10,000 THB
After:  gram_jewel = 5g, baht_jewel = 5 baht (unchanged), gram_bar96 = 0g (unchanged), baht_bar96 = 2 baht, money = 9,600 THB

Calculation:
  Debit: -15g from gram_jewel
  Credit: +2 baht to baht_bar96
  Money debit: 2 baht × 200 THB/baht = 400 THB
```

#### Conversion Between Grams and Baht (Same Type)

**IMPORTANT**: Only converts the specified unit, never touches the other unit.

```
Example 1: Convert 10g of jewel to baht

Debit: gram_jewel -= 10g
Credit: baht_jewel += (10g × 0.0656) baht

No money charge (same gold, different unit)
Note: If customer has 0 baht_jewel, it becomes positive. If has existing baht_jewel, it increases.

Example 2: Convert 5 baht of bar96 to grams

Debit: baht_bar96 -= 5 baht
Credit: gram_bar96 += (5 × 15.244)g

No money charge (same gold, different unit)
Note: If customer has 0 gram_bar96, it becomes positive. If has existing gram_bar96, it increases.
```

#### Conversion Between Gold Types

**IMPORTANT**: Clerk specifies BOTH source unit AND destination unit independently.

```
Example 1: Convert 10g of jewelry to 10g of bar96

Debit: gram_jewel -= 10g
       (baht_jewel unchanged)

Credit: gram_bar96 += 10g
        (baht_bar96 unchanged)

Money Debit = ROUND(10g × 0.0656 × conversion_charge_rate)

Example 2: Convert 5 baht of jewelry to 3 baht of bar96

Debit: baht_jewel -= 5 baht
       (gram_jewel unchanged)

Credit: baht_bar96 += 3 baht
        (gram_bar96 unchanged)

Money Debit = ROUND(3 baht × conversion_charge_rate)

Example 3: Convert 10g of jewelry to 2 baht of bar96

Debit: gram_jewel -= 10g
       (baht_jewel unchanged)

Credit: baht_bar96 += 2 baht
        (gram_bar96 unchanged)

Money Debit = ROUND(2 baht × conversion_charge_rate)

Note: Source and destination amounts can be different (customer's choice).
      Charge is always calculated based on destination amount.
      If destination is in grams, use: ROUND(grams × 0.0656 × conversion_charge_rate)
```

#### Split Gold Bar

**IMPORTANT**: Always in baht unit. Net weight change is zero (only charge applies).

```
Example: Split 5-baht bar into five 1-baht bars

Debit: baht_bar96 -= 5 baht
Credit: baht_bar96 += 5 baht

Net effect on balance: 0 (same gold, just different physical sizes)

Money Debit = ROUND(5 baht × split_charge_rate)

Note: Splitting is purely administrative (physical bar division).
      Customer still has same total weight, just in smaller pieces.
```

### Accumulated Totals Logic (CRITICAL)

**Key Rule**: Transaction groups are checkpoints.

```
[Transactions 1: Previous Balance = -5000 THB, +10g jewelry]
  Own: -5000, +10g jewelry
  Accumulated: -5000, +10g jewelry

[Tray 1: New jewelry, -1000 THB, +10g]
  Own: -1000, +10g
  Accumulated: -1000, +10g  (RESET after checkpoint)

[Tray 2: New jewelry, -500 THB, +5g]
  Own: -500, +5g
  Accumulated: -1500, +15g  (accumulate from Tray 1)

[Pack 1: Used gold, +5000 THB, +20g bar 965]
  Own: +5000, +20g bar 965
  Accumulated: +3500 THB, +15g jewelry, +20g bar 965

[Transactions 2: Payment +2000 THB]
  Own: +2000, 0g
  Accumulated: +500 THB, +25g jewelry, +20g bar 965  (EVERYTHING from bill start)

[Tray 3: New jewelry, -800 THB, +8g]
  Own: -800, +8g
  Accumulated: -800, +8g  (RESET after checkpoint)

Grand Total: -300 THB, +33g jewelry, +20g bar 965
```

**Algorithm**:

```purescript
calculateAccumulated :: Array BillGroup -> Array BillGroup
calculateAccumulated groups =
  let sorted = sortBy displayOrder groups
      go [] _ billTotal = []
      go (g:gs) lastTxIdx billTotal =
        case g of
          TransactionGroupData tx ->
            -- Checkpoint: accumulate everything
            let newTotal = billTotal + tx.totals
                updated = tx { accumulated = newTotal }
            in updated : go gs (currentIdx) newTotal

          TrayGroupData tray ->
            if lastTxIdx == currentIdx - 1 then
              -- First after transaction: RESET
              let acc = tray.totals
              in tray { accumulated = acc } : go gs lastTxIdx billTotal
            else
              -- Continue accumulation
              let acc = previousAccumulated + tray.totals
              in tray { accumulated = acc } : go gs lastTxIdx billTotal

          -- Same logic for PackGroupData
  in go sorted (-1) emptyBalance
```

## Database Schema

### Tables

```sql
-- Customers (already exists)
CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  customer_type customer_type DEFAULT 'regular' NOT NULL,

  balance_money NUMERIC(12,2) DEFAULT 0 NOT NULL,

  gram_jewel NUMERIC(10,3) DEFAULT 0 NOT NULL,
  baht_jewel NUMERIC(10,3) DEFAULT 0 NOT NULL,

  gram_bar96 NUMERIC(10,3) DEFAULT 0 NOT NULL,
  baht_bar96 NUMERIC(10,3) DEFAULT 0 NOT NULL,

  gram_bar99 NUMERIC(10,3) DEFAULT 0 NOT NULL,
  baht_bar99 NUMERIC(10,3) DEFAULT 0 NOT NULL,

  created_at TIMESTAMP DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP DEFAULT NOW() NOT NULL
);

-- Bills
CREATE TABLE bills (
  id SERIAL PRIMARY KEY,
  customer_id INT NOT NULL REFERENCES customers(id),
  date TIMESTAMP DEFAULT NOW() NOT NULL,

  -- Previous balances (snapshot at bill creation)
  prev_balance_money NUMERIC(12,2) NOT NULL,
  prev_gram_jewel NUMERIC(10,3) NOT NULL,
  prev_baht_jewel NUMERIC(10,3) NOT NULL,
  prev_gram_bar96 NUMERIC(10,3) NOT NULL,
  prev_baht_bar96 NUMERIC(10,3) NOT NULL,
  prev_gram_bar99 NUMERIC(10,3) NOT NULL,
  prev_baht_bar99 NUMERIC(10,3) NOT NULL,

  -- Final balances (calculated when bill is finalized)
  final_balance_money NUMERIC(12,2),
  final_gram_jewel NUMERIC(10,3),
  final_baht_jewel NUMERIC(10,3),
  final_gram_bar96 NUMERIC(10,3),
  final_baht_bar96 NUMERIC(10,3),
  final_gram_bar99 NUMERIC(10,3),
  final_baht_bar99 NUMERIC(10,3),

  -- VAT fields
  is_vat_deferred BOOLEAN DEFAULT TRUE NOT NULL,  -- Clerk unchecks for taxable bills
  vat_rate NUMERIC(5,2) DEFAULT 7.00 NOT NULL,    -- Adjustable (government may change)
  market_buying_price_jewel NUMERIC(12,2),        -- Announced price (jewelry only, bars exempted)
  vat_taxable_amount NUMERIC(12,2),               -- Cached when finalized
  vat_amount NUMERIC(12,2),                       -- Cached when finalized

  -- Status
  is_finalized BOOLEAN DEFAULT FALSE NOT NULL,
  finalized_at TIMESTAMP,

  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP DEFAULT NOW() NOT NULL,

  -- Concurrent editing support (optimistic locking + polling every 3 seconds)
  version INT DEFAULT 1 NOT NULL  -- Increment on each update
);

-- Shape enum
CREATE TYPE shape_type AS ENUM ('jewelry', 'bar');

-- Bill Groups
CREATE TABLE bill_groups (
  id SERIAL PRIMARY KEY,
  bill_id INT NOT NULL REFERENCES bills(id) ON DELETE CASCADE,
  group_type group_type NOT NULL,  -- 'tray', 'pack', 'transaction'
  display_order INT NOT NULL,
  
  -- Concurrent editing support (optimistic locking)
  version INT DEFAULT 1 NOT NULL,      -- Increment on each update
  updated_by VARCHAR(100),             -- Clerk name/ID who last updated
  
  created_at TIMESTAMP DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP DEFAULT NOW() NOT NULL,
  
  UNIQUE(bill_id, display_order)
);

-- Trays
CREATE TABLE trays (
  id SERIAL PRIMARY KEY,
  group_id INT NOT NULL UNIQUE REFERENCES bill_groups(id) ON DELETE CASCADE,
  internal_num INT NOT NULL,
  is_return BOOLEAN DEFAULT FALSE NOT NULL,

  -- Purity: NULL = 96.5%, 100 = 99.99%, literal = custom
  purity NUMERIC(6,3),

  shape shape_type NOT NULL,  -- Always 'jewelry' for trays
  discount INT DEFAULT 0 CHECK (discount IN (0, 5, 10)),

  actual_weight_grams NUMERIC(10,3) NOT NULL,
  price_rate NUMERIC(12,2),  -- Selling price (THB/baht), NULL = Money & Gold settlement
  additional_charge_rate NUMERIC(12,2)  -- 99.99% premium rate (THB/baht), MUST be set if purity > 96.5%
  
  -- NO totals - calculated on-the-fly from tray_items
  -- This prevents data inconsistency
);

-- Tray Items
CREATE TABLE tray_items (
  id SERIAL PRIMARY KEY,
  tray_id INT NOT NULL REFERENCES trays(id) ON DELETE CASCADE,
  display_order INT NOT NULL,

  making_charge NUMERIC(10,2) NOT NULL,
  jewelry_type_id INT NOT NULL REFERENCES jewelry_types(id),
  design_name VARCHAR(255),
  nominal_weight VARCHAR(50) NOT NULL,  -- "½ส", "1ส", "2ส", "3ส", "1บ", "6ส", etc.
  quantity INT NOT NULL CHECK (quantity > 0),
  amount NUMERIC(12,2) NOT NULL,

  UNIQUE(tray_id, display_order)
);

-- Packs
CREATE TABLE packs (
  id SERIAL PRIMARY KEY,
  group_id INT NOT NULL UNIQUE REFERENCES bill_groups(id) ON DELETE CASCADE,
  internal_id INT NOT NULL,
  user_number VARCHAR(50) NOT NULL,

  -- NO totals - calculated on-the-fly from pack_items
  -- This prevents data inconsistency
);

-- Pack Items
CREATE TABLE pack_items (
  id SERIAL PRIMARY KEY,
  pack_id INT NOT NULL REFERENCES packs(id) ON DELETE CASCADE,
  display_order INT NOT NULL,

  deduction_rate VARCHAR(50) NOT NULL,  -- "500", "42.5%", "+300", "+3%"
  shape shape_type NOT NULL,
  purity NUMERIC(6,3),  -- NULL = 96.5%, 100 = 99.99%, literal = custom
  description TEXT NOT NULL,
  weight VARCHAR(50) NOT NULL,  -- "10g" or "5บ"
  calculation_amount NUMERIC(12,2),

  UNIQUE(pack_id, display_order)
);

-- Transactions
CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  group_id INT NOT NULL UNIQUE REFERENCES bill_groups(id) ON DELETE CASCADE
  
  -- NO totals - calculated on-the-fly from transaction_items
  -- This prevents data inconsistency
);

-- Balance type enum (only 3 types)
CREATE TYPE balance_type AS ENUM ('jewel', 'bar96', 'bar99');

-- Transaction types
CREATE TYPE transaction_type AS ENUM (
  'prev_debit_money',
  'prev_credit_money',
  'prev_debit_jewel',
  'prev_credit_jewel',
  'prev_debit_bar96',
  'prev_credit_bar96',
  'prev_debit_bar99',
  'prev_credit_bar99',
  'in_money',
  'out_money',
  'in_jewel',
  'out_jewel',
  'in_bar96',
  'out_bar96',
  'in_bar99',
  'out_bar99',
  'buy_jewel',
  'sell_jewel',
  'buy_bar96',
  'sell_bar96',
  'buy_bar99',
  'sell_bar99',
  'convert_jewel_to_bar96',
  'convert_grams_to_baht',
  'convert_baht_to_grams',
  'split_bar'
);

-- Transaction Items
CREATE TABLE transaction_items (
  id SERIAL PRIMARY KEY,
  transaction_id INT NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
  display_order INT NOT NULL,

  transaction_type transaction_type NOT NULL,

  amount_money NUMERIC(12,2),

  -- Use Either: amount_grams OR amount_baht (not both)
  amount_grams NUMERIC(10,3),
  amount_baht NUMERIC(10,3),

  balance_type balance_type,
  price_rate NUMERIC(12,2),  -- THB/baht

  -- For type conversion
  from_balance_type balance_type,
  to_balance_type balance_type,
  conversion_charge_rate NUMERIC(12,2),  -- THB/baht

  -- For bar splitting
  split_charge_rate NUMERIC(12,2),  -- THB/baht
  
  -- For gold bar purchases (1-2 baht bars)
  block_making_charge_rate NUMERIC(12,2),  -- THB/baht, VAT INCLUSIVE
  
  additional_rate NUMERIC(12,2),  -- For +percentage pack items

  is_deletable BOOLEAN DEFAULT TRUE NOT NULL,
  description TEXT,
  price_validated BOOLEAN DEFAULT FALSE NOT NULL,

  UNIQUE(transaction_id, display_order),

  -- Check constraint: only one of amount_grams or amount_baht should be set
  -- CRITICAL: Never both! This enforces the single-unit rule.
  CHECK (
    (amount_grams IS NOT NULL AND amount_baht IS NULL) OR
    (amount_grams IS NULL AND amount_baht IS NOT NULL) OR
    (amount_grams IS NULL AND amount_baht IS NULL)
  )
);

-- IMPORTANT NOTES:
-- 1. amount_grams and amount_baht are mutually exclusive (enforced by CHECK constraint)
-- 2. When amount_grams is used, only the corresponding gram_* field is affected
-- 3. When amount_baht is used, only the corresponding baht_* field is affected
-- 4. price_rate is ALWAYS in THB/baht
-- 5. If transaction uses grams, multiply by 0.0656 to convert to baht for charge calculation
-- 6. For "Convert Jewelry to Bar96", clerk specifies BOTH source and destination units independently

-- Indexes
CREATE INDEX idx_bills_customer ON bills(customer_id);
CREATE INDEX idx_bills_date ON bills(date DESC);
CREATE INDEX idx_groups_bill_order ON bill_groups(bill_id, display_order);
CREATE INDEX idx_tray_items_tray_order ON tray_items(tray_id, display_order);
CREATE INDEX idx_pack_items_pack_order ON pack_items(pack_id, display_order);
CREATE INDEX idx_transaction_items_transaction_order ON transaction_items(transaction_id, display_order);
```

## UI/UX Requirements

### Bill Editor Layout

```
┌────────────────────────────────────────────────────────────┐
│ HEADER                                                     │
│ Bill #123 - Customer: นาย สมชาย ใจดี (VIP)                │
│ Date: 2025-01-15 14:30                                     │
│                                                            │
│ Today's Announced Price: 45,000 THB/baht                  │
│ (From "Today's Bills" page - read-only here)              │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│ ⋮⋮ [Tray 1: New Jewelry 96.5%]                      [×]   │
│                                                            │
│ Settings: [Edit]                                          │
│   Price Rate: (empty) → Money & Gold                      │
│   Discount: 5%                                            │
│   Actual Weight: 38.100g                                  │
│                                                            │
│ Items:                                                     │
│ ┌──────────────────────────────────────────────────────┐ │
│ │ Making │ Type    │ Design │ Weight │ Qty │ Amount   │ │
│ │ [500▼] │ สร้อยคอ │ [Aurora▼] │ [2บ▼]  │ [3▼] │ 1500 │ │
│ │ [200▼] │ แหวน    │ [Rainbow▼] │ [2ส▼]  │ [2▼] │  400 │ │
│ └──────────────────────────────────────────────────────┘ │
│ [+ Add Item]                                              │
│                                                            │
│ =================                                          │
│ Jewel: 38.100g        │ Money: 1805 THB                   │
│ =================                                          │
│ Accumulated:                                               │
│ Jewel: 38.100g        │ Money: 1805 THB                   │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│ ⋮⋮ [Pack "A-001": Used Gold]                        [×]   │
│                                                            │
│ Items:                                                     │
│ ┌──────────────────────────────────────────────────────┐ │
│ │ Rate   │ Shape  │ Purity │ Desc      │ Weight      │ │
│ │ [500▼] │ [Jewel▼]│ [NULL▼]│ Used gold │ [10g▼]      │ │
│ │ [+300▼]│ [Bar▼]  │ [100▼] │ Used bar  │ [15g▼]      │ │
│ │ [42.5%▼]│[Jewel▼]│ [42.5▼]│ Rose gold │ [20g▼]      │ │
│ └──────────────────────────────────────────────────────┘ │
│ [+ Add Item]                                              │
│                                                            │
│ =================                                          │
│ Jewel: 9.1g (equiv)   │ Money: +4672 THB                 │
│ Bar99: 15g            │                                   │
│ =================                                          │
│ Accumulated:                                               │
│ Jewel: 47.2g          │ Money: +2867 THB                 │
│ Bar99: 15g            │                                   │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│ ⋮⋮ [Transactions]                                    [×]   │
│                                                            │
│ [เก่าค้างเงิน] -5000 THB (non-editable)                   │
│ [เก่าเหลือทอง] +10g jewel (non-editable)                  │
│ [เก่าเหลือแท่ง 96.5%] +5g bar96 (non-editable)            │
│                                                            │
│ [มาเงิน] +2000 THB                                        │
│                                                            │
│ [แปลงประเภท] 5g jewel → bar96                            │
│   Conversion charge: 50 THB                               │
│                                                            │
│ [+ Add Transaction]                                       │
│                                                            │
│ =================                                          │
│ Money: -3050 THB                                          │
│ Jewel: +5g                                                │
│ Bar96: +10g                                               │
│ =================                                          │
│ Accumulated:                                               │
│ Money: -183 THB                                           │
│ Jewel: +57.2g                                             │
│ Bar96: +10g                                               │
│ Bar99: +15g                                               │
└────────────────────────────────────────────────────────────┘

[+ Add Tray] [+ Add Pack] [+ Add Transactions]

┌────────────────────────────────────────────────────────────┐
│ GRAND TOTAL                                                │
│ Money: -183 THB (Customer owes shop)                      │
│ Gold:                                                      │
│   Jewel: +57.2g (Shop owes customer)                      │
│   Bar96: +10g (Shop owes customer)                        │
│   Bar99: +15g (Shop owes customer)                        │
└────────────────────────────────────────────────────────────┘

[Save] [Print] [Cancel]
```

### Drag and Drop

- **Groups**: Drag handle (⋮⋮) appears on hover
- **Items**: Drag handle on each row
- Auto-recalculate accumulated totals after reorder
- Visual feedback: dragged item 50% opacity, elevated shadow
- Drop zones: dashed border, highlighted background

### Inline Editing

**Editable fields are shown with dropdown (▼) or input styling**:

- Tray items: Making charge, Design name, Nominal weight, Quantity
- Tray settings: Actual weight, Price rate, Discount, Additional charge rate
- Pack items: Deduction rate, Shape, Purity, Description, Weight

**Non-editable fields**: Plain text, no input styling

- Previous balance entries in Transactions group

### Virtual Scrolling

Use existing implementation from CustomerList:

- Only render visible groups
- Per-group height caching (stored in memory with group)
- Smooth scroll-to-group with stability checking
- Handles variable group heights

### Real-time Collaboration

- WebSocket connection per bill
- Show active clerks with avatars
- Live editing indicators: "นาย สมชาย is editing Tray 2..."
- Broadcast changes to all connected clients
- Conflict notification (last-write-wins)

## API Requirements

### Endpoints

```
/bills
  Body: { customer_id, date }
  Returns: Bill with first Transactions group (previous balance)

GET    /api/bills/:id
  Returns: Bill with all groups, items, calculated totals

PUT    /api/bills/:id
  Body: { /* bill fields */ }
  Returns: Updated bill

DELETE /api/bills/:id
  Returns: { success: boolean }

# Groups
POST   /api/bills/:billId/groups
  Body: { group_type, display_order?, tray_settings?, pack_settings? }
  Returns: Created group

PUT    /api/bills/:billId/groups/reorder
  Body: { group_ids: [1, 3, 2, 4] }
  Returns: { success: boolean }
  Note: Triggers accumulated totals recalculation

PUT    /api/bills/:billId/groups/:groupId
  Body: { /* group-specific fields */ }
  Returns: Updated group with recalculated totals

DELETE /api/bills/:billId/groups/:groupId
  Returns: { success: boolean }
  Note: Cannot delete if contains non-deletable items

# Items (Tray/Pack/Transaction)
POST   /api/groups/:groupId/items
  Body: { /* item-specific fields */ }
  Returns: Created item

PUT    /api/groups/:groupId/items/reorder
  Body: { item_ids: [1, 3, 2] }
  Returns: { success: boolean }

PUT    /api/groups/:groupId/items/:itemId
  Body: { /* editable fields */ }
  Returns: Updated item
  Note: Triggers group totals recalculation

DELETE /api/groups/:groupId/items/:itemId
  Returns: { success: boolean }
  Note: Cannot delete if is_deletable = false

# Daily Gold Price (from "Today's Bills" page)
GET    /api/daily-price/:date
  Returns: { date, announced_price }

PUT    /api/daily-price/:date
  Body: { announced_price }
  Returns: { date, announced_price }

# Validation
POST   /api/validate-gold-price
  Body: { input_price, announced_price, transaction_type }
  Returns: { valid, warning?, spread? }

# Jewelry Types
GET    /api/jewelry-types
  Returns: Array of jewelry types
```

## Calculation Requirements

### Rounding Rules

```purescript
-- Weight: round to nearest 0.050g
roundWeight :: WeightGrams -> WeightGrams
roundWeight (WeightGrams w) =
  WeightGrams $ D.fromNumber $
    (Math.round (D.toNumber w / 0.05)) * 0.05

-- Money: round to integer (no decimals)
roundMoney :: Money -> Money
roundMoney (Money m) =
  Money $ D.fromNumber $ Math.round $ D.toNumber m
```

### Unit Conversions

```purescript
parseNominalWeight :: String -> D.Decimal
parseNominalWeight "½ส" = 0.125  -- 1/8 baht
parseNominalWeight "1ส" = 0.25
parseNominalWeight "2ส" = 0.5
parseNominalWeight "3ส" = 0.75
parseNominalWeight "1บ" = 1.0
parseNominalWeight "6ส" = 1.5
parseNominalWeight "2บ" = 2.0
parseNominalWeight "3บ" = 3.0
parseNominalWeight "4บ" = 4.0
parseNominalWeight "5บ" = 5.0
parseNominalWeight other = parseDecimal other  -- Custom weight
```

### Balance Type Conversion

```purescript
-- Convert non-standard purity jewelry to 96.5% equivalent
toStandardJewel :: WeightGrams -> Purity -> WeightGrams
toStandardJewel weight Nothing = weight  -- Already 96.5%
toStandardJewel weight (Just 100.0) = weight  -- Not converted (bar99)
toStandardJewel weight (Just purity) =
  roundWeight $ WeightGrams $
    (unwrap weight) * purity / 96.5
```

### Tray Totals

```purescript
calculateTrayTotals :: Tray -> TrayTotals
calculateTrayTotals tray =
  let
    -- Sum nominal weights
    nominalBaht = sum $ map (\item ->
      parseNominalWeight item.nominalWeight * toNumber item.quantity
    ) tray.items

    nominalGrams = nominalBaht * 15.200

    -- Sum making charges with discount
    makingCharge = sum $ map (_.amount) tray.items
    discountedCharge = makingCharge * (1.0 - tray.discount / 100.0)

    -- Effective weight based on purity
    effectiveWeight = case tray.purity of
      Nothing -> tray.actualWeight  -- 96.5% (NULL)
      Just 100.0 -> tray.actualWeight  -- 99.99%
      Just p -> roundWeight $ tray.actualWeight * (p / 100.0)

    -- Additional charge for 99.99%
    additionalCharge = case tray.purity of
      Just 100.0 | Just rate <- tray.additionalChargeRate ->
        roundMoney $ (effectiveWeight * 0.0656) * rate
      _ -> Money 0

    -- Settlement calculation
    balanceType = toBalanceType tray.shape tray.purity

    (moneyTotal, jewelTotal, bar96Total, bar99Total) =
      case tray.priceRate of
        Nothing ->  -- Money & Gold settlement
          let standardWeight =
                if balanceType == Jewel && tray.purity /= Just 96.5
                then toStandardJewel effectiveWeight tray.purity
                else effectiveWeight

              weightBaht = gramsToBaht standardWeight

              (j, b96, b99) = case balanceType of
                Jewel -> ({ grams: standardWeight, baht: weightBaht }, emptyBalance, emptyBalance)
                Bar96 -> (emptyBalance, { grams: effectiveWeight, baht: weightBaht }, emptyBalance)
                Bar99 -> (emptyBalance, emptyBalance, { grams: effectiveWeight, baht: weightBaht })
           in (discountedCharge + additionalCharge, j, b96, b99)

        Just rate ->  -- Money Only settlement
          let goldValue = roundMoney $ (effectiveWeight * 0.0656) * rate
              totalMoney = goldValue + discountedCharge + additionalCharge
           in (totalMoney, emptyBalance, emptyBalance, emptyBalance)

    -- Negate if return
    sign = if tray.isReturn then -1.0 else 1.0

   in { money: moneyTotal * sign
      , jewel: jewelTotal * sign
      , bar96: bar96Total * sign
      , bar99: bar99Total * sign
      }
```

### Pack Totals

```purescript
calculatePackTotals :: Pack -> PackTotals
calculatePackTotals pack =
  foldr addPackItem emptyTotals pack.items
  where
    addPackItem item totals =
      let weight = parseWeight item.weight
          balanceType = toBalanceType item.shape item.purity

          (goldCredit, moneyEffect) =
            if contains "%" item.deductionRate then
              -- Percentage-based
              let isAddition = startsWith "+" item.deductionRate
                  pct = parsePercentage item.deductionRate
              in if isAddition then
                   -- Higher purity: Money credit only, NO gold credit
                   -- additionalRate must be manually input for this item
                   let effectiveWeight = weight * (100.0 + pct) / 100.0
                       moneyCredit = roundMoney $ effectiveWeight * 0.0656 * item.additionalRate
                   in (WeightGrams 0, Money moneyCredit)
                 else
                   -- Lower purity: Adjust weight
                   let effectiveWeight = roundWeight $ weight * (pct / 100.0)
                   in (effectiveWeight, Money 0)
            else
              -- Per-baht rate
              let isAddition = startsWith "+" item.deductionRate
                  rate = parseRate item.deductionRate
                  moneyAmount = roundMoney $ weight * 0.0656 * rate
              in if isAddition then
                   (weight, Money moneyAmount)  -- Addition
                 else
                   (weight, Money (-moneyAmount))  -- Deduction

          -- Convert to standard if needed
          standardCredit =
            if balanceType == Jewel && item.purity /= Nothing && item.purity /= Just 96.5
            then toStandardJewel goldCredit item.purity
            else goldCredit

          creditBaht = gramsToBaht standardCredit

          -- Add to appropriate balance
          (j, b96, b99) = case balanceType of
            Jewel -> ({ grams: standardCredit, baht: creditBaht }, emptyBalance, emptyBalance)
            Bar96 -> (emptyBalance, { grams: goldCredit, baht: creditBaht }, emptyBalance)
            Bar99 -> (emptyBalance, emptyBalance, { grams: goldCredit, baht: creditBaht })

      in totals
           { money = totals.money + moneyEffect
           , jewel = addBalance totals.jewel j
           , bar96 = addBalance totals.bar96 b96
           , bar99 = addBalance totals.bar99 b99
           }
```

### Transaction Effects

```purescript
-- Gold amount as Either type
data GoldAmount
  = InGrams WeightGrams
  | InBaht WeightBaht

derive instance eqGoldAmount :: Eq GoldAmount

-- Convert to both units
toGramsAndBaht :: GoldAmount -> { grams :: WeightGrams, baht :: WeightBaht }
toGramsAndBaht (InGrams g) = { grams: g, baht: gramsToBaht g }
toGramsAndBaht (InBaht b) = { grams: bahtToGrams b, baht: b }

calculateTransactionEffect :: TransactionItem -> Effect
calculateTransactionEffect item = case item.transactionType of
  PreviousBalance ->
    { money: item.amountMoney
    , goldJewelry: item.goldBalances.jewelry
    , goldBar965: item.goldBalances.bar965
    , goldBar9999: item.goldBalances.bar9999
    }

  Payment ->
    { money: +item.amountMoney
    , goldJewelry: emptyBalance
    , goldBar965: emptyBalance
    , goldBar9999: emptyBalance
    }

  MoneyWithdrawal ->
    { money: -item.amountMoney
    , ... (same as Payment for gold)
    }

  GoldPayment goldType ->
    { money: Money 0
    , goldJewelry: if goldType == Jewelry then +item.amountGold else empty
    , goldBar965: if goldType == Bar965 then +item.amountGold else empty
    , goldBar9999: if goldType == Bar9999 then +item.amountGold else empty
    }

  GoldWithdrawal goldType ->
    -- Same as GoldPayment but negative

  BuyGold goldType | Just rate <- item.goldPriceRate ->
    let goldValue = roundMoney $ item.amountGold * 0.0656 * rate
    in { money: -goldValue
       , [goldType]: +item.amountGold
       }

  SellGold goldType | Just rate <- item.goldPriceRate ->
    let goldValue = roundMoney $ item.amountGold * 0.0656 * rate
    in { money: +goldValue
       , [goldType]: -item.amountGold
       }

  ConvertGoldType fromType toType | Just rate <- item.conversionChargeRate ->
    let conversionCharge = roundMoney $ item.amountGold * 0.0656 * rate
    in { money: -conversionCharge
       , [fromType]: -item.amountGold
       , [toType]: +item.amountGold
       }

  SplitGoldBar goldType | Just rate <- item.splitChargeRate ->
    let splitCharge = roundMoney $ item.amountGold * 0.0656 * rate
    in { money: -splitCharge
       , [goldType]: 0  -- Net zero (same gold, different sizes)
       }

  InJewel | Just goldAmt
    let { grams, baht } = toGramsAndBaht goldAmt
    in { money: Money 0
       , jewel: { grams: +grams, baht: +baht }
       , bar96: emptyBalance
       , bar99: emptyBalance
       }

  OutJewel | Just goldAmt
    let { grams, baht } = toGramsAndBaht goldAmt
    in { money: Money 0
       , jewel: { grams: -grams, baht: -baht }
       , bar96: emptyBalance
       , bar99: emptyBalance
       }

  -- Similar for In/Out Bar96, In/Out Bar99

  BuyJewel | Just goldAmt
    let { grams, baht } = toGramsAndBaht goldAmt
        goldValue = roundMoney $ (unwrap baht) * rate
    in { money: -goldValue
       , jewel: { grams: +grams, baht: +baht }
       , bar96: emptyBalance
       , bar99: emptyBalance
       }

  -- Similar for Buy/Sell Bar96, Buy/Sell Bar99

  ConvertJewelryToBar96 | Just from
    let { grams, baht } = toGramsAndBaht goldAmt
        conversionCharge = roundMoney $ (unwrap baht) * rate
        debit = makeBalance from (-grams) (-baht)
        credit = makeBalance to (+grams) (+baht)
    in { money: -conversionCharge
       , jewel: debit.jewel
       , bar96: credit.bar96
       , bar99: emptyBalance
       }

  ConvertGramsToBaht | Just balType
    let baht = gramsToBaht (WeightGrams grams)
        debitGrams = makeBalance balType (-WeightGrams grams) (WeightBaht 0)
        creditBaht = makeBalance balType (WeightGrams 0) baht
    in { money: Money 0
       , jewel: debitGrams.jewel + creditBaht.jewel
       , bar96: debitGrams.bar96 + creditBaht.bar96
       , bar99: debitGrams.bar99 + creditBaht.bar99
       }

  ConvertBahtToGrams | Just balType
    let grams = bahtToGrams (WeightBaht baht)
        debitBaht = makeBalance balType (WeightGrams 0) (-WeightBaht baht)
        creditGrams = makeBalance balType grams (WeightBaht 0)
    in { money: Money 0
       , jewel: debitBaht.jewel + creditGrams.jewel
       , bar96: debitBaht.bar96 + creditGrams.bar96
       , bar99: debitBaht.bar99 + creditGrams.bar99
       }

  SplitBar | Just balType
    let { grams, baht } = toGramsAndBaht goldAmt
        splitCharge = roundMoney $ (unwrap baht) * rate
        credit = makeBalance balType grams baht
    in { money: -splitCharge
       , jewel: credit.jewel
       , bar96: credit.bar96
       , bar99: credit.bar99
       }
```

## Testing Requirements

### Unit Tests

Create tests for:

1. **Calculation functions**:
   - `calculateTrayTotals` with various purities and settlement types
   - `calculatePackTotals` with percentage and per-baht rates
   - `calculateTransactionEffect` for all transaction types
   - `calculateAccumulatedTotals` with complex group ordering
   - `toBalanceType` for all shape/purity combinations
   - `toStandardJewel` for purity conversion
2. **Rounding functions:**
   - `roundWeight` to 0.050g increments
   - `roundMoney` to integers
3. **Parsing functions:**
   - `parseNominalWeight` for all weight options
   - `parseWeight` for "10g" and "5บ" formats
   - `parseDeductionRate` for "500", "42.5%", "+300", "+3%"
4. **Type safety:**
   - Cannot mix `WeightGrams` and `WeightBaht`
   - Cannot mix different gold types without explicit conversion

## Integration Tests

1. **API endpoints:**
   - Create bill with previous balance
   - Add tray/pack/transaction groups
   - Reorder groups and verify accumulated totals recalculation
   - Update editable fields and verify totals recalculation
   - Delete groups and items
2. **Database:**
   - Purity `NULL`/`100`/literal handling with `COALESCE`
   - Dual unit balance updates
   - Transaction isolation for concurrent updates
3. **WebSocket:**
   - Multi-clerk editing
   - Broadcast changes
   - Conflict resolution

## E2E Tests (Playwright or similar)

1. **Create bill flow:**
   - Select customer
   - Auto-create first Transactions group with previous balance
   - Verify previous balance is non-deletable
2. **Add tray flow:**
   - Click "Add Tray"
   - Configure settings (purity, settlement, discount)
   - Add items with inline editing
   - Verify totals calculation
   - Verify accumulated totals
3. **Add pack flow:**
   - Click "Add Pack"
   - Enter user number
   - Add items with different gold types
   - Verify gold credited to correct balance type
4. **Add transactions flow:**
   - Click "Add Transactions"
   - Add payment/withdrawal
   - Add gold conversion
   - Add gold bar split
   - Verify all transaction types work
5. **Drag and drop flow:**
   - Drag groups to reorder
   - Verify accumulated totals recalculate correctly
   - Drag items within group
   - Verify totals remain correct
6. **Inline editing flow:**
   - Edit tray item making charge → verify amount updates
   - Edit tray item quantity → verify amount updates
   - Edit tray settings discount → verify totals update
   - Edit pack item weight → verify totals update
7. **Price validation flow:**
   - Enter gold price different from announced price
   - Verify warning modal appears
   - Click "Edit Price" → modal closes, field focused
   - Click "Confirm Anyway" → transaction saved with flag
8. **Print flow:**
   - Click Print button
   - Verify print preview shows all groups in order
   - Verify Thai language display
   - Verify drag handles hidden in print mode

---

# Implementation Steps

### Phase 1: Core Types and Database (Week 1)

1. Define PureScript types with phantom types
2. Create constants module (text and numeric)
3. Write database schema with purity trick
4. Create migrations
5. Write seed data
6. Implement database queries with `COALESCE` for purity

### Phase 2: Calculation Logic (Week 1-2)

1. Implement rounding functions
2. Implement parsing functions
3. Implement tray totals calculation
4. Implement pack totals calculation
5. Implement transaction effect calculation
6. Implement accumulated totals algorithm
7. Write unit tests for all calculations

### Phase 3: API Layer (Week 2)

1. Create HTTPure routes
2. Implement API handlers
3. Add request validation
4. Add error handling
5. Write API integration tests

### Phase 4: Frontend Components (Week 3-4)

1. Create `BillEditor` main component
2. Create `TrayGroup` component with inline editing
3. Create `PackGroup` component with inline editing
4. Create `TransactionGroup` component
5. Create item components (`TrayItem`, `PackItem`, `TransactionItem`)
6. Implement virtual scrolling for groups
7. Add drag-and-drop with FFI

### Phase 5: Real-time Features (Week 4)

1. Implement WebSocket client/server
2. Add multi-clerk indicators
3. Add live editing indicators
4. Add conflict resolution
5. Test concurrent editing scenarios

### Phase 6: UI Polish (Week 5)

1. Add price validation modal
2. Add toast notifications
3. Implement print layout
4. Add loading states
5. Add error boundaries
6. Responsive design

### Phase 7: Testing (Week 5-6)

1. Write unit tests
2. Write integration tests
3. Write E2E tests
4. Performance testing
5. Multi-clerk testing

### Phase 8: Documentation (Week 6)

1. API documentation
2. User manual (Thai)
3. Developer guide
4. Deployment guide

---

# Success Criteria

The implementation is complete when:

1.  ✅ All editable fields work with inline editing
2.  ✅ All calculations produce correct results (verified by tests)
3.  ✅ Accumulated totals recalculate correctly after reordering
4.  ✅ Purity `NULL`/`100`/literal works correctly in database
5.  ✅ Dual unit balances prevent rounding errors
6.  ✅ All three gold types (jewelry, bar 965, bar 9999) work correctly
7.  ✅ All transaction types (15+ types) work correctly
8.  ✅ Drag-and-drop works smoothly for groups and items
9.  ✅ Multi-clerk editing works without data loss
10. ✅ Price validation prevents input mistakes
11. ✅ Print layout displays correctly in Thai
12. ✅ All constants are in modules (no hard-coded strings/numbers)
13. ✅ Virtual scrolling handles 100+ groups efficiently
14. ✅ All tests pass (unit, integration, E2E)
15. ✅ No type errors in PureScript compilation
16. ✅ Code follows functional programming best practices

---

# Code Quality Requirements

1. **Type Safety:**
   - Use phantom types to prevent mixing units
   - No `Any` or `Foreign` types except in FFI
   - All functions fully typed
2. **Functional Programming:**
   - Pure functions for calculations
   - Immutable data structures
   - Effect types (`Aff`, `Effect`) for side effects
   - Use `fold`/`map`/`filter` instead of loops
3. **Error Handling:**
   - Use `Either` for operations that can fail
   - Use `Maybe` for optional values
   - Proper error messages in Thai
4. **Performance:**
   - Memoize expensive calculations
   - Use virtual scrolling for large lists
   - Debounce API calls
   - Optimize database queries
5. **Code Organization:**
   - One module per responsibility
   - Clear module exports
   - Consistent naming conventions
   - Comments in English
6. **Testing:**
   - 80%+ code coverage
   - Test edge cases
   - Test error conditions
   - Test concurrent scenarios

---

# Deliverables

Please provide:

1. **Source Code:**
   - All PureScript modules
   - FFI JavaScript files
   - SQL migration scripts
   - Configuration files
2. **Documentation:**
   - `README.md` with setup instructions
   - API documentation
   - Database schema documentation
   - User manual (Thai)
3. **Tests:**
   - Unit tests with coverage report
   - Integration tests
   - E2E test scripts
4. **Build Artifacts:**
   - Compiled JavaScript bundle
   - Database with seed data
   - Docker Compose file (optional)
5. **Demo:**
   - Video walkthrough of all features
   - Screenshot of print layout
   - Performance metrics

---

## Implementation Strategy

### Calculation Approach: On-The-Fly (No Cached Totals)

**Decision:** Calculate all totals on-the-fly from items, do NOT store in database.

**Rationale:**
1. **Correctness > Performance** - Gold shop data must be 100% accurate
2. **Bills are small** - Typically 10-50 items, calculation is instant
3. **Simpler code** - No trigger complexity, easier to maintain
4. **Single source of truth** - Items only, no inconsistency possible
5. **Modern databases are fast** - PostgreSQL handles these calculations easily

**Calculation Flow:**
```purescript
-- 1. Calculate group totals from items
calculateTrayTotal :: Tray -> Array TrayItem -> Balance
calculatePackTotal :: Pack -> Array PackItem -> Balance
calculateTransactionTotal :: Transaction -> Array TransactionItem -> Balance

-- 2. Calculate accumulated totals (running sum)
calculateAccumulated :: Array BillGroup -> Array BillGroup

-- 3. Calculate grand total
calculateBillTotal :: Bill -> Array BillGroup -> Balance

-- 4. Calculate VAT (if not deferred)
calculateVAT :: Bill -> Array BillGroup -> Either String VATCalculation
calculateVAT bill groups = do
  -- Check if VAT deferred
  when bill.is_vat_deferred do
    Left "VAT is deferred for this bill"
  
  -- Check if market price is set
  marketPrice <- note "Market buying price not set" bill.market_buying_price_jewel
  
  -- Get all non-return trays (jewelry)
  let trays = filter (not _.is_return) $ getTrays groups
  
  -- Calculate jewelry VAT (EXCLUSIVE)
  let jewelryVAT = calculateJewelryVAT trays marketPrice bill.vat_rate
  
  -- Get all Buy Bar transactions
  let barTransactions = filter isBuyBarTransaction $ getTransactions groups
  
  -- Calculate bar making charge VAT (INCLUSIVE - extracted)
  let barVAT = calculateBarMakingChargeVAT barTransactions bill.vat_rate
  
  -- Total VAT
  let totalVAT = jewelryVAT + barVAT
  
  pure { jewelryVAT, barVAT, totalVAT }

where
  calculateJewelryVAT :: Array Tray -> Number -> Number -> Number
  calculateJewelryVAT trays marketPrice vatRate =
    let totalWeight = sum $ map (_.actual_weight_grams >>> (*) 0.0656) trays
        totalCharges = sum $ map calculateTrayCharges trays
        netAmount = totalWeight * bill.price_rate + totalCharges
        deduction = totalWeight * marketPrice
        taxableAmount = netAmount - deduction
    in round2 (taxableAmount * vatRate / 100.0)
  
  calculateTrayCharges :: Tray -> Number
  calculateTrayCharges tray =
    let makingCharge = sum $ map _.amount tray.items
        discountedCharge = makingCharge * (100.0 - toNumber tray.discount) / 100.0
        premium = case tray.purity of
          Just 100.0 -> 
            case tray.additional_charge_rate of
              Just rate -> tray.actual_weight_grams * 0.0656 * rate
              Nothing -> error "99.99% premium rate must be set"
          _ -> 0.0
    in discountedCharge + premium
  
  calculateBarMakingChargeVAT :: Array TransactionItem -> Number -> Number
  calculateBarMakingChargeVAT items vatRate =
    let totalMakingCharge = sum $ map getBarMakingCharge items
    in round2 (totalMakingCharge * vatRate / (100.0 + vatRate))
  
  getBarMakingCharge :: TransactionItem -> Number
  getBarMakingCharge item =
    case item.block_making_charge_rate of
      Just rate ->
        let weight = fromMaybe 0.0 item.amount_baht + (fromMaybe 0.0 item.amount_grams * 0.0656)
        in weight * rate
      Nothing -> 0.0
  
  isBuyBarTransaction :: TransactionItem -> Boolean
  isBuyBarTransaction item = 
    item.transaction_type == BuyBar96 || item.transaction_type == BuyBar99
  
  round2 :: Number -> Number
  round2 n = (Math.round (n * 100.0)) / 100.0

-- 5. When bill is finalized, save to bills.final_balance_*
finalizeBill :: Bill -> Balance -> m Unit
```

### Concurrent Editing: Optimistic Locking + Polling

**Decision:** Use optimistic locking with 3-second polling (Option C).

**How It Works:**

1. **Version Numbers**
   - Each `bill_groups` row has a `version` field
   - Incremented on every update
   - Used to detect conflicts

2. **Polling Every 3 Seconds**
   ```purescript
   -- In component
   H.subscribe' \_ -> do
     interval 3000 $ do
       -- Fetch latest groups from server
       serverGroups <- H.lift $ api.getBillGroups billId
       localGroups <- H.gets _.groups
       
       -- Find changed groups (version mismatch)
       let changed = filter (\g -> g.version > findVersion g.id localGroups) serverGroups
       
       -- Auto-merge changes
       when (not $ null changed) do
         H.modify_ _ { groups = mergeGroups localGroups changed }
         showNotification "Another clerk updated this bill"
   ```

3. **On Save - Check Version**
   ```purescript
   saveTrayGroup :: Tray -> m (Either String Tray)
   saveTrayGroup tray = do
     result <- db.query 
       "UPDATE bill_groups 
        SET version = version + 1, 
            updated_at = NOW(),
            updated_by = $1
        WHERE id = $2 AND version = $3
        RETURNING *"
       [currentClerk, tray.id, tray.version]
     
     case result of
       [] -> Left "Conflict: Another clerk modified this tray. Please reload."
       [updated] -> Right updated
   ```

4. **Visual Feedback**
   ```
   ┌─────────────────────────────────────────┐
   │ Bill #12345 - Customer: นายสมชาย        │
   ├─────────────────────────────────────────┤
   │ ✓ Tray 1 (You)                          │
   │   Making charge: 5,000 THB              │
   │                                         │
   │ 🔄 Tray 2 (Clerk B - editing...)       │ ← Shows who's editing
   │   Making charge: 3,000 THB              │
   │                                         │
   │ ✓ Pack 1 (You)                          │
   │   Weight: 10g                           │
   └─────────────────────────────────────────┘
   
   [Toast: Clerk B updated Tray 2]
   ```

5. **Auto-Merge Strategy**
   - If different groups changed → Auto-merge (no conflict)
   - If same group changed → Show error, ask to reload
   - Clerks typically work on different trays → Conflicts rare

**Benefits:**
- ✅ Simple to implement (no WebSocket complexity)
- ✅ 3-second delay is acceptable
- ✅ Prevents data loss
- ✅ Shows who's editing what
- ✅ Auto-merges when possible

### Bill Lifecycle

1. **Draft** - Bill is being edited
   - `is_finalized = FALSE`
   - Can be edited by multiple clerks
   - Totals calculated on-the-fly
   - Customer balances NOT updated

2. **Finalized** - Bill is complete
   - `is_finalized = TRUE`
   - `finalized_at` timestamp set
   - Final balances cached in `bills` table
   - Customer balances updated
   - Can still be edited until end of day

3. **Locked** - End of day
   - Cannot be edited anymore
   - Balances reflected in customer account
   - Used for accounting/reports

---

# Start Implementation

Once you have reviewed this specification and clarified any questions, please:

1. Set up the project structure
2. Install dependencies (`spago`, `PostgreSQL`)
3. Create initial database with migrations
4. Implement core types module
5. Implement constants module
6. Begin with calculation logic (easiest to test)

**See BILLING_IMPLEMENTATION_PLAN.md for detailed 12-week implementation roadmap.**
7. Proceed through phases as outlined above