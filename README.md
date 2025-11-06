# Customer Management Application

A full-stack PureScript application for managing a customer list, built with Halogen and designed to work with PostgreSQL.

## Features

- **Virtual Scrolling (JIT Rendering)**: Renders only visible rows for optimal performance
  - Handles thousands of customers without lag
  - Constant rendering time regardless of dataset size
  - Smooth 60 FPS scrolling
- **Scrollable Customer List**: Displays customers with efficient scrolling
- **In-line Editing**: Click edit icon to modify customer names directly in the list
- **Delete Customers**: Remove customers with the delete icon button
- **Sortable Columns**: Click column headers to sort by ID or Name
  - Stable sorting: Apply multiple sort keys
  - Toggle direction: Click same column to reverse sort order
  - Visual indicators: Icons show current sort state (ascending/descending/neutral)
- **Icon-based UI**: All actions use intuitive SVG icons (Edit, Delete, Add, Sort)
- **Sticky Add Form**: Add new customers using the form at the bottom of the page
- **Mock Database**: Fully functional in-memory database with 100 test customers
- **PostgreSQL Ready**: Real database implementation ready to use when you have a live database

## Project Structure

```
src/
├── Database/
│   ├── Types.purs          # Database interface and Customer type
│   ├── Mock.purs           # In-memory mock database (100 test customers)
│   └── Database.purs       # PostgreSQL database implementation (commented out)
├── Component/
│   ├── CustomerList.purs   # Main Halogen component with virtual scrolling
│   ├── CustomerList.js     # FFI for scroll position tracking
│   └── Icons.purs          # SVG icon components
└── Main.purs               # Application entry point

dist/
├── index.html              # HTML entry point
└── app.js                  # Bundled JavaScript (generated)
```

## Tech Stack

- **Language**: PureScript
- **Frontend**: Halogen (functional UI framework)
- **Backend**: PostgreSQL (with mock implementation for development)
- **Build Tool**: Spago
- **Bundler**: esbuild

## Getting Started

### Prerequisites

- Node.js and npm
- PureScript and Spago (installed via npm)

### Installation

```bash
# Install dependencies
npm install

# Install PureScript packages
npx spago install
```

### Development

```bash
# Build the project
npm run build

# Bundle for production
npm run bundle

# Serve the application
npm run serve

# Or build and serve in one command
npm start
```

The application will be available at [http://localhost:8000](http://localhost:8000)

### Watch Mode

```bash
# Watch for changes and rebuild
npx spago build --watch
```

## Database Interface

The application uses a `DatabaseInterface` type that abstracts database operations:

```purescript
type DatabaseInterface m =
  { getAllCustomers :: m (Array Customer)
  , addNewCustomer :: String -> m Unit
  , updateCustomerName :: { id :: Int, name :: String } -> m Unit
  , deleteCustomer :: Int -> m Unit
  }
```

### Mock Database

The mock database (`Database.Mock`) uses an in-memory `Ref` to store customers. It comes pre-populated with **100 test customers** including:

- Alice Johnson (ID: 1)
- Bob Smith (ID: 2)
- Charlie Brown (ID: 3)
- ... (97 more customers)
- Vito Corleone (ID: 100)

This allows testing the virtual scrolling performance with a realistic dataset.

### PostgreSQL Database

The real database implementation (`Database.Database`) is currently commented out because `purescript-node-postgres` is not in the standard package set.

To enable PostgreSQL support:

1. Add `purescript-node-postgres` to your `packages.dhall`:

```dhall
let additions =
  { node-postgres =
    { dependencies =
      [ "aff", "arrays", "bifunctors", "bytestrings", "datetime"
      , "decimals", "effect", "either", "exceptions"
      , "foldable-traversable", "foreign", "foreign-generic"
      , "foreign-object", "js-date", "lists", "maybe", "newtype"
      , "nullable", "prelude", "transformers"
      ]
    , repo = "https://github.com/rightfold/purescript-node-postgres.git"
    , version = "v5.0.1"
    }
  }

in  upstream // additions
```

2. Uncomment the code in `src/Database/Database.purs`

3. Update `src/Main.purs` to use the real database:

```purescript
import Database.Database as DB
import Database.PostgreSQL (defaultPoolConfiguration, newPool, withConnection)

main :: Effect Unit
main = launchAff_ do
  pool <- newPool defaultPoolConfiguration
    { host = "localhost"
    , port = 5432
    , database = "customers_db"
    , user = "postgres"
    , password = "password"
    }
  
  withConnection pool \conn -> do
    let db = DB.createPostgresDatabase conn
    HA.runHalogenAff do
      body <- HA.awaitBody
      runUI (CustomerList.component db) unit body
```

## Database Schema

```sql
CREATE TABLE IF NOT EXISTS customer (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL
);
```

## UI Features

### Table Header
- Sortable columns for ID and Name
- Click column header to sort
- Visual indicators show sort direction:
  - ↕️ Neutral (no sort applied)
  - ↑ Ascending
  - ↓ Descending
- Clicking same column toggles direction
- Stable sorting allows multiple sort keys

### Customer List
- Scrollable container with `max-height: 80vh`
- Each row shows customer ID and name
- Hover effect for better UX
- Icon-based action buttons

### In-line Editing
1. Click edit icon (✏️) on any customer row
2. Name field becomes an editable input
3. Edit icon changes to save icon (✓)
4. Click save to update the customer name

### Delete Customer
- Click delete icon (🗑️) to remove a customer
- Immediate deletion with list refresh

### Add Customer Form
- Sticky positioned at the bottom of the page
- Input field for new customer name
- Add button with plus icon
- Form clears automatically after submission

## Styling

The application includes embedded CSS with:
- Clean, modern design
- Responsive layout
- Smooth transitions and hover effects
- Sticky form that stays visible while scrolling
- Professional color scheme

## Development Notes

- The mock database is perfect for UI development and testing
- All database operations are asynchronous (using `Effect` monad)
- The same interface works for both mock and real databases
- Easy to switch between mock and real database by changing one line in `Main.purs`

## License

MIT
