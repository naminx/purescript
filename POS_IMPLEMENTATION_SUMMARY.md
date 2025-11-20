# POS Implementation Summary

## Thai Label Format

### Gold Balance Display

**Format:** `[prefix][gold_type] [amount][unit]`

**Prefixes:**
- `ค้าง` = Debit (owe/outstanding)
- `เหลือ` = Credit (remaining/balance)

**Gold Types:**
- `ทอง` = Jewelry
- `แท่ง 96.5%` = Bar 96.5%
- `แท่ง 99.99%` = Bar 99.99%

**Examples:**
```
ค้างทอง 60.500g          (jewelry 60.500g debit)
เหลือทอง 2บ              (jewelry 2 baht credit)
ค้างแท่ง 96.5% 5บ        (bar 96.5% 5 baht debit)
เหลือแท่ง 99.99% 10บ     (bar 99.99% 10 baht credit)
```

**Display Rules:**
1. Show debits first, then credits
2. Each balance on separate line
3. Maximum 6 lines (3 types × 2 units)
4. Empty cell if all zero
5. Grams: 3 decimals, no thousand separator
6. Baht: 3 decimals if fraction, no decimals if integer

### Money Balance Display

**Format:** `[prefix] [amount]`

**Prefixes:**
- `ค้างเงิน` = Debit (owe money)
- `เหลือเงิน` = Credit (remaining money)

**Examples:**
```
ค้างเงิน 23,000          (23,000 THB debit)
เหลือเงิน 18,000         (18,000 THB credit)
เหลือเงิน 18,500.50      (18,500.50 THB credit)
```

**Display Rules:**
1. Thousand separator (comma)
2. No decimals if .00
3. Show decimals if not .00
4. Empty cell if zero

---

## Hover Colors

### Color Scheme

| Element | Background | Hover | Purpose |
|---------|-----------|-------|---------|
| Clickable cells | Transparent | `#e8f4f8` | Light blue - POS clickable |
| Customer name | Transparent | `#e8f4f8` | Light blue - POS clickable |
| Settlement row | `#e3f2fd` | `#bbdefb` | Blue - last settlement |
| New bill row | `#fff9c4` | `#fff59d` | Yellow - create new |
| Editable (CustomerList) | Transparent | `#f0f0f0` | Gray - existing |

**Key Difference:**
- **POS clickable:** `#e8f4f8` (light blue)
- **CustomerList editable:** `#f0f0f0` (light gray)

This ensures users can distinguish between:
- **POS:** Click to view/edit bill
- **CustomerList:** Click to edit customer data

---

## Complete Example

### Customer Bills Table

```
┌─────────────────────────────────────────────────────────────┐
│ Jane Smith (ID: 123)                                         │
│                                                               │
│ ┌───────────────────────────────────────────────────────┐  │
│ │ Date      │ Gold Balance      │ Money Balance │ Actions│  │
│ ├───────────┼───────────────────┼───────────────┼────────┤  │
│ │ 2024-11-18│ ค้างทอง 60.500g   │ เหลือเงิน 5,000│        │  │ ← Settlement
│ │           │ เหลือทอง 2บ       │               │        │  │   (light blue bg)
│ │           │ ค้างแท่ง 96.5% 5บ │               │        │  │
│ │           │ เหลือแท่ง 99.99% 10บ│             │        │  │
│ ├───────────┼───────────────────┼───────────────┼────────┤  │
│ │ 09:15     │ ค้างทอง 55.500g   │               │ 🗑️     │  │ ← Bill 1
│ │           │ เหลือทอง 2บ       │               │        │  │   (hover: light blue)
│ │           │ ค้างแท่ง 96.5% 5บ │               │        │  │
│ │           │ เหลือแท่ง 99.99% 10บ│             │        │  │
│ ├───────────┼───────────────────┼───────────────┼────────┤  │
│ │ 10:30     │ ค้างทอง 50.500g   │ ค้างเงิน 5,000 │ 🗑️     │  │ ← Bill 2
│ │           │ เหลือทอง 2บ       │               │        │  │
│ │           │ ค้างแท่ง 96.5% 5บ │               │        │  │
│ │           │ เหลือแท่ง 99.99% 10บ│             │        │  │
│ ├───────────┼───────────────────┼───────────────┼────────┤  │
│ │ 11:45     │ ค้างทอง 45.500g   │ ค้างเงิน 2,500 │ 🗑️     │  │ ← Bill 3
│ │           │ เหลือทอง 2บ       │               │        │  │
│ │           │ ค้างแท่ง 96.5% 5บ │               │        │  │
│ │           │ เหลือแท่ง 99.99% 10บ│             │        │  │
│ └───────────┴───────────────────┴───────────────┴────────┘  │
│ │                          ➕                               │  │ ← New bill
│ └───────────────────────────────────────────────────────┘  │   (yellow bg)
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

**Interactions:**
- **Hover settlement row:** Background changes to `#bbdefb` (darker blue)
- **Hover bill balance cells:** Background changes to `#e8f4f8` (light blue)
- **Hover new bill row:** Background changes to `#fff59d` (darker yellow)
- **Click any balance cell:** Opens bill editor
- **Click ➕:** Creates new bill

---

## Implementation Notes

### 1. Balance Calculation Logic

For each bill row, calculate running balance:
```
running_balance = settlement_balance + sum(bills_up_to_this_point)
```

Example:
```
Settlement:  jewelry: -60.500g, money: +5,000
Bill 1:      jewelry: +5.000g,  money: -5,000
Bill 2:      jewelry: +5.000g,  money: -2,500
Bill 3:      jewelry: +5.000g,  money: 0

Running balances:
After Bill 1: jewelry: -55.500g, money: 0
After Bill 2: jewelry: -50.500g, money: -2,500
After Bill 3: jewelry: -45.500g, money: -2,500
```

### 2. Display Order

**Gold balances:**
1. Sort by type: jewelry, bar96, bar99
2. Within each type: debits first, then credits
3. Within debit/credit: grams first, then baht

**Example order:**
```
ค้างทอง 60.500g       (jewelry debit grams)
ค้างทอง 1บ            (jewelry debit baht)
เหลือทอง 2บ           (jewelry credit baht)
ค้างแท่ง 96.5% 5บ     (bar96 debit baht)
เหลือแท่ง 99.99% 10บ  (bar99 credit baht)
```

### 3. Empty Cells

**When to show empty:**
- All gold balances are zero → Empty gold cell
- Money balance is zero → Empty money cell
- Both empty → Both cells empty but still clickable

**Clickable even when empty:**
- User can click empty cell to create bill
- Hover effect still applies
- Cursor changes to pointer

### 4. Number Formatting

**Grams:**
```purescript
formatGrams :: Number -> String
formatGrams n =
  let str = toFixed 3 (abs n)
      trimmed = trimTrailingZeros str
  in trimmed <> "g"

-- Examples:
-- 60.500 -> "60.500g"
-- 60.000 -> "60g"
-- 0.125 -> "0.125g"
```

**Baht:**
```purescript
formatBaht :: Number -> String
formatBaht n =
  let str = toFixed 3 (abs n)
      trimmed = trimTrailingZeros str
  in trimmed <> "บ"

-- Examples:
-- 2.000 -> "2บ"
-- 2.125 -> "2.125บ"
-- 0.500 -> "0.5บ"
```

**Money:**
```purescript
formatMoney :: Number -> String
formatMoney n =
  let str = toFixed 2 (abs n)
      parts = split "." str
      intPart = addThousandSeparator (parts !! 0)
      fracPart = parts !! 1
  in if fracPart == "00"
       then intPart
       else intPart <> "." <> fracPart

-- Examples:
-- 23000.00 -> "23,000"
-- 18500.50 -> "18,500.50"
-- 1234567.89 -> "1,234,567.89"
```

### 5. CSS Classes

```css
/* Balance cells */
.pos-balance-cell {
  cursor: pointer;
  padding: 12px;
  vertical-align: top;
}

.pos-balance-cell:hover {
  background: #e8f4f8 !important;
}

/* Gold balance - multiple lines */
.pos-gold-balance {
  line-height: 1.5;
}

.pos-gold-balance-line {
  display: block;
}

/* Money balance - single line */
.pos-money-balance {
  white-space: nowrap;
}

/* Settlement row */
.pos-settlement-row {
  background: #e3f2fd !important;
  font-weight: 500;
}

.pos-settlement-row .pos-balance-cell:hover {
  background: #bbdefb !important;
}

/* Empty but clickable */
.pos-balance-cell.empty {
  min-height: 40px; /* Ensure clickable area */
}
```

---

## Testing Scenarios

### Scenario 1: All Debits
```
Settlement:
  ค้างทอง 60.500g
  ค้างแท่ง 96.5% 5บ
  ค้างเงิน 23,000
```

### Scenario 2: All Credits
```
Settlement:
  เหลือทอง 10.500g
  เหลือแท่ง 99.99% 10บ
  เหลือเงิน 18,000
```

### Scenario 3: Mixed
```
Settlement:
  ค้างทอง 60.500g
  เหลือทอง 2บ
  ค้างแท่ง 96.5% 5บ
  เหลือแท่ง 99.99% 10บ
  เหลือเงิน 5,000
```

### Scenario 4: Single Type
```
Settlement:
  เหลือทอง 10.500g
  เหลือเงิน 5,000
```

### Scenario 5: Zero Balance
```
Settlement:
  (empty gold cell)
  (empty money cell)
```

### Scenario 6: Money Only
```
Settlement:
  (empty gold cell)
  ค้างเงิน 23,000
```

### Scenario 7: Gold Only
```
Settlement:
  เหลือทอง 10.500g
  (empty money cell)
```

---

## Summary

**Key Changes from Original Spec:**

1. **Thai labels** for all balances
2. **Debit/Credit prefixes:**
   - `ค้าง` (debit) vs `เหลือ` (credit)
3. **Gold format:**
   - `ค้างทอง 60.500g` not `60.500g jewelry Debit`
4. **Money format:**
   - `ค้างเงิน 23,000` not `23,000 Debit`
5. **Hover color:**
   - `#e8f4f8` (light blue) for POS
   - Different from `#f0f0f0` (gray) in CustomerList
6. **Display order:**
   - Debits first, then credits
   - Within each: jewelry, bar96, bar99

**Ready for implementation!**
