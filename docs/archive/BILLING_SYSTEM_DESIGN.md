# Gold Jewelry Shop Billing System - Design Document

## System Overview

A point-of-sale (POS) billing system for a gold jewelry shop that integrates with the existing customer management system. The system handles daily transactions, maintains running balances, and performs end-of-day settlement.

---

## Workflow

### Morning - System Startup

1. **Clerk logs in**
   - Opens web application
   - Authenticates (clerk ID/name)
   - System loads:
     - Customer list (read-only for quick lookup)
     - Pending bills from previous day (if any)
     - Today's bills (if any)

2. **System displays main screen**
   - Customer search/select
   - Quick "New Customer" button
   - List of today's bills (by clerk or all)
   - "New Bill" button (prominent)

### During Day - Transaction Flow

#### Scenario 1: New Customer

1. **Clerk clicks "New Customer"**
   - Modal/form appears
   - Enter customer name
   - System creates customer with zero balances
   - Customer immediately available for billing

2. **Proceed to create bill** (see Scenario 2)

#### Scenario 2: Existing Customer - First Bill of Day

1. **Clerk searches for customer**
   - Type name in search box
   - Select from filtered list
   - System shows:
     - Customer name
     - **Opening balance** (from customer table)
     - Previous bills today (if any)

2. **Clerk clicks "New Bill"**
   - Bill creation screen opens
   - Shows:
     - Customer name
     - Bill number (auto-generated: `YYYYMMDD-XXXX`)
     - **Starting balance** = Customer's current balance
     - Empty line items
     - Running total

3. **Clerk adds items**
   - For each item:
     - Select item type (buy/sell, jewelry/bar96/bar99)
     - Enter weight (grams or baht)
     - Enter price per unit
     - System calculates line total
   - Running balance updates after each line

4. **Clerk completes bill**
   - Review totals
   - Click "Save Bill" (not "Confirm" yet)
   - Bill saved as **PENDING**
   - System returns to main screen

#### Scenario 3: Same Customer - Second Bill of Day

1. **Clerk searches for same customer**
   - System shows:
     - Customer name
     - **Opening balance** (original from customer table)
     - **Previous bills today**:
       - Bill #1: 10:30 AM, -5,000 THB, Status: PENDING
       - Running balance after Bill #1: -5,000 THB

2. **Clerk clicks "New Bill"**
   - **Starting balance** = Opening balance + Sum of previous bills today
   - Example: 0 + (-5,000) = -5,000 THB
   - Clerk adds items as before

3. **Bill saved as PENDING**
   - Does not update customer balance yet
   - Visible in "Today's Bills" list

#### Scenario 4: Customer Returns - Modify Existing Bill

1. **Clerk finds customer**
   - Views today's bills
   - Clicks on bill to edit

2. **System opens bill in edit mode**
   - Can add/remove/modify line items
   - Running balance recalculates
   - Click "Save" to update

3. **Subsequent bills automatically adjust**
   - If Bill #1 is modified, Bill #2's starting balance updates
   - Chain effect through all bills for that customer today

### End of Day - Settlement

#### Review Phase

1. **Manager/Clerk clicks "End of Day Review"**
   - System shows:
     - All pending bills for today
     - Grouped by customer
     - Summary per customer:
       - Opening balance
       - Total transactions today
       - Closing balance (calculated)

2. **Review each customer**
   - Expand to see individual bills
   - Can still edit/delete bills if needed
   - Mark bills for confirmation or void

#### Confirmation Phase

1. **Manager clicks "Confirm All Bills"**
   - System prompts: "This will update all customer balances. Continue?"
   - Confirmation code required (like delete confirmation)

2. **System processes**
   - For each customer with pending bills:
     - Calculate net change (sum of all bills)
     - Update customer balance fields:
       - `money += net_money_change`
       - `gram_jewelry += net_jewelry_grams_change`
       - `baht_jewelry += net_jewelry_baht_change`
       - `gram_bar96 += net_bar96_grams_change`
       - `baht_bar96 += net_bar96_baht_change`
       - `gram_bar99 += net_bar99_grams_change`
       - `baht_bar99 += net_bar99_baht_change`
     - Mark all bills as **CONFIRMED**
     - Set confirmation timestamp

3. **System displays summary**
   - "X customers updated"
   - "Y bills confirmed"
   - "Total money: +/- Z THB"
   - "Total gold: +/- W grams"

4. **Bills are now immutable**
   - Cannot edit confirmed bills
   - Can only view for reference

---

## Database Schema

### New Table: `bill`

```sql
CREATE TABLE bill (
  id SERIAL PRIMARY KEY,
  bill_number VARCHAR(20) UNIQUE NOT NULL,  -- Format: YYYYMMDD-XXXX
  customer_id INT NOT NULL REFERENCES customer(id),
  clerk_name VARCHAR(100) NOT NULL,
  
  -- Starting balance (snapshot from customer + previous bills)
  starting_money NUMERIC(15, 2) NOT NULL,
  starting_gram_jewelry NUMERIC(15, 3) NOT NULL,
  starting_baht_jewelry NUMERIC(15, 3) NOT NULL,
  starting_gram_bar96 NUMERIC(15, 3) NOT NULL,
  starting_baht_bar96 NUMERIC(15, 3) NOT NULL,
  starting_gram_bar99 NUMERIC(15, 3) NOT NULL,
  starting_baht_bar99 NUMERIC(15, 3) NOT NULL,
  
  -- Net changes from this bill
  net_money NUMERIC(15, 2) NOT NULL DEFAULT 0,
  net_gram_jewelry NUMERIC(15, 3) NOT NULL DEFAULT 0,
  net_baht_jewelry NUMERIC(15, 3) NOT NULL DEFAULT 0,
  net_gram_bar96 NUMERIC(15, 3) NOT NULL DEFAULT 0,
  net_baht_bar96 NUMERIC(15, 3) NOT NULL DEFAULT 0,
  net_gram_bar99 NUMERIC(15, 3) NOT NULL DEFAULT 0,
  net_baht_bar99 NUMERIC(15, 3) NOT NULL DEFAULT 0,
  
  -- Ending balance (starting + net)
  ending_money NUMERIC(15, 2) NOT NULL,
  ending_gram_jewelry NUMERIC(15, 3) NOT NULL,
  ending_baht_jewelry NUMERIC(15, 3) NOT NULL,
  ending_gram_bar96 NUMERIC(15, 3) NOT NULL,
  ending_baht_bar96 NUMERIC(15, 3) NOT NULL,
  ending_gram_bar99 NUMERIC(15, 3) NOT NULL,
  ending_baht_bar99 NUMERIC(15, 3) NOT NULL,
  
  -- Status and timestamps
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING',  -- PENDING, CONFIRMED, VOIDED
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  confirmed_at TIMESTAMP,
  confirmed_by VARCHAR(100),
  
  -- Optional notes
  notes TEXT
);

CREATE INDEX idx_bill_customer_id ON bill(customer_id);
CREATE INDEX idx_bill_status ON bill(status);
CREATE INDEX idx_bill_created_at ON bill(created_at);
CREATE INDEX idx_bill_number ON bill(bill_number);
```

### New Table: `bill_item`

```sql
CREATE TABLE bill_item (
  id SERIAL PRIMARY KEY,
  bill_id INT NOT NULL REFERENCES bill(id) ON DELETE CASCADE,
  line_number INT NOT NULL,  -- Order within bill
  
  -- Item details
  item_type VARCHAR(20) NOT NULL,  -- BUY_JEWELRY, SELL_JEWELRY, BUY_BAR96, SELL_BAR96, BUY_BAR99, SELL_BAR99, CASH_IN, CASH_OUT
  description TEXT,
  
  -- Weight (for gold items)
  weight_grams NUMERIC(15, 3),
  weight_baht NUMERIC(15, 3),
  
  -- Pricing
  price_per_unit NUMERIC(15, 2),  -- Price per gram or per baht
  amount NUMERIC(15, 2) NOT NULL,  -- Total for this line (positive or negative)
  
  -- Impact on balances (calculated)
  money_change NUMERIC(15, 2) NOT NULL DEFAULT 0,
  gram_jewelry_change NUMERIC(15, 3) NOT NULL DEFAULT 0,
  baht_jewelry_change NUMERIC(15, 3) NOT NULL DEFAULT 0,
  gram_bar96_change NUMERIC(15, 3) NOT NULL DEFAULT 0,
  baht_bar96_change NUMERIC(15, 3) NOT NULL DEFAULT 0,
  gram_bar99_change NUMERIC(15, 3) NOT NULL DEFAULT 0,
  baht_bar99_change NUMERIC(15, 3) NOT NULL DEFAULT 0,
  
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE(bill_id, line_number)
);

CREATE INDEX idx_bill_item_bill_id ON bill_item(bill_id);
```

---

## Data Model

### Bill States

```
PENDING → CONFIRMED
   ↓
VOIDED (can void before confirmation)
```

### Transaction Types

| Type | Description | Money | Gold | Example |
|------|-------------|-------|------|---------|
| `BUY_JEWELRY` | Customer sells jewelry to shop | + | - | Customer sells 10g jewelry for 30,000 THB |
| `SELL_JEWELRY` | Shop sells jewelry to customer | - | + | Customer buys 5g jewelry for 15,000 THB |
| `BUY_BAR96` | Customer sells 96.5% bar | + | - | Customer sells 1 baht bar96 |
| `SELL_BAR96` | Shop sells 96.5% bar | - | + | Customer buys 2 baht bar96 |
| `BUY_BAR99` | Customer sells 99.99% bar | + | - | Customer sells 10g bar99 |
| `SELL_BAR99` | Shop sells 99.99% bar | - | + | Customer buys 1 baht bar99 |
| `CASH_IN` | Customer deposits cash | + | 0 | Customer pays 10,000 THB |
| `CASH_OUT` | Customer withdraws cash | - | 0 | Customer withdraws 5,000 THB |

### Balance Calculation

**For each bill:**
```
ending_balance = starting_balance + net_change

where:
  starting_balance = customer_balance + sum(previous_bills_today.net_change)
  net_change = sum(bill_items.change)
```

**At end of day confirmation:**
```
customer.money += sum(confirmed_bills_today.net_money)
customer.gram_jewelry += sum(confirmed_bills_today.net_gram_jewelry)
... (for all fields)
```

---

## UI Components

### 1. Main Dashboard

```
┌─────────────────────────────────────────────────────────────┐
│ Gold Shop POS - Clerk: John                    [End of Day] │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Customer: [Search customer.....................] [New]      │
│                                                               │
│  Selected: Jane Smith                                        │
│  Opening Balance: 5,000 THB | 10.5g jewelry | 2บ bar96      │
│                                                               │
│  Today's Bills:                                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ 20241119-0001  10:30 AM  -5,000 THB  PENDING  [Edit] │  │
│  │ 20241119-0002  11:45 AM  +2,500 THB  PENDING  [Edit] │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                               │
│  Running Balance: 2,500 THB | 10.5g jewelry | 2บ bar96      │
│                                                               │
│  [New Bill]                                                  │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### 2. Bill Creation/Edit Screen

```
┌─────────────────────────────────────────────────────────────┐
│ Bill: 20241119-0003                              [Save] [×]  │
├─────────────────────────────────────────────────────────────┤
│ Customer: Jane Smith                                         │
│ Clerk: John                                                  │
│ Date: 2024-11-19 14:30                                      │
│                                                               │
│ Starting Balance:                                            │
│   Money: 2,500 THB                                          │
│   Jewelry: 10.5g / 0บ                                       │
│   Bar 96.5%: 0g / 2บ                                        │
│   Bar 99.99%: 0g / 0บ                                       │
│                                                               │
│ Items:                                                       │
│ ┌───────────────────────────────────────────────────────┐  │
│ │ # │ Type        │ Weight  │ Price/Unit │ Amount      │  │
│ ├───┼─────────────┼─────────┼────────────┼─────────────┤  │
│ │ 1 │ Sell Jewelry│ 5.000g  │ 3,000/g    │ -15,000 THB │  │
│ │ 2 │ Cash In     │ -       │ -          │ +10,000 THB │  │
│ │   │             │         │            │             │  │
│ └───┴─────────────┴─────────┴────────────┴─────────────┘  │
│                                                               │
│ [Add Item ▼]                                                 │
│                                                               │
│ Net Change:                                                  │
│   Money: -5,000 THB                                         │
│   Jewelry: +5.000g                                          │
│                                                               │
│ Ending Balance:                                              │
│   Money: -2,500 THB (DEBIT)                                 │
│   Jewelry: 15.5g / 0บ                                       │
│   Bar 96.5%: 0g / 2บ                                        │
│   Bar 99.99%: 0g / 0บ                                       │
│                                                               │
│ Notes: [Optional notes....................................]  │
│                                                               │
│ [Save as Pending]                              [Cancel]      │
└─────────────────────────────────────────────────────────────┘
```

### 3. End of Day Review Screen

```
┌─────────────────────────────────────────────────────────────┐
│ End of Day Review - 2024-11-19                               │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│ Pending Bills: 15                                            │
│ Customers Affected: 8                                        │
│                                                               │
│ ┌───────────────────────────────────────────────────────┐  │
│ │ ▼ Jane Smith (3 bills)                                │  │
│ │   Opening: 5,000 THB | 10.5g jewelry                  │  │
│ │   Bills:                                               │  │
│ │     20241119-0001  -5,000 THB  [View] [Edit] [Void]  │  │
│ │     20241119-0002  +2,500 THB  [View] [Edit] [Void]  │  │
│ │     20241119-0003  -5,000 THB  [View] [Edit] [Void]  │  │
│ │   Net Change: -7,500 THB | +5g jewelry                │  │
│ │   Closing: -2,500 THB | 15.5g jewelry                 │  │
│ └───────────────────────────────────────────────────────┘  │
│                                                               │
│ │ ▼ John Doe (2 bills)                                  │  │
│ │   ...                                                  │  │
│ └───────────────────────────────────────────────────────┘  │
│                                                               │
│ Summary:                                                     │
│   Total Money Change: -25,000 THB                           │
│   Total Gold Change: +150g jewelry, +5บ bar96               │
│                                                               │
│ [Confirm All Bills]                            [Cancel]      │
└─────────────────────────────────────────────────────────────┘
```

---

## API Endpoints

### Bills

```
GET    /api/bills                    # Get all bills (with filters)
GET    /api/bills/:id                # Get single bill with items
POST   /api/bills                    # Create new bill
PUT    /api/bills/:id                # Update bill (if PENDING)
DELETE /api/bills/:id                # Delete bill (if PENDING)
POST   /api/bills/:id/void           # Void bill (if PENDING)

GET    /api/bills/today              # Get today's bills
GET    /api/bills/today/:customer_id # Get today's bills for customer
GET    /api/bills/pending            # Get all pending bills
```

### Bill Items

```
GET    /api/bills/:bill_id/items     # Get items for bill
POST   /api/bills/:bill_id/items     # Add item to bill
PUT    /api/bills/:bill_id/items/:id # Update item
DELETE /api/bills/:bill_id/items/:id # Delete item
```

### End of Day

```
GET    /api/eod/summary              # Get end-of-day summary
POST   /api/eod/confirm              # Confirm all pending bills
```

### Bill Number Generation

```
POST   /api/bills/next-number        # Get next bill number
```

---

## Business Rules

### 1. Bill Creation
- Bill number auto-generated: `YYYYMMDD-XXXX` (date + sequence)
- Starting balance = customer balance + sum of previous bills today
- Bill saved as PENDING by default
- Can create multiple bills per customer per day

### 2. Bill Editing
- Can only edit PENDING bills
- Editing a bill recalculates all subsequent bills for that customer
- Cannot edit after confirmation

### 3. Bill Deletion/Voiding
- Can only delete/void PENDING bills
- Voiding marks bill as VOIDED (keeps record)
- Deleting removes bill completely
- Subsequent bills recalculate

### 4. End of Day Confirmation
- Requires manager/supervisor role (future enhancement)
- Requires confirmation code
- Updates all customer balances atomically
- Marks all bills as CONFIRMED
- Cannot undo after confirmation

### 5. Balance Calculations
- All calculations use NUMERIC type (no floating point errors)
- Negative balances allowed (customer owes shop)
- Positive balances allowed (shop owes customer)

### 6. Transaction Types
- BUY = Customer sells to shop (shop buys)
  - Money increases (shop pays customer)
  - Gold decreases (shop receives gold)
- SELL = Shop sells to customer (customer buys)
  - Money decreases (customer pays shop)
  - Gold increases (customer receives gold)

---

## Implementation Phases

### Phase 1: Core Billing (Week 1-2)
- [ ] Database schema (bill, bill_item tables)
- [ ] Bill CRUD API endpoints
- [ ] Bill creation UI
- [ ] Bill item management
- [ ] Balance calculations

### Phase 2: Customer Integration (Week 3)
- [ ] Customer search/select
- [ ] New customer creation from POS
- [ ] Display customer balances
- [ ] Today's bills per customer
- [ ] Running balance display

### Phase 3: End of Day (Week 4)
- [ ] End of day review screen
- [ ] Bill confirmation logic
- [ ] Customer balance updates
- [ ] Confirmation audit trail

### Phase 4: Enhancements (Week 5+)
- [ ] Bill printing/PDF export
- [ ] Receipt generation
- [ ] Clerk authentication
- [ ] Role-based permissions
- [ ] Bill search/filtering
- [ ] Reports (daily, weekly, monthly)
- [ ] Void/refund handling
- [ ] Multi-clerk support

---

## Technical Considerations

### 1. Concurrency
- Multiple clerks may work simultaneously
- Use optimistic locking (version field) for bills
- Real-time updates via polling or WebSockets

### 2. Data Integrity
- Use database transactions for:
  - Bill confirmation (update multiple customers)
  - Bill editing (recalculate subsequent bills)
- Foreign key constraints ensure referential integrity

### 3. Performance
- Index on customer_id, status, created_at
- Pagination for bill lists
- Cache today's bills in memory

### 4. Audit Trail
- Keep all bill history (don't delete)
- Track who created/modified/confirmed each bill
- Log all balance changes

### 5. Error Handling
- Validate all inputs (weights, prices, amounts)
- Handle network failures gracefully
- Show clear error messages to clerks

---

## Security Considerations

### 1. Authentication
- Clerk must log in before using POS
- Session timeout after inactivity
- Secure password storage

### 2. Authorization
- Clerks can create/edit their own bills
- Managers can confirm end of day
- Admins can void confirmed bills (future)

### 3. Data Protection
- HTTPS for all API calls
- Encrypt sensitive data at rest
- Regular backups

### 4. Audit Logging
- Log all bill operations
- Log all balance changes
- Log all confirmations

---

## Questions to Consider

1. **Pricing Strategy**
   - Fixed price per gram/baht?
   - Different prices for buy vs sell?
   - Price adjustments for quality/purity?

2. **Item Descriptions**
   - Free text or predefined categories?
   - SKU/barcode support?
   - Photo attachments?

3. **Payment Methods**
   - Cash only?
   - Credit card, bank transfer?
   - Partial payments?

4. **Returns/Exchanges**
   - How to handle returns?
   - Exchange old gold for new?
   - Refund policy?

5. **Inventory Management**
   - Track shop's gold inventory?
   - Alert when inventory low?
   - Integration with suppliers?

6. **Multi-Store Support**
   - Single store or multiple branches?
   - Centralized customer database?
   - Store-specific pricing?

---

## Next Steps

1. **Review and approve this design**
2. **Clarify business rules** (pricing, returns, etc.)
3. **Create database migration** (add bill tables)
4. **Implement Phase 1** (core billing)
5. **Test with sample data**
6. **Deploy to staging environment**
7. **Train clerks on new system**
8. **Go live with Phase 1**
9. **Iterate based on feedback**

---

## Summary

This billing system design provides:

- **Seamless integration** with existing customer management
- **Flexible transaction handling** (buy, sell, cash)
- **Running balance tracking** throughout the day
- **Safe end-of-day settlement** with confirmation
- **Audit trail** for all transactions
- **Scalable architecture** for future enhancements

The system follows the natural workflow of a gold shop, from morning startup through daily transactions to end-of-day settlement, while maintaining data integrity and providing clear visibility into customer balances.
