# Decimal Implementation Roadmap

## Quick Reference

**Database:** ✅ Already correct (PostgreSQL NUMERIC)  
**Library:** decimal.js (industry standard)  
**Approach:** Opaque Decimal type via FFI  
**Timeline:** 2-3 days for full implementation

## Phase-by-Phase Implementation

### Phase 1: Foundation (Day 1, Morning)

#### 1.1 Install decimal.js
```bash
npm install decimal.js
```

#### 1.2 Create Decimal Module
- [ ] Create `src/Decimal.purs` (type definitions)
- [ ] Create `src/Decimal.js` (FFI implementation)
- [ ] Configure decimal.js for financial calculations
- [ ] Test basic operations in REPL

**Deliverable:** Working Decimal module with arithmetic operations

**Test:**
```purescript
import Decimal as D

test = do
  let a = D.unsafeFromString "0.1"
  let b = D.unsafeFromString "0.2"
  let result = D.add a b
  log $ D.toString result  -- Should print "0.3"
```

### Phase 2: Type System Update (Day 1, Afternoon)

#### 2.1 Update Database Types
- [ ] Update `src/Database/Types.purs`
- [ ] Change all `Number` to `Decimal` for financial fields
- [ ] Keep `rowHeight` as `Number` (not financial)

#### 2.2 Update API Module
- [ ] Update `src/Database/API.purs`
- [ ] Add Decimal JSON decoding
- [ ] Parse string values to Decimal
- [ ] Handle parsing errors gracefully

**Deliverable:** Type system updated, compilation errors identified

**Expected:** ~50-100 compilation errors (all Number → Decimal conversions)

### Phase 3: Server Update (Day 1, Evening)

#### 3.1 Remove Number Conversions
- [ ] Update `server.js`
- [ ] Remove `convertNumericFields()` function
- [ ] Keep numeric fields as strings from pg driver
- [ ] Test all API endpoints return strings

#### 3.2 Verify Database Connection
- [ ] Test GET /api/customers
- [ ] Verify money field is string: `"10000.50"`
- [ ] Verify gram fields are strings: `"40.000"`

**Deliverable:** Server returns numeric fields as strings

**Test:**
```bash
curl http://localhost:8080/api/customers | jq '.[0].money'
# Should return: "10000.50" (string, not number)
```

### Phase 4: Display Layer (Day 2, Morning)

#### 4.1 Update Formatting Functions
- [ ] Update `formatMoneyValue` to use Decimal
- [ ] Update `formatGramsValue` to use Decimal
- [ ] Update `formatBahtValue` to use Decimal
- [ ] Test formatting with various values

#### 4.2 Update Rendering
- [ ] Update `renderMoney` to use Decimal
- [ ] Update `renderGrams` to use Decimal
- [ ] Update `renderBaht` to use Decimal
- [ ] Test display in browser

**Deliverable:** Values display correctly in UI

**Test:** Open browser, verify all money/gold values display correctly

### Phase 5: Input Parsing (Day 2, Afternoon)

#### 5.1 Update Input Handlers
- [ ] Update `parseMoneyInput` to return `Maybe Decimal`
- [ ] Update `parseGoldInput` to return `Maybe Decimal`
- [ ] Add validation for decimal format
- [ ] Handle invalid input gracefully

#### 5.2 Update Edit Mode
- [ ] Update `getFieldValue` to format Decimal for editing
- [ ] Update `UpdateField` action to parse Decimal
- [ ] Test editing values in UI

**Deliverable:** Can edit and save values without precision loss

**Test:** Edit a value like "0.01", save, reload - should be exact

### Phase 6: Sorting & Filtering (Day 2, Evening)

#### 6.1 Update Comparison Functions
- [ ] Update `compareByMoney` to use `D.compare`
- [ ] Update `compareByGoldJewelry` to use `D.compare`
- [ ] Update all gold comparison functions
- [ ] Test sorting in UI

#### 6.2 Update Filtering
- [ ] Update `filterByDebit` to use `D.isNegative`
- [ ] Update `filterByCredit` to use `D.isPositive`
- [ ] Test filtering in UI

**Deliverable:** Sorting and filtering work correctly

**Test:** Sort by money, verify order is correct

### Phase 7: Calculations (Day 3, Morning)

#### 7.1 Create Tax Module
- [ ] Create `src/Tax.purs`
- [ ] Implement VAT calculation
- [ ] Implement withholding tax
- [ ] Implement rounding functions
- [ ] Add unit tests

#### 7.2 Example Calculations
```purescript
-- VAT (7%)
calculateVAT :: Decimal -> Decimal
calculateVAT amount =
  D.multiply amount (D.unsafeFromString "0.07")

-- Total with VAT
totalWithVAT :: Decimal -> Decimal
totalWithVAT amount =
  D.add amount (calculateVAT amount)

-- Round to 2 decimals
roundMoney :: Decimal -> Decimal
roundMoney d =
  let hundred = D.fromInt 100
      multiplied = D.multiply d hundred
      rounded = D.round multiplied
  in D.divide rounded hundred
```

**Deliverable:** Tax calculation functions ready

**Test:** Unit tests for all tax calculations

### Phase 8: Testing & Verification (Day 3, Afternoon)

#### 8.1 Unit Tests
- [ ] Test Decimal arithmetic
- [ ] Test tax calculations
- [ ] Test edge cases (zero, negative, large numbers)
- [ ] Test rounding behavior

#### 8.2 Integration Tests
- [ ] Test full CRUD cycle
- [ ] Test precision preservation
- [ ] Test with real data
- [ ] Test concurrent edits

#### 8.3 Manual Testing
- [ ] Create customer with precise values
- [ ] Edit values multiple times
- [ ] Verify no precision loss
- [ ] Test sorting/filtering
- [ ] Test calculations

**Deliverable:** Fully tested system

### Phase 9: Documentation (Day 3, Evening)

#### 9.1 Code Documentation
- [ ] Document Decimal module
- [ ] Document Tax module
- [ ] Add usage examples
- [ ] Document gotchas

#### 9.2 User Documentation
- [ ] Update README
- [ ] Document precision guarantees
- [ ] Document calculation formulas
- [ ] Add troubleshooting guide

**Deliverable:** Complete documentation

## Verification Checklist

### Precision Tests

```purescript
-- Test 1: Addition
D.add (D.unsafeFromString "0.1") (D.unsafeFromString "0.2")
-- Expected: "0.3" (not 0.30000000000000004)

-- Test 2: Subtraction
D.subtract (D.unsafeFromString "1.0") (D.unsafeFromString "0.9")
-- Expected: "0.1" (not 0.09999999999999998)

-- Test 3: Multiplication
D.multiply (D.unsafeFromString "0.1") (D.unsafeFromString "0.1")
-- Expected: "0.01" (exact)

-- Test 4: Division
D.divide (D.unsafeFromString "1.0") (D.unsafeFromString "3.0")
-- Expected: "0.33333..." (with configured precision)

-- Test 5: VAT Calculation
calculateVAT (D.unsafeFromString "1000.00")
-- Expected: "70.00" (exact)

-- Test 6: Rounding
roundMoney (D.unsafeFromString "10.555")
-- Expected: "10.56" (rounded up)
```

### Database Tests

```sql
-- Test 1: Insert precise value
INSERT INTO customer (name, money) VALUES ('Test', 0.01);
SELECT money FROM customer WHERE name = 'Test';
-- Expected: 0.01 (exact)

-- Test 2: Update precise value
UPDATE customer SET money = 0.03 WHERE name = 'Test';
SELECT money FROM customer WHERE name = 'Test';
-- Expected: 0.03 (exact)

-- Test 3: Arithmetic in database
SELECT money + 0.01 FROM customer WHERE name = 'Test';
-- Expected: 0.04 (exact)
```

### UI Tests

1. **Display Test**
   - Open customer list
   - Verify all values display correctly
   - Check formatting (commas, decimals)

2. **Edit Test**
   - Edit a money value to "0.01"
   - Save
   - Reload page
   - Verify still shows "0.01"

3. **Sort Test**
   - Sort by money
   - Verify order is correct
   - Check negative values sort correctly

4. **Filter Test**
   - Filter by debit (negative)
   - Filter by credit (positive)
   - Verify correct customers shown

## Rollback Plan

If issues arise, we can rollback in phases:

### Rollback Phase 1-2 (Types)
```bash
git revert <commit>
npm run build
```

### Rollback Phase 3 (Server)
```bash
git checkout server.js
npm restart
```

### Rollback Phase 4-6 (UI)
```bash
git revert <commit>
npm run build
```

## Success Criteria

- [ ] All money/gold values use Decimal type
- [ ] No `parseFloat()` in server code
- [ ] No `Number` type for financial fields
- [ ] All arithmetic operations exact
- [ ] Tax calculations correct to 0.01
- [ ] UI displays values correctly
- [ ] Can edit values without precision loss
- [ ] Sorting/filtering works correctly
- [ ] All tests pass
- [ ] Documentation complete

## Risk Mitigation

### Risk 1: Performance
**Mitigation:** Profile and optimize if needed. decimal.js is fast enough for UI.

### Risk 2: Bugs in Conversion
**Mitigation:** Comprehensive testing, gradual rollout, keep old code for reference.

### Risk 3: User Confusion
**Mitigation:** Clear documentation, training, support.

### Risk 4: Integration Issues
**Mitigation:** Test with real data, have rollback plan ready.

## Timeline Summary

| Phase | Duration | Deliverable |
|-------|----------|-------------|
| 1. Foundation | 4 hours | Decimal module working |
| 2. Types | 4 hours | Types updated, errors identified |
| 3. Server | 2 hours | Server returns strings |
| 4. Display | 4 hours | UI displays correctly |
| 5. Input | 4 hours | Can edit values |
| 6. Sort/Filter | 2 hours | Sorting works |
| 7. Calculations | 4 hours | Tax functions ready |
| 8. Testing | 6 hours | All tests pass |
| 9. Documentation | 2 hours | Docs complete |
| **Total** | **32 hours** | **Production ready** |

## Next Steps

1. **Review this plan** - Confirm approach
2. **Install decimal.js** - `npm install decimal.js`
3. **Create Decimal module** - Start with Phase 1
4. **Iterate through phases** - One at a time
5. **Test thoroughly** - At each phase
6. **Deploy to production** - When all tests pass

## Questions to Answer

Before starting:
1. ✅ Database schema correct? **YES - NUMERIC type**
2. ✅ Library choice approved? **decimal.js recommended**
3. ✅ Timeline acceptable? **2-3 days**
4. ✅ Testing strategy clear? **Unit + Integration + Manual**
5. ✅ Rollback plan ready? **Yes, per phase**

Ready to proceed? Let me know and I'll start with Phase 1!
