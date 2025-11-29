# Specs.md Corrections Summary

## Date: 2025-11-21

## Issues Found and Fixed

### Issue 1: Automatic Unit Conversion (CRITICAL)

**Problem:** Original spec implied that transactions could automatically convert between grams and baht.

**Example of incorrect behavior:**
```
Customer gives 10g jewelry
Old spec: Add to both gram_jewel AND baht_jewel
```

**Corrected behavior:**
```
Customer gives 10g jewelry
New spec: Add ONLY to gram_jewel, leave baht_jewel untouched

Customer gives 5 baht jewelry
New spec: Add ONLY to baht_jewel, leave gram_jewel untouched
```

**Rationale:** The dual-unit system exists to prevent rounding errors, not to force conversion. Only explicit "Convert Grams to Baht" / "Convert Baht to Grams" transactions should convert units.

---

### Issue 2: Transaction Type Fields

**Problem:** Transaction types showed `amount_gold: Either grams baht` which was ambiguous.

**Corrected:** Changed to `amount_gold: Either grams baht (ONE unit only)` to emphasize mutual exclusivity.

**Database enforcement:** Added CHECK constraint to ensure only one of `amount_grams` or `amount_baht` is set.

---

### Issue 3: Conversion Between Gold Types

**Problem:** Original spec showed automatic conversion of both units:
```
Convert 10g jewelry to bar96
Debit: gram_jewel -= 10g
       baht_jewel -= (10g × 0.0656) baht  ← WRONG!
```

**Corrected:** Clerk specifies BOTH source and destination units independently:
```
Example 1: Convert 15g jewelry to 2 baht bar96
Debit: gram_jewel -= 15g (baht_jewel unchanged)
Credit: baht_bar96 += 2 baht (gram_bar96 unchanged)

Example 2: Convert 10g jewelry to 10g bar96
Debit: gram_jewel -= 10g (baht_jewel unchanged)
Credit: gram_bar96 += 10g (baht_bar96 unchanged)
```

**Key insight:** Source and destination amounts can be different. Customer decides how much to convert from and to.

---

### Issue 4: Charge Calculation Clarity

**Problem:** Not clear how to calculate charges when transaction is in grams.

**Clarified:** 
- Price rate is ALWAYS in THB/baht
- If transaction is in grams, multiply by 0.0656 to get baht equivalent
- Example: 10g at 40,000 THB/baht → 10 × 0.0656 × 40,000 = 26,240 THB

---

### Issue 5: Split Bar Unit

**Problem:** Not specified whether splitting can be in grams or baht.

**Clarified:** Split Bar is ALWAYS in baht unit. Net weight change is zero (only charge applies).

---

## New Sections Added

### 1. Critical Requirements Summary (at top of specs)
Added ⚠️ section highlighting the 5 most important rules that must be understood before implementing.

### 2. Transaction Examples (Detailed)
Added 6 comprehensive examples showing:
- Jewel In (grams)
- Jewel In (baht)
- Bar96 Out (grams)
- Buy Jewel (grams with price)
- Sell Bar99 (baht with price)
- Convert Jewelry to Bar96 (mixed units)

### 3. Database Schema Notes
Added comments to transaction_items table explaining:
- Mutual exclusivity of amount_grams and amount_baht
- Single-unit rule enforcement
- Price rate always in THB/baht
- Conversion calculation rules

---

## Key Principles Established

1. **Single-Unit Transactions:** Every transaction affects exactly ONE unit (grams OR baht, never both)

2. **Explicit Conversions Only:** No automatic unit conversion. Clerk must explicitly choose "Convert Grams to Baht" or "Convert Baht to Grams"

3. **Independent Source/Destination:** For type conversions (Jewelry ↔ Bar96), source and destination units are specified independently

4. **Consistent Charge Calculation:** All price rates are in THB/baht. Use 0.0656 multiplier for gram-based transactions

5. **Dual-Unit Purpose:** The system allows customers to have mixed balances (e.g., 10g credit but 2 baht debit) to prevent rounding errors

---

## Implementation Checklist

- [ ] Update transaction input forms to show "Grams OR Baht" radio buttons
- [ ] Add validation to prevent both units being entered
- [ ] Update charge calculation to use 0.0656 multiplier for gram transactions
- [ ] Update conversion forms to show separate source and destination unit selectors
- [ ] Add database CHECK constraint for amount_grams/amount_baht mutual exclusivity
- [ ] Update UI to clearly show which unit is being affected
- [ ] Add tooltips explaining the single-unit rule
- [ ] Test edge cases (negative balances, mixed units, conversions)

---

## Questions Answered

**Q: If customer gives us gold in grams, should we add it to both gram and baht fields?**
A: NO. Add ONLY to the gram field, leave baht field untouched.

**Q: How do we calculate charges for gram-based transactions?**
A: Multiply grams by 0.0656 to get baht equivalent, then multiply by price rate (THB/baht).

**Q: Can source and destination amounts be different in conversions?**
A: YES. Customer can convert 15g jewelry to 2 baht bar96. They're independent.

**Q: What if customer doesn't have enough balance in the specified unit?**
A: Allow negative balance. The system tracks debits and credits separately. Customer might have 10g credit but 5 baht debit in the same gold type.

**Q: Why have dual units if we never convert automatically?**
A: To prevent rounding errors and allow flexible transactions. Customer can accumulate grams from some transactions and baht from others without forced conversions.
