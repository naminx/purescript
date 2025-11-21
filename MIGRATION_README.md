# MySQL to PostgreSQL Customer Data Migration

This document describes how to migrate customer data from the MySQL `yuhuad2` database to the PostgreSQL `customer` table.

## Overview

The MySQL database stores customer gold balances split across 3 separate rows per customer (one for each gold type), while PostgreSQL consolidates them into a single row with separate columns for each gold type.

### Data Mapping

| MySQL (yuhuad2.client) | PostgreSQL (customer) | Notes |
|------------------------|----------------------|-------|
| `base` | `name` | Customer name (from base field) |
| `base_id` | - | Used for grouping, not stored |
| `money` (SUM) | `money` | Sum of all 3 goldtype rows |
| `gold` WHERE goldtype=1 | `gram_jewelry` | Gold jewelry (96.5% purity) |
| - | `baht_jewelry` | Always 0 |
| `gold` WHERE goldtype=2 | `gram_bar96` | 96.5% gold bars |
| - | `baht_bar96` | Always 0 |
| `gold` WHERE goldtype=3 | `gram_bar99` | 99.99% gold bars |
| - | `baht_bar99` | Always 0 |
| NOW() | `created_at` | Current timestamp |
| MAX(`date`) | `updated_at` | Latest date from grouped rows |

### MySQL Data Structure

Each customer has up to 3 rows in the `client` table:
- `goldtype=1`: Gold jewelry account
- `goldtype=2`: 96.5% gold bar account  
- `goldtype=3`: 99.99% gold bar account

All rows with the same `base_id` belong to the same customer.

## Migration Script

### Prerequisites

```bash
# Python 3.6+ required
python3 --version

# For direct database insertion (optional)
pip install psycopg2-binary
```

### Usage

#### 1. Validate Data (Recommended First Step)

```bash
python3 migrate_yuhuad.py yuhuad2.sql --validate-only --show-warnings
```

This will:
- Parse the MySQL dump file
- Group records by `base_id`
- Report any data issues
- Show statistics

**Expected output:**
```
Reading yuhuad2.sql...
Parsed 10210 MySQL rows into 4073 customers

Validation warnings:
  ⚠️  Customer 'ไพลิน' has only 1 goldtype(s) (expected 3)
  ...

✅ Validation complete: 4073 customers, 1231 warnings
```

**Note:** Warnings about missing goldtypes are normal - not all customers have all 3 gold types.

#### 2. Generate SQL File

```bash
python3 migrate_yuhuad.py yuhuad2.sql --output migrated_data.sql
```

This creates a PostgreSQL-compatible SQL file that you can review before importing.

#### 3. Direct Database Import

```bash
python3 migrate_yuhuad.py yuhuad2.sql --direct \
  --db-host localhost \
  --db-port 5432 \
  --db-name customer_db \
  --db-user postgres \
  --db-pass postgres
```

This will:
1. Connect to PostgreSQL
2. Truncate the `customer` table
3. Insert all migrated data
4. Commit the transaction

**⚠️ WARNING:** This will delete all existing data in the `customer` table!

#### 4. Import Generated SQL File

If you generated a SQL file in step 2:

```bash
# Using docker exec
docker exec -i purescript-postgres psql -U postgres -d customer_db < migrated_data.sql

# Or using psql directly
psql -h localhost -p 5432 -U postgres -d customer_db -f migrated_data.sql
```

### Command-Line Options

```
positional arguments:
  input_file            Input MySQL dump file (yuhuad2.sql)

optional arguments:
  -h, --help            Show help message
  --output FILE, -o FILE
                        Write SQL to file (default: stdout)
  --direct              Insert directly to PostgreSQL
  --db-host HOST        PostgreSQL host (default: localhost)
  --db-port PORT        PostgreSQL port (default: 5432)
  --db-name NAME        Database name (default: customer_db)
  --db-user USER        Database user (default: postgres)
  --db-pass PASS        Database password (default: postgres)
  --validate-only       Only validate data without generating output
  --show-warnings       Show all validation warnings
```

## Data Handling

### Duplicate Base Names

If multiple `base_id` values have the same `base` name, they are treated as different customers and numbered:
- First occurrence: `"Customer Name"`
- Second occurrence: `"Customer Name (2)"`
- Third occurrence: `"Customer Name (3)"`
- etc.

### Missing Gold Types

If a customer doesn't have all 3 goldtype rows, missing values default to 0:
- Missing goldtype=1: `gram_jewelry = 0`
- Missing goldtype=2: `gram_bar96 = 0`
- Missing goldtype=3: `gram_bar99 = 0`

### Negative Values

Negative values are preserved as-is:
- Negative `money`: Customer owes money
- Negative `gold`: Customer owes gold

### Money Aggregation

The `money` field is summed across all 3 goldtype rows for each customer:
```
total_money = money[goldtype=1] + money[goldtype=2] + money[goldtype=3]
```

### Date Handling

The `updated_at` field uses the latest `date` value from all goldtype rows for that customer.

## Example Migration

### Source MySQL Data (3 rows)
```sql
-- base_id = 651, base = 'ยู่หลงกิมกี่'
(40,  'ยู่หลงกิมกี่แท่ง96.5',  2, '-20525.000', '-14059400.00', ..., '2025-10-24 15:10:44', ..., 'ยู่หลงกิมกี่', 651, 0)
(651, 'ยู่หลงกิมกี่',           1, '0.000',      '-30017831.00', ..., '2025-06-11 15:40:23', ..., 'ยู่หลงกิมกี่', 651, 0)
(878, 'ยู่หลงกิมกี่แท่ง99.99',  3, '-8000.000',  '21440.00',     ..., '2025-09-26 12:15:15', ..., 'ยู่หลงกิมกี่', 651, 0)
```

### Migrated PostgreSQL Data (1 row)
```sql
INSERT INTO customer (name, money, gram_jewelry, baht_jewelry, gram_bar96, baht_bar96, gram_bar99, baht_bar99, created_at, updated_at)
VALUES ('ยู่หลงกิมกี่', -44055791.00, 0.000, 0.000, -20525.000, 0.000, -8000.000, 0.000, NOW(), '2025-10-24 15:10:44');
```

**Calculations:**
- `money`: -14059400.00 + -30017831.00 + 21440.00 = **-44055791.00**
- `gram_jewelry`: 0.000 (from goldtype=1)
- `gram_bar96`: -20525.000 (from goldtype=2)
- `gram_bar99`: -8000.000 (from goldtype=3)
- `updated_at`: 2025-10-24 15:10:44 (latest date)

## Verification

After migration, verify the data:

```sql
-- Check total customer count
SELECT COUNT(*) FROM customer;
-- Expected: ~4073 customers

-- Check for customers with balances
SELECT COUNT(*) FROM customer 
WHERE money != 0 OR gram_jewelry != 0 OR gram_bar96 != 0 OR gram_bar99 != 0;

-- View sample customers
SELECT id, name, money, gram_jewelry, gram_bar96, gram_bar99 
FROM customer 
ORDER BY id 
LIMIT 10;

-- Check for extreme values
SELECT name, money, gram_jewelry, gram_bar96, gram_bar99
FROM customer
WHERE ABS(money) > 10000000 OR ABS(gram_jewelry) > 10000 
   OR ABS(gram_bar96) > 10000 OR ABS(gram_bar99) > 10000;
```

## Troubleshooting

### Script Errors

**"File not found"**
```bash
# Make sure yuhuad2.sql is in the current directory
ls -lh yuhuad2.sql
```

**"psycopg2 not installed"**
```bash
pip install psycopg2-binary
```

**"Connection refused"**
```bash
# Check if PostgreSQL container is running
docker-compose ps
docker-compose up -d
```

### Data Issues

**Too many warnings**
- Most warnings about missing goldtypes are normal
- Use `--show-warnings` to see details
- Focus on warnings about extreme values

**Duplicate names**
- Check the migration output for "(2)", "(3)" suffixes
- These indicate customers with the same base name but different base_id

**Missing data**
- Verify the MySQL dump file is complete
- Check if the file encoding is UTF-8

## Future Migrations

When you need to migrate fresh data from MySQL:

1. **Export latest MySQL data:**
   ```bash
   mysqldump -u root -p yuhuad2 client > yuhuad2_latest.sql
   ```

2. **Validate the new dump:**
   ```bash
   python3 migrate_yuhuad.py yuhuad2_latest.sql --validate-only --show-warnings
   ```

3. **Backup current PostgreSQL data:**
   ```bash
   docker exec purescript-postgres pg_dump -U postgres customer_db > backup_$(date +%Y%m%d).sql
   ```

4. **Run migration:**
   ```bash
   python3 migrate_yuhuad.py yuhuad2_latest.sql --direct
   ```

5. **Verify the migration:**
   ```bash
   docker exec purescript-postgres psql -U postgres -d customer_db -c "SELECT COUNT(*) FROM customer;"
   ```

## Script Maintenance

The migration script is designed to be flexible for future schema changes:

- **Adding new fields:** Modify the `to_sql_values()` method in `CustomerRecord` class
- **Changing aggregation logic:** Update the `add_row()` method
- **Custom validation:** Add checks in the `validate_data()` function

The script is located at: `migrate_yuhuad.py`
