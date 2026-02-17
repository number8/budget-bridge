# Quickstart Guide: BudgetBridge Backend Development

**Date**: February 16, 2026  
**Feature**: 001-dotnet-backend-setup

## Overview

This guide helps you get the BudgetBridge backend running on your local machine in under 5 minutes. Multiple run modes are supported for different development workflows.

---

## Prerequisites

### Required Tools

| Tool | Minimum Version | Check Command | Install |
|------|----------------|---------------|---------|
| .NET SDK | 9.0 | `dotnet --version` | [dotnet.microsoft.com/download](https://dotnet.microsoft.com/download) |
| Docker | 20.10+ | `docker --version` | [docker.com/get-started](https://www.docker.com/get-started) |
| Docker Compose | 2.0+ | `docker compose version` | Included with Docker Desktop |
| pnpm | 9.0+ | `pnpm --version` | `npm install -g pnpm` |

### Platform Support

- ✅ **macOS**: Fully supported (Intel & Apple Silicon)
- ✅ **Linux**: Fully supported (Ubuntu 22.04+, Debian 12+)
- ✅ **Windows**: Supported via WSL2 or native Docker Desktop

---

## Quick Start (Default Mode)

**Goal**: Run both frontend and backend from source code with containerized PostgreSQL.

### Step 1: Clone and Navigate

```bash
git clone https://github.com/mmorales/budget-bridge.git
cd budget-bridge
```

### Step 2: Run Initial Setup

```bash
# From repository root
./scripts/setup.sh
```

**What this does**:
- Initializes .NET user secrets with generated DB password
- Creates `.env` file from `.env.example`
- Installs frontend dependencies (`pnpm install`)
- Verifies prerequisites are installed

### Step 3: Start Services

```bash
./scripts/start.sh
```

**Default behavior** (no arguments):
- Starts PostgreSQL container
- Runs .NET backend from code (port 5000)
- Runs React frontend from code (port 3000)

### Step 4: Verify

Open browser to:
- **Frontend**: http://localhost:3000
- **Backend Health**: http://localhost:5000/health
- **API Docs** (future): http://localhost:5000/swagger

**Expected health response**:
```json
{
  "status": "Healthy",
  "version": "1.0.0",
  "timestamp": "2026-02-16T12:00:00Z"
}
```

### Stop Services

Press `Ctrl+C` in the terminal running `start.sh`, or:

```bash
./scripts/stop.sh
```

---

## Run Modes

The `start.sh` script supports multiple modes for different workflows:

### Mode 1: Local Development (Default)

**Use case**: Active development on both frontend and backend.

```bash
./scripts/start.sh local
# or just: ./scripts/start.sh
```

**What runs**:
- PostgreSQL: Docker container
- Backend: Code (hot reload via `dotnet watch`)
- Frontend: Code (hot reload via Vite)

**Ports**:
- Frontend: 3000
- Backend: 5000
- PostgreSQL: 5432 (host-accessible)

---

### Mode 2: Full Docker

**Use case**: Test production-like deployment or CI/CD validation.

```bash
./scripts/start.sh full
```

**What runs**:
- PostgreSQL: Docker container
- Backend: Docker container (published image)
- Frontend: Docker container (Nginx serving built assets)

**Ports**:
- Frontend: 3000
- Backend: 5000
- PostgreSQL: 5432 (internal only)

**Container images used**:
- Backend: `ghcr.io/mmorales/budget-bridge/backend:latest`
- Frontend: `ghcr.io/mmorales/budget-bridge/frontend:latest`

**Docker Compose file location**: Repository root (`/docker-compose.yml`)

---

### Mode 3: Backend Docker Only

**Use case**: Frontend development against stable backend version.

```bash
./scripts/start.sh backend
```

**What runs**:
- PostgreSQL: Docker container
- Backend: Docker container (published image)
- Frontend: Code (you start manually)

**Ports**:
- Backend: 5000
- PostgreSQL: 5432 (internal only)

**Then start frontend**:
```bash
cd frontend
pnpm dev
```

---

### Mode 4: Frontend Docker Only

**Use case**: Backend development with stable frontend (rare).

```bash
./scripts/start.sh frontend
```

**What runs**:
- PostgreSQL: Docker container
- Backend: Code (you start manually)
- Frontend: Docker container

**Then start backend**:
```bash
cd backend
dotnet run --project src/BudgetBridge.Api
```

---

## Configuration

### Environment Variables

Key configuration values are loaded from:
1. `.env` file (created by `setup.sh`)
2. .NET user secrets (created by `setup.sh`)
3. Environment variables (override all)

**Common variables**:

```bash
# Database
DB_HOST=localhost           # Use 'db' in Docker mode
DB_PORT=5432
DB_NAME=budgetbridge
DB_USER=postgres
DB_PASSWORD=<generated>     # Stored in user secrets

# API
ASPNETCORE_ENVIRONMENT=Development
ASPNETCORE_URLS=http://+:8080

# Frontend
VITE_API_URL=http://localhost:5000
```

### Viewing User Secrets

```bash
cd backend/src/BudgetBridge.Api
dotnet user-secrets list
```

### Updating Secrets

```bash
cd backend/src/BudgetBridge.Api
dotnet user-secrets set "ConnectionStrings:DefaultConnection" \
  "Host=localhost;Database=budgetbridge;Username=postgres;Password=YOUR_PASSWORD"
```

---

## Common Tasks

### Run Backend Tests

```bash
cd backend
dotnet test
```

**Test projects**:
- `BudgetBridge.Domain.Tests`: Unit tests for domain logic
- `BudgetBridge.Application.Tests`: Unit tests for use cases
- `BudgetBridge.Infrastructure.Tests`: Integration tests with Testcontainers
- `BudgetBridge.Api.Tests`: API endpoint tests

### Run Frontend Tests

```bash
cd frontend
pnpm test
```

### Apply Database Migrations

Migrations are automatically applied on backend startup (Development environment).

**Manual migration**:
```bash
cd backend
dotnet ef database update --project src/BudgetBridge.Infrastructure \
  --startup-project src/BudgetBridge.Api
```

### Create New Migration

```bash
cd backend
dotnet ef migrations add YourMigrationName \
  --project src/BudgetBridge.Infrastructure \
  --startup-project src/BudgetBridge.Api
```

### Format Code

**Backend**:
```bash
cd backend
dotnet format
```

**Frontend**:
```bash
cd frontend
pnpm format
```

### Build Docker Images Locally

**Backend**:
```bash
cd backend
docker build -t budgetbridge-backend:local .
```

**Frontend**:
```bash
cd frontend
docker build -t budgetbridge-frontend:local .
```

---

## Troubleshooting

### Error: "Port 5000 already in use"

**Cause**: Another process is using port 5000.

**Solution**:
```bash
# Find process using port 5000
lsof -ti:5000 | xargs kill -9

# Or change backend port
export ASPNETCORE_URLS="http://+:5001"
./scripts/start.sh
```

### Error: "PostgreSQL container won't start"

**Cause**: Port 5432 already in use or volume corruption.

**Solution**:
```bash
# Stop all containers
docker compose down

# Remove volumes (WARNING: deletes data)
docker compose down -v

# Restart
./scripts/start.sh
```

### Error: "dotnet: command not found"

**Cause**: .NET SDK not installed or not in PATH.

**Solution**:
1. Install .NET SDK: https://dotnet.microsoft.com/download
2. Verify: `dotnet --version`
3. Restart terminal

### Error: "Cannot connect to Docker daemon"

**Cause**: Docker Desktop not running.

**Solution**:
- **macOS/Windows**: Start Docker Desktop app
- **Linux**: `sudo systemctl start docker`

### Error: "Migration failed" or "Database connection error"

**Cause**: Database password mismatch between user secrets and Docker container.

**Solution**:
```bash
# Get DB password from user secrets
cd backend/src/BudgetBridge.Api
dotnet user-secrets list | grep ConnectionStrings

# Update .env file with matching password
echo "DB_PASSWORD=<password-from-above>" >> ../../.env

# Restart services
./scripts/stop.sh
./scripts/start.sh
```

---

## Development Workflow

### Typical Day-to-Day Development

1. **Morning**: `./scripts/start.sh` (local mode)
2. **Work**: Edit code, hot reload automatically applies changes
3. **Test**: `dotnet test` (backend) or `pnpm test` (frontend)
4. **Commit**: Git commit with conventional commit format
5. **Evening**: `./scripts/stop.sh` or just close terminal

### Before Creating Pull Request

1. **Format code**:
   ```bash
   cd backend && dotnet format
   cd ../frontend && pnpm format
   ```

2. **Run tests**:
   ```bash
   cd backend && dotnet test
   cd ../frontend && pnpm test
   ```

3. **Test in Docker mode** (validates production build):
   ```bash
   ./scripts/start.sh full
   ```

4. **Check health endpoints**:
   - http://localhost:5000/health
   - http://localhost:5000/health/ready

---

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│                   Frontend                      │
│         React + Vite + TanStack Router          │
│              (Port 3000)                        │
└───────────────────┬─────────────────────────────┘
                    │ HTTP
                    ▼
┌─────────────────────────────────────────────────┐
│              Backend API Layer                  │
│           ASP.NET Core Controllers              │
│              (Port 5000/8080)                   │
└───────────────────┬─────────────────────────────┘
                    │
    ┌───────────────┼───────────────┐
    │               │               │
    ▼               ▼               ▼
┌────────┐  ┌──────────────┐  ┌──────────────┐
│ Domain │  │ Application  │  │Infrastructure│
│        │◄─┤   (Use Cases)│◄─┤ (EF Core)    │
└────────┘  └──────────────┘  └──────┬───────┘
                                      │
                                      ▼
                              ┌──────────────┐
                              │  PostgreSQL  │
                              │ (Port 5432)  │
                              └──────────────┘
```

**Dependency Rule**: Outer layers depend on inner layers. Domain has no dependencies.

---

## Next Steps

### For New Developers

1. **Read the architecture docs**: [architecture/budgetbridge-architecture-v0.1.md](../../../architecture/budgetbridge-architecture-v0.1.md)
2. **Review the constitution**: [.specify/memory/constitution.md](../../../.specify/memory/constitution.md)
3. **Pick an issue**: Look for `good first issue` label on GitHub
4. **Join discussions**: Ask questions in GitHub Discussions

### For Feature Development

1. **Create feature spec**: Use template in `.specify/templates/spec-template.md`
2. **Run planning**: `/speckit.plan` command generates implementation plan
3. **Create tasks**: `/speckit.tasks` command generates breakdown
4. **Implement with TDD**: Write tests first!
5. **Submit PR**: Follow contribution guidelines

### For Self-Hosting

1. **Review production deployment guide** (future feature)
2. **Set up reverse proxy** (Nginx/Caddy)
3. **Configure SSL certificates** (Let's Encrypt)
4. **Set up backups** for PostgreSQL
5. **Monitor logs** and health endpoints

---

## Resources

- **Repository**: https://github.com/mmorales/budget-bridge
- **Issue Tracker**: https://github.com/mmorales/budget-bridge/issues
- **Discussions**: https://github.com/mmorales/budget-bridge/discussions
- **.NET Docs**: https://learn.microsoft.com/en-us/dotnet/
- **EF Core**: https://learn.microsoft.com/en-us/ef/core/
- **Docker Compose**: https://docs.docker.com/compose/

---

## Support

- **Found a bug?** Open an issue with the `bug` label
- **Need help?** Start a discussion in GitHub Discussions
- **Want to contribute?** See [CONTRIBUTING.md](../../../CONTRIBUTING.md)
