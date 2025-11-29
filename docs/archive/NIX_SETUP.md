# Nix Development Environment Setup

This guide shows how to set up the complete development environment using Nix Flakes.

## Prerequisites

- **Nix** with flakes enabled
- **Git**

### Installing Nix (if not already installed)

```bash
# Install Nix (multi-user installation)
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes (add to ~/.config/nix/nix.conf or /etc/nix/nix.conf)
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd purescript
```

### 2. Enter Development Environment

```bash
nix develop
```

This will:
- ✅ Install Node.js 20
- ✅ Install PureScript and Spago
- ✅ Install PostgreSQL 15
- ✅ Initialize PostgreSQL database
- ✅ Install npm dependencies
- ✅ Create helper scripts

### 3. Start PostgreSQL

In the first terminal:

```bash
./start-db.sh
```

This will:
- Start PostgreSQL server
- Create `customer_db` database
- Create `customer` table
- Insert sample data (10 customers)
- Show connection info

### 4. Build and Start Web Server

In a second terminal (also run `nix develop` first):

```bash
nix develop  # Enter the environment
./dev.sh
```

This will:
- Build PureScript code
- Bundle JavaScript
- Start the web server on port 8080

### 5. Open Browser

Navigate to: [http://localhost:8080](http://localhost:8080)

### 6. Stop Services

When done, stop PostgreSQL:

```bash
./stop-db.sh
```

Press `Ctrl+C` in the web server terminal to stop it.

## Development Workflow

### Watch Mode (Auto-rebuild)

Terminal 1 - Database:
```bash
nix develop
./start-db.sh
```

Terminal 2 - Watch PureScript:
```bash
nix develop
npm run dev  # Watches for changes and rebuilds
```

Terminal 3 - Web Server:
```bash
nix develop
npm run bundle  # Bundle once
node server.js  # Start server
```

After making changes:
1. PureScript rebuilds automatically (Terminal 2)
2. Run `npm run bundle` in Terminal 3
3. Refresh browser

### Database Management

Connect to database:
```bash
psql customer_db
```

Common SQL commands:
```sql
-- View all customers
SELECT * FROM customer ORDER BY id;

-- Count customers
SELECT COUNT(*) FROM customer;

-- Add a customer
INSERT INTO customer (name) VALUES ('New Customer');

-- Delete all customers
DELETE FROM customer;

-- Reset auto-increment
ALTER SEQUENCE customer_id_seq RESTART WITH 1;
```

Exit psql: `\q`

### Useful Commands

```bash
# Build PureScript
npm run build

# Bundle JavaScript
npm run bundle

# Build and bundle
npm run build && npm run bundle

# Start web server
npm start

# Watch mode (auto-rebuild PureScript)
npm run dev

# Database status
pg_ctl -D ./.pgdata status

# View database logs
tail -f ./.pgdata/logfile
```

## Project Structure

```
purescript/
├── flake.nix              # Nix flake configuration
├── .pgdata/               # PostgreSQL data (created automatically)
├── src/                   # PureScript source code
├── dist/                  # Built JavaScript and HTML
├── server.js              # Node.js server
├── start-db.sh           # Helper: Start PostgreSQL
├── stop-db.sh            # Helper: Stop PostgreSQL
├── dev.sh                # Helper: Build and start server
└── node_modules/         # npm dependencies
```

## Configuration

### PostgreSQL Settings

Default configuration (defined in `flake.nix`):
- **Host**: localhost
- **Port**: 5432
- **Database**: customer_db
- **User**: postgres
- **Password**: postgres

To change these, edit `flake.nix` and run `nix develop` again.

### Server Settings

Edit `server.js` to change:
- Web server port (default: 8080)
- Database connection settings

## Troubleshooting

### PostgreSQL won't start

```bash
# Check if already running
pg_ctl -D ./.pgdata status

# Stop existing instance
./stop-db.sh

# Remove lock file if needed
rm -f ./.pgdata/postmaster.pid

# Start again
./start-db.sh
```

### Port 5432 already in use

Another PostgreSQL instance is running. Either:
1. Stop it: `sudo systemctl stop postgresql`
2. Or change the port in `flake.nix`

### Port 8080 already in use

Change the port in `server.js`:
```javascript
const PORT = 8080;  // Change to another port
```

### npm dependencies issues

```bash
# Clean and reinstall
rm -rf node_modules package-lock.json
npm install
```

### PureScript build errors

```bash
# Clean build cache
rm -rf output .spago

# Rebuild
npm run build
```

### Database connection errors

Check connection settings in `server.js`:
```javascript
const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'customer_db',
  user: 'postgres',
  password: 'postgres'
});
```

## Clean Up

### Remove PostgreSQL data

```bash
./stop-db.sh
rm -rf ./.pgdata
```

### Remove all generated files

```bash
./stop-db.sh
rm -rf ./.pgdata node_modules output .spago dist/app.js
rm -f start-db.sh stop-db.sh dev.sh
```

### Exit Nix environment

```bash
exit
```

## Benefits of Nix

✅ **Reproducible** - Same environment on every machine
✅ **Isolated** - Doesn't affect system packages
✅ **Complete** - All dependencies included
✅ **Fast** - Binary cache for quick setup
✅ **Clean** - Easy to remove (just delete the directory)

## Alternative: Without Nix

If you prefer not to use Nix, see [README.md](README.md) for manual setup instructions using your system's package manager.
