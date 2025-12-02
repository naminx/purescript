-- Customer Management Database Schema
-- Using NUMERIC type for all monetary and weight values to avoid floating point errors

DROP TABLE IF EXISTS customer CASCADE;

CREATE TABLE customer (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  
  -- Money credit in THB (Thai Baht)
  -- Positive = customer has money with us, Negative = customer owes us
  money NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
  
  -- Gold jewelry credit (96.5% purity)
  -- 1 baht = 15.24 grams
  -- Store both to avoid rounding errors
  gram_jewelry NUMERIC(15, 3) NOT NULL DEFAULT 0.000,
  baht_jewelry NUMERIC(15, 3) NOT NULL DEFAULT 0.000,
  
  -- 96.5% gold bar credit
  -- 1 baht = 15.244 grams
  gram_bar96 NUMERIC(15, 3) NOT NULL DEFAULT 0.000,
  baht_bar96 NUMERIC(15, 3) NOT NULL DEFAULT 0.000,
  
  -- 99.99% gold bar credit
  -- 1 baht = 15.244 grams (same conversion)
  gram_bar99 NUMERIC(15, 3) NOT NULL DEFAULT 0.000,
  baht_bar99 NUMERIC(15, 3) NOT NULL DEFAULT 0.000,
  
  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Index on updated_at for efficient change queries
CREATE INDEX idx_customer_updated_at ON customer(updated_at);

-- Sample data for testing
-- Fractions in baht are multiples of 1/8 (0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875)
INSERT INTO customer (name, money, gram_jewelry, baht_jewelry, gram_bar96, baht_bar96, gram_bar99, baht_bar99) VALUES
  ('John Doe', 10000.50, 40.000, -3.500, 0.000, 0.000, 0.000, 0.000),
  ('Jane Smith', -5000.00, -25.000, 2.125, 15.244, -1.750, 0.000, 0.000),
  ('Bob Johnson', 0.00, 100.500, -5.875, 0.000, 0.000, 30.488, 2.250),
  ('Alice Williams', 25000.75, -15.240, 3.625, 45.000, -2.375, 15.244, 1.125),
  ('Charlie Brown', -1500.25, 75.000, -4.250, -20.000, 1.500, 0.000, 0.000),
  ('David Lee', 3500.00, 12.345, 0.875, 8.500, -0.625, 25.000, -1.375),
  ('Emma Wilson', -750.50, -5.000, 0.375, 50.000, 3.750, -10.000, 0.750);

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to call the function before UPDATE
CREATE TRIGGER update_customer_updated_at BEFORE UPDATE ON customer
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
