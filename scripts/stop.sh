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
BACKEND_STOPPED=false
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
        BACKEND_STOPPED=true
    fi
    rm "$PROJECT_ROOT/.backend.pid"
fi

# Also search for any dotnet watch/run processes for BudgetBridge.Api
DOTNET_PIDS=$(pgrep -f "dotnet.*BudgetBridge\.Api" 2>/dev/null || true)
if [ -n "$DOTNET_PIDS" ]; then
    echo "Stopping additional backend processes..."
    for pid in $DOTNET_PIDS; do
        if ps -p $pid > /dev/null 2>&1; then
            echo "  Stopping PID: $pid"
            kill $pid 2>/dev/null || true
        fi
    done
    sleep 2
    # Force kill any remaining
    DOTNET_PIDS=$(pgrep -f "dotnet.*BudgetBridge\.Api" 2>/dev/null || true)
    if [ -n "$DOTNET_PIDS" ]; then
        for pid in $DOTNET_PIDS; do
            kill -9 $pid 2>/dev/null || true
        done
    fi
    BACKEND_STOPPED=true
fi

if [ "$BACKEND_STOPPED" = true ]; then
    echo "✅ Backend stopped"
fi

# Stop local frontend process
FRONTEND_STOPPED=false
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
        FRONTEND_STOPPED=true
    fi
    rm "$PROJECT_ROOT/.frontend.pid"
fi

# Also search for any pnpm dev processes in frontend directory
PNPM_PIDS=$(pgrep -f "pnpm.*dev" 2>/dev/null || true)
if [ -n "$PNPM_PIDS" ]; then
    echo "Stopping additional frontend processes..."
    for pid in $PNPM_PIDS; do
        if ps -p $pid > /dev/null 2>&1; then
            echo "  Stopping PID: $pid"
            kill $pid 2>/dev/null || true
        fi
    done
    sleep 2
    # Force kill any remaining
    PNPM_PIDS=$(pgrep -f "pnpm.*dev" 2>/dev/null || true)
    if [ -n "$PNPM_PIDS" ]; then
        for pid in $PNPM_PIDS; do
            kill -9 $pid 2>/dev/null || true
        done
    fi
    FRONTEND_STOPPED=true
fi

ORPHANED=false
if lsof -Pi :5432 -sTCP:LISTEN -t >/dev/null 2>&1; then
    local pid=$(lsof -Pi :5432 -sTCP:LISTEN -t)
    echo "⚠️  Port 5432 still in use by process $pid (PostgreSQL)"
    echo "   Run: kill $pid"
    ORPHANED=true
fi

if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1; then
    local pid=$(lsof -Pi :8080 -sTCP:LISTEN -t)
    echo "⚠️  Port 8080 still in use by process $pid (Backend)"
    echo "   Run: kill $pid"
    ORPHANED=true
fi

if lsof -Pi :5173 -sTCP:LISTEN -t >/dev/null 2>&1; then
    local pid=$(lsof -Pi :5173 -sTCP:LISTEN -t)
    echo "⚠️  Port 5173 still in use by process $pid (Frontend)"
    echo "   Run: kill $pid"
    ORPHANED=true
fi

if [ "$ORPHANED" = false ]; then
    echo "✅ No orphaned processes detected"
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
