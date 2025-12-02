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
        pgSocketDir = "./.pgdata/socket";
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

            # PostgreSQL client tools
            postgresql

            # Python for scripts
            (python3.withPackages (ps: with ps; [ beautifulsoup4 ]))

            # Utilities
            which
            gnused
          ];

          shellHook = ''
            echo "🚀 Customer Management Development Environment"
            echo "=============================================="
            echo ""

            # PostgreSQL Connection Settings (Connecting to Local Socket)
            export PGHOST="${pgSocketDir}"
            export PGDATABASE="${pgDatabase}"
            export PGUSER="${pgUser}"
            export PGPASSWORD="${pgPassword}"

            # Install npm dependencies if needed
            if [ ! -d "node_modules" ]; then
              echo "📦 Installing npm dependencies..."
              npm install
              echo "✅ Dependencies installed"
              echo ""
            fi

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
            echo "1. Ensure PostgreSQL is managed by the main flake.nix (via 'nix develop')"
            echo "   This flake connects to the Unix socket managed by the main flake."
            echo ""
            echo "2. Build and start web server:"
            echo "   ./dev.sh"
            echo ""
            echo "3. Open browser:"
            echo "   http://localhost:8080"
            echo ""
            echo "📚 Other commands:"
            echo "   npm run build        - Build PureScript"
            echo "   npm run bundle       - Bundle JavaScript"
            echo "   npm run dev          - Watch mode (rebuild on changes)"
            echo "   psql ${pgDatabase}   - Connect to database"
            echo "   ./ona2md.py input.html > output.md - Convert HTML to Markdown"
            echo ""
            echo "✨ Ready to develop!"
          '';
        };
      }
    );
}
