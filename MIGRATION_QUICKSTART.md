# Quick Start: Migrate yuhuad2.sql to PostgreSQL

## One-Command Migration

```bash
# Direct migration to PostgreSQL (⚠️ DELETES existing data)
python3 migrate_yuhuad.py yuhuad2.sql --direct
```

## Step-by-Step (Recommended)

### 1. Validate First
```bash
python3 migrate_yuhuad.py yuhuad2.sql --validate-only
```

### 2. Generate SQL File
```bash
python3 migrate_yuhuad.py yuhuad2.sql --output migrated_data.sql
```

### 3. Review the SQL
```bash
head -50 migrated_data.sql
tail -20 migrated_data.sql
```

### 4. Import to PostgreSQL
```bash
docker exec -i purescript-postgres psql -U postgres -d customer_db < migrated_data.sql
```

### 5. Verify
```bash
docker exec purescript-postgres psql -U postgres -d customer_db -c "SELECT COUNT(*) FROM customer;"
```

## What It Does

- ✅ Groups 10,210 MySQL rows → 4,073 PostgreSQL customers
- ✅ Sums money across 3 goldtype accounts
- ✅ Consolidates jewelry, bar96, bar99 into one row
- ✅ Preserves negative values (debits)
- ✅ Handles missing goldtypes (defaults to 0)
- ✅ Renames duplicate base names with (2), (3), etc.

## Expected Results

```
Reading yuhuad2.sql...
Parsed 10210 MySQL rows into 4073 customers
✅ Successfully inserted 4073 customers
```

## Need Help?

See [MIGRATION_README.md](MIGRATION_README.md) for detailed documentation.
