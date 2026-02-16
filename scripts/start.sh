#!/usr/bin/env bash
set -e

# BudgetBridge Start Script
# Starts development environment in various modes

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Default mode
MODE="local"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --mode=*)
            MODE="${1#*=}"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--mode=full|backend|frontend|local]"
            exit 1
            ;;
    esac
done

# Validate mode
if [[ ! "$MODE" =~ ^(full|backend|frontend|local)$ ]]; then
    echo "❌ Invalid mode: $MODE"
    echo "Valid modes: full, backend, frontend, local"
    exit 1
fi

echo "🚀 Starting BudgetBridge (mode: $MODE)"
echo "========================================"
echo ""

# Check for port conflicts
check_port() {
    local port=$1
    local service=$2
    
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "⚠️  Port $port is already in use"
        echo "   Service: $service"
        local pid=$(lsof -Pi :$port -sTCP:LISTEN -t)
        echo "   Process: $(ps -p $pid -o comm= 2>/dev/null || echo 'unknown')"
        return 1
    fi
    return 0
}

if [ "$MODE" = "full" ]; then
    # Full containerized mode
    echo "Starting all services in Docker..."
    cd "$PROJECT_ROOT"
    
    check_port 5432 "PostgreSQL" || true
    check_port 8080 "Backend API" || true
    check_port 5173 "Frontend Dev Server" || true
    
    docker compose --profile full up -d
    
    echo ""
    echo "✅ All services started!"
    echo ""
    echo "Services:"
    echo "  🗄️  PostgreSQL: localhost:5432"
    echo "  🔧 Backend API: http://localhost:8080"
    echo "  🎨 Frontend: http://localhost:5173"
    echo ""
    echo "Logs: docker compose logs -f"
    echo "Stop: ./scripts/stop.sh"

elif [ "$MODE" = "backend" ]; then
    # Backend-only containerized mode
    echo "Starting backend services in Docker..."
    cd "$PROJECT_ROOT"
    
    check_port 5432 "PostgreSQL" || true
    check_port 8080 "Backend API" || true
    
    docker compose --profile backend-only up -d
    
    echo ""
    echo "✅ Backend services started!"
    echo ""
    echo "Services:"
    echo "  🗄️  PostgreSQL: localhost:5432"
    echo "  🔧 Backend API: http://localhost:8080"
    echo ""
    echo "Logs: docker compose logs -f backend"
    echo "Stop: ./scripts/stop.sh"

elif [ "$MODE" = "frontend" ]; then
    # Frontend-only mode
    echo "Starting frontend dev server..."
    cd "$PROJECT_ROOT/frontend"
    
    if ! check_port 5173 "Frontend Dev Server"; then
        echo "❌ Cannot start frontend (port conflict)"
        exit 1
    fi
    
    pnpm dev &
    FRONTEND_PID=$!
    echo $FRONTEND_PID > "$PROJECT_ROOT/.frontend.pid"
    
    echo ""
    echo "✅ Frontend dev server started!"
    echo ""
    echo "  🎨 Frontend: http://localhost:5173"
    echo "  PID: $FRONTEND_PID"
    echo ""
    echo "Stop: ./scripts/stop.sh"

elif [ "$MODE" = "local" ]; then
    # Local development mode (no containers)
    echo "Starting backend locally with dotnet watch..."
    cd "$PROJECT_ROOT/backend/src/BudgetBridge.Api"
    
    if ! check_port 8080 "Backend API"; then
        echo "❌ Cannot start backend (port conflict)"
        exit 1
    fi
    
    # Check if PostgreSQL is available
    if ! docker ps --format '{{.Names}}' | grep -q 'budgetbridge-db'; then
        echo "⚠️  PostgreSQL not running. Starting container..."
        "$SCRIPT_DIR/db-init.sh" local
    fi
    
    # Start backend with hot reload
    export ASPNETCORE_ENVIRONMENT=Development
    dotnet watch run &
    BACKEND_PID=$!
    echo $BACKEND_PID > "$PROJECT_ROOT/.backend.pid"
    
    echo ""
    echo "✅ Backend started locally!"
    echo ""
    echo "  🔧 Backend API: http://localhost:8080"
    echo "  PID: $BACKEND_PID"
    echo ""
    echo "Health check: curl http://localhost:8080/health"
    echo "Logs: tail -f backend logs or check terminal"
    echo "Stop: ./scripts/stop.sh"
    echo ""
    echo "To start frontend separately:"
    echo "  cd frontend && pnpm dev"
fi

echo ""
