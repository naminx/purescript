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
        pgDataDir = "$PWD/.pgdata";
        pgSocketDir = "$PWD/.pgdata/socket";
        pgDatabase = "huatkimhang";
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
            nodePackages.purescript-language-server
            nodePackages.purs-tidy

            # PostgreSQL server and client tools
            postgresql

            # Python for scripts
            (python3.withPackages (
              ps: with ps; [
                beautifulsoup4
                fonttools # Core font manipulation library
                brotli # Compression for WOFF2 fonts
                zopfli # Better compression
                unicodedata2 # Unicode character data
                lxml # XML processing (for some font formats)
                scipy # Scientific computing (if needed for font metrics)
              ]
            ))

            # Utilities
            which
            gnused
          ];

          shellHook = ''
                        echo "🚀 Customer Management Development Environment"
                        echo "=============================================="
                        echo ""
                        echo "DEBUG: Starting shellHook"

                        # PostgreSQL directories
                        export PGDATA="$PWD/.pgdata"
                        export PGHOST="$PWD/.pgdata/socket"
                        export PGDATABASE="${pgDatabase}"
                        export PGUSER="${pgUser}"
                        export PGPASSWORD="${pgPassword}"
                        echo "DEBUG: Environment variables set"

                        # Create data and socket directories
                        mkdir -p "$PGDATA"
                        mkdir -p "$PGHOST"
                        echo "DEBUG: Directories created"

                        # Initialize database if it doesn't exist
                        if [ ! -f "$PGDATA/PG_VERSION" ]; then
                          echo "📦 Initializing PostgreSQL database..."
                          rm -rf "$PGDATA"
                          mkdir -p "$PGDATA"
                          initdb --auth=trust --no-locale --encoding=UTF8 -D "$PGDATA" -U "${pgUser}"
                          echo "✅ Database initialized"
                          echo ""
                        fi
                        echo "DEBUG: Database initialization check done"

                        # Start PostgreSQL if not already running
                        if ! pg_ctl status > /dev/null 2>&1; then
                          echo "🔄 Starting PostgreSQL..."
                          pg_ctl start -l "$PGDATA/logfile" -o "-k $PGHOST -c listen_addresses="
                          echo "DEBUG: pg_ctl start issued"

                          # Wait for PostgreSQL to be ready
                          for i in {1..30}; do
                            if pg_isready -h "$PGHOST" > /dev/null 2>&1; then
                              break
                            fi
                            sleep 0.5
                          done
                          echo "DEBUG: PostgreSQL ready check done"

                          # Create database if it doesn't exist
                          if ! psql -h "$PGHOST" -U "${pgUser}" -lqt | cut -d \| -f 1 | grep -qw "${pgDatabase}"; then
                            echo "📊 Creating database '${pgDatabase}'..."
                            createdb -h "$PGHOST" -U "${pgUser}" "${pgDatabase}"
                            echo "✅ Database created"
                          fi

                          echo "✅ PostgreSQL started (user: ${pgUser}, password: ${pgPassword})"
                          echo ""
                        else
                          echo "✅ PostgreSQL already running"
                          echo ""
                        fi
                        echo "DEBUG: PostgreSQL setup done"

                        # Install npm dependencies if needed
                        if [ ! -d "node_modules" ]; then
                          echo "📦 Installing npm dependencies..."
                          npm install
                          echo "✅ Dependencies installed"
                          echo ""
                        fi
                        echo "DEBUG: npm install check done"

                        echo "DEBUG: Creating scripts"
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

                        cat > stop-postgres.sh << 'EOF'
            #!/usr/bin/env bash
            echo "🛑 Stopping PostgreSQL..."
            pg_ctl stop
            echo "✅ PostgreSQL stopped"
            EOF
                        chmod +x stop-postgres.sh
                        echo "DEBUG: Scripts created"

                        echo "📚 Quick Start Guide:"
                        echo "===================="
                        echo ""
                        echo "Database: PostgreSQL running locally via Unix socket"
                        echo "  Location: $PWD/.pgdata"
                        echo "  Database: ${pgDatabase}"
                        echo "  User: ${pgUser}"
                        echo "  Password: ${pgPassword}"
                        echo ""
                        echo "1. Build and start web server:"
                        echo "   ./dev.sh"
                        echo ""
                        echo "2. Open browser:"
                        echo "   http://localhost:8088"
                        echo ""
                        echo "📚 Other commands:"
                        echo "   npm run build        - Build PureScript"
                        echo "   npm run bundle       - Bundle JavaScript"
                        echo "   npm run dev          - Watch mode (rebuild on changes)"
                        echo "   psql ${pgDatabase}   - Connect to database"
                        echo "   ./stop-postgres.sh   - Stop PostgreSQL"
                        echo "   cat .pgdata/logfile  - View PostgreSQL logs"
                        echo "   ./ona2md.py input.html > output.md - Convert HTML to Markdown"
                        echo ""
                        echo "⚠️  Note: PostgreSQL data is stored in .pgdata/ (not tracked in git)"
                        echo ""
                        echo "✨ Ready to develop!"
                        echo "DEBUG: shellHook complete"
          '';
        };
      }
    );
}
