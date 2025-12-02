#!/usr/bin/env bash
set -e

echo "🚀 Setting up PureScript development environment..."

# Install PureScript toolchain
echo "📦 Installing PureScript toolchain..."
npm install -g purescript@0.15.15 spago@0.21.0 purs-tidy@0.10.0

# Install Parcel bundler (common choice for Halogen apps)
echo "📦 Installing Parcel..."
npm install -g parcel@2.12.0

# Install project dependencies if package.json exists
if [ -f "package.json" ]; then
    echo "📦 Installing Node.js dependencies..."
    npm install
fi

# Install Spago dependencies if spago.dhall exists
if [ -f "spago.dhall" ] || [ -f "spago.yaml" ]; then
    echo "📦 Installing PureScript dependencies..."
    spago install
fi

echo "✅ Development environment ready!"
echo ""
echo "Quick start commands:"
echo "  spago build          - Build PureScript code"
echo "  spago test           - Run tests"
echo "  spago repl           - Start REPL"
echo "  npm run dev          - Start dev server (if configured)"
echo "  psql \$DATABASE_URL   - Connect to PostgreSQL"
