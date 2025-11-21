const http = require('http');
const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');

// PostgreSQL connection pool (connects to Docker container)
// Container is defined in docker-compose.yml with persistent volume
const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'customer_db',
  user: 'postgres',
  password: 'postgres',
  connectionTimeoutMillis: 5000,
  query_timeout: 10000,
  max: 20
});

// Test database connection on startup
pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('Database connection error:', err.message);
  } else {
    console.log('Database connected successfully at', res.rows[0].now);
  }
});

// Note: Numeric fields are kept as strings to preserve precision
// PostgreSQL NUMERIC -> pg driver (string) -> JSON (string) -> PureScript Decimal
// This prevents floating-point rounding errors

// MIME types
const mimeTypes = {
  '.html': 'text/html',
  '.js': 'text/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon'
};

const server = http.createServer(async (req, res) => {
  console.log(`${req.method} ${req.url}`);

  // CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  // API endpoints
  if (req.url.startsWith('/api/')) {
    try {
      if (req.url === '/api/customers' && req.method === 'GET') {
        console.log('Fetching customers from database...');
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
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(result.rows));
        return;
      }

      // Get changes since a timestamp
      if (req.url.startsWith('/api/customers/changes?since=') && req.method === 'GET') {
        const urlParams = new URL(req.url, `http://${req.headers.host}`);
        const since = urlParams.searchParams.get('since');
        console.log(`Fetching changes since ${since}...`);
        
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
          WHERE updated_at > $1 
          ORDER BY updated_at
        `, [since]);
        
        console.log(`Found ${result.rows.length} changes`);
        // Keep numeric fields as strings (no conversion)
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(result.rows));
        return;
      }

      // Get single customer
      if (req.url.match(/^\/api\/customers\/\d+$/) && req.method === 'GET') {
        const id = req.url.split('/')[3];
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
          WHERE id = $1
        `, [id]);
        if (result.rows.length === 0) {
          res.writeHead(404, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'Customer not found' }));
        } else {
          // Keep numeric fields as strings (no conversion)
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify(result.rows[0]));
        }
        return;
      }

      if (req.url === '/api/customers' && req.method === 'POST') {
        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', async () => {
          const { name } = JSON.parse(body);
          const result = await pool.query(`
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
          `, [name]);
          // Keep numeric fields as strings (no conversion)
          res.writeHead(201, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify(result.rows[0]));
        });
        return;
      }

      if (req.url.match(/^\/api\/customers\/\d+$/) && req.method === 'PUT') {
        const id = req.url.split('/')[3];
        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', async () => {
          const { field, value } = JSON.parse(body);
          
          // Validate field name to prevent SQL injection
          const allowedFields = [
            'name', 'money',
            'gram_jewelry', 'baht_jewelry',
            'gram_bar96', 'baht_bar96',
            'gram_bar99', 'baht_bar99'
          ];
          
          if (!allowedFields.includes(field)) {
            res.writeHead(400, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ error: 'Invalid field name' }));
            return;
          }
          
          const result = await pool.query(`
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
          `, [value, id]);
          
          if (result.rows.length === 0) {
            res.writeHead(404, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ error: 'Customer not found' }));
          } else {
            // Keep numeric fields as strings (no conversion)
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify(result.rows[0]));
          }
        });
        return;
      }

      if (req.url.match(/^\/api\/customers\/\d+$/) && req.method === 'DELETE') {
        const id = req.url.split('/')[3];
        await pool.query('DELETE FROM customer WHERE id = $1', [id]);
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: true }));
        return;
      }

      res.writeHead(404, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'Not found' }));
    } catch (error) {
      console.error('Database error:', error);
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: error.message }));
    }
    return;
  }

  // Static file serving
  let filePath = './dist' + (req.url === '/' ? '/index.html' : req.url);
  const extname = String(path.extname(filePath)).toLowerCase();
  const contentType = mimeTypes[extname] || 'application/octet-stream';

  fs.readFile(filePath, (error, content) => {
    if (error) {
      if (error.code === 'ENOENT') {
        res.writeHead(404, { 'Content-Type': 'text/html' });
        res.end('<h1>404 Not Found</h1>', 'utf-8');
      } else {
        res.writeHead(500);
        res.end('Server Error: ' + error.code, 'utf-8');
      }
    } else {
      res.writeHead(200, { 'Content-Type': contentType });
      res.end(content, 'utf-8');
    }
  });
});

const PORT = process.env.PORT || 8080;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Database: customer_db on localhost:5432`);
});
