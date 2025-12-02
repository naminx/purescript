# Gold Bar Making Charge - VAT Inclusive

## Date: 2025-11-21

## New Requirement

Small gold bars (1-2 baht) incur a **block making charge** which is the cost of making a block mold to cast them. This making charge is **VAT INCLUSIVE** (unlike jewelry making charges which are VAT EXCLUSIVE).

---

## Key Differences

### Jewelry Making Charges (VAT EXCLUSIVE)
```
Making charge: 5,000 THB
VAT (7%): 5,000 × 0.07 = 350 THB
Total: 5,000 + 350 = 5,350 THB

VAT is ADDED to the charge
```

### Bar Making Charges (VAT INCLUSIVE)
```
Making charge: 930 THB (already includes VAT)
VAT (7%): 930 × 7/107 = 60.84 THB
Total: 930 THB (VAT already included)

VAT is EXTRACTED from the charge
```

---

## Example Transaction

**Customer buys gold bars:**

### Transaction 1: Buy Bar96 (1 baht bars)
- Quantity: 1 baht × 3 pcs = 3 baht
- Gold price: 41,000 THB/baht
- Block making charge rate: 150 THB/baht (VAT INCLUSIVE)

**Calculation:**
```
Gold cost: 3 × 41,000 = 123,000 THB
Making charge: 3 × 150 = 450 THB (VAT INCLUSIVE)
Total: 123,450 THB

VAT extracted: 450 × 7/107 = 29.44 THB
```

### Transaction 2: Buy Bar96 (2 baht bars)
- Quantity: 2 baht × 2 pcs = 4 baht
- Gold price: 41,000 THB/baht
- Block making charge rate: 120 THB/baht (VAT INCLUSIVE)
  - Note: 2 baht blocks are cheaper per baht than 1 baht blocks

**Calculation:**
```
Gold cost: 4 × 41,000 = 164,000 THB
Making charge: 4 × 120 = 480 THB (VAT INCLUSIVE)
Total: 164,480 THB

VAT extracted: 480 × 7/107 = 31.40 THB
```

### Summary
```
Total gold cost: 287,000 THB
Total making charge: 930 THB (VAT INCLUSIVE)
Customer pays: 287,930 THB

Total VAT collected: 60.84 THB (extracted from 930 THB)
```

---

## VAT Calculation Formula

### For VAT INCLUSIVE charges (bars):
```
VAT = charge × vat_rate / (100 + vat_rate)
VAT = charge × 7 / 107

Example:
  Charge = 930 THB
  VAT = 930 × 7 / 107 = 60.84 THB
  Net (excluding VAT) = 930 - 60.84 = 869.16 THB
```

### For VAT EXCLUSIVE charges (jewelry):
```
VAT = charge × vat_rate / 100
VAT = charge × 7 / 100

Example:
  Charge = 5,000 THB
  VAT = 5,000 × 7 / 100 = 350 THB
  Total (including VAT) = 5,000 + 350 = 5,350 THB
```

---

## Database Schema Update

### transaction_items table - Added field:
```sql
-- For gold bar purchases (1-2 baht bars)
block_making_charge_rate NUMERIC(12,2),  -- THB/baht, VAT INCLUSIVE
```

### Transaction Types Updated:
```
Buy Bar96: amount_gold, price_rate, block_making_charge_rate (optional, VAT INCLUSIVE)
Buy Bar99: amount_gold, price_rate, block_making_charge_rate (optional, VAT INCLUSIVE)
```

---

## Implementation Notes

### 1. UI Input
- Add optional "Block Making Charge" field for Buy Bar96/Bar99 transactions
- Label: "ค่าทำแม่พิมพ์" (Block mold cost)
- Unit: THB/baht
- Note: "VAT included" (รวม VAT แล้ว)
- Typically used for 1-2 baht bars only

### 2. Validation
- `block_making_charge_rate` is optional (can be NULL)
- If set, must be positive number
- No validation against announced price (it's a fixed cost)

### 3. Calculation
```purescript
calculateBarMakingCharge :: TransactionItem -> { charge :: Number, vat :: Number }
calculateBarMakingCharge item =
  case item.block_making_charge_rate of
    Nothing -> { charge: 0.0, vat: 0.0 }
    Just rate ->
      let weight = getWeight item  -- in baht
          charge = weight * rate
          vat = round2 (charge * 7.0 / 107.0)
      in { charge, vat }

where
  getWeight :: TransactionItem -> Number
  getWeight item = 
    fromMaybe 0.0 item.amount_baht + 
    (fromMaybe 0.0 item.amount_grams * 0.0656)
```

### 4. Display
```
Buy Bar96: 3 baht @ 41,000 THB/baht
  Gold cost: 123,000 THB
  Block making: 450 THB (incl. VAT 29.44)
  Total: 123,450 THB
```

### 5. VAT Report
```
Bill #12345 - VAT Breakdown:

Jewelry VAT (exclusive):
  Tray 1: 402.25 THB
  Subtotal: 402.25 THB

Bar Making Charge VAT (inclusive - extracted):
  Transaction 1 (3 baht): 29.44 THB
  Transaction 2 (4 baht): 31.40 THB
  Subtotal: 60.84 THB

Total VAT: 463.09 THB
```

---

## Why VAT Inclusive for Bars?

**Business Reason:**
- Block making is a fixed cost service
- Price is quoted including VAT (like retail prices)
- Customer sees one price, no surprise VAT addition
- Simpler for small transactions

**Accounting:**
- Shop still tracks VAT separately for tax reporting
- VAT is extracted from the inclusive price
- Net revenue = charge - VAT

---

## Testing Checklist

- [ ] Add block_making_charge_rate field to transaction_items table
- [ ] Update Buy Bar96/Bar99 transaction forms to include optional making charge input
- [ ] Implement VAT extraction formula (× 7/107)
- [ ] Test with example: 3 baht @ 150 THB/baht = 450 THB → VAT = 60.84 THB
- [ ] Verify VAT report shows both exclusive (jewelry) and inclusive (bars) VAT
- [ ] Test combined bill with jewelry + bars
- [ ] Verify customer total is correct (gold + making charge, VAT already in making charge)
- [ ] Test with NULL making charge (should work, no making charge applied)
- [ ] Test with different bar sizes (1 baht, 2 baht, larger bars without making charge)

---

## Common Scenarios

### Scenario 1: Small bars with making charge
```
Buy 1 baht bar × 5 pcs
Gold: 5 × 41,000 = 205,000 THB
Making: 5 × 150 = 750 THB (incl VAT 49.07)
Total: 205,750 THB
```

### Scenario 2: Large bars without making charge
```
Buy 10 baht bar × 1 pc
Gold: 10 × 41,000 = 410,000 THB
Making: 0 THB (no block needed for large bars)
Total: 410,000 THB
```

### Scenario 3: Mixed sizes
```
Buy 1 baht × 3 pcs: 123,000 + 450 (incl VAT 29.44) = 123,450 THB
Buy 10 baht × 1 pc: 410,000 + 0 = 410,000 THB
Total: 533,450 THB
Total VAT: 29.44 THB
```

---

## Questions & Answers

**Q: Why is bar making charge VAT inclusive but jewelry making charge is VAT exclusive?**
A: Business practice. Bar making is quoted as a fixed price including VAT (like retail). Jewelry making is a service charge where VAT is added separately.

**Q: Do all bars have making charges?**
A: No. Only small bars (1-2 baht) typically have block making charges. Larger bars don't need custom molds.

**Q: Can the rate be different for different bar sizes?**
A: Yes. Typically 1 baht bars have higher rate per baht than 2 baht bars (economies of scale).

**Q: Is the making charge per piece or per baht?**
A: Per baht. So 3 pieces of 1 baht = 3 baht × rate.

**Q: What if customer buys bars in grams instead of baht?**
A: Convert to baht first (grams × 0.0656), then apply rate.

**Q: Does this apply to 99.99% bars too?**
A: Yes. Both Bar96 and Bar99 can have block making charges.
