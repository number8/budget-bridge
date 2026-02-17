# BudgetBridge

BudgetBridge is a Web application that simplifies personal finance management by converting diverse bank statement formats into structured, importable data for budgeting tools like YNAB (You Need A Budget), Monarch, or EveryDollar.

## Overview

BudgetBridge streamlines the process of importing financial data into your budgeting app. Upload statements in various formats (CSV, QIF, PDF), let the system parse and normalize the data, apply AI-powered categorization, and export clean CSV files ready for import.

## Getting Started

### Prerequisites

- [.NET SDK 9.0+](https://dotnet.microsoft.com/download)
- [Docker](https://www.docker.com/get-started)
- [pnpm](https://pnpm.io/installation) (or npm/yarn)
- [PostgreSQL 16+](https://www.postgresql.org/) (or use Docker container)

### Quick Start

```bash
# Initial setup (run once - fully automated)
./scripts/setup.sh

# Start development environment
./scripts/start.sh --mode=local

# Access the application
# Backend: http://localhost:8080/health
# Frontend: http://localhost:5173

# Stop all services
./scripts/stop.sh
```

### Run Modes

BudgetBridge supports four run modes optimized for different development scenarios:

#### Mode 1: **Local Development** (Default)
**When to use**: Active development with hot reload  
**What runs**: Backend via `dotnet watch`, Frontend via `pnpm dev`, PostgreSQL in Docker  
**Pros**: Fastest feedback loop, full debugging support  
**Cons**: Requires .NET SDK and pnpm installed

```bash
./scripts/start.sh --mode=local
# or
./scripts/start.sh  # local is default
```

- Backend: http://localhost:8080 (hot reload enabled)
- Frontend: http://localhost:5173 (hot reload enabled)
- PostgreSQL: localhost:5432

#### Mode 2: **Backend-Only** (Containerized)
**When to use**: Frontend-only development, testing backend in production-like environment  
**What runs**: Backend + PostgreSQL in Docker  
**Pros**: Matches production environment, isolated from system  
**Cons**: No hot reload, slower build cycles

```bash
./scripts/start.sh --mode=backend
```

- Backend: http://localhost:8080 (containerized)
- PostgreSQL: Internal Docker network
- Frontend: Start separately with `cd frontend && pnpm dev`

#### Mode 3: **Full Stack** (Containerized)
**When to use**: Integration testing, deployment verification, contributors without local tooling  
**What runs**: Backend + PostgreSQL + Frontend, all in Docker  
**Pros**: Complete environment, no local dependencies beyond Docker  
**Cons**: Slowest feedback loop, harder to debug

```bash
./scripts/start.sh --mode=full
```

- Backend: http://localhost:8080 (containerized)
- Frontend: http://localhost:5173 (containerized)
- PostgreSQL: Internal Docker network

#### Mode 4: **Frontend-Only**
**When to use**: Frontend development against deployed backend  
**What runs**: Frontend dev server only  
**Pros**: Minimal resource usage, frontend hot reload  
**Cons**: Requires backend running elsewhere

```bash
./scripts/start.sh --mode=frontend
```

- Frontend: http://localhost:5173 (hot reload enabled)
- Backend: Must be running at configured URL

### VS Code Integration

Run modes are also available as VS Code tasks (Command Palette → "Tasks: Run Task"):

- **Setup: Initialize BudgetBridge** - One-time setup
- **Database: Initialize (Local)** - Apply migrations
- **Start: Local Development** - Mode 1 (local)
- **Start: Backend Only (Docker)** - Mode 2 (backend)
- **Start: Full (Docker)** - Mode 3 (full)
- **Start: Frontend Only** - Mode 4 (frontend)
- **Stop: All Services** - Graceful shutdown

### Project Structure

```
budget-bridge/
├── backend/              # .NET 9 Web API (Clean Architecture)
├── frontend/             # React + TypeScript + Vite
├── scripts/              # Unified startup and setup scripts
│   ├── setup.sh         # Initial environment setup
│   ├── start.sh         # Multi-mode startup
│   ├── stop.sh          # Graceful shutdown
│   └── db-init.sh       # Database initialization
├── docker-compose.yml    # Production orchestration
├── docker-compose.dev.yml # Development overrides
└── .vscode/tasks.json   # VS Code task definitions
```

### Development Documentation

- **Backend**: See [backend/README.md](backend/README.md) for .NET development details
- **Frontend**: See [frontend/README.md](frontend/README.md) for React development details

## Contributing

We welcome contributions! To ensure smooth collaboration:

### Before You Start

1. **Check existing issues** – Browse open issues to see if your idea is already being discussed
2. **Open an issue first** – For significant changes, create an issue to discuss your proposal before starting work
3. **Ask questions** – Use GitHub Discussions or issues to clarify requirements

### Pull Request Workflow

1. **Fork and branch** – Create a feature branch from `main`
2. **Keep changes focused** – One PR should address one issue or feature
3. **Write clear commit messages** – Describe what and why, not just how
4. **Add tests** – Include unit tests for new functionality
5. **Update documentation** – Keep README and inline docs current
6. **Request review** – Tag relevant maintainers for review

### Code Standards

- **Backend (.NET)**: Follow standard C# conventions, use dependency injection, write testable code
- **Frontend (React)**: Use TypeScript, follow shadcn/ui + Tailwind patterns, implement responsive designs
- **AI agents welcome**: Our tasks are written to be AI-agent friendly. Feel free to use AI coding assistants, but review all generated code carefully

### Communication

- **GitHub Issues**: Primary channel for bug reports and feature requests
- **GitHub Discussions**: For questions, ideas, and general discussion
- **Pull Request comments**: For code-specific discussions during review

### What We're Looking For

- Bug fixes
- Feature implementations (check issues labeled `good first issue` or `help wanted`)
- Documentation improvements
- Test coverage improvements
- Performance optimizations

### What to Avoid

- Large refactors without prior discussion
- Style-only changes (unless fixing consistency issues)
- Breaking changes without clear justification and migration path

## License

MIT
