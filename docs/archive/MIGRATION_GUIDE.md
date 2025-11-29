# Migration Guide: Extended Customer Fields

## Overview

This migration adds comprehensive financial tracking fields to the customer table, including money credit and three types of gold credits with dual weight units (grams and Thai baht).

## Database Changes

### New Fields Added

1. **money_credit** (NUMERIC(15,2)) - Money balance in THB
   - Positive: Customer has money with us
   - Negative: Customer owes us money

2. **Gold Accessory (96.5% purity)**
   - gold_accessory_grams (NUMERIC(15,3))
   - gold_accessory_baht (NUMERIC(15,3))
   - Conversion: 1 baht = 15.200 grams

3. **Gold Bar 96.5%**
   - gold_bar_965_grams (NUMERIC(15,3))
   - gold_bar_965_baht (NUMERIC(15,3))
   - Conversion: 1 baht = 15.244 grams

4. **Gold Bar 99.99%**
   - gold_bar_9999_grams (NUMERIC(15,3))
   - gold_bar_9999_baht (NUMERIC(15,3))
   - Conversion: 1 baht = 15.244 grams

5. **Timestamps**
   - created_at (TIMESTAMP) - Account creation time
   - updated_at (TIMESTAMP) - Last balance update time

### Why Dual Units for Gold?

Storing both grams and baht separately prevents rounding errors. Example:
- Customer has: +1.000 grams, -1.000 baht
- Net: 1.000 - 15.244 = -14.244 grams

If we only stored grams and converted, we'd lose precision.

## Migration Steps

### 1. Apply Database Schema

```bash
# Start database
./start-db.sh

# Apply schema
psql -U postgres -d customer_db -f schema.sql
```

### 2. Verify Migration

```bash
psql -U postgres -d customer_db -c "\d customer"
psql -U postgres -d customer_db -c "SELECT * FROM customer LIMIT 5;"
```

## API Changes

### Updated Endpoints

**GET /api/customers**
- Now returns all new fields

**GET /api/customers/changes?since={timestamp}**
- Now returns all new fields

**POST /api/customers**
- Body: `{ "name": "Customer Name" }`
- Returns: Full customer record with default values (all balances = 0)

**PUT /api/customers/:id**
- Body: `{ "field": "field_name", "value": "value" }`
- Allowed fields: name, money_credit, gold_accessory_grams, gold_accessory_baht, gold_bar_965_grams, gold_bar_965_baht, gold_bar_9999_grams, gold_bar_9999_baht
- Returns: Full updated customer record

**DELETE /api/customers/:id**
- No changes

## UI Changes

### New Table Columns

1. **Money** - Debit/Credit columns
2. **Gold Accessory** - Debit/Credit columns (shows grams + baht)
3. **Gold Bar 96.5%** - Debit/Credit columns (shows grams + baht)
4. **Gold Bar 99.99%** - Debit/Credit columns (shows grams + baht)
5. **Updated** - Shows last update timestamp

### Click-to-Edit Behavior

- All fields are now editable by clicking
- Hover shows highlight to indicate editability
- Edit confirmed by:
  - Pressing Enter
  - Clicking outside the field
- Edit canceled by:
  - Pressing ESC
  - Clicking outside (reverts changes)

### Display Rules

- Debit and Credit columns never show values simultaneously
- Show value in Debit column if negative (display as positive)
- Show value in Credit column if positive
- Leave blank if zero
- Gold weights show grams on top, baht below (blank if zero)

## Testing

### Test Data

The schema includes sample data with various scenarios:
- Positive money credit
- Negative money credit (debt)
- Mixed gold credits (grams + baht)
- Negative gold credits

### Manual Testing Checklist

- [ ] View customers with all field types
- [ ] Edit money credit (positive and negative)
- [ ] Edit gold accessory (grams and baht separately)
- [ ] Edit gold bar 96.5% (grams and baht)
- [ ] Edit gold bar 99.99% (grams and baht)
- [ ] Edit customer name
- [ ] Verify debit/credit display logic
- [ ] Verify gold weight display (grams + baht)
- [ ] Verify updated_at timestamp changes
- [ ] Test sorting by different columns
- [ ] Test search/filter functionality
- [ ] Test virtual scrolling with new wider table

## Rollback

If you need to rollback:

```sql
-- Backup current data
CREATE TABLE customer_backup AS SELECT * FROM customer;

-- Drop and recreate with old schema
DROP TABLE customer CASCADE;
CREATE TABLE customer (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Restore names only
INSERT INTO customer (id, name, updated_at)
SELECT id, name, updated_at FROM customer_backup;
```

## Performance Considerations

- NUMERIC type is slower than FLOAT but necessary for accuracy
- Additional columns increase row size (~100 bytes per row)
- Virtual scrolling handles this efficiently
- Index on updated_at remains for efficient change queries

## Future Enhancements

1. Add validation for gold weight conversions
2. Add automatic conversion between grams and baht
3. Add transaction history (audit log)
4. Add balance summary/totals
5. Add export to Excel/CSV
