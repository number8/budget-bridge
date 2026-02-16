#!/usr/bin/env bash
set -e

# BudgetBridge Stop Script
# Gracefully stops all running services

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🛑 Stopping BudgetBridge services..."
echo ""

# Stop Docker Compose services
if docker compose -f "$PROJECT_ROOT/docker-compose.yml" ps -q 2>/dev/null | grep -q .; then
    echo "Stopping Docker Compose services..."
    cd "$PROJECT_ROOT"
    docker compose down
    echo "✅ Docker services stopped"
else
    echo "ℹ️  No Docker Compose services running"
fi

# Stop local backend process
if [ -f "$PROJECT_ROOT/.backend.pid" ]; then
    BACKEND_PID=$(cat "$PROJECT_ROOT/.backend.pid")
    if ps -p $BACKEND_PID > /dev/null 2>&1; then
        echo "Stopping backend process (PID: $BACKEND_PID)..."
        kill $BACKEND_PID 2>/dev/null || true
        sleep 2
        # Force kill if still running
        if ps -p $BACKEND_PID > /dev/null 2>&1; then
            kill -9 $BACKEND_PID 2>/dev/null || true
        fi
        echo "✅ Backend stopped"
    fi
    rm "$PROJECT_ROOT/.backend.pid"
fi

# Stop local frontend process
if [ -f "$PROJECT_ROOT/.frontend.pid" ]; then
    FRONTEND_PID=$(cat "$PROJECT_ROOT/.frontend.pid")
    if ps -p $FRONTEND_PID > /dev/null 2>&1; then
        echo "Stopping frontend process (PID: $FRONTEND_PID)..."
        kill $FRONTEND_PID 2>/dev/null || true
        sleep 2
        # Force kill if still running
        if ps -p $FRONTEND_PID > /dev/null 2>&1; then
            kill -9 $FRONTEND_PID 2>/dev/null || true
        fi
        echo "✅ Frontend stopped"
    fi
    rm "$PROJECT_ROOT/.frontend.pid"
fi

# Stop standalone PostgreSQL container
if docker ps --format '{{.Names}}' | grep -q 'budgetbridge-db'; then
    echo "Stopping standalone PostgreSQL container..."
    docker stop budgetbridge-db 2>/dev/null || true
    docker rm budgetbridge-db 2>/dev/null || true
    echo "✅ PostgreSQL container stopped"
fi

# Check for any remaining processes on our ports
check_and_warn() {
    local port=$1
    local service=$2
    
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        local pid=$(lsof -Pi :$port -sTCP:LISTEN -t)
        echo "⚠️  Port $port still in use by process $pid ($service)"
        echo "   Run: kill $pid"
    fi
}

echo ""
echo "Checking for orphaned processes..."
check_and_warn 5432 "PostgreSQL"
check_and_warn 8080 "Backend"
check_and_warn 5173 "Frontend"

echo ""
echo "✅ All services stopped!"
echo ""
