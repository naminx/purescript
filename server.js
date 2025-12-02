const http = require("http");
const fs = require("fs");
const path = require("path");
const { Pool } = require("pg");

// PostgreSQL connection pool (connects via Unix domain socket)
// Socket is located at .pgdata/socket to avoid port 5432 conflicts
// Note: pg library requires absolute path for Unix sockets
const pool = new Pool({
  host: process.env.DB_HOST || path.join(process.cwd(), ".pgdata/socket"),
  database: process.env.DB_NAME || "huatkimhang",
  user: process.env.DB_USER || "postgres",
  password: process.env.DB_PASSWORD || "postgres",
  connectionTimeoutMillis: 5000,
  query_timeout: 10000,
  max: 20,
});

// Test database connection on startup
pool.query("SELECT NOW()", (err, res) => {
  if (err) {
    console.error("Database connection error:", err.message);
  } else {
    console.log("Database connected successfully at", res.rows[0].now);
  }
});

// Note: Numeric fields are kept as strings to preserve precision
// PostgreSQL NUMERIC -> pg driver (string) -> JSON (string) -> PureScript Decimal
// This prevents floating-point rounding errors

// MIME types
const mimeTypes = {
  ".html": "text/html",
  ".js": "text/javascript",
  ".css": "text/css",
  ".json": "application/json",
  ".png": "image/png",
  ".jpg": "image/jpg",
  ".gif": "image/gif",
  ".svg": "image/svg+xml",
  ".ico": "image/x-icon",
};

const server = http.createServer(async (req, res) => {
  console.log(`${req.method} ${req.url}`);

  // CORS headers
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader(
    "Access-Control-Allow-Methods",
    "GET, POST, PUT, DELETE, OPTIONS",
  );
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    res.writeHead(200);
    res.end();
    return;
  }

  // API endpoints
  if (req.url.startsWith("/api/")) {
    try {
      if (req.url === "/api/customers" && req.method === "GET") {
        console.log("Fetching customers from database...");
        const result = await pool.query(`
          SELECT 
            id, name, 
            money, 
            gram_jewelry, baht_jewelry,
            gram_bar96, baht_bar96,
            gram_bar99, baht_bar99,
            created_at, updated_at,
            NULL as row_height 
          FROM customer 
          ORDER BY id
        `);
        console.log(`Retrieved ${result.rows.length} customers`);
        // Keep numeric fields as strings (no conversion)
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify(result.rows));
        return;
      }

      // Get changes since a timestamp
      if (
        req.url.startsWith("/api/customers/changes?since=") &&
        req.method === "GET"
      ) {
        const urlParams = new URL(req.url, `http://${req.headers.host}`);
        const since = urlParams.searchParams.get("since");
        console.log(`Fetching changes since ${since}...`);

        const result = await pool.query(
          `
          SELECT 
            id, name, 
            money, 
            gram_jewelry, baht_jewelry,
            gram_bar96, baht_bar96,
            gram_bar99, baht_bar99,
            created_at, updated_at,
            NULL as row_height 
          FROM customer 
          WHERE updated_at > $1 
          ORDER BY updated_at
        `,
          [since],
        );

        console.log(`Found ${result.rows.length} changes`);
        // Keep numeric fields as strings (no conversion)
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify(result.rows));
        return;
      }

      // Get single customer
      if (req.url.match(/^\/api\/customers\/\d+$/) && req.method === "GET") {
        const id = req.url.split("/")[3];
        const result = await pool.query(
          `
          SELECT 
            id, name, 
            money, 
            gram_jewelry, baht_jewelry,
            gram_bar96, baht_bar96,
            gram_bar99, baht_bar99,
            created_at, updated_at,
            NULL as row_height 
          FROM customer 
          WHERE id = $1
        `,
          [id],
        );
        if (result.rows.length === 0) {
          res.writeHead(404, { "Content-Type": "application/json" });
          res.end(JSON.stringify({ error: "Customer not found" }));
        } else {
          // Keep numeric fields as strings (no conversion)
          res.writeHead(200, { "Content-Type": "application/json" });
          res.end(JSON.stringify(result.rows[0]));
        }
        return;
      }

      if (req.url === "/api/customers" && req.method === "POST") {
        let body = "";
        req.on("data", (chunk) => (body += chunk));
        req.on("end", async () => {
          const { name } = JSON.parse(body);
          const result = await pool.query(
            `
            INSERT INTO customer (name) 
            VALUES ($1) 
            RETURNING 
              id, name, 
              money, 
              gram_jewelry, baht_jewelry,
              gram_bar96, baht_bar96,
              gram_bar99, baht_bar99,
              created_at, updated_at,
              NULL as row_height
          `,
            [name],
          );
          // Keep numeric fields as strings (no conversion)
          res.writeHead(201, { "Content-Type": "application/json" });
          res.end(JSON.stringify(result.rows[0]));
        });
        return;
      }

      if (req.url.match(/^\/api\/customers\/\d+$/) && req.method === "PUT") {
        const id = req.url.split("/")[3];
        let body = "";
        req.on("data", (chunk) => (body += chunk));
        req.on("end", async () => {
          const { field, value } = JSON.parse(body);

          // Validate field name to prevent SQL injection
          const allowedFields = [
            "name",
            "money",
            "gram_jewelry",
            "baht_jewelry",
            "gram_bar96",
            "baht_bar96",
            "gram_bar99",
            "baht_bar99",
          ];

          if (!allowedFields.includes(field)) {
            res.writeHead(400, { "Content-Type": "application/json" });
            res.end(JSON.stringify({ error: "Invalid field name" }));
            return;
          }

          const result = await pool.query(
            `
            UPDATE customer 
            SET ${field} = $1 
            WHERE id = $2 
            RETURNING 
              id, name, 
              money, 
              gram_jewelry, baht_jewelry,
              gram_bar96, baht_bar96,
              gram_bar99, baht_bar99,
              created_at, updated_at,
              NULL as row_height
          `,
            [value, id],
          );

          if (result.rows.length === 0) {
            res.writeHead(404, { "Content-Type": "application/json" });
            res.end(JSON.stringify({ error: "Customer not found" }));
          } else {
            // Keep numeric fields as strings (no conversion)
            res.writeHead(200, { "Content-Type": "application/json" });
            res.end(JSON.stringify(result.rows[0]));
          }
        });
        return;
      }

      if (req.url.match(/^\/api\/customers\/\d+$/) && req.method === "DELETE") {
        const id = req.url.split("/")[3];
        await pool.query("DELETE FROM customer WHERE id = $1", [id]);
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ success: true }));
        return;
      }

      // ========================================================================
      // BILL API ROUTES
      // ========================================================================

      // GET /api/bills/:id - Get bill with all groups and items
      if (req.url.match(/^\/api\/bills\/\d+$/) && req.method === "GET") {
        const billId = parseInt(req.url.split("/")[3]);

        // Get bill
        const billResult = await pool.query(
          "SELECT * FROM bills WHERE id = $1",
          [billId],
        );
        if (billResult.rows.length === 0) {
          res.writeHead(404, { "Content-Type": "application/json" });
          res.end(JSON.stringify({ error: "Bill not found" }));
          return;
        }

        const bill = billResult.rows[0];

        // Get all groups
        const groupsResult = await pool.query(
          "SELECT * FROM bill_groups WHERE bill_id = $1 ORDER BY display_order",
          [billId],
        );

        // For each group, get its data
        const groups = await Promise.all(
          groupsResult.rows.map(async (group) => {
            let groupData = {};

            if (group.group_type === "tray") {
              const trayResult = await pool.query(
                "SELECT * FROM trays WHERE group_id = $1",
                [group.id],
              );
              const tray = trayResult.rows[0];
              const itemsResult = await pool.query(
                "SELECT * FROM tray_items WHERE tray_id = $1 ORDER BY display_order",
                [tray.id],
              );
              groupData = { type: "tray", tray, items: itemsResult.rows };
            } else if (group.group_type === "pack") {
              const packResult = await pool.query(
                "SELECT * FROM packs WHERE group_id = $1",
                [group.id],
              );
              const pack = packResult.rows[0];
              const itemsResult = await pool.query(
                "SELECT * FROM pack_items WHERE pack_id = $1 ORDER BY display_order",
                [pack.id],
              );
              groupData = { type: "pack", pack, items: itemsResult.rows };
            } else if (group.group_type === "transaction") {
              const txResult = await pool.query(
                "SELECT * FROM transactions WHERE group_id = $1",
                [group.id],
              );
              const transaction = txResult.rows[0];
              const itemsResult = await pool.query(
                "SELECT * FROM transaction_items WHERE transaction_id = $1 ORDER BY display_order",
                [transaction.id],
              );
              groupData = {
                type: "transaction",
                transaction,
                items: itemsResult.rows,
              };
            }

            return { ...group, data: groupData };
          }),
        );

        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ bill, groups }));
        return;
      }

      // POST /api/bills - Create new bill
      if (req.url === "/api/bills" && req.method === "POST") {
        let body = "";
        req.on("data", (chunk) => {
          body += chunk.toString();
        });
        req.on("end", async () => {
          try {
            const { customer_id } = JSON.parse(body);

            // Get customer balances
            const customerResult = await pool.query(
              "SELECT * FROM customer WHERE id = $1",
              [customer_id],
            );
            if (customerResult.rows.length === 0) {
              res.writeHead(404, { "Content-Type": "application/json" });
              res.end(JSON.stringify({ error: "Customer not found" }));
              return;
            }

            const customer = customerResult.rows[0];

            // Create bill
            const billResult = await pool.query(
              `INSERT INTO bills (
                customer_id, prev_balance_money, prev_gram_jewel, prev_baht_jewel,
                prev_gram_bar96, prev_baht_bar96, prev_gram_bar99, prev_baht_bar99
              ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
              [
                customer_id,
                customer.money || 0,
                customer.gram_jewelry || 0,
                customer.baht_jewelry || 0,
                customer.gram_bar96 || 0,
                customer.baht_bar96 || 0,
                customer.gram_bar99 || 0,
                customer.baht_bar99 || 0,
              ],
            );

            res.writeHead(200, { "Content-Type": "application/json" });
            res.end(JSON.stringify(billResult.rows[0]));
          } catch (err) {
            res.writeHead(500, { "Content-Type": "application/json" });
            res.end(JSON.stringify({ error: err.message }));
          }
        });
        return;
      }

      // PUT /api/bills/:id - Update bill
      if (req.url.match(/^\/api\/bills\/\d+$/) && req.method === "PUT") {
        const billId = parseInt(req.url.split("/")[3]);
        let body = "";
        req.on("data", (chunk) => {
          body += chunk.toString();
        });
        req.on("end", async () => {
          try {
            const {
              is_vat_deferred,
              vat_rate,
              market_buying_price_jewel,
              version,
            } = JSON.parse(body);

            const result = await pool.query(
              `UPDATE bills 
               SET is_vat_deferred = $1, vat_rate = $2, market_buying_price_jewel = $3,
                   version = version + 1, updated_at = NOW()
               WHERE id = $4 AND version = $5
               RETURNING *`,
              [
                is_vat_deferred,
                vat_rate,
                market_buying_price_jewel,
                billId,
                version,
              ],
            );

            if (result.rows.length === 0) {
              res.writeHead(409, { "Content-Type": "application/json" });
              res.end(
                JSON.stringify({
                  error: "Conflict: Bill was modified by another user",
                }),
              );
              return;
            }

            res.writeHead(200, { "Content-Type": "application/json" });
            res.end(JSON.stringify(result.rows[0]));
          } catch (err) {
            res.writeHead(500, { "Content-Type": "application/json" });
            res.end(JSON.stringify({ error: err.message }));
          }
        });
        return;
      }

      // DELETE /api/bills/:id - Delete bill
      if (req.url.match(/^\/api\/bills\/\d+$/) && req.method === "DELETE") {
        try {
          const billId = parseInt(req.url.split("/")[3]);
          await pool.query("DELETE FROM bills WHERE id = $1", [billId]);
          res.writeHead(200, { "Content-Type": "application/json" });
          res.end(JSON.stringify({ success: true }));
        } catch (err) {
          res.writeHead(500, { "Content-Type": "application/json" });
          res.end(JSON.stringify({ error: err.message }));
        }
        return;
      }

      // POST /api/tray-items - Add tray item
      if (req.url === "/api/tray-items" && req.method === "POST") {
        let body = "";
        req.on("data", (chunk) => {
          body += chunk.toString();
        });
        req.on("end", async () => {
          try {
            const item = JSON.parse(body);
            const makingCharge = parseInt(item.making_charge || "0");
            const quantity = parseInt(item.quantity || "1");
            const amount = makingCharge * quantity;

            const result = await pool.query(
              `INSERT INTO tray_items (
                tray_id, making_charge, jewelry_type_id, design_name, 
                nominal_weight, nominal_weight_id, quantity, amount, display_order
              ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8,
                COALESCE((SELECT MAX(display_order) + 1 FROM tray_items WHERE tray_id = $1), 0)
              ) RETURNING *`,
              [
                item.tray_id,
                makingCharge,
                item.jewelry_type_id,
                item.design_name,
                item.nominal_weight || "0",
                item.nominal_weight_id || null,
                quantity,
                amount,
              ],
            );
            res.writeHead(201, { "Content-Type": "application/json" });
            res.end(JSON.stringify(result.rows[0]));
          } catch (err) {
            console.error("Error adding tray item:", err);
            res.writeHead(500, { "Content-Type": "application/json" });
            res.end(JSON.stringify({ error: err.message }));
          }
        });
        return;
      }

      // PUT /api/tray-items/:id - Update tray item
      if (req.url.match(/^\/api\/tray-items\/\d+$/) && req.method === "PUT") {
        const itemId = parseInt(req.url.split("/")[3]);
        let body = "";
        req.on("data", (chunk) => {
          body += chunk.toString();
        });
        req.on("end", async () => {
          try {
            const item = JSON.parse(body);
            const makingCharge = parseInt(item.making_charge || "0");
            const quantity = parseInt(item.quantity || "1");
            const amount = makingCharge * quantity;

            const result = await pool.query(
              `UPDATE tray_items 
               SET making_charge = $1, jewelry_type_id = $2, design_name = $3,
                   nominal_weight = $4, nominal_weight_id = $5, quantity = $6, amount = $7
               WHERE id = $8
               RETURNING *`,
              [
                makingCharge,
                item.jewelry_type_id,
                item.design_name,
                item.nominal_weight || "0",
                item.nominal_weight_id || null,
                quantity,
                amount,
                itemId,
              ],
            );

            if (result.rows.length === 0) {
              res.writeHead(404, { "Content-Type": "application/json" });
              res.end(JSON.stringify({ error: "Item not found" }));
              return;
            }

            res.writeHead(200, { "Content-Type": "application/json" });
            res.end(JSON.stringify(result.rows[0]));
          } catch (err) {
            console.error("Error updating tray item:", err);
            res.writeHead(500, { "Content-Type": "application/json" });
            res.end(JSON.stringify({ error: err.message }));
          }
        });
        return;
      }

      // DELETE /api/tray-items/:id - Delete tray item
      if (
        req.url.match(/^\/api\/tray-items\/\d+$/) &&
        req.method === "DELETE"
      ) {
        try {
          const itemId = parseInt(req.url.split("/")[3]);
          await pool.query("DELETE FROM tray_items WHERE id = $1", [itemId]);
          res.writeHead(200, { "Content-Type": "application/json" });
          res.end(JSON.stringify({ success: true }));
        } catch (err) {
          res.writeHead(500, { "Content-Type": "application/json" });
          res.end(JSON.stringify({ error: err.message }));
        }
        return;
      }

      // PUT /api/trays/:id - Update tray
      if (req.url.match(/^\/api\/trays\/\d+$/) && req.method === "PUT") {
        const trayId = parseInt(req.url.split("/")[3]);
        let body = "";
        req.on("data", (chunk) => {
          body += chunk.toString();
        });
        req.on("end", async () => {
          try {
            const updates = JSON.parse(body);

            // Build dynamic update query based on provided fields
            const updateFields = [];
            const values = [];
            let paramCounter = 1;

            if (updates.price_rate !== undefined) {
              updateFields.push(`price_rate = $${paramCounter}`);
              values.push(updates.price_rate);
              paramCounter++;
            }
            if (updates.purity !== undefined) {
              updateFields.push(`purity = $${paramCounter}`);
              values.push(updates.purity);
              paramCounter++;
            }
            if (updates.discount !== undefined) {
              updateFields.push(`discount = $${paramCounter}`);
              values.push(updates.discount);
              paramCounter++;
            }
            if (updates.actual_weight_grams !== undefined) {
              updateFields.push(`actual_weight_grams = $${paramCounter}`);
              values.push(updates.actual_weight_grams);
              paramCounter++;
            }
            if (updates.additional_charge_rate !== undefined) {
              updateFields.push(`additional_charge_rate = $${paramCounter}`);
              values.push(updates.additional_charge_rate);
              paramCounter++;
            }

            if (updateFields.length === 0) {
              res.writeHead(400, { "Content-Type": "application/json" });
              res.end(JSON.stringify({ error: "No valid fields to update" }));
              return;
            }

            // Add trayId as the last parameter
            values.push(trayId);

            const query = `UPDATE trays 
                           SET ${updateFields.join(", ")}
                           WHERE id = $${paramCounter}
                           RETURNING *`;

            const result = await pool.query(query, values);

            if (result.rows.length === 0) {
              res.writeHead(404, { "Content-Type": "application/json" });
              res.end(JSON.stringify({ error: "Tray not found" }));
              return;
            }

            res.writeHead(200, { "Content-Type": "application/json" });
            res.end(JSON.stringify(result.rows[0]));
          } catch (err) {
            console.error("Error updating tray:", err);
            res.writeHead(500, { "Content-Type": "application/json" });
            res.end(JSON.stringify({ error: err.message }));
          }
        });
        return;
      }

      // GET /api/jewelry-types - Get all jewelry types
      if (req.url === "/api/jewelry-types" && req.method === "GET") {
        try {
          const result = await pool.query(
            "SELECT id, name FROM jewelry_types ORDER BY id",
          );
          res.writeHead(200, { "Content-Type": "application/json" });
          res.end(JSON.stringify(result.rows));
        } catch (err) {
          res.writeHead(500, { "Content-Type": "application/json" });
          res.end(JSON.stringify({ error: err.message }));
        }
        return;
      }

      // GET /api/nominal-weights - Get all nominal weights
      if (req.url === "/api/nominal-weights" && req.method === "GET") {
        try {
          const result = await pool.query(
            "SELECT id, label, weight_grams FROM nominal_weights ORDER BY id",
          );
          res.writeHead(200, { "Content-Type": "application/json" });
          res.end(JSON.stringify(result.rows));
        } catch (err) {
          res.writeHead(500, { "Content-Type": "application/json" });
          res.end(JSON.stringify({ error: err.message }));
        }
        return;
      }

      // GET /api/predefined-purities - Get all predefined purities
      if (req.url === "/api/predefined-purities" && req.method === "GET") {
        try {
          const result = await pool.query(
            "SELECT id, metal_type, display_val, purity FROM predefined_purities ORDER BY id",
          );
          res.writeHead(200, { "Content-Type": "application/json" });
          res.end(JSON.stringify(result.rows));
        } catch (err) {
          res.writeHead(500, { "Content-Type": "application/json" });
          res.end(JSON.stringify({ error: err.message }));
        }
        return;
      }

      // GET /api/bills/customer/:customerId - Get bills by customer
      if (
        req.url.match(/^\/api\/bills\/customer\/\d+$/) &&
        req.method === "GET"
      ) {
        try {
          const customerId = parseInt(req.url.split("/")[4]);
          const result = await pool.query(
            "SELECT * FROM bills WHERE customer_id = $1 ORDER BY date DESC",
            [customerId],
          );
          res.writeHead(200, { "Content-Type": "application/json" });
          res.end(JSON.stringify(result.rows));
        } catch (err) {
          res.writeHead(500, { "Content-Type": "application/json" });
          res.end(JSON.stringify({ error: err.message }));
        }
        return;
      }

      res.writeHead(404, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ error: "Not found" }));
    } catch (error) {
      console.error("Database error:", error);
      res.writeHead(500, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ error: error.message }));
    }
    return;
  }

  // Static file serving
  // Serve from project root for /output, from dist for everything else
  let filePath;
  if (req.url === "/") {
    filePath = "./dist/index.html";
  } else if (req.url.startsWith("/output/")) {
    filePath = "." + req.url;
  } else {
    filePath = "./dist" + req.url;
  }

  const extname = String(path.extname(filePath)).toLowerCase();
  const contentType = mimeTypes[extname] || "application/octet-stream";

  fs.readFile(filePath, (error, content) => {
    if (error) {
      if (error.code === "ENOENT") {
        res.writeHead(404, { "Content-Type": "text/html" });
        res.end("<h1>404 Not Found</h1>", "utf-8");
      } else {
        res.writeHead(500);
        res.end("Server Error: " + error.code, "utf-8");
      }
    } else {
      res.writeHead(200, { "Content-Type": contentType });
      res.end(content, "utf-8");
    }
  });
});

const PORT = process.env.PORT || 8088;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Database: huatkimhang via Unix socket at .pgdata/socket`);
});
