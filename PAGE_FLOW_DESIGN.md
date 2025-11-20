# Gold Shop System - Page Flow & Navigation Design

## System Architecture

### Multi-Page Application (MPA) vs Single-Page Application (SPA)

**Recommendation: Hybrid SPA with Multiple Views**

The system should be a single-page application with multiple views/screens, but with clear separation between:
1. **Customer Management** (existing)
2. **Point of Sale (POS)** (new)
3. **End of Day** (new)
4. **Reports** (future)

---

## Page Structure

```
┌─────────────────────────────────────────────────────────────┐
│ Gold Shop System                    Clerk: John    [Logout] │
├─────────────────────────────────────────────────────────────┤
│ [Customers] [POS] [End of Day] [Reports]                    │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│                    MAIN CONTENT AREA                         │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Navigation Flow

### Option A: POS-First Approach (Recommended)

**Rationale:** Clerks primarily use POS for daily work. Customer management is secondary.

```
Login
  ↓
POS Dashboard (Default Landing Page)
  ├→ [Customers] tab → Customer Management
  ├→ [End of Day] tab → End of Day Review
  └→ [Reports] tab → Reports (future)
```

**Flow:**
1. Clerk opens app → **POS Dashboard**
2. Need to check customer? → Click **[Customers]** tab
3. Need to register new customer? → Click **[New Customer]** in POS (quick modal)
4. End of day? → Click **[End of Day]** tab
5. View reports? → Click **[Reports]** tab

### Option B: Customer-First Approach

**Rationale:** Customer management is the foundation. POS is built on top.

```
Login
  ↓
Customer Management (Default Landing Page)
  ├→ [POS] tab → POS Dashboard
  ├→ [End of Day] tab → End of Day Review
  └→ [Reports] tab → Reports (future)
```

**Flow:**
1. Clerk opens app → **Customer Management**
2. Select customer → Click **[Create Bill]** button → Opens POS with customer pre-selected
3. Or click **[POS]** tab → POS Dashboard
4. End of day? → Click **[End of Day]** tab

### Option C: Unified Dashboard

**Rationale:** Single dashboard shows everything at a glance.

```
Login
  ↓
Unified Dashboard
  ├─ Quick Actions
  │   ├→ New Bill
  │   ├→ New Customer
  │   └→ End of Day
  ├─ Today's Summary
  │   ├→ Bills: 15 pending
  │   ├→ Customers: 8 served
  │   └→ Total: 125,000 THB
  └─ Navigation
      ├→ [POS] → Full POS interface
      ├→ [Customers] → Customer Management
      ├→ [End of Day] → Review & Confirm
      └→ [Reports] → Reports
```

---

## Recommended Flow: Option A (POS-First)

### Detailed Page Flow

#### 1. Login Page

```
┌─────────────────────────────────────────────────────────────┐
│                                                               │
│                     Gold Shop System                         │
│                                                               │
│                  ┌─────────────────────┐                     │
│                  │  Clerk Name: [____] │                     │
│                  │  Password:   [____] │                     │
│                  │                      │                     │
│                  │      [Login]         │                     │
│                  └─────────────────────┘                     │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

**Actions:**
- Enter credentials
- Click Login → Navigate to **POS Dashboard**

---

#### 2. POS Dashboard (Default Landing Page)

```
┌─────────────────────────────────────────────────────────────┐
│ Gold Shop System                    Clerk: John    [Logout] │
├─────────────────────────────────────────────────────────────┤
│ [POS] [Customers] [End of Day] [Reports]                    │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Customer Search                                      │   │
│  │ [Search customer by name................] [New]     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Today's Activity                                     │   │
│  │                                                       │   │
│  │ Bills Created: 15                                    │   │
│  │ Customers Served: 8                                  │   │
│  │ Total Transactions: 125,000 THB                      │   │
│  │                                                       │   │
│  │ Recent Bills:                                        │   │
│  │ ┌───────────────────────────────────────────────┐  │   │
│  │ │ 20241119-0015  14:30  Jane Smith  -5,000 THB │  │   │
│  │ │ 20241119-0014  14:15  John Doe    +2,500 THB │  │   │
│  │ │ 20241119-0013  14:00  Alice Wong  -1,200 THB │  │   │
│  │ └───────────────────────────────────────────────┘  │   │
│  │                                                       │   │
│  │ [View All Bills]                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Quick Actions                                        │   │
│  │                                                       │   │
│  │  [New Bill]  [New Customer]  [End of Day Review]    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

**Actions:**
- **Search customer** → Shows customer details + [Create Bill] button
- **[New]** → Opens "New Customer" modal → After save, auto-opens bill creation
- **[New Bill]** → Opens bill creation (must select customer first)
- **Click on recent bill** → Opens bill in view/edit mode
- **[View All Bills]** → Opens bill list view
- **[End of Day Review]** → Navigate to End of Day page
- **[Customers] tab** → Navigate to Customer Management
- **[End of Day] tab** → Navigate to End of Day Review

---

#### 3. Customer Selected State

```
┌─────────────────────────────────────────────────────────────┐
│ Gold Shop System                    Clerk: John    [Logout] │
├─────────────────────────────────────────────────────────────┤
│ [POS] [Customers] [End of Day] [Reports]                    │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Customer: Jane Smith                    [Change]     │   │
│  │                                                       │   │
│  │ Opening Balance (from customer table):               │   │
│  │   Money: 5,000 THB                                   │   │
│  │   Jewelry: 10.5g / 0บ                                │   │
│  │   Bar 96.5%: 0g / 2บ                                 │   │
│  │   Bar 99.99%: 0g / 0บ                                │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Today's Bills for Jane Smith                         │   │
│  │                                                       │   │
│  │ ┌───────────────────────────────────────────────┐  │   │
│  │ │ 20241119-0001  10:30  -5,000 THB  [View][Edit]│  │   │
│  │ │ 20241119-0002  11:45  +2,500 THB  [View][Edit]│  │   │
│  │ └───────────────────────────────────────────────┘  │   │
│  │                                                       │   │
│  │ Running Balance (after today's bills):               │   │
│  │   Money: 2,500 THB                                   │   │
│  │   Jewelry: 10.5g / 0บ                                │   │
│  │   Bar 96.5%: 0g / 2บ                                 │   │
│  │   Bar 99.99%: 0g / 0บ                                │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                               │
│  [Create New Bill for Jane Smith]                           │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

**Actions:**
- **[Change]** → Clear selection, return to search
- **[View]** → Opens bill in read-only mode (modal or side panel)
- **[Edit]** → Opens bill in edit mode (full screen or modal)
- **[Create New Bill]** → Opens bill creation screen

---

#### 4. Bill Creation/Edit Screen (Full Screen)

```
┌─────────────────────────────────────────────────────────────┐
│ [← Back to POS]          Bill: 20241119-0003                │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Customer: Jane Smith                          Clerk: John   │
│  Date: 2024-11-19 14:30                                     │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Starting Balance                                     │   │
│  │   Money: 2,500 THB                                   │   │
│  │   Jewelry: 10.5g / 0บ                                │   │
│  │   Bar 96.5%: 0g / 2บ                                 │   │
│  │   Bar 99.99%: 0g / 0บ                                │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Items                                                │   │
│  │                                                       │   │
│  │ ┌───────────────────────────────────────────────┐  │   │
│  │ │#│Type        │Weight │Price/Unit│Amount    │[×]│  │   │
│  │ ├─┼────────────┼───────┼──────────┼──────────┼───┤  │   │
│  │ │1│Sell Jewelry│5.000g │3,000/g   │-15,000   │[×]│  │   │
│  │ │2│Cash In     │-      │-         │+10,000   │[×]│  │   │
│  │ └───────────────────────────────────────────────┘  │   │
│  │                                                       │   │
│  │ [+ Add Item ▼]                                       │   │
│  │   ├─ Buy Jewelry                                     │   │
│  │   ├─ Sell Jewelry                                    │   │
│  │   ├─ Buy Bar 96.5%                                   │   │
│  │   ├─ Sell Bar 96.5%                                  │   │
│  │   ├─ Buy Bar 99.99%                                  │   │
│  │   ├─ Sell Bar 99.99%                                 │   │
│  │   ├─ Cash In                                         │   │
│  │   └─ Cash Out                                        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Summary                                              │   │
│  │                                                       │   │
│  │ Net Change:                                          │   │
│  │   Money: -5,000 THB                                  │   │
│  │   Jewelry: +5.000g                                   │   │
│  │                                                       │   │
│  │ Ending Balance:                                      │   │
│  │   Money: -2,500 THB (DEBIT)                         │   │
│  │   Jewelry: 15.5g / 0บ                                │   │
│  │   Bar 96.5%: 0g / 2บ                                 │   │
│  │   Bar 99.99%: 0g / 0บ                                │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                               │
│  Notes: [Optional notes..................................]  │
│                                                               │
│  [Save & Close]  [Save & New Bill]  [Print]  [Cancel]      │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

**Actions:**
- **[← Back to POS]** → Return to POS Dashboard (with customer still selected)
- **[+ Add Item]** → Opens item entry form (inline or modal)
- **[×]** on item → Remove item from bill
- **[Save & Close]** → Save bill, return to POS Dashboard
- **[Save & New Bill]** → Save bill, immediately create another bill for same customer
- **[Print]** → Print receipt/bill (future)
- **[Cancel]** → Discard changes, return to POS Dashboard

---

#### 5. Customer Management Page

```
┌─────────────────────────────────────────────────────────────┐
│ Gold Shop System                    Clerk: John    [Logout] │
├─────────────────────────────────────────────────────────────┤
│ [POS] [Customers] [End of Day] [Reports]                    │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  รายชื่อลูกค้า (15 ราย)                                      │
│                                                               │
│  [Search.....................] [+ Add Customer]             │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ ID │ Name       │ Money  │ Jewelry │ ... │ Actions │   │
│  ├────┼────────────┼────────┼─────────┼─────┼─────────┤   │
│  │ 1  │ Jane Smith │ 5,000  │ 10.5g   │ ... │ [Bill]  │   │
│  │ 2  │ John Doe   │-2,500  │ 0g      │ ... │ [Bill]  │   │
│  │ ... (existing customer list)                        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

**Actions:**
- **[Bill]** button → Navigate to POS Dashboard with customer pre-selected
- **Click on customer row** → Edit customer details (existing functionality)
- **[+ Add Customer]** → Create new customer (existing functionality)
- **[POS] tab** → Navigate back to POS Dashboard

---

#### 6. End of Day Review Page

```
┌─────────────────────────────────────────────────────────────┐
│ Gold Shop System                    Clerk: John    [Logout] │
├─────────────────────────────────────────────────────────────┤
│ [POS] [Customers] [End of Day] [Reports]                    │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  End of Day Review - 2024-11-19                              │
│                                                               │
│  Pending Bills: 15                                           │
│  Customers Affected: 8                                       │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ ▼ Jane Smith (3 bills)                               │   │
│  │   Opening: 5,000 THB | 10.5g jewelry                 │   │
│  │   Bills:                                              │   │
│  │     20241119-0001  -5,000 THB  [View] [Edit] [Void] │   │
│  │     20241119-0002  +2,500 THB  [View] [Edit] [Void] │   │
│  │     20241119-0003  -5,000 THB  [View] [Edit] [Void] │   │
│  │   Net Change: -7,500 THB | +5g jewelry               │   │
│  │   Closing: -2,500 THB | 15.5g jewelry                │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                               │
│  │ ▼ John Doe (2 bills)                                 │   │
│  │   ...                                                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                               │
│  Summary:                                                    │
│    Total Money Change: -25,000 THB                          │
│    Total Gold Change: +150g jewelry, +5บ bar96              │
│                                                               │
│  [Confirm All Bills]                           [Cancel]      │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

**Actions:**
- **[View]** → Opens bill in read-only modal
- **[Edit]** → Navigate to bill edit screen
- **[Void]** → Mark bill as voided (with confirmation)
- **[Confirm All Bills]** → Opens confirmation dialog
- **[Cancel]** → Return to POS Dashboard
- **[POS] tab** → Navigate back to POS Dashboard

---

## Navigation Patterns

### Tab Navigation (Primary)

```
[POS] [Customers] [End of Day] [Reports]
  ↓        ↓           ↓           ↓
 POS    Customer    End of Day   Reports
Dashboard  List      Review       (future)
```

**Behavior:**
- Clicking tab switches main content area
- Current tab highlighted
- Tab state persists during session
- Can use browser back/forward buttons

### Breadcrumb Navigation (Secondary)

```
POS > Jane Smith > Bill 20241119-0003
```

**Behavior:**
- Shows current location in hierarchy
- Click any breadcrumb to navigate back
- Useful when deep in bill editing

### Context Actions (Tertiary)

```
Customer List → [Bill] button → Opens POS with customer selected
Bill List → Click bill → Opens bill editor
```

**Behavior:**
- Quick actions from any context
- Maintains context (customer selection, filters, etc.)

---

## State Management

### URL Structure

```
/                          → Redirect to /pos
/pos                       → POS Dashboard
/pos?customer=123          → POS with customer 123 selected
/pos/bill/new?customer=123 → New bill for customer 123
/pos/bill/456              → Edit bill 456
/customers                 → Customer Management
/customers?search=jane     → Customer list filtered by "jane"
/eod                       → End of Day Review
/reports                   → Reports (future)
```

**Benefits:**
- Bookmarkable URLs
- Browser back/forward works
- Deep linking support
- Clear navigation state

### Session State

```purescript
type AppState =
  { currentPage :: Page
  , selectedCustomer :: Maybe Customer
  , currentBill :: Maybe Bill
  , clerk :: Clerk
  , todaysBills :: Array Bill
  }

data Page
  = POSPage
  | CustomersPage
  | EndOfDayPage
  | ReportsPage
```

---

## User Experience Considerations

### 1. Fast Customer Selection

**Problem:** Clerk needs to quickly find and select customer.

**Solution:**
- Auto-focus search box on POS page load
- Type-ahead search (filter as you type)
- Show recent customers at top
- Keyboard shortcuts (↑↓ to navigate, Enter to select)

### 2. Quick Bill Creation

**Problem:** Creating bills should be fast and efficient.

**Solution:**
- Pre-fill customer from selection
- Auto-calculate balances
- Keyboard shortcuts for common actions
- "Save & New Bill" for multiple bills

### 3. Minimal Navigation

**Problem:** Too many clicks slow down workflow.

**Solution:**
- Most common actions on POS Dashboard
- Context actions (e.g., [Bill] button in customer list)
- Modal dialogs for quick tasks (new customer)
- Full screen for complex tasks (bill editing)

### 4. Clear Visual Hierarchy

**Problem:** Clerk needs to see important info at a glance.

**Solution:**
- Large, clear numbers for balances
- Color coding (red for debit, green for credit)
- Visual separation between sections
- Consistent layout across pages

### 5. Error Prevention

**Problem:** Mistakes are costly in financial transactions.

**Solution:**
- Confirmation dialogs for destructive actions
- Clear warnings for negative balances
- Validation before saving
- Undo capability (before confirmation)

---

## Recommended Implementation

### Phase 1: Basic Navigation

1. Implement tab navigation (POS, Customers, End of Day)
2. POS Dashboard as landing page
3. Customer selection flow
4. Basic bill creation (full screen)

### Phase 2: Enhanced UX

1. URL routing with state management
2. Breadcrumb navigation
3. Modal dialogs for quick actions
4. Keyboard shortcuts

### Phase 3: Polish

1. Smooth transitions between pages
2. Loading states
3. Error handling
4. Responsive design

---

## Comparison: Page Flow Options

| Aspect | Option A: POS-First | Option B: Customer-First | Option C: Unified Dashboard |
|--------|---------------------|--------------------------|----------------------------|
| **Landing Page** | POS Dashboard | Customer Management | Unified Dashboard |
| **Primary Use Case** | Daily transactions | Customer lookup | Overview + quick actions |
| **Clicks to Bill** | 2 (search, create) | 3 (select, POS, create) | 2 (quick action, create) |
| **Learning Curve** | Low | Medium | Medium |
| **Flexibility** | High | Medium | High |
| **Best For** | Busy shops | Customer-focused | Multi-role users |

**Recommendation: Option A (POS-First)**

**Rationale:**
- Clerks spend 90% of time creating bills
- Fastest path to common tasks
- Customer management is secondary
- Clean separation of concerns
- Easy to add more tabs later

---

## Summary

The recommended page flow is:

1. **Login** → **POS Dashboard** (default landing)
2. **POS Dashboard** has:
   - Customer search
   - Today's activity summary
   - Quick actions (New Bill, New Customer, End of Day)
3. **Tab navigation** for major sections:
   - [POS] - Main workspace
   - [Customers] - Customer management (existing)
   - [End of Day] - Review and confirm
   - [Reports] - Future
4. **Bill creation** is full-screen for focus
5. **Context actions** provide shortcuts (e.g., [Bill] button in customer list)
6. **URL routing** enables bookmarking and back/forward navigation

This design prioritizes speed and efficiency for daily POS operations while maintaining easy access to customer management and end-of-day tasks.
