# POS Interface - Final Specification

## Overview

Clean, efficient POS interface optimized for wholesale gold shop with frequent customers.

---

## Page Layout

### POS Page Structure

```
┌─────────────────────────────────────────────────────────────┐
│ Gold Shop POS                                                │
├─────────────────────────────────────────────────────────────┤
│ [Search customer................ ×] [📋 Customer Management]│
├─────────────────────────────────────────────────────────────┤
│                                                               │
│ (Content Area - switches between two views)                  │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## View 1: Today's Bills (Default View)

**When:** Search box is empty

```
┌─────────────────────────────────────────────────────────────┐
│ Gold Shop POS                                                │
├─────────────────────────────────────────────────────────────┤
│ [Search customer................ ×] [📋]                     │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│ Today's Bills (15)                                           │
│                                                               │
│ ┌───────────────────────────────────────────────────────┐  │
│ │ Time  │ Customer Name        │ Actions                │  │
│ ├───────┼──────────────────────┼────────────────────────┤  │
│ │ 09:15 │ Jane Smith           │ 🗑️                     │  │
│ │ 09:45 │ John Doe             │ 🗑️                     │  │
│ │ 10:30 │ Jane Smith           │ 🗑️                     │  │
│ │ 11:20 │ Alice Wong           │ 🗑️                     │  │
│ │ 11:45 │ Jane Smith           │ 🗑️                     │  │
│ │ 13:15 │ Bob Chen             │ 🗑️                     │  │
│ │ 14:30 │ David Lee            │ 🗑️                     │  │
│ │ ...                                                    │  │
│ └───────────────────────────────────────────────────────┘  │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

**Behavior:**
- **Click customer name** → Opens bill editor (full screen)
- **Click 🗑️** → Delete bill (with confirmation)
- **Sorted by time** (newest first or oldest first - your choice)

---

## View 2: Customer Bills (When Customer Selected)

**When:** Customer selected from search popup

```
┌─────────────────────────────────────────────────────────────┐
│ Gold Shop POS                                                │
├─────────────────────────────────────────────────────────────┤
│ [Jane Smith..................... ×] [📋]                     │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│ Jane Smith (ID: 123)                                         │
│                                                               │
│ ┌───────────────────────────────────────────────────────┐  │
│ │ Date      │ Gold Balance      │ Money Balance │ Actions│  │
│ ├───────────┼───────────────────┼───────────────┼────────┤  │
│ │ 2024-11-18│ เหลือทอง 10.500g  │ เหลือเงิน 5,000│        │  │ ← Last settlement
│ │           │ เหลือแท่ง 96.5% 2บ│               │        │  │
│ ├───────────┼───────────────────┼───────────────┼────────┤  │
│ │ 09:15     │ เหลือทอง 10.500g  │               │ 🗑️     │  │ ← Bill 1
│ │           │ เหลือแท่ง 96.5% 2บ│               │        │  │
│ ├───────────┼───────────────────┼───────────────┼────────┤  │
│ │ 10:30     │ เหลือทอง 15.500g  │ ค้างเงิน 5,000 │ 🗑️     │  │ ← Bill 2
│ │           │ เหลือแท่ง 96.5% 2บ│               │        │  │
│ ├───────────┼───────────────────┼───────────────┼────────┤  │
│ │ 11:45     │ เหลือทอง 15.500g  │ ค้างเงิน 2,500 │ 🗑️     │  │ ← Bill 3
│ │           │ เหลือแท่ง 96.5% 2บ│               │        │  │
│ └───────────┴───────────────────┴───────────────┴────────┘  │
│ │                          ➕                               │  │ ← New bill button
│ └───────────────────────────────────────────────────────┘  │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

**First Row (Last Settlement):**
- **Date:** Last settlement date (YYYY-MM-DD)
- **Gold Balance:** All gold types with non-zero balance
  - Debit format: `ค้างทอง 60.500g` or `ค้างแท่ง 96.5% 5บ`
  - Credit format: `เหลือทอง 2บ` or `เหลือแท่ง 99.99% 10บ`
  - Empty if zero
  - Multiple lines if multiple gold types (max 6 lines)
  - Show debits first, then credits
- **Money Balance:** 
  - Debit format: `ค้างเงิน 23,000`
  - Credit format: `เหลือเงิน 18,000`
  - Empty if zero
- **Actions:** Empty (no delete button for settlement)

**Subsequent Rows (Today's Bills):**
- **Time:** Creation time (HH:MM in 24-hour format)
- **Gold Balance:** Running balance after this bill
- **Money Balance:** Running balance after this bill
- **Actions:** 🗑️ delete button

**Last Row (New Bill):**
- **Merged columns:** All four columns merged
- **Content:** ➕ icon (centered)
- **Click:** Creates new bill for this customer

**Behavior:**
- **Click any balance cell** → Opens bill editor (full screen)
- **Click ➕** → Opens bill editor for new bill (full screen)
- **Click 🗑️** → Delete bill (with confirmation)
- **Click × in search box** → Clear search, return to Today's Bills view
- **Manually delete text** → When empty, return to Today's Bills view

---

## Search Box

### Search Box Design

```
┌─────────────────────────────────────────────────────────────┐
│ [Search customer................ ×] [📋]                     │
└─────────────────────────────────────────────────────────────┘
```

**Components:**
- **Input field:** Full width (minus button space)
- **× button:** Clear button (inside input, right side)
- **📋 button:** Opens Customer Management page

**States:**

1. **Empty (default):**
   ```
   [Search customer................ ] [📋]
   ```
   - Placeholder text: "Search customer"
   - No × button visible
   - Shows Today's Bills view

2. **Typing:**
   ```
   [jane........................... ×] [📋]
   ```
   - × button appears
   - Popup appears below with matches

3. **Customer selected:**
   ```
   [Jane Smith..................... ×] [📋]
   ```
   - Shows customer name
   - × button visible
   - Shows Customer Bills view

### Search Popup

**Appears when typing (minimum 1 character):**

```
┌─────────────────────────────────────────────────────────────┐
│ [jane........................... ×] [📋]                     │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ Jane Smith (ID: 123)                                    ││ ← Highlighted
│ │ • 3 bills today                                         ││
│ ├─────────────────────────────────────────────────────────┤│
│ │ Jane Doe (ID: 456)                                      ││
│ │ • No bills today                                        ││
│ ├─────────────────────────────────────────────────────────┤│
│ │ Janet Wong (ID: 789)                                    ││
│ │ • Last visit: Yesterday                                 ││
│ └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

**Behavior:**
- **Auto-focus on page load** (clerk can immediately type)
- **Filter as you type** (debounced 200ms)
- **Keyboard navigation:**
  - ↓ = Next result
  - ↑ = Previous result
  - Enter = Select highlighted result
  - Esc = Close popup
- **Click to select**
- **Shows:**
  - Customer name and ID
  - Bills today (if any)
  - Last visit (if no bills today)

---

## Icons

### Icon Specifications

| Icon | Unicode | Meaning | Usage |
|------|---------|---------|-------|
| 📋 | U+1F4CB | Clipboard | Customer Management |
| × | U+00D7 | Multiplication sign | Clear search |
| 🗑️ | U+1F5D1 | Wastebasket | Delete bill |
| ➕ | U+2795 | Heavy plus sign | New bill |
| ← | U+2190 | Leftwards arrow | Back |

**Alternative Icons (if Unicode not suitable):**

Using SVG icons:
- **📋** → `<svg>...</svg>` (clipboard icon)
- **×** → `<svg>...</svg>` (X icon)
- **🗑️** → `<svg>...</svg>` (trash icon)
- **➕** → `<svg>...</svg>` (plus icon)
- **←** → `<svg>...</svg>` (arrow left icon)

**Recommendation:** Use existing Icons module from CustomerList component.

---

## Bill Editor (Placeholder)

### Bill Editor Screen

```
┌─────────────────────────────────────────────────────────────┐
│ ← Bill: 20241119-0003                                        │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│                                                               │
│                                                               │
│                  (Bill editor content)                        │
│                  (To be implemented)                          │
│                                                               │
│                                                               │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

**Components:**
- **← button:** Back to POS (returns to previous view)
- **Title:** "Bill: [bill_number]" or "New Bill" for new bills

**Behavior:**
- **Click ←** → Return to POS page
  - If came from Today's Bills → Return to Today's Bills view
  - If came from Customer Bills → Return to Customer Bills view (customer still selected)

---

## Data Model

### POS State

```purescript
type POSState =
  { view :: POSView
  , searchQuery :: String
  , searchResults :: Array Customer
  , selectedCustomer :: Maybe Customer
  , todaysBills :: Array Bill
  , customerBills :: Array Bill
  }

data POSView
  = TodaysBillsView
  | CustomerBillsView Customer
```

### Balance Formatting Functions

```purescript
-- Format gold balance for display
formatGoldBalance :: GoldBalance -> Array String
formatGoldBalance balance =
  let debits = formatGoldDebits balance
      credits = formatGoldCredits balance
  in debits <> credits

formatGoldDebits :: GoldBalance -> Array String
formatGoldDebits { jewelry, bar96, bar99 } =
  catMaybes
    [ formatGoldDebit "ทอง" jewelry.grams jewelry.baht
    , formatGoldDebit "แท่ง 96.5%" bar96.grams bar96.baht
    , formatGoldDebit "แท่ง 99.99%" bar99.grams bar99.baht
    ]

formatGoldCredits :: GoldBalance -> Array String
formatGoldCredits { jewelry, bar96, bar99 } =
  catMaybes
    [ formatGoldCredit "ทอง" jewelry.grams jewelry.baht
    , formatGoldCredit "แท่ง 96.5%" bar96.grams bar96.baht
    , formatGoldCredit "แท่ง 99.99%" bar99.grams bar99.baht
    ]

formatGoldDebit :: String -> Number -> Number -> Maybe String
formatGoldDebit goldType grams baht
  | grams < 0.0 = Just $ "ค้าง" <> goldType <> " " <> formatWeight (-grams) "g"
  | baht < 0.0 = Just $ "ค้าง" <> goldType <> " " <> formatWeight (-baht) "บ"
  | otherwise = Nothing

formatGoldCredit :: String -> Number -> Number -> Maybe String
formatGoldCredit goldType grams baht
  | grams > 0.0 = Just $ "เหลือ" <> goldType <> " " <> formatWeight grams "g"
  | baht > 0.0 = Just $ "เหลือ" <> goldType <> " " <> formatWeight baht "บ"
  | otherwise = Nothing

-- Format weight (grams or baht)
formatWeight :: Number -> String -> String
formatWeight value unit =
  let str = toFixed 3 value  -- Always 3 decimals
      trimmed = trimTrailingZeros str
  in trimmed <> unit

-- Format money balance for display
formatMoneyBalance :: Number -> Maybe String
formatMoneyBalance amount
  | amount < 0.0 = Just $ "ค้างเงิน " <> formatMoney (-amount)
  | amount > 0.0 = Just $ "เหลือเงิน " <> formatMoney amount
  | otherwise = Nothing

-- Format money amount with thousand separator
formatMoney :: Number -> String
formatMoney amount =
  let str = toFixed 2 amount
      parts = split "." str
      intPart = parts !! 0
      fracPart = parts !! 1
      formatted = addThousandSeparator intPart
  in if fracPart == "00"
       then formatted
       else formatted <> "." <> fracPart

-- Add thousand separator to integer part
addThousandSeparator :: String -> String
addThousandSeparator str =
  -- Implementation: Insert comma every 3 digits from right
  -- "23000" -> "23,000"
  -- "1234567" -> "1,234,567"
```

**Examples:**

```purescript
-- Gold balance with mixed debit/credit
balance = 
  { jewelry: { grams: -60.500, baht: 2.000 }
  , bar96: { grams: 0.0, baht: -5.000 }
  , bar99: { grams: 0.0, baht: 10.000 }
  }

formatGoldBalance balance
-- Returns:
-- [ "ค้างทอง 60.500g"
-- , "ค้างแท่ง 96.5% 5บ"
-- , "เหลือทอง 2บ"
-- , "เหลือแท่ง 99.99% 10บ"
-- ]

-- Money balance
formatMoneyBalance (-23000.00)  -- "ค้างเงิน 23,000"
formatMoneyBalance 18000.00     -- "เหลือเงิน 18,000"
formatMoneyBalance 18500.50     -- "เหลือเงิน 18,500.50"
formatMoneyBalance 0.0          -- Nothing
```

### Bill Display Data

```purescript
type BillRow =
  { time :: String              -- "09:15" or "2024-11-18"
  , goldBalance :: GoldBalance
  , moneyBalance :: MoneyBalance
  , billId :: Maybe Int         -- Nothing for settlement row
  , isSettlement :: Boolean
  }

type GoldBalance =
  { jewelry :: BalanceDisplay
  , bar96 :: BalanceDisplay
  , bar99 :: BalanceDisplay
  }

type BalanceDisplay =
  { grams :: Number
  , baht :: Number
  , isEmpty :: Boolean
  , isDebit :: Boolean
  }

type MoneyBalance =
  { amount :: Number
  , isEmpty :: Boolean
  , isDebit :: Boolean
  }
```

---

## Detailed Specifications

### Today's Bills Table

**Columns:**
1. **Time** (80px)
   - Format: HH:MM (24-hour)
   - Example: "09:15", "14:30"
   - Right-aligned

2. **Customer Name** (flexible width)
   - Full customer name
   - Left-aligned
   - **Clickable** (entire cell)
   - Hover effect

3. **Actions** (60px)
   - 🗑️ icon button
   - Centered
   - Hover effect

**Styling:**
- Header row: Bold, background color
- Data rows: Alternating colors (zebra striping)
- Hover: Highlight entire row
- Click: Customer name cell is clickable

### Customer Bills Table

**Columns:**
1. **Date/Time** (120px)
   - First row: "YYYY-MM-DD" (settlement date)
   - Other rows: "HH:MM" (bill time)
   - Right-aligned

2. **Gold Balance** (250px)
   - Multiple lines if multiple gold types
   - Format: `10.500g jewelry`
   - Format: `2.000บ bar96`
   - Show "Debit" or "Credit" suffix if non-zero
   - Empty if zero
   - Left-aligned
   - **Clickable** (entire cell, even if empty)

3. **Money Balance** (150px)
   - Format: `5,000 Credit` or `-2,500 Debit`
   - Empty if zero
   - Right-aligned
   - **Clickable** (entire cell, even if empty)

4. **Actions** (60px)
   - 🗑️ icon button (for bill rows)
   - Empty (for settlement row)
   - Centered

**Special Rows:**

1. **Settlement Row (First Row):**
   - Background: Light blue or light gray
   - Font: Slightly bold
   - No delete button
   - Shows last confirmed balance

2. **Bill Rows:**
   - Normal styling
   - Zebra striping
   - Hover effect on entire row
   - Delete button visible

3. **New Bill Row (Last Row):**
   - All columns merged
   - ➕ icon centered
   - Background: Light green or light yellow
   - Hover effect
   - **Clickable** (entire row)

### Balance Display Format

**Gold Balance:**

Each non-zero balance shows on separate line with Thai label:

```
Empty:
  (empty cell)

Debit (ค้าง = owe):
  ค้างทอง 60.500g        (jewelry 60.500g debit)
  ค้างแท่ง 96.5% 5บ      (bar 96.5% 5 baht debit)

Credit (เหลือ = remaining):
  เหลือทอง 2บ            (jewelry 2 baht credit)
  เหลือแท่ง 99.99% 10บ   (bar 99.99% 10 baht credit)

Mixed (up to 6 lines):
  ค้างทอง 60.500g
  เหลือทอง 2บ
  ค้างแท่ง 96.5% 5บ
  เหลือแท่ง 99.99% 10บ
```

**Format Rules:**
- **Debit prefix:** `ค้าง` (owe/outstanding)
- **Credit prefix:** `เหลือ` (remaining/balance)
- **Gold types:**
  - Jewelry: `ทอง`
  - Bar 96.5%: `แท่ง 96.5%`
  - Bar 99.99%: `แท่ง 99.99%`
- **Weight format:**
  - Grams: `60.500g` (3 decimals, no thousand separator)
  - Baht: `2บ` (3 decimals if fraction, no decimals if integer)
- **Order:** Show all debits first, then all credits
- **Maximum:** 6 lines (3 gold types × 2 units)

**Money Balance:**

```
Empty:
  (empty cell)

Debit (ค้าง = owe):
  ค้างเงิน 23,000        (23,000 THB debit)

Credit (เหลือ = remaining):
  เหลือเงิน 18,000       (18,000 THB credit)

Zero:
  (empty cell)
```

**Format Rules:**
- **Debit prefix:** `ค้างเงิน` (owe money)
- **Credit prefix:** `เหลือเงิน` (remaining money)
- **Amount format:** Thousand separator, no decimals shown if .00
- **Examples:**
  - `ค้างเงิน 23,000` (not `ค้างเงิน 23,000.00`)
  - `เหลือเงิน 18,500.50` (show decimals if not .00)

---

## User Interactions

### Scenario 1: View Today's Bills

1. Clerk opens POS page
2. Sees Today's Bills view (default)
3. Can scroll through list
4. Click customer name → Opens bill editor

### Scenario 2: Search and Select Customer

1. Clerk types in search box: "jane"
2. Popup appears with matches
3. Clerk presses ↓ to highlight "Jane Smith"
4. Clerk presses Enter (or clicks)
5. View switches to Customer Bills
6. Search box shows "Jane Smith"
7. × button visible

### Scenario 3: Create New Bill

**From Customer Bills view:**
1. Clerk has customer selected
2. Clicks ➕ in last row
3. Bill editor opens (full screen)
4. (Bill editor functionality TBD)

**From Today's Bills view:**
1. Clerk searches for customer
2. Selects customer
3. Clicks ➕ in last row
4. Bill editor opens

### Scenario 4: Edit Existing Bill

**From Today's Bills view:**
1. Clerk clicks customer name in bill row
2. Bill editor opens with that bill

**From Customer Bills view:**
1. Clerk clicks any balance cell
2. Bill editor opens with that bill

### Scenario 5: Delete Bill

1. Clerk clicks 🗑️ button
2. Confirmation dialog appears:
   ```
   Delete bill 20241119-0003?
   This cannot be undone.
   [Cancel] [Delete]
   ```
3. If confirmed:
   - Bill deleted from database
   - View refreshes
   - Subsequent bills recalculate

### Scenario 6: Return to Today's Bills

**Method 1: Clear button**
1. Clerk clicks × in search box
2. Search box clears
3. View switches to Today's Bills

**Method 2: Manual delete**
1. Clerk deletes text in search box
2. When empty, view switches to Today's Bills

### Scenario 7: Open Customer Management

1. Clerk clicks 📋 button
2. Customer Management page opens
3. (Existing functionality)

---

## CSS Styling

### Search Box

```css
.pos-search-container {
  display: flex;
  gap: 8px;
  margin-bottom: 16px;
}

.pos-search-box {
  position: relative;
  flex: 1;
}

.pos-search-input {
  width: 100%;
  padding: 8px 32px 8px 12px; /* Space for × button */
  font-size: 16px;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.pos-search-clear {
  position: absolute;
  right: 8px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  color: #999;
}

.pos-search-clear:hover {
  color: #333;
}

.pos-customer-mgmt-btn {
  padding: 8px 16px;
  font-size: 20px;
  border: 1px solid #ddd;
  border-radius: 4px;
  background: white;
  cursor: pointer;
}

.pos-customer-mgmt-btn:hover {
  background: #f5f5f5;
}
```

### Search Popup

```css
.pos-search-popup {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: white;
  border: 1px solid #ddd;
  border-top: none;
  border-radius: 0 0 4px 4px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.1);
  max-height: 300px;
  overflow-y: auto;
  z-index: 1000;
}

.pos-search-result {
  padding: 12px;
  border-bottom: 1px solid #eee;
  cursor: pointer;
}

.pos-search-result:hover,
.pos-search-result.highlighted {
  background: #f5f5f5;
}

.pos-search-result-name {
  font-weight: 500;
  font-size: 14px;
}

.pos-search-result-info {
  font-size: 12px;
  color: #666;
  margin-top: 4px;
}
```

### Tables

```css
.pos-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 16px;
}

.pos-table th {
  background: #f8f9fa;
  padding: 12px;
  text-align: left;
  font-weight: 600;
  border-bottom: 2px solid #dee2e6;
}

.pos-table td {
  padding: 12px;
  border-bottom: 1px solid #eee;
}

.pos-table tr:hover {
  background: #f5f5f5;
}

/* Clickable cells - different from Customer Management editable color */
.pos-table-clickable {
  cursor: pointer;
}

.pos-table-clickable:hover {
  background: #e8f4f8 !important;  /* Light blue - different from #f0f0f0 in CustomerList */
}

/* Today's Bills - clickable customer name */
.pos-customer-name-cell {
  cursor: pointer;
}

.pos-customer-name-cell:hover {
  background: #e8f4f8 !important;
  text-decoration: underline;
}

/* Customer Bills - clickable balance cells */
.pos-balance-cell {
  cursor: pointer;
}

.pos-balance-cell:hover {
  background: #e8f4f8 !important;
}

.pos-settlement-row {
  background: #e3f2fd !important;
  font-weight: 500;
}

.pos-settlement-row .pos-balance-cell:hover {
  background: #bbdefb !important;  /* Darker blue for settlement row hover */
}

.pos-new-bill-row {
  background: #fff9c4 !important;
  text-align: center;
  cursor: pointer;
}

.pos-new-bill-row:hover {
  background: #fff59d !important;
}
```

**Color Scheme:**
- **Clickable hover:** `#e8f4f8` (light blue)
- **Customer Management editable hover:** `#f0f0f0` (light gray) - existing
- **Settlement row:** `#e3f2fd` (light blue background)
- **Settlement hover:** `#bbdefb` (darker blue)
- **New bill row:** `#fff9c4` (light yellow)
- **New bill hover:** `#fff59d` (darker yellow)

### Icon Buttons

```css
.pos-icon-btn {
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  padding: 4px 8px;
  color: #666;
}

.pos-icon-btn:hover {
  color: #333;
}

.pos-delete-btn:hover {
  color: #dc3545;
}
```

---

## Implementation Checklist

### Phase 1: Basic Structure
- [ ] Create POS page component
- [ ] Add search box with × button
- [ ] Add 📋 button (link to Customer Management)
- [ ] Implement view switching (Today's Bills ↔ Customer Bills)

### Phase 2: Today's Bills View
- [ ] Fetch today's bills from API
- [ ] Render bills table (time, customer, delete)
- [ ] Implement delete bill functionality
- [ ] Handle click on customer name

### Phase 3: Search Functionality
- [ ] Implement search input handling
- [ ] Create search popup component
- [ ] Implement filter logic
- [ ] Add keyboard navigation (↑↓ Enter Esc)
- [ ] Handle customer selection

### Phase 4: Customer Bills View
- [ ] Fetch customer data and bills
- [ ] Calculate running balances
- [ ] Render customer bills table
- [ ] Format balance displays (gold, money)
- [ ] Implement settlement row
- [ ] Implement new bill row (➕)
- [ ] Make balance cells clickable

### Phase 5: Bill Editor (Placeholder)
- [ ] Create bill editor component
- [ ] Add back button (←)
- [ ] Handle navigation state
- [ ] Return to correct view on back

### Phase 6: Polish
- [ ] Add loading states
- [ ] Add error handling
- [ ] Add animations/transitions
- [ ] Test keyboard navigation
- [ ] Test with real data
- [ ] Responsive design

---

## API Requirements

### Endpoints Needed

```
GET  /api/bills/today              # Get all bills created today
GET  /api/bills/customer/:id/today # Get customer's bills today
GET  /api/customers/search?q=jane  # Search customers
GET  /api/customers/:id/balance    # Get customer's last settlement
POST /api/bills                    # Create new bill
DELETE /api/bills/:id              # Delete bill
```

### Response Formats

**Today's Bills:**
```json
[
  {
    "id": 1,
    "bill_number": "20241119-0001",
    "customer_id": 123,
    "customer_name": "Jane Smith",
    "created_at": "2024-11-19T09:15:00Z",
    "status": "PENDING"
  }
]
```

**Customer Bills:**
```json
{
  "customer": {
    "id": 123,
    "name": "Jane Smith",
    "last_settlement_date": "2024-11-18",
    "money": 5000.00,
    "gram_jewelry": 10.500,
    "baht_jewelry": 0.000,
    "gram_bar96": 0.000,
    "baht_bar96": 2.000,
    "gram_bar99": 0.000,
    "baht_bar99": 0.000
  },
  "bills": [
    {
      "id": 1,
      "bill_number": "20241119-0001",
      "created_at": "2024-11-19T09:15:00Z",
      "net_money": -5000.00,
      "net_gram_jewelry": 5.000,
      "net_baht_jewelry": 0.000,
      "net_gram_bar96": 0.000,
      "net_baht_bar96": 0.000,
      "net_gram_bar99": 0.000,
      "net_baht_bar99": 0.000
    }
  ]
}
```

---

## Summary

This specification provides:

1. **Clean interface** - No tabs, minimal chrome
2. **Two views** - Today's Bills (default) and Customer Bills
3. **Smart search** - Type-ahead with popup
4. **Clear navigation** - × button to return to default view
5. **Icon-only buttons** - 📋 🗑️ ➕ ← (no text)
6. **Clickable balances** - Even zero balances are clickable
7. **Running balances** - Shows balance progression through the day
8. **Settlement row** - Shows last confirmed balance
9. **New bill row** - Merged row with ➕ icon

The design is optimized for:
- **Speed** - Minimal clicks to create bills
- **Clarity** - Clear visual hierarchy
- **Efficiency** - Frequent customers workflow
- **Simplicity** - No unnecessary features

Ready to implement!
