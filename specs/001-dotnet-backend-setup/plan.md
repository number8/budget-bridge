# Implementation Plan: .NET Backend Development Environment Setup

**Branch**: `001-dotnet-backend-setup` | **Date**: February 16, 2026 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-dotnet-backend-setup/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Set up a .NET 9 backend solution following Clean Architecture patterns with four distinct layers (Domain, Application, Infrastructure, API). Provide containerized deployment options supporting multiple run modes: all-docker, no-docker, mixed (docker backend + code frontend), and default (code-only with optional DB container). Include unified startup scripts, GitHub Actions for container registry publishing, linting/formatting tooling, and comprehensive developer documentation.

## Technical Context

**Language/Version**: .NET 9.0 SDK (C# 13)
**Primary Dependencies**: 
- ASP.NET Core Web API 9.0+
- Entity Framework Core 9.0+ (for future database interactions)
- FluentValidation (for request validation)
- Microsoft.Extensions.* (logging, configuration, DI)

**Storage**: PostgreSQL 16+ (containerized for local dev, managed by EF Core migrations)
**Testing**: xUnit with Moq for mocking, Testcontainers for integration tests
**Target Platform**: Linux containers (Docker) for deployment, cross-platform development (macOS, Linux, Windows)
**Project Type**: Web application (separate frontend + backend)
**Performance Goals**: <100ms response time for health endpoints, support for 100+ concurrent connections in dev mode
**Constraints**: 
- Must support self-hosted deployment (no cloud dependencies)
- Configuration via environment variables and .NET user secrets
- No hardcoded secrets in code or version control

**Scale/Scope**: 
- Initial setup: 4 project structure + 1 health endpoint
- Future: ~50-100 API endpoints across budget, transaction, and AI categories
- Expected load: 10-100 concurrent users in typical self-hosted deployment

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### ✅ I. Privacy-First & Self-Hosted
- ✅ Backend runs locally via Docker Compose or direct code execution
- ✅ PostgreSQL containerized for user control
- ✅ No telemetry or external service dependencies
- ✅ Secrets managed via .NET user secrets (not in version control)

### ✅ II. API-First Architecture  
- ✅ Health check endpoint implemented before any UI
- ✅ Clean Architecture separates API layer from business logic
- ✅ Future: OpenAPI documentation required (not in initial scope per requirements)
- ✅ REST endpoints using standard ASP.NET Core patterns

### ✅ III. Test-Driven Development
- ✅ xUnit test projects included in solution structure
- ✅ Unit tests for domain/application layers
- ✅ Integration tests using Testcontainers for real database tests
- ✅ CI/CD pipeline will enforce test execution before merging

### ✅ IV. Type Safety & Static Analysis
- ✅ C# 13 with nullable reference types enabled
- ✅ EditorConfig and dotnet-format for code quality
- ✅ FluentValidation for runtime validation at API boundaries
- ✅ Strict compiler warnings enabled (`TreatWarningsAsErrors`)

### ✅ V. Incremental Learning & AI Assistance  
- ⚠️ Not applicable for initial backend setup
- 🔮 Future: AI service abstraction will be implemented in Application layer

### ✅ VI. Extensibility & Pluggability
- ✅ Clean Architecture enables future parser/exporter plugins
- ✅ Infrastructure layer abstracts external dependencies
- ✅ Dependency Injection supports runtime provider swapping

### ✅ VII. Simplicity & YAGNI
- ✅ Minimal initial implementation (health endpoint only)
- ✅ No premature optimization or speculative features
- ✅ Infrastructure scaffolded but not over-engineered

**GATE STATUS**: ✅ **PASS** - All applicable principles satisfied. No violations requiring justification.

## Project Structure

### Documentation (this feature)

```text
specs/001-dotnet-backend-setup/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
│   └── health-api.yaml  # OpenAPI spec for health endpoint
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
backend/
├── BudgetBridge.sln                    # Solution file
├── .editorconfig                       # Code style configuration
├── Directory.Build.props               # Shared MSBuild properties
├── Directory.Packages.props            # Central package management
├── Dockerfile                          # Multi-stage backend build
├── README.md                           # Backend-specific documentation
├── .env.example                        # Environment variable template
│
├── src/
│   ├── BudgetBridge.Domain/            # Core business entities and interfaces
│   │   ├── Entities/                   # Domain entities (future: Budget, Transaction)
│   │   ├── Interfaces/                 # Repository and service contracts
│   │   └── BudgetBridge.Domain.csproj
│   │
│   ├── BudgetBridge.Application/       # Use cases and business logic
│   │   ├── Common/                     # Shared application concerns
│   │   ├── Services/                   # Application services
│   │   ├── DTOs/                       # Data transfer objects
│   │   └── BudgetBridge.Application.csproj
│   │
│   ├── BudgetBridge.Infrastructure/    # External integrations
│   │   ├── Persistence/                # EF Core DbContext, repositories
│   │   │   ├── ApplicationDbContext.cs
│   │   │   └── Migrations/
│   │   ├── Configuration/              # Service registration
│   │   └── BudgetBridge.Infrastructure.csproj
│   │
│   └── BudgetBridge.Api/               # HTTP API layer
│       ├── Controllers/                # API controllers
│       │   └── HealthController.cs     # Health check endpoint
│       ├── Middleware/                 # Request pipeline components
│       ├── Program.cs                  # Application entry point
│       ├── appsettings.json            # Base configuration
│       ├── appsettings.Development.json
│       └── BudgetBridge.Api.csproj
│
└── tests/
    ├── BudgetBridge.Domain.Tests/      # Unit tests for domain layer
    ├── BudgetBridge.Application.Tests/ # Unit tests for application layer
    ├── BudgetBridge.Infrastructure.Tests/ # Integration tests with Testcontainers
    └── BudgetBridge.Api.Tests/         # API endpoint tests

frontend/
├── Dockerfile                          # Frontend Nginx build (existing)
├── [existing React/Vite structure]

# Root-level orchestration
docker-compose.yml                      # Base services (db, backend, frontend)
docker-compose.dev.yml                  # Development overrides
.env.example                            # Environment variable template

.github/
├── workflows/
│   ├── backend-ci.yml                  # Backend build, test, publish
│   └── frontend-ci.yml                 # Frontend build, test, publish

scripts/
├── start.sh                            # Unified startup script
├── setup.sh                            # Initial environment setup
└── db-init.sh                          # Database initialization with secrets
```

**Structure Decision**: Web application structure (Option 2) selected. Backend and frontend are separate concerns with independent build/deploy pipelines. Docker orchestration files (docker-compose.yml) live at repository root to coordinate all services. Clean Architecture within backend enforces dependency rules: Domain (core) ← Application ← Infrastructure ← Api. Each layer is a separate project for compile-time dependency enforcement.

## Complexity Tracking

> **No violations - complexity justification not required**

All constitution principles are satisfied without requiring additional complexity or architectural exceptions. The Clean Architecture pattern is foundational to the project design (per constitution) rather than an addition.
