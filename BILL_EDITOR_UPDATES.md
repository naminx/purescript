# Bill Editor Specification Updates

## Date: 2025-11-21

## Summary

Updated `specs.md` → `BILL_EDITOR.md` with comprehensive VAT calculation rules (including gold bar making charges), concurrent editing strategy, and on-the-fly calculation approach.

## Latest Update: Gold Bar Making Charges (VAT Inclusive)

Small gold bars (1-2 baht) incur **block making charges** which are **VAT INCLUSIVE** (unlike jewelry making charges which are VAT EXCLUSIVE).

**Key Formula:**
- Jewelry: VAT = charge × 7/100 (VAT ADDED)
- Bars: VAT = charge × 7/107 (VAT EXTRACTED)

**See VAT_BAR_MAKING_CHARGE.md for complete details.**

---

## Major Updates

### 1. Module Naming
- **Old:** "Billing Statement Module"
- **New:** "Bill Editor" (บิลลูกค้า)
- **Rationale:** Clear, concise, matches existing "Today's Bills" naming pattern

### 2. VAT (Value Added Tax) Section Added

Complete VAT calculation specification including:

#### What Gets Taxed
- ✅ Making charges (after discount)
- ✅ 99.99% premium (MUST be set if purity > 96.5%)
- ✅ Spread (selling price - market buying price)
- ❌ Conversion charges (shop-customer only)
- ❌ Split bar charges (shop-customer only)
- ❌ Gold bars (exempted in Thailand)
- ❌ Customer selling to us (only buying is taxed)
- ❌ Return trays (VAT deferred if bill has returns)

#### VAT Rate
- Current: 7% flat
- Adjustable: Government may change
- Applied: Per bill total (not per item)

#### VAT Calculation Formula
```
For non-return trays only:
  Total weight = actual_weight_grams × 0.0656 baht
  Making charge = sum(items.amount) × (100 - discount) / 100
  Premium = IF purity == 100.0 THEN weight × premium_rate ELSE 0
  Total charges = making_charge + premium

Net amount = weight × selling_price + total_charges
Deduction = weight × market_buying_price
Taxable amount = net_amount - deduction
VAT = ROUND(taxable_amount × vat_rate / 100, 2)
```

#### VAT Determination
- **Taxable:** Clerk unchecks "VAT Deferred" checkbox
- **Deferred:** Bill has returns OR mixed settlement (gold + money)

#### VAT Validation
1. If purity > 96.5% → `additional_charge_rate` MUST be set (not NULL)
2. If VAT not deferred → `market_buying_price_jewel` MUST be set
3. If bill has returns → VAT MUST be deferred

### 3. Database Schema Updates

#### Bills Table - Added VAT Fields
```sql
-- VAT fields
is_vat_deferred BOOLEAN DEFAULT TRUE NOT NULL,
vat_rate NUMERIC(5,2) DEFAULT 7.00 NOT NULL,
market_buying_price_jewel NUMERIC(12,2),
vat_taxable_amount NUMERIC(12,2),
vat_amount NUMERIC(12,2),

-- Status
is_finalized BOOLEAN DEFAULT FALSE NOT NULL,
finalized_at TIMESTAMP,

-- Concurrent editing
version INT DEFAULT 1 NOT NULL
```

#### Bill Groups Table - Added Concurrent Editing
```sql
-- Concurrent editing support
version INT DEFAULT 1 NOT NULL,
updated_by VARCHAR(100),
created_at TIMESTAMP DEFAULT NOW() NOT NULL,
updated_at TIMESTAMP DEFAULT NOW() NOT NULL
```

#### Removed All Totals from Groups
- **Trays:** Removed `money_total`, `gram_jewel_total`, etc. (7 fields)
- **Packs:** Removed `money_total`, `gram_jewel_total`, etc. (7 fields)
- **Transactions:** Removed `money_total`, `gram_jewel_total`, etc. (7 fields)

**Rationale:** Calculate on-the-fly to prevent data inconsistency

### 4. Calculation Strategy: On-The-Fly

**Decision:** NO cached totals in database (except final balances in bills table)

**Benefits:**
- ✅ Single source of truth (items only)
- ✅ No inconsistency possible
- ✅ Simpler code (no triggers)
- ✅ Easier to debug
- ✅ Fast enough (bills are small)

**Calculation Flow:**
```
Items → Group Totals → Accumulated Totals → Grand Total → VAT → Final Balance
```

### 5. Concurrent Editing: Optimistic Locking + Polling

**Decision:** Option C - Optimistic locking with 3-second polling

**How It Works:**
1. Each group has `version` field
2. Poll server every 3 seconds
3. Auto-merge changes from other clerks
4. Show who's editing what
5. Conflict detection on save

**Benefits:**
- ✅ Simple (no WebSocket)
- ✅ 3-second delay acceptable
- ✅ Prevents data loss
- ✅ Auto-merges when possible

**Conflict Resolution:**
- Different groups → Auto-merge
- Same group → Show error, ask reload

### 6. Bill Lifecycle

1. **Draft** (`is_finalized = FALSE`)
   - Being edited
   - Multiple clerks can work simultaneously
   - Totals calculated on-the-fly
   - Customer balances NOT updated

2. **Finalized** (`is_finalized = TRUE`)
   - Complete
   - Final balances cached
   - Customer balances updated
   - Can still edit until end of day

3. **Locked** (end of day)
   - Cannot edit
   - Used for accounting

---

## Key Clarifications Received

### VAT Taxation
1. **Only customer buying jewelry is taxed** (not selling, not bars)
2. **Market price changes 47 times/day** → Must input per bill
3. **99.99% premium MUST be set** if purity > 96.5% (validation required)
4. **Packs don't contribute to taxable amount** (customer brings used gold)
5. **Return trays → VAT deferred** (can't calculate spread)

### Concurrent Editing
1. **3-second polling is enough** (not real-time needed)
2. **Auto-merge when possible** (clerks work on different trays)
3. **Show who's editing** (visual feedback)
4. **Conflicts are rare** (different trays)

### Calculation
1. **On-the-fly is acceptable** (no noticeable delay)
2. **No cached totals** (prevents inconsistency)
3. **Only cache final balances** (when bill finalized)

---

## Files Updated

1. **BILL_EDITOR.md** (renamed from specs.md)
   - Added VAT section (complete specification)
   - Updated database schema (removed totals, added VAT fields)
   - Added concurrent editing section
   - Added calculation strategy section
   - Added implementation strategy section

2. **SPECS_CORRECTIONS.md** (created)
   - Documents all corrections made to original specs
   - Explains single-unit transaction rule
   - Provides examples and FAQ

3. **BILLING_IMPLEMENTATION_PLAN.md** (created)
   - 12-week implementation roadmap
   - 8 phases with detailed tasks
   - Technical decisions documented
   - Risk mitigation strategies

4. **BILL_EDITOR_UPDATES.md** (this file)
   - Summary of all updates
   - Key clarifications
   - Decision rationale

---

## Next Steps

1. ✅ Specification complete and reviewed
2. ✅ VAT calculation clarified
3. ✅ Concurrent editing strategy decided
4. ✅ Database schema finalized
5. ⏭️ Ready to begin implementation (Phase 0: Foundation)

**See BILLING_IMPLEMENTATION_PLAN.md for detailed implementation steps.**

---

## Questions Answered

**Q: How is VAT calculated?**
A: Only for customer buying jewelry. Taxable amount = (weight × selling_price + charges) - (weight × market_price). VAT = taxable × 7%.

**Q: Should we cache totals in database?**
A: NO. Calculate on-the-fly from items to prevent inconsistency.

**Q: How to handle concurrent editing?**
A: Optimistic locking + 3-second polling. Auto-merge when possible.

**Q: What if 99.99% premium not set?**
A: Validation error. MUST be set if purity > 96.5%.

**Q: Can bills be edited after finalization?**
A: YES, until end of day. Then locked.

**Q: How often does market price change?**
A: Up to 47 times per day! Must input per bill.

**Q: Do packs contribute to VAT?**
A: NO. Packs are customer bringing used gold (not buying).

**Q: What if bill has return trays?**
A: VAT is automatically deferred (can't calculate spread on returns).
