#!/usr/bin/env bash
set -e

# BudgetBridge Database Initialization Script
# Creates database and applies EF Core migrations

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🗄️  BudgetBridge Database Initialization"
echo "======================================="
echo ""

# Parse arguments
MODE="${1:-local}"  # local, docker, or connection string

if [ "$MODE" = "local" ]; then
    echo "Mode: Local PostgreSQL (localhost:5432)"
    
    # Check if PostgreSQL is running
    if ! docker ps --format '{{.Names}}' | grep -q 'budgetbridge-db'; then
        echo "Starting PostgreSQL container..."
        docker run -d \
            --name budgetbridge-db \
            -e POSTGRES_USER=budgetbridge \
            -e POSTGRES_PASSWORD="${DB_PASSWORD:-dev_password}" \
            -e POSTGRES_DB=budgetbridge \
            -p 5432:5432 \
            postgres:16-alpine
        
        echo "⏳ Waiting for PostgreSQL to be ready..."
        sleep 5
    else
        echo "✅ PostgreSQL container already running"
    fi
    
    CONNECTION_STRING="Host=localhost;Port=5432;Database=budgetbridge;Username=budgetbridge;Password=${DB_PASSWORD:-dev_password}"
    
elif [ "$MODE" = "docker" ]; then
    echo "Mode: Docker Compose"
    
    # Start PostgreSQL via docker-compose
    cd "$PROJECT_ROOT"
    docker compose up -d postgres
    
    echo "⏳ Waiting for PostgreSQL to be healthy..."
    docker compose exec postgres pg_isready -U budgetbridge || sleep 5
    
    CONNECTION_STRING="Host=postgres;Port=5432;Database=budgetbridge;Username=budgetbridge;Password=${POSTGRES_PASSWORD:-changeme}"
    
else
    echo "Mode: Custom connection string"
    CONNECTION_STRING="$MODE"
fi

echo ""
echo "🔄 Applying EF Core migrations..."

cd "$PROJECT_ROOT/backend/src/BudgetBridge.Infrastructure"

# Apply migrations using dotnet ef
export PATH="$PATH:/Users/mmorales/.dotnet/tools"
dotnet ef database update \
    --startup-project ../BudgetBridge.Api \
    --connection "$CONNECTION_STRING"

if [ $? -eq 0 ]; then
    echo "✅ Database migrations applied successfully"
else
    echo "❌ Migration failed"
    exit 1
fi

echo ""
echo "📊 Database initialized!"
echo ""
echo "Connection details:"
echo "  Host: $(echo "$CONNECTION_STRING" | grep -oP '(?<=Host=)[^;]+')"
echo "  Database: $(echo "$CONNECTION_STRING" | grep -oP '(?<=Database=)[^;]+')"
echo "  User: $(echo "$CONNECTION_STRING" | grep -oP '(?<=Username=)[^;]+')"
echo ""
