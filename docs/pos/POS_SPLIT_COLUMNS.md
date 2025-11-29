# POS Interface - Split Column Design

## Customer Bills Table (Final Design)

### Table Structure

**6 Columns:**
1. **Date/Time** (100px) - Right-aligned
2. **Gold Label** (120px) - Left-aligned
3. **Gold Value** (100px) - Right-aligned
4. **Money Label** (80px) - Left-aligned
5. **Money Value** (100px) - Right-aligned
6. **Actions** (60px) - Centered

### Visual Layout

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ Jane Smith (ID: 123)                                                         │
│                                                                               │
│ ┌───────────────────────────────────────────────────────────────────────┐  │
│ │ Date      │ Gold Label    │ Gold Value │ Money Label │ Money Value │ × │  │
│ ├───────────┼───────────────┼────────────┼─────────────┼─────────────┼───┤  │
│ │ 2024-11-18│ เหลือทอง      │ 10.500g    │ เหลือเงิน    │ 5,000       │   │  │
│ │           │ เหลือแท่ง 96.5%│ 2บ        │             │             │   │  │
│ ├───────────┼───────────────┼────────────┼─────────────┼─────────────┼───┤  │
│ │ 09:15     │ เหลือทอง      │ 10.500g    │             │             │ 🗑️│  │
│ │           │ เหลือแท่ง 96.5%│ 2บ        │             │             │   │  │
│ ├───────────┼───────────────┼────────────┼─────────────┼─────────────┼───┤  │
│ │ 10:30     │ เหลือทอง      │ 15.500g    │ ค้างเงิน     │ 5,000       │ 🗑️│  │
│ │           │ เหลือแท่ง 96.5%│ 2บ        │             │             │   │  │
│ ├───────────┼───────────────┼────────────┼─────────────┼─────────────┼───┤  │
│ │ 11:45     │ เหลือทอง      │ 15.500g    │ ค้างเงิน     │ 2,500       │ 🗑️│  │
│ │           │ เหลือแท่ง 96.5%│ 2บ        │             │             │   │  │
│ └───────────┴───────────────┴────────────┴─────────────┴─────────────┴───┘  │
│ │                                    ➕                                     │  │
│ └───────────────────────────────────────────────────────────────────────┘  │
│                                                                               │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Column Details

### Column 1: Date/Time
- **Width:** 100px
- **Alignment:** Right
- **Content:**
  - Settlement row: `YYYY-MM-DD`
  - Bill rows: `HH:MM`
- **Example:** `2024-11-18`, `09:15`

### Column 2: Gold Label
- **Width:** 120px
- **Alignment:** Left
- **Content:** Thai label for gold type
- **Multiple lines:** Yes (one per gold type)
- **Examples:**
  - `เหลือทอง` (jewelry credit)
  - `ค้างทอง` (jewelry debit)
  - `เหลือแท่ง 96.5%` (bar 96.5% credit)
  - `ค้างแท่ง 96.5%` (bar 96.5% debit)
  - `เหลือแท่ง 99.99%` (bar 99.99% credit)
  - `ค้างแท่ง 99.99%` (bar 99.99% debit)

### Column 3: Gold Value
- **Width:** 100px
- **Alignment:** Right
- **Content:** Weight with unit
- **Multiple lines:** Yes (matches Gold Label lines)
- **Examples:**
  - `10.500g`
  - `2บ`
  - `60.500g`
  - `5บ`

### Column 4: Money Label
- **Width:** 80px
- **Alignment:** Left
- **Content:** Thai label for money
- **Single line:** Yes
- **Examples:**
  - `เหลือเงิน` (credit)
  - `ค้างเงิน` (debit)
  - (empty if zero)

### Column 5: Money Value
- **Width:** 100px
- **Alignment:** Right
- **Content:** Amount with thousand separator
- **Single line:** Yes
- **Examples:**
  - `5,000`
  - `23,000`
  - `18,500.50`
  - (empty if zero)

### Column 6: Actions
- **Width:** 60px
- **Alignment:** Center
- **Content:**
  - Settlement row: Empty
  - Bill rows: 🗑️ delete button
  - New bill row: (merged, shows ➕)

---

## Label Format

### Gold Labels

**Debit (ค้าง):**
- `ค้างทอง` - Jewelry debit
- `ค้างแท่ง 96.5%` - Bar 96.5% debit
- `ค้างแท่ง 99.99%` - Bar 99.99% debit

**Credit (เหลือ):**
- `เหลือทอง` - Jewelry credit
- `เหลือแท่ง 96.5%` - Bar 96.5% credit
- `เหลือแท่ง 99.99%` - Bar 99.99% credit

### Money Labels

- `ค้างเงิน` - Money debit
- `เหลือเงิน` - Money credit

---

## Display Rules

### Gold Balance

**Order:**
1. Show all debits first (ค้าง)
2. Then show all credits (เหลือ)
3. Within each group: jewelry, bar96, bar99
4. Within each type: grams first, then baht

**Example order:**
```
ค้างทอง          60.500g
ค้างทอง          1บ
ค้างแท่ง 96.5%   5บ
เหลือทอง         2บ
เหลือแท่ง 99.99% 10บ
```

**Empty:**
- If all gold balances are zero, both columns are empty
- Columns still clickable

### Money Balance

**Format:**
- Label column: `ค้างเงิน` or `เหลือเงิน`
- Value column: Amount with thousand separator

**Empty:**
- If money balance is zero, both columns are empty
- Columns still clickable

---

## Clickable Behavior

### Gold Columns (2 & 3)

**Both columns are one clickable unit:**
- Hover over either column → Both highlight
- Click either column → Opens bill editor
- Cursor: pointer on both columns

**Implementation:**
```html
<td class="pos-gold-label pos-clickable-gold" onclick="openBill(...)">
  เหลือทอง<br/>
  เหลือแท่ง 96.5%
</td>
<td class="pos-gold-value pos-clickable-gold" onclick="openBill(...)">
  10.500g<br/>
  2บ
</td>
```

**CSS:**
```css
.pos-clickable-gold {
  cursor: pointer;
}

.pos-clickable-gold:hover,
.pos-clickable-gold:hover + .pos-clickable-gold,
.pos-gold-label:hover ~ .pos-gold-value {
  background: #e8f4f8 !important;
}
```

### Money Columns (4 & 5)

**Both columns are one clickable unit:**
- Hover over either column → Both highlight
- Click either column → Opens bill editor
- Cursor: pointer on both columns

**Implementation:**
```html
<td class="pos-money-label pos-clickable-money" onclick="openBill(...)">
  เหลือเงิน
</td>
<td class="pos-money-value pos-clickable-money" onclick="openBill(...)">
  5,000
</td>
```

**CSS:**
```css
.pos-clickable-money {
  cursor: pointer;
}

.pos-clickable-money:hover,
.pos-clickable-money:hover + .pos-clickable-money,
.pos-money-label:hover ~ .pos-money-value {
  background: #e8f4f8 !important;
}
```

---

## Complete Examples

### Example 1: Mixed Debit/Credit

```
┌───────────┬───────────────┬────────────┬─────────────┬─────────────┬───┐
│ 2024-11-18│ ค้างทอง       │ 60.500g    │ เหลือเงิน    │ 5,000       │   │
│           │ เหลือทอง      │ 2บ        │             │             │   │
│           │ ค้างแท่ง 96.5%│ 5บ        │             │             │   │
│           │ เหลือแท่ง 99.99%│ 10บ      │             │             │   │
└───────────┴───────────────┴────────────┴─────────────┴─────────────┴───┘
```

### Example 2: All Credits

```
┌───────────┬───────────────┬────────────┬─────────────┬─────────────┬───┐
│ 2024-11-18│ เหลือทอง      │ 10.500g    │ เหลือเงิน    │ 18,000      │   │
│           │ เหลือแท่ง 99.99%│ 10บ      │             │             │   │
└───────────┴───────────────┴────────────┴─────────────┴─────────────┴───┘
```

### Example 3: All Debits

```
┌───────────┬───────────────┬────────────┬─────────────┬─────────────┬───┐
│ 2024-11-18│ ค้างทอง       │ 60.500g    │ ค้างเงิน     │ 23,000      │   │
│           │ ค้างแท่ง 96.5%│ 5บ        │             │             │   │
└───────────┴───────────────┴────────────┴─────────────┴─────────────┴───┘
```

### Example 4: Money Only

```
┌───────────┬───────────────┬────────────┬─────────────┬─────────────┬───┐
│ 2024-11-18│               │            │ ค้างเงิน     │ 23,000      │   │
└───────────┴───────────────┴────────────┴─────────────┴─────────────┴───┘
```

### Example 5: Gold Only

```
┌───────────┬───────────────┬────────────┬─────────────┬─────────────┬───┐
│ 2024-11-18│ เหลือทอง      │ 10.500g    │             │             │   │
└───────────┴───────────────┴────────────┴─────────────┴─────────────┴───┘
```

### Example 6: Zero Balance (Empty but Clickable)

```
┌───────────┬───────────────┬────────────┬─────────────┬─────────────┬───┐
│ 2024-11-18│               │            │             │             │   │
└───────────┴───────────────┴────────────┴─────────────┴─────────────┴───┘
```

---

## CSS Styling

```css
/* Table structure */
.pos-customer-bills-table {
  width: 100%;
  border-collapse: collapse;
}

.pos-customer-bills-table th {
  background: #f8f9fa;
  padding: 12px 8px;
  font-weight: 600;
  border-bottom: 2px solid #dee2e6;
}

.pos-customer-bills-table td {
  padding: 12px 8px;
  border-bottom: 1px solid #eee;
  vertical-align: top;
}

/* Column alignments */
.pos-date-col {
  text-align: right;
  width: 100px;
}

.pos-gold-label {
  text-align: left;
  width: 120px;
  line-height: 1.6;
}

.pos-gold-value {
  text-align: right;
  width: 100px;
  line-height: 1.6;
}

.pos-money-label {
  text-align: left;
  width: 80px;
}

.pos-money-value {
  text-align: right;
  width: 100px;
}

.pos-actions-col {
  text-align: center;
  width: 60px;
}

/* Clickable cells */
.pos-clickable-gold,
.pos-clickable-money {
  cursor: pointer;
}

/* Hover effect - both label and value highlight together */
.pos-gold-label:hover,
.pos-gold-label:hover + .pos-gold-value {
  background: #e8f4f8 !important;
}

.pos-gold-value:hover,
.pos-gold-value:hover ~ .pos-gold-label {
  background: #e8f4f8 !important;
}

.pos-money-label:hover,
.pos-money-label:hover + .pos-money-value {
  background: #e8f4f8 !important;
}

.pos-money-value:hover,
.pos-money-value:hover ~ .pos-money-label {
  background: #e8f4f8 !important;
}

/* Settlement row */
.pos-settlement-row {
  background: #e3f2fd !important;
  font-weight: 500;
}

.pos-settlement-row .pos-clickable-gold:hover,
.pos-settlement-row .pos-clickable-money:hover {
  background: #bbdefb !important;
}

/* New bill row */
.pos-new-bill-row {
  background: #fff9c4 !important;
  text-align: center;
  cursor: pointer;
}

.pos-new-bill-row:hover {
  background: #fff59d !important;
}

/* Empty but clickable cells */
.pos-clickable-gold.empty,
.pos-clickable-money.empty {
  min-height: 40px;
}
```

---

## Data Model

```purescript
type CustomerBillRow =
  { date :: String              -- "2024-11-18" or "09:15"
  , goldLabels :: Array String  -- ["เหลือทอง", "เหลือแท่ง 96.5%"]
  , goldValues :: Array String  -- ["10.500g", "2บ"]
  , moneyLabel :: Maybe String  -- Just "เหลือเงิน" or Nothing
  , moneyValue :: Maybe String  -- Just "5,000" or Nothing
  , billId :: Maybe Int         -- Nothing for settlement row
  , isSettlement :: Boolean
  }

-- Format functions
formatGoldLabels :: GoldBalance -> Array String
formatGoldLabels balance =
  let debits = formatGoldDebitLabels balance
      credits = formatGoldCreditLabels balance
  in debits <> credits

formatGoldValues :: GoldBalance -> Array String
formatGoldValues balance =
  let debits = formatGoldDebitValues balance
      credits = formatGoldCreditValues balance
  in debits <> credits

formatGoldDebitLabels :: GoldBalance -> Array String
formatGoldDebitLabels { jewelry, bar96, bar99 } =
  catMaybes
    [ if jewelry.grams < 0.0 then Just "ค้างทอง" else Nothing
    , if jewelry.baht < 0.0 then Just "ค้างทอง" else Nothing
    , if bar96.grams < 0.0 then Just "ค้างแท่ง 96.5%" else Nothing
    , if bar96.baht < 0.0 then Just "ค้างแท่ง 96.5%" else Nothing
    , if bar99.grams < 0.0 then Just "ค้างแท่ง 99.99%" else Nothing
    , if bar99.baht < 0.0 then Just "ค้างแท่ง 99.99%" else Nothing
    ]

formatGoldDebitValues :: GoldBalance -> Array String
formatGoldDebitValues { jewelry, bar96, bar99 } =
  catMaybes
    [ if jewelry.grams < 0.0 then Just (formatWeight (-jewelry.grams) "g") else Nothing
    , if jewelry.baht < 0.0 then Just (formatWeight (-jewelry.baht) "บ") else Nothing
    , if bar96.grams < 0.0 then Just (formatWeight (-bar96.grams) "g") else Nothing
    , if bar96.baht < 0.0 then Just (formatWeight (-bar96.baht) "บ") else Nothing
    , if bar99.grams < 0.0 then Just (formatWeight (-bar99.grams) "g") else Nothing
    , if bar99.baht < 0.0 then Just (formatWeight (-bar99.baht) "บ") else Nothing
    ]

-- Similar for credits...

formatMoneyLabel :: Number -> Maybe String
formatMoneyLabel amount
  | amount < 0.0 = Just "ค้างเงิน"
  | amount > 0.0 = Just "เหลือเงิน"
  | otherwise = Nothing

formatMoneyValue :: Number -> Maybe String
formatMoneyValue amount
  | amount /= 0.0 = Just (formatMoney (abs amount))
  | otherwise = Nothing
```

---

## HTML Structure

```html
<table class="pos-customer-bills-table">
  <thead>
    <tr>
      <th class="pos-date-col">Date</th>
      <th class="pos-gold-label">Gold Label</th>
      <th class="pos-gold-value">Gold Value</th>
      <th class="pos-money-label">Money Label</th>
      <th class="pos-money-value">Money Value</th>
      <th class="pos-actions-col">×</th>
    </tr>
  </thead>
  <tbody>
    <!-- Settlement row -->
    <tr class="pos-settlement-row">
      <td class="pos-date-col">2024-11-18</td>
      <td class="pos-gold-label pos-clickable-gold" onclick="openBill(null)">
        เหลือทอง<br/>
        เหลือแท่ง 96.5%
      </td>
      <td class="pos-gold-value pos-clickable-gold" onclick="openBill(null)">
        10.500g<br/>
        2บ
      </td>
      <td class="pos-money-label pos-clickable-money" onclick="openBill(null)">
        เหลือเงิน
      </td>
      <td class="pos-money-value pos-clickable-money" onclick="openBill(null)">
        5,000
      </td>
      <td class="pos-actions-col"></td>
    </tr>
    
    <!-- Bill row -->
    <tr>
      <td class="pos-date-col">09:15</td>
      <td class="pos-gold-label pos-clickable-gold" onclick="openBill(1)">
        เหลือทอง<br/>
        เหลือแท่ง 96.5%
      </td>
      <td class="pos-gold-value pos-clickable-gold" onclick="openBill(1)">
        10.500g<br/>
        2บ
      </td>
      <td class="pos-money-label pos-clickable-money" onclick="openBill(1)">
      </td>
      <td class="pos-money-value pos-clickable-money" onclick="openBill(1)">
      </td>
      <td class="pos-actions-col">
        <button class="pos-icon-btn pos-delete-btn" onclick="deleteBill(1)">🗑️</button>
      </td>
    </tr>
    
    <!-- New bill row -->
    <tr class="pos-new-bill-row" onclick="createNewBill()">
      <td colspan="6">➕</td>
    </tr>
  </tbody>
</table>
```

---

## Benefits of Split Columns

1. **Clean Alignment:**
   - Labels left-aligned
   - Values right-aligned
   - Professional appearance

2. **Easy to Read:**
   - Clear separation between label and value
   - Consistent spacing
   - No mixed alignment issues

3. **Easy to Implement:**
   - Simple table structure
   - Standard CSS alignment
   - No complex flexbox needed

4. **Easy to Click:**
   - Both columns highlight together
   - Clear clickable area
   - Good UX

5. **Scalable:**
   - Easy to add more gold types
   - Easy to adjust column widths
   - Easy to style

---

## Summary

**Key Changes:**
- Split gold balance into 2 columns (label + value)
- Split money balance into 2 columns (label + value)
- Total 6 columns instead of 4
- Both columns in a pair highlight together on hover
- Both columns in a pair are clickable
- Clean left/right alignment

**Result:**
- More professional appearance
- Easier to read
- Easier to implement
- Better UX

Ready to implement!
