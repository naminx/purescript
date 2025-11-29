-- Rollback: Bill Editor Module
-- Date: 2025-11-23
-- Description: Drop all tables and enums for Bill Editor module

-- Drop tables (in reverse order of creation)
DROP TABLE IF EXISTS transaction_items CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS pack_items CASCADE;
DROP TABLE IF EXISTS packs CASCADE;
DROP TABLE IF EXISTS tray_items CASCADE;
DROP TABLE IF EXISTS trays CASCADE;
DROP TABLE IF EXISTS bill_groups CASCADE;
DROP TABLE IF EXISTS bills CASCADE;

-- Drop enums
DROP TYPE IF EXISTS transaction_type;
DROP TYPE IF EXISTS group_type;
DROP TYPE IF EXISTS balance_type;
DROP TYPE IF EXISTS shape_type;

-- Note: jewelry_types table is not dropped as it may be used by other modules
