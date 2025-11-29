{
  description = "Customer Management Application - PureScript + Halogen + PostgreSQL";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # PostgreSQL configuration
        pgDataDir = "./.pgdata";
        pgPort = "5432";
        pgDatabase = "customer_db";
        pgUser = "postgres";
        pgPassword = "postgres";
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Node.js and npm
            nodejs

            # PureScript toolchain
            purescript
            spago
            esbuild

            # PostgreSQL
            postgresql

            # Utilities
            which
            gnused
          ];

          shellHook = ''
                        echo "🚀 Customer Management Development Environment"
                        echo "=============================================="
                        echo ""

                        # Setup PostgreSQL data directory
                        export PGDATA="${pgDataDir}"
                        export PGHOST="localhost"
                        export PGPORT="${pgPort}"
                        export PGDATABASE="${pgDatabase}"
                        export PGUSER="${pgUser}"
                        export PGPASSWORD="${pgPassword}"

                        # Initialize PostgreSQL if not already done
                        if [ ! -d "$PGDATA" ]; then
                          echo "📦 Initializing PostgreSQL database..."
                          initdb -U ${pgUser} --pwfile=<(echo "${pgPassword}") --auth=trust
                          echo "✅ PostgreSQL initialized"
                          echo ""
                        fi

                        # Install npm dependencies if needed
                        if [ ! -d "node_modules" ]; then
                          echo "📦 Installing npm dependencies..."
                          npm install
                          echo "✅ Dependencies installed"
                          echo ""
                        fi

                        # Create helper scripts
                        cat > start-db.sh << 'EOF'
            #!/usr/bin/env bash
            echo "🗄️  Starting PostgreSQL..."
            pg_ctl -D ${pgDataDir} -l ${pgDataDir}/logfile start
            sleep 2

            # Create database if it doesn't exist
            if ! psql -lqt | cut -d \| -f 1 | grep -qw ${pgDatabase}; then
              echo "📊 Creating database '${pgDatabase}'..."
              createdb ${pgDatabase}

              echo "📋 Creating schema..."
              psql ${pgDatabase} << 'SQL'
            CREATE TABLE IF NOT EXISTS customer (
              id SERIAL PRIMARY KEY,
              name VARCHAR(255) NOT NULL,
              updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );

            -- Insert sample data
            INSERT INTO customer (name) VALUES
              ('Alice Johnson'),
              ('Bob Smith'),
              ('Charlie Brown'),
              ('Diana Prince'),
              ('Eve Anderson'),
              ('Frank Miller'),
              ('Grace Lee'),
              ('Henry Wilson'),
              ('Iris Chen'),
              ('Jack Robinson')
            ON CONFLICT DO NOTHING;
            SQL
              echo "✅ Database ready!"
            else
              echo "✅ Database already exists"
            fi

            echo ""
            echo "📊 Database Status:"
            psql ${pgDatabase} -c "SELECT COUNT(*) as customer_count FROM customer;"
            echo ""
            echo "🔗 Connection: postgresql://${pgUser}:${pgPassword}@localhost:${pgPort}/${pgDatabase}"
            EOF
                        chmod +x start-db.sh

                        cat > stop-db.sh << 'EOF'
            #!/usr/bin/env bash
            echo "🛑 Stopping PostgreSQL..."
            pg_ctl -D ${pgDataDir} stop
            echo "✅ PostgreSQL stopped"
            EOF
                        chmod +x stop-db.sh

                        cat > start-server.sh << 'EOF'
            #!/usr/bin/env bash
            echo "🌐 Starting web server..."
            node server.js
            EOF
                        chmod +x start-server.sh

                        cat > dev.sh << 'EOF'
            #!/usr/bin/env bash
            echo "🔨 Building PureScript..."
            npm run build && npm run bundle
            echo "✅ Build complete!"
            echo ""
            echo "🌐 Starting web server..."
            node server.js
            EOF
                        chmod +x dev.sh

                        echo "📝 Quick Start Guide:"
                        echo "===================="
                        echo ""
                        echo "1. Start PostgreSQL:"
                        echo "   ./start-db.sh"
                        echo ""
                        echo "2. Build and start web server (in another terminal):"
                        echo "   ./dev.sh"
                        echo ""
                        echo "3. Open browser:"
                        echo "   http://localhost:8080"
                        echo ""
                        echo "4. Stop PostgreSQL when done:"
                        echo "   ./stop-db.sh"
                        echo ""
                        echo "📚 Other commands:"
                        echo "   npm run build        - Build PureScript"
                        echo "   npm run bundle       - Bundle JavaScript"
                        echo "   npm run dev          - Watch mode (rebuild on changes)"
                        echo "   psql ${pgDatabase}   - Connect to database"
                        echo ""
                        echo "✨ Ready to develop!"
          '';
        };
      }
    );
}
