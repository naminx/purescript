-- Sample data for Bill Editor - matching ACTUAL database schema

-- Clean up
DELETE FROM bills WHERE id IN (30, 31);

-- Bill 30: Jewelry purchase
INSERT INTO bills (id, customer_id, date,
  prev_balance_money, prev_gram_jewel, prev_baht_jewel,
  prev_gram_bar96, prev_baht_bar96, prev_gram_bar99, prev_baht_bar99,
  is_vat_deferred, vat_rate, market_buying_price_jewel)
VALUES (30, 1, '2025-11-23',
  1000.00, 0.000, 0.000,
  0.000, 0.000, 0.000, 0.000,
  false, 7.00, 30000.00);

-- Tray group
INSERT INTO bill_groups (bill_id, group_type, display_order)
VALUES (30, 'tray', 1);

-- Tray
INSERT INTO trays (group_id, internal_num, is_return, purity, shape, discount, actual_weight_grams, price_rate)
SELECT id, 1, false, 96.5, 'jewelry', 5, 53.354, 30000.00
FROM bill_groups WHERE bill_id = 30 AND group_type = 'tray';

-- Tray items
INSERT INTO tray_items (tray_id, display_order, making_charge, nominal_weight, quantity, amount)
SELECT t.id, 1, 500.00, 1.000, 1, 30500.00
FROM trays t JOIN bill_groups bg ON t.group_id = bg.id WHERE bg.bill_id = 30;

INSERT INTO tray_items (tray_id, display_order, making_charge, nominal_weight, quantity, amount)
SELECT t.id, 2, 800.00, 2.000, 1, 60800.00
FROM trays t JOIN bill_groups bg ON t.group_id = bg.id WHERE bg.bill_id = 30;

-- Transaction group
INSERT INTO bill_groups (bill_id, group_type, display_order)
VALUES (30, 'transaction', 2);

-- Transaction
INSERT INTO transactions (group_id)
SELECT id FROM bill_groups WHERE bill_id = 30 AND group_type = 'transaction';

-- Transaction item (money out - shop pays customer)
INSERT INTO transaction_items (transaction_id, display_order, transaction_type, balance_type, amount_money)
SELECT tr.id, 1, 'money_out', 'jewel', 100000.00
FROM transactions tr JOIN bill_groups bg ON tr.group_id = bg.id WHERE bg.bill_id = 30;

-- Bill 31: Gold bar sale
INSERT INTO bills (id, customer_id, date,
  prev_balance_money, prev_gram_jewel, prev_baht_jewel,
  prev_gram_bar96, prev_baht_bar96, prev_gram_bar99, prev_baht_bar99,
  is_vat_deferred, vat_rate, market_buying_price_jewel)
VALUES (31, 2, '2025-11-23',
  50000.00, 0.000, 0.000,
  0.000, 0.000, 0.000, 0.000,
  false, 7.00, 30500.00);

-- Pack group
INSERT INTO bill_groups (bill_id, group_type, display_order)
VALUES (31, 'pack', 1);

-- Pack
INSERT INTO packs (group_id, internal_id, user_number)
SELECT id, 1, 'PACK-001'
FROM bill_groups WHERE bill_id = 31 AND group_type = 'pack';

-- Pack items (with required fields)
INSERT INTO pack_items (pack_id, display_order, deduction_rate, shape, purity, weight_grams, calculation_amount)
SELECT p.id, 1, '0', 'bar', 96.5, 15.244, 30500.00
FROM packs p JOIN bill_groups bg ON p.group_id = bg.id WHERE bg.bill_id = 31;

INSERT INTO pack_items (pack_id, display_order, deduction_rate, shape, purity, weight_grams, calculation_amount)
SELECT p.id, 2, '0', 'bar', 96.5, 15.244, 30500.00
FROM packs p JOIN bill_groups bg ON p.group_id = bg.id WHERE bg.bill_id = 31;

-- Transaction group
INSERT INTO bill_groups (bill_id, group_type, display_order)
VALUES (31, 'transaction', 2);

-- Transaction
INSERT INTO transactions (group_id)
SELECT id FROM bill_groups WHERE bill_id = 31 AND group_type = 'transaction';

-- Transaction item (money in - customer pays shop)
INSERT INTO transaction_items (transaction_id, display_order, transaction_type, balance_type, amount_money)
SELECT tr.id, 1, 'money_in', 'bar96', 62000.00
FROM transactions tr JOIN bill_groups bg ON tr.group_id = bg.id WHERE bg.bill_id = 31;

-- Verify
SELECT 'Bills:' as info, COUNT(*) FROM bills WHERE id IN (30, 31);
SELECT 'Groups:' as info, COUNT(*) FROM bill_groups WHERE bill_id IN (30, 31);
SELECT 'Trays:' as info, COUNT(*) FROM trays WHERE group_id IN (SELECT id FROM bill_groups WHERE bill_id IN (30, 31));
SELECT 'Tray items:' as info, COUNT(*) FROM tray_items WHERE tray_id IN (SELECT id FROM trays WHERE group_id IN (SELECT id FROM bill_groups WHERE bill_id IN (30, 31)));
SELECT 'Packs:' as info, COUNT(*) FROM packs WHERE group_id IN (SELECT id FROM bill_groups WHERE bill_id IN (30, 31));
SELECT 'Pack items:' as info, COUNT(*) FROM pack_items WHERE pack_id IN (SELECT id FROM packs WHERE group_id IN (SELECT id FROM bill_groups WHERE bill_id IN (30, 31)));
SELECT 'Transactions:' as info, COUNT(*) FROM transactions WHERE group_id IN (SELECT id FROM bill_groups WHERE bill_id IN (30, 31));
SELECT 'Transaction items:' as info, COUNT(*) FROM transaction_items WHERE transaction_id IN (SELECT id FROM transactions WHERE group_id IN (SELECT id FROM bill_groups WHERE bill_id IN (30, 31)));
