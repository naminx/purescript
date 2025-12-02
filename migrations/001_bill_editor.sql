-- Migration: Bill Editor Module
-- Date: 2025-11-23
-- Description: Create all tables and enums for Bill Editor module

-- ============================================================================
-- ENUMS
-- ============================================================================

-- Shape type (jewelry or bar)
CREATE TYPE shape_type AS ENUM ('jewelry', 'bar');

-- Balance type (3 gold types)
CREATE TYPE balance_type AS ENUM ('jewel', 'bar96', 'bar99');

-- Group type (tray, pack, or transaction)
CREATE TYPE group_type AS ENUM ('tray', 'pack', 'transaction');

-- Transaction types
CREATE TYPE transaction_type AS ENUM (
  'prev_debit_money',
  'prev_credit_money',
  'prev_debit_jewel',
  'prev_credit_jewel',
  'prev_debit_bar96',
  'prev_credit_bar96',
  'prev_debit_bar99',
  'prev_credit_bar99',
  'money_in',
  'money_out',
  'jewel_in',
  'jewel_out',
  'bar96_in',
  'bar96_out',
  'bar99_in',
  'bar99_out',
  'buy_jewel',
  'sell_jewel',
  'buy_bar96',
  'sell_bar96',
  'buy_bar99',
  'sell_bar99',
  'convert_jewel_to_bar96',
  'convert_bar96_to_jewel',
  'convert_grams_to_baht',
  'convert_baht_to_grams',
  'split_bar'
);

-- ============================================================================
-- TABLES
-- ============================================================================

-- Bills
CREATE TABLE bills (
  id SERIAL PRIMARY KEY,
  customer_id INT NOT NULL REFERENCES customer(id),
  date TIMESTAMP DEFAULT NOW() NOT NULL,

  -- Previous balances (snapshot at bill creation)
  prev_balance_money NUMERIC(12,2) NOT NULL,
  prev_gram_jewel NUMERIC(10,3) NOT NULL,
  prev_baht_jewel NUMERIC(10,3) NOT NULL,
  prev_gram_bar96 NUMERIC(10,3) NOT NULL,
  prev_baht_bar96 NUMERIC(10,3) NOT NULL,
  prev_gram_bar99 NUMERIC(10,3) NOT NULL,
  prev_baht_bar99 NUMERIC(10,3) NOT NULL,

  -- Final balances (calculated when bill is finalized)
  final_balance_money NUMERIC(12,2),
  final_gram_jewel NUMERIC(10,3),
  final_baht_jewel NUMERIC(10,3),
  final_gram_bar96 NUMERIC(10,3),
  final_baht_bar96 NUMERIC(10,3),
  final_gram_bar99 NUMERIC(10,3),
  final_baht_bar99 NUMERIC(10,3),

  -- VAT fields
  is_vat_deferred BOOLEAN DEFAULT TRUE NOT NULL,
  vat_rate NUMERIC(5,2) DEFAULT 7.00 NOT NULL,
  market_buying_price_jewel NUMERIC(12,2),
  vat_taxable_amount NUMERIC(12,2),
  vat_amount NUMERIC(12,2),

  -- Status
  is_finalized BOOLEAN DEFAULT FALSE NOT NULL,
  finalized_at TIMESTAMP,

  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP DEFAULT NOW() NOT NULL,

  -- Concurrent editing support
  version INT DEFAULT 1 NOT NULL
);

CREATE INDEX idx_bills_customer_id ON bills(customer_id);
CREATE INDEX idx_bills_date ON bills(date);
CREATE INDEX idx_bills_is_finalized ON bills(is_finalized);

-- Bill groups
CREATE TABLE bill_groups (
  id SERIAL PRIMARY KEY,
  bill_id INT NOT NULL REFERENCES bills(id) ON DELETE CASCADE,
  group_type group_type NOT NULL,
  display_order INT NOT NULL,

  -- Concurrent editing support
  version INT DEFAULT 1 NOT NULL,
  updated_by VARCHAR(100),

  created_at TIMESTAMP DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP DEFAULT NOW() NOT NULL,

  UNIQUE(bill_id, display_order)
);

CREATE INDEX idx_bill_groups_bill_id ON bill_groups(bill_id);

-- Trays (NO totals - calculated on-the-fly)
CREATE TABLE trays (
  id SERIAL PRIMARY KEY,
  group_id INT NOT NULL UNIQUE REFERENCES bill_groups(id) ON DELETE CASCADE,
  internal_num INT NOT NULL,
  is_return BOOLEAN DEFAULT FALSE NOT NULL,

  -- Purity: NULL = 96.5%, 100 = 99.99%, literal = custom
  purity NUMERIC(6,3),

  shape shape_type NOT NULL,
  discount INT DEFAULT 0 CHECK (discount IN (0, 5, 10)),

  actual_weight_grams NUMERIC(10,3) NOT NULL,
  price_rate NUMERIC(12,2),
  additional_charge_rate NUMERIC(12,2)
);

CREATE INDEX idx_trays_group_id ON trays(group_id);

-- Tray items
CREATE TABLE tray_items (
  id SERIAL PRIMARY KEY,
  tray_id INT NOT NULL REFERENCES trays(id) ON DELETE CASCADE,
  display_order INT NOT NULL,

  making_charge NUMERIC(10,2) NOT NULL,
  jewelry_type_id INT,
  design_name VARCHAR(255),
  nominal_weight NUMERIC(6,3) NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  amount NUMERIC(12,2) NOT NULL,

  UNIQUE(tray_id, display_order)
);

CREATE INDEX idx_tray_items_tray_id ON tray_items(tray_id);

-- Packs (NO totals)
CREATE TABLE packs (
  id SERIAL PRIMARY KEY,
  group_id INT NOT NULL UNIQUE REFERENCES bill_groups(id) ON DELETE CASCADE,
  internal_id INT NOT NULL,
  user_number VARCHAR(50) NOT NULL
);

CREATE INDEX idx_packs_group_id ON packs(group_id);

-- Pack items
CREATE TABLE pack_items (
  id SERIAL PRIMARY KEY,
  pack_id INT NOT NULL REFERENCES packs(id) ON DELETE CASCADE,
  display_order INT NOT NULL,

  deduction_rate VARCHAR(20) NOT NULL,
  shape shape_type NOT NULL,
  purity NUMERIC(6,3),
  description VARCHAR(255),
  weight_grams NUMERIC(10,3),
  weight_baht NUMERIC(10,3),
  calculation_amount NUMERIC(12,2) NOT NULL,

  UNIQUE(pack_id, display_order),
  CHECK (
    (weight_grams IS NOT NULL AND weight_baht IS NULL) OR
    (weight_grams IS NULL AND weight_baht IS NOT NULL)
  )
);

CREATE INDEX idx_pack_items_pack_id ON pack_items(pack_id);

-- Transactions (NO totals)
CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  group_id INT NOT NULL UNIQUE REFERENCES bill_groups(id) ON DELETE CASCADE
);

CREATE INDEX idx_transactions_group_id ON transactions(group_id);

-- Transaction items
CREATE TABLE transaction_items (
  id SERIAL PRIMARY KEY,
  transaction_id INT NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
  display_order INT NOT NULL,

  transaction_type transaction_type NOT NULL,

  -- Money fields
  amount_money NUMERIC(12,2),

  -- Gold fields (ONE unit only)
  amount_grams NUMERIC(10,3),
  amount_baht NUMERIC(10,3),

  -- Additional fields
  balance_type balance_type,
  price_rate NUMERIC(12,2),
  conversion_charge_rate NUMERIC(12,2),
  split_charge_rate NUMERIC(12,2),
  block_making_charge_rate NUMERIC(12,2),

  -- For "Convert Jewelry to Bar96" with different units
  source_amount_grams NUMERIC(10,3),
  source_amount_baht NUMERIC(10,3),
  dest_amount_grams NUMERIC(10,3),
  dest_amount_baht NUMERIC(10,3),

  UNIQUE(transaction_id, display_order),
  CHECK (
    (amount_grams IS NOT NULL AND amount_baht IS NULL) OR
    (amount_grams IS NULL AND amount_baht IS NOT NULL) OR
    (amount_grams IS NULL AND amount_baht IS NULL)
  )
);

CREATE INDEX idx_transaction_items_transaction_id ON transaction_items(transaction_id);

-- Jewelry types reference table (if not exists)
CREATE TABLE IF NOT EXISTS jewelry_types (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT NOW() NOT NULL
);

-- Insert some default jewelry types
INSERT INTO jewelry_types (name) VALUES
  ('แหวน'),
  ('สร้อย'),
  ('กำไล'),
  ('ต่างหู'),
  ('จี้'),
  ('เข็มกลัด')
ON CONFLICT (name) DO NOTHING;

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE bills IS 'Customer bills with previous and final balances';
COMMENT ON TABLE bill_groups IS 'Groups within a bill (trays, packs, transactions)';
COMMENT ON TABLE trays IS 'Tray groups for new jewelry purchases';
COMMENT ON TABLE tray_items IS 'Individual items within a tray';
COMMENT ON TABLE packs IS 'Pack groups for used gold brought by customer';
COMMENT ON TABLE pack_items IS 'Individual items within a pack';
COMMENT ON TABLE transactions IS 'Transaction groups for money/gold movements';
COMMENT ON TABLE transaction_items IS 'Individual transactions';

COMMENT ON COLUMN bills.is_vat_deferred IS 'TRUE = VAT deferred (default), FALSE = VAT taxable';
COMMENT ON COLUMN bills.market_buying_price_jewel IS 'Announced price by Gold Traders Association (jewelry only)';
COMMENT ON COLUMN trays.additional_charge_rate IS '99.99% premium rate (THB/baht), MUST be set if purity > 96.5%';
COMMENT ON COLUMN transaction_items.block_making_charge_rate IS 'Block mold cost for small bars (THB/baht), VAT INCLUSIVE';
COMMENT ON COLUMN transaction_items.amount_grams IS 'Gold amount in grams (mutually exclusive with amount_baht)';
COMMENT ON COLUMN transaction_items.amount_baht IS 'Gold amount in baht (mutually exclusive with amount_grams)';
