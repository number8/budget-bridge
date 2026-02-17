#!/usr/bin/env bash
set -e

# BudgetBridge Setup Script
# Initializes development environment for local development
#
# ⚠️ BACKWARD COMPATIBILITY REQUIREMENT ⚠️
# This script MUST be idempotent and backward compatible. Developers should be able to
# run this script multiple times without errors or conflicts with existing setups.
#
# When adding new requirements or setup steps:
# 1. ALWAYS check if the resource/file/configuration already exists before creating
# 2. Skip creation if already present (with informational message)
# 3. NEVER overwrite existing configurations without explicit user confirmation
# 4. Use append operations for config files when possible (check for duplicates)
# 5. Version-check dependencies and warn if version is lower than required (don't fail)
# 6. Add clear "already exists (skipping)" messages for clarity
#
# This ensures the script can be re-run as the project evolves without breaking
# existing development environments or requiring manual cleanup.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🚀 BudgetBridge Setup"
echo "===================="
echo ""

# Check prerequisites
check_prerequisite() {
    local cmd=$1
    local name=$2
    local install_url=$3
    
    if ! command -v "$cmd" &> /dev/null; then
        echo "❌ $name not found"
        echo "   Install from: $install_url"
        return 1
    else
        local version=$("$cmd" --version 2>&1 | head -n 1)
        echo "✅ $name: $version"
        return 0
    fi
}

echo "Checking prerequisites..."
echo ""

PREREQ_FAILED=0 (backward compatible: preserves existing)

check_prerequisite "dotnet" ".NET SDK" "https://dotnet.microsoft.com/download" || PREREQ_FAILED=1
check_prerequisite "docker" "Docker" "https://docker.com/get-started" || PREREQ_FAILED=1
check_prerequisite "pnpm" "pnpm" "https://pnpm.io/installation" || PREREQ_FAILED=1

if [ $PREREQ_FAILED -eq 1 ]; then
    echo ""
    echo "❌ Missing prerequisites. Please install the required tools and try again."
    exit 1
fi

echo ""
echo "📝 Setting up environment files..."

# Create .env file if it doesn't exist
if [ ! -f "$PROJECT_ROOT/.env" ]; then
    cp "$PROJECT_ROOT/.env.example" "$PROJECT_ROOT/.env"
    echo "✅ Created .env from .env.example"
    echo "   ⚠️  Please update DB_PASSWORD in .env before starting services"
else
    echo "ℹ️  .env already exists (skipping)"
fi

# Create backend .env if it doesn't exist (backward compatible: preserves existing)
if [ ! -f "$PROJECT_ROOT/backend/.env" ]; then
    cp "$PROJECT_ROOT/backend/.env.example" "$PROJECT_ROOT/backend/.env"
    echo "✅ Created backend/.env from backend/.env.example"
else
    echo "ℹ️  backend/.env already exists (skipping)"
fi

echo ""
echo "🔐 Initializing .NET user secrets..."

# Initialize user secrets for API project
cd "$PROJECT_ROOT/backend/src/BudgetBridge.Api"

# Check if user secrets are already initialized (backward compatible: preserves existing)
if ! dotnet user-secrets list &> /dev/null; then
    dotnet user-secrets init
    echo "✅ Initialized user secrets"
else
    echo "ℹ️  User secrets already initialized"
fi

# Set default connection string if not set (backward compatible: only sets if missing)
if ! dotnet user-secrets list 2>&1 | grep -q "ConnectionStrings__DefaultConnection"; then
    DB_PASSWORD="${DB_PASSWORD:-dev_password}"
    dotnet user-secrets set "ConnectionStrings__DefaultConnection" \
        "Host=localhost;Port=5432;Database=budgetbridge;Username=budgetbridge;Password=$DB_PASSWORD"
    echo "✅ Set default connection string in user secrets"
    echo "   ℹ️  Using password: $DB_PASSWORD"
else
    echo "ℹ️  Connection string already set in user secrets"
fi

echo ""
echo "📦 Installing frontend dependencies..."
cd "$PROJECT_ROOT/frontend"

if [ -f "package.json" ]; then
    pnpm install
    echo "✅ Frontend dependencies installed"
else
    echo "⚠️  No package.json found in frontend directory"
fi

echo ""
echo "🏗️  Building backend solution..."
cd "$PROJECT_ROOT/backend"
dotnet build
echo "✅ Backend solution built successfully"

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Update passwords in .env and user secrets if needed"
echo "  2. Run './scripts/start.sh' to start development environment"
echo "  3. Access backend at http://localhost:8080/health"
echo "  4. Access frontend at http://localhost:5173"
echo ""
