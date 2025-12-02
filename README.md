# Customer Management Application

A production-ready full-stack customer management system with balance tracking, built with PureScript/Halogen, featuring virtual scrolling, real-time updates, and comprehensive financial tracking.

## Features

### Core Functionality
- ✅ **Customer Management** - Full CRUD operations with click-to-edit interface
- ✅ **Balance Tracking** - Money credit and three types of gold (Accessory, 96.5% Bar, 99.99% Bar)
- ✅ **Dual Unit System** - Each gold type tracks both grams and baht separately
- ✅ **Debit/Credit Display** - Clear visualization of positive and negative balances
- ✅ **Real-time Sync** - Polls server every 3 seconds for changes from other users
- ✅ **Search/Filter** - Real-time filtering by customer name
- ✅ **Advanced Sorting** - Sort by any column including debit/credit separately
- ✅ **Click-to-Edit** - Direct editing of names and all balance fields

### Balance System
- 💰 **Money Credit** - 2 decimal places, debit/credit columns
- 🥇 **Gold Accessory** - Grams and baht (15.200 g/baht conversion)
- 🥈 **96.5% Gold Bar** - Grams and baht (15.244 g/baht conversion)
- 🥉 **99.99% Gold Bar** - Grams and baht (15.244 g/baht conversion)
- ⚖️ **Net Weight Sorting** - Sorts by combined grams + baht (converted to grams)

### Performance & UX
- ⚡ **Virtual Scrolling** - Handles thousands of customers smoothly
  - Only renders visible rows (~20-30 at a time)
  - Constant 60 FPS regardless of dataset size
  - Per-customer height caching for variable-height rows
- 🎨 **Visual Feedback**
  - Recently added/edited customers highlighted with earth tone background
  - Alternating row colors (zebra striping) for easy reading
  - Warning highlight when editing opposite side (debit ↔ credit)
  - Hover effects on all editable fields
- 🎯 **Smart Editing**
  - Click any field to edit in-place
  - Cursor placed at end (no accidental data loss)
  - Auto-focus with requestAnimationFrame (no delays)
  - Input validation (2-3 decimal places, positive numbers only)
  - Warning when editing will replace opposite side value
- 📱 **Responsive Design** - Works on different screen sizes and zoom levels

### Technical Highlights
- **Callback-based Operations** - Uses `requestAnimationFrame` instead of arbitrary delays
- **Smart Caching** - Per-customer height cache that survives sorting/filtering
- **Optimistic Updates** - Immediate UI feedback, server reconciliation in background
- **Stable Sorting** - Multi-level sorting (sort by debit, then by date)
- **Type-safe Editing** - Reusable click-to-edit system with field validation
- **Internationalization Ready** - All text constants in one place for easy translation

## Quick Start

### Using Nix (Recommended)

The Nix environment manages PostgreSQL automatically using Unix domain sockets at `.pgdata/socket` to avoid port conflicts with system PostgreSQL.

```bash
# Clone and enter the repository
git clone <repository-url>
cd purescript

# Enter Nix development environment (automatically starts PostgreSQL)
nix develop

# Build and start web server
./dev.sh
```

See [NIX_SETUP.md](NIX_SETUP.md) for detailed instructions.

### Manual Installation

#### Prerequisites
- Node.js (v16+)
- PostgreSQL (v12+)

#### Installation

```bash
# Install dependencies
npm install

# Configure PostgreSQL connection in server.js if using custom socket/host

# Build the application
npm run build
npm run bundle

# Start the server
npm start
```

The application will be available at [http://localhost:8080](http://localhost:8080)

## Project Structure

```
src/
├── Component/
│   ├── CustomerList.purs      # Main component with virtual scrolling
│   ├── CustomerList.js        # FFI for DOM operations and formatting
│   └── Icons.purs             # SVG icon components
├── Database/
│   ├── Types.purs             # Customer type and database interface
│   ├── API.purs               # HTTP API client
│   └── Mock.purs              # Mock database for testing
└── Main.purs                  # Application entry point

server.js                       # Node.js server with PostgreSQL
schema.sql                      # Database schema with balance fields
dist/
├── index.html                 # HTML entry point
└── app.js                     # Bundled JavaScript (generated)
```

## Database Schema

```sql
CREATE TABLE customer (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  money_credit NUMERIC(15, 2) DEFAULT 0.00,
  gold_accessory_grams NUMERIC(10, 3) DEFAULT 0.000,
  gold_accessory_baht NUMERIC(10, 3) DEFAULT 0.000,
  gold_bar_965_grams NUMERIC(10, 3) DEFAULT 0.000,
  gold_bar_965_baht NUMERIC(10, 3) DEFAULT 0.000,
  gold_bar_9999_grams NUMERIC(10, 3) DEFAULT 0.000,
  gold_bar_9999_baht NUMERIC(10, 3) DEFAULT 0.000,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Usage Guide

### Adding a Customer
1. Type name in the input field at the bottom
2. Click the "+" button or press Enter
3. Customer is added with zero balances and highlighted

### Editing Customer Name
1. Click on the customer name
2. Modify the name in the input field
3. Press Enter or click outside to save
4. Press Escape to cancel

### Editing Balances
1. Click on any balance cell (money or gold, debit or credit)
2. Enter a positive number (system handles sign based on column)
3. Press Enter or click outside to save
4. If opposite side has value, it will pulse red (warning: will be replaced)

### Deleting a Customer
1. Click the delete icon next to the customer
2. Enter the confirmation code shown in the dialog
3. Press Enter or click Confirm

### Sorting
- Click column headers to sort
- Click again to toggle ascending/descending
- **Multi-level sorting**: Sort by one column, then another (stable sort)

### Searching
- Type in the search box at the top
- List filters in real-time

## Documentation

### Active Documentation
- **[BILL_EDITOR.md](BILL_EDITOR.md)** - Bill Editor module specification (in development)
- **[BILLING_IMPLEMENTATION_PLAN.md](BILLING_IMPLEMENTATION_PLAN.md)** - 12-week implementation roadmap
- **[VAT_BAR_MAKING_CHARGE.md](VAT_BAR_MAKING_CHARGE.md)** - VAT calculation specification
- **[SPECS_CORRECTIONS.md](SPECS_CORRECTIONS.md)** - Important corrections to specifications
- **[BILL_EDITOR_UPDATES.md](BILL_EDITOR_UPDATES.md)** - Change log for Bill Editor module

### Archived Documentation
- [docs/archive/](docs/archive/) - Historical design documents
- [docs/pos/](docs/pos/) - POS module specifications (future implementation)

## Tech Stack

- **Frontend**: PureScript + Halogen
- **Backend**: Node.js + PostgreSQL
- **Build**: Spago + esbuild
- **Database**: PostgreSQL with NUMERIC types

## License

MIT
