// Bill Editor API Routes
// Handles all HTTP endpoints for Bill Editor module

const express = require('express');
const router = express.Router();

// ============================================================================
// BILL ROUTES
// ============================================================================

// GET /api/bills/:id - Get bill with all groups and items
router.get('/:id', async (req, res) => {
  const { pool } = req.app.locals;
  const billId = parseInt(req.params.id);
  
  try {
    // Get bill
    const billResult = await pool.query(
      'SELECT * FROM bills WHERE id = $1',
      [billId]
    );
    
    if (billResult.rows.length === 0) {
      return res.status(404).json({ error: 'Bill not found' });
    }
    
    const bill = billResult.rows[0];
    
    // Get all groups for this bill
    const groupsResult = await pool.query(
      `SELECT * FROM bill_groups 
       WHERE bill_id = $1 
       ORDER BY display_order`,
      [billId]
    );
    
    // For each group, get its data (tray/pack/transaction) and items
    const groups = await Promise.all(groupsResult.rows.map(async (group) => {
      let groupData;
      
      if (group.group_type === 'tray') {
        const trayResult = await pool.query(
          'SELECT * FROM trays WHERE group_id = $1',
          [group.id]
        );
        const tray = trayResult.rows[0];
        
        const itemsResult = await pool.query(
          `SELECT * FROM tray_items 
           WHERE tray_id = $1 
           ORDER BY display_order`,
          [tray.id]
        );
        
        groupData = {
          type: 'tray',
          tray,
          items: itemsResult.rows
        };
      } else if (group.group_type === 'pack') {
        const packResult = await pool.query(
          'SELECT * FROM packs WHERE group_id = $1',
          [group.id]
        );
        const pack = packResult.rows[0];
        
        const itemsResult = await pool.query(
          `SELECT * FROM pack_items 
           WHERE pack_id = $1 
           ORDER BY display_order`,
          [pack.id]
        );
        
        groupData = {
          type: 'pack',
          pack,
          items: itemsResult.rows
        };
      } else if (group.group_type === 'transaction') {
        const transactionResult = await pool.query(
          'SELECT * FROM transactions WHERE group_id = $1',
          [group.id]
        );
        const transaction = transactionResult.rows[0];
        
        const itemsResult = await pool.query(
          `SELECT * FROM transaction_items 
           WHERE transaction_id = $1 
           ORDER BY display_order`,
          [transaction.id]
        );
        
        groupData = {
          type: 'transaction',
          transaction,
          items: itemsResult.rows
        };
      }
      
      return {
        ...group,
        data: groupData
      };
    }));
    
    res.json({
      bill,
      groups
    });
  } catch (error) {
    console.error('Error fetching bill:', error);
    res.status(500).json({ error: error.message });
  }
});

// POST /api/bills - Create new bill for customer
router.post('/', async (req, res) => {
  const { pool } = req.app.locals;
  const { customer_id } = req.body;
  
  if (!customer_id) {
    return res.status(400).json({ error: 'customer_id is required' });
  }
  
  try {
    // Get customer's current balances
    const customerResult = await pool.query(
      'SELECT * FROM customer WHERE id = $1',
      [customer_id]
    );
    
    if (customerResult.rows.length === 0) {
      return res.status(404).json({ error: 'Customer not found' });
    }
    
    const customer = customerResult.rows[0];
    
    // Create bill with previous balances from customer
    const billResult = await pool.query(
      `INSERT INTO bills (
        customer_id,
        prev_balance_money,
        prev_gram_jewel,
        prev_baht_jewel,
        prev_gram_bar96,
        prev_baht_bar96,
        prev_gram_bar99,
        prev_baht_bar99
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      RETURNING *`,
      [
        customer_id,
        customer.money || 0,
        customer.gram_jewelry || 0,
        customer.baht_jewelry || 0,
        customer.gram_bar96 || 0,
        customer.baht_bar96 || 0,
        customer.gram_bar99 || 0,
        customer.baht_bar99 || 0
      ]
    );
    
    res.json(billResult.rows[0]);
  } catch (error) {
    console.error('Error creating bill:', error);
    res.status(500).json({ error: error.message });
  }
});

// PUT /api/bills/:id - Update bill
router.put('/:id', async (req, res) => {
  const { pool } = req.app.locals;
  const billId = parseInt(req.params.id);
  const {
    is_vat_deferred,
    vat_rate,
    market_buying_price_jewel,
    version
  } = req.body;
  
  try {
    // Optimistic locking - check version
    const result = await pool.query(
      `UPDATE bills 
       SET is_vat_deferred = $1,
           vat_rate = $2,
           market_buying_price_jewel = $3,
           version = version + 1,
           updated_at = NOW()
       WHERE id = $4 AND version = $5
       RETURNING *`,
      [is_vat_deferred, vat_rate, market_buying_price_jewel, billId, version]
    );
    
    if (result.rows.length === 0) {
      return res.status(409).json({ 
        error: 'Conflict: Bill was modified by another user' 
      });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error updating bill:', error);
    res.status(500).json({ error: error.message });
  }
});

// DELETE /api/bills/:id - Delete bill
router.delete('/:id', async (req, res) => {
  const { pool } = req.app.locals;
  const billId = parseInt(req.params.id);
  
  try {
    await pool.query('DELETE FROM bills WHERE id = $1', [billId]);
    res.json({ success: true });
  } catch (error) {
    console.error('Error deleting bill:', error);
    res.status(500).json({ error: error.message });
  }
});

// GET /api/bills/customer/:customerId - Get bills by customer
router.get('/customer/:customerId', async (req, res) => {
  const { pool } = req.app.locals;
  const customerId = parseInt(req.params.customerId);
  
  try {
    const result = await pool.query(
      `SELECT * FROM bills 
       WHERE customer_id = $1 
       ORDER BY date DESC`,
      [customerId]
    );
    
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching bills:', error);
    res.status(500).json({ error: error.message });
  }
});

// POST /api/bills/:id/finalize - Finalize bill
router.post('/:id/finalize', async (req, res) => {
  const { pool } = req.app.locals;
  const billId = parseInt(req.params.id);
  const { final_balances } = req.body;
  
  try {
    // Update bill with final balances
    const result = await pool.query(
      `UPDATE bills 
       SET is_finalized = TRUE,
           finalized_at = NOW(),
           final_balance_money = $1,
           final_gram_jewel = $2,
           final_baht_jewel = $3,
           final_gram_bar96 = $4,
           final_baht_bar96 = $5,
           final_gram_bar99 = $6,
           final_baht_bar99 = $7
       WHERE id = $8
       RETURNING *`,
      [
        final_balances.money,
        final_balances.gram_jewel,
        final_balances.baht_jewel,
        final_balances.gram_bar96,
        final_balances.baht_bar96,
        final_balances.gram_bar99,
        final_balances.baht_bar99,
        billId
      ]
    );
    
    // Update customer balances
    const bill = result.rows[0];
    await pool.query(
      `UPDATE customer 
       SET money = $1,
           gram_jewelry = $2,
           baht_jewelry = $3,
           gram_bar96 = $4,
           baht_bar96 = $5,
           gram_bar99 = $6,
           baht_bar99 = $7,
           updated_at = NOW()
       WHERE id = $8`,
      [
        final_balances.money,
        final_balances.gram_jewel,
        final_balances.baht_jewel,
        final_balances.gram_bar96,
        final_balances.baht_bar96,
        final_balances.gram_bar99,
        final_balances.baht_bar99,
        bill.customer_id
      ]
    );
    
    res.json(bill);
  } catch (error) {
    console.error('Error finalizing bill:', error);
    res.status(500).json({ error: error.message });
  }
});

// ============================================================================
// GROUP ROUTES
// ============================================================================

// POST /api/bills/:id/groups - Add group (tray/pack/transaction)
router.post('/:id/groups', async (req, res) => {
  const { pool } = req.app.locals;
  const billId = parseInt(req.params.id);
  const { group_type, data } = req.body;
  
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    // Get next display_order
    const orderResult = await client.query(
      'SELECT COALESCE(MAX(display_order), 0) + 1 as next_order FROM bill_groups WHERE bill_id = $1',
      [billId]
    );
    const displayOrder = orderResult.rows[0].next_order;
    
    // Create bill_group
    const groupResult = await client.query(
      `INSERT INTO bill_groups (bill_id, group_type, display_order)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [billId, group_type, displayOrder]
    );
    const group = groupResult.rows[0];
    
    // Create specific group data and items based on type
    let groupData;
    if (group_type === 'tray') {
      const trayResult = await client.query(
        `INSERT INTO trays (
          group_id, internal_num, is_return, purity, shape,
          discount, actual_weight_grams, price_rate, additional_charge_rate
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
        RETURNING *`,
        [
          group.id,
          data.internal_num,
          data.is_return || false,
          data.purity,
          data.shape,
          data.discount || 0,
          data.actual_weight_grams,
          data.price_rate,
          data.additional_charge_rate
        ]
      );
      groupData = { type: 'tray', tray: trayResult.rows[0], items: [] };
    }
    // Add pack and transaction handling here...
    
    await client.query('COMMIT');
    
    res.json({
      ...group,
      data: groupData
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error adding group:', error);
    res.status(500).json({ error: error.message });
  } finally {
    client.release();
  }
});

// More routes for items, reordering, etc...

module.exports = router;
