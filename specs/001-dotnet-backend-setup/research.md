# Research: .NET Backend Development Environment Setup

**Date**: February 16, 2026  
**Feature**: 001-dotnet-backend-setup  
**Phase**: 0 (Outline & Research)

## Overview

This document consolidates research findings for setting up a .NET 9 backend solution following Clean Architecture patterns with multiple deployment modes (Docker, hybrid, local-only). All NEEDS CLARIFICATION items from Technical Context have been resolved.

---

## 1. Clean Architecture in .NET 9

### Decision
Implement Clean Architecture with four projects: Domain, Application, Infrastructure, and API. Use project references to enforce dependency rules at compile time.

### Rationale
- **Separation of Concerns**: Each layer has distinct responsibilities (business rules, use cases, data access, HTTP concerns)
- **Testability**: Domain and Application layers can be tested independently without infrastructure dependencies
- **Maintainability**: Changes to external dependencies (database, APIs) are isolated to Infrastructure layer
- **Constitution Alignment**: Clean Architecture is explicitly mandated in the BudgetBridge constitution

### Alternatives Considered
- **Vertical Slice Architecture**: Rejected because Clean Architecture is already a constitutional requirement for this project
- **Modular Monolith with Features**: Could revisit in future if domain complexity grows, but premature for initial setup
- **Single Project Structure**: Rejected—doesn't enforce dependency rules and violates constitution

### Implementation Pattern
```
Domain:
  - Pure C# entities and interfaces
  - No external dependencies except .NET BCL
  - Value objects, domain events, domain exceptions

Application:
  - Use case implementations (commands/queries)
  - DTOs for cross-layer communication
  - Depends only on Domain layer
  - Interfaces for infrastructure concerns (IRepository, IAIProvider)

Infrastructure:
  - EF Core DbContext and repository implementations
  - External API clients (AI providers, bank APIs)
  - Depends on Application and Domain layers

API:
  - ASP.NET Core controllers
  - Middleware (authentication, error handling)
  - Depends on Application and Infrastructure layers
  - Registers dependencies in DI container
```

### References
- Jason Taylor's Clean Architecture template: github.com/jasontaylordev/CleanArchitecture
- .NET 9 project organization: learn.microsoft.com/en-us/dotnet/architecture/modern-web-apps-azure/common-web-application-architectures

---

## 2. Docker Multi-Stage Builds for .NET 9

### Decision
Use multi-stage Dockerfile with SDK image for build and runtime-only image for final container. Separate Dockerfiles: `backend/Dockerfile` for API and `frontend/Dockerfile` (existing) for UI. Docker Compose at repository root orchestrates both.

### Rationale
- **Size Optimization**: Runtime image ~200MB vs SDK image ~1.2GB
- **Security**: Production containers don't include build tools
- **Build Reproducibility**: SDK version pinned in Dockerfile ensures consistent builds
- **Layer Caching**: Separate restore/build/publish stages maximize Docker cache efficiency

### Alternatives Considered
- **Single-Stage Build**: Rejected—produces bloated images with unnecessary SDK tools
- **External Build + Dockerfile**: Rejected—complicates CI/CD and loses reproducibility benefits
- **Chiseled Ubuntu Images**: Considered for future optimization but adds complexity for initial setup

### Implementation Pattern
```dockerfile
# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY ["src/BudgetBridge.Api/BudgetBridge.Api.csproj", "src/BudgetBridge.Api/"]
# ... copy other project files
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /app/publish

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "BudgetBridge.Api.dll"]
```

### Best Practices
- Pin specific SDK/runtime versions (not `latest`)
- Copy `.csproj` files first to leverage Docker layer caching on `dotnet restore`
- Use `dotnet publish` with `-c Release` for optimized builds
- Set `ASPNETCORE_ENVIRONMENT` via environment variables, not hardcoded

### References
- Docker best practices for .NET: learn.microsoft.com/en-us/dotnet/core/docker/build-container
- Multi-stage builds: docs.docker.com/build/building/multi-stage/

---

## 3. Docker Compose Orchestration for Multiple Run Modes

### Decision
Create multiple compose files: `docker-compose.yml` (full stack), `docker-compose.dev.yml` (DB only), and override patterns for hybrid modes. Use profiles to control service startup.

### Rationale
- **Flexibility**: Developers can run any combination of services (full docker, DB-only, etc.)
- **DRY Principle**: Base configuration shared, overrides for specific modes
- **Standard Tooling**: Docker Compose widely adopted and well-documented
- **Development Experience**: Single command to start environment

### Alternatives Considered
- **Separate Compose Files**: `docker-compose.full.yml`, `docker-compose.backend-only.yml`, etc.
  - Rejected: Lots of duplication, hard to maintain
- **Kubernetes (k3s/minikube)**: Rejected—overkill for local development
- **Podman Compose**: Considered for future but Docker is more widely adopted

### Implementation Pattern
```yaml
# docker-compose.yml (root level of repository)
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  backend:
    build: ./backend
    profiles: ["full", "backend-only"]
    environment:
      - ConnectionStrings__DefaultConnection=Host=db;Database=budgetbridge;...
    depends_on:
      - db
    ports:
      - "5000:8080"

  frontend:
    build: ./frontend
    profiles: ["full"]
    environment:
      - VITE_API_URL=http://backend:8080
    depends_on:
      - backend
    ports:
      - "3000:80"

volumes:
  postgres_data:
```

### Run Mode Commands
- **All Docker**: `docker compose --profile full up`
- **DB Only** (code frontend + backend): `docker compose up db`
- **Docker Backend + Code Frontend**: `docker compose --profile backend-only up` + `cd frontend && pnpm dev`
- **No Docker** (local code only): Script handles DB via `dotnet ef database update` or Testcontainers

### References
- Docker Compose profiles: docs.docker.com/compose/profiles/
- .NET Docker samples: github.com/dotnet/dotnet-docker/tree/main/samples

---

## 4. Unified Startup Script Design

### Decision
Create `scripts/start.sh` that accepts mode argument: `--mode=full|backend|frontend|local` (default: `local`). Script handles prerequisite checks, environment setup, and service orchestration.

### Rationale
- **Single Entry Point**: Developers don't need to remember different commands for different modes
- **Prerequisite Validation**: Script checks for required tools (Docker, .NET SDK, pnpm) before starting
- **Error Handling**: Clear error messages when dependencies missing or ports in use
- **Discoverability**: Developers naturally look for `start.sh` or similar

### Alternatives Considered
- **Makefile**: Rejected—less portable across platforms (Windows), make syntax less intuitive
- **npm scripts in root package.json**: Rejected—couples project to Node.js ecosystem
- **Separate script per mode**: Rejected—harder to discover, more maintenance

### Implementation Pattern
```bash
#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-local}"  # Default to local (no docker)

case "$MODE" in
  full)
    echo "Starting full stack (Docker)..."
    docker compose --profile full up
    ;;
  backend)
    echo "Starting backend only (Docker)..."
    docker compose --profile backend-only up
    ;;
  frontend)
    echo "Starting frontend only (code)..."
    docker compose up db -d
    cd backend && dotnet run --project src/BudgetBridge.Api
    ;;
  local)
    echo "Starting local development (no Docker for services)..."
    docker compose up db -d  # Still use containerized DB
    # Run backend and frontend in parallel
    (cd backend && dotnet run --project src/BudgetBridge.Api) &
    (cd frontend && pnpm dev) &
    wait
    ;;
  *)
    echo "Unknown mode: $MODE"
    echo "Usage: $0 [full|backend|frontend|local]"
    exit 1
    ;;
esac
```

### Prerequisite Checks
- `.NET SDK 9.0`: Check via `dotnet --version`
- `Docker`: Check via `docker --version`
- `pnpm`: Check via `pnpm --version`
- Port availability: Check 3000, 5000, 5432 before starting

### References
- Bash best practices: mywiki.wooledge.org/BashGuide/Practices
- Cross-platform shell scripting: github.com/modernish/modernish

---

## 5. .NET User Secrets for Local Development

### Decision
Use `dotnet user-secrets` for local development secrets (DB passwords, API keys). Provide `scripts/setup.sh` that initializes secrets with generated values.

### Rationale
- **Security**: Secrets never committed to version control
- **Per-Developer**: Each developer has their own secret values
- **Standard Tooling**: Built into .NET SDK, no additional tools required
- **Constitution Compliance**: Aligns with "no hardcoded secrets" principle

### Alternatives Considered
- **.env files**: Rejected—risk of accidental commit, not .NET-idiomatic
- **Azure Key Vault/HashiCorp Vault**: Rejected—overkill for local dev, requires external service
- **appsettings.Development.json**: Rejected—would be committed to repo

### Implementation Pattern
```bash
# scripts/setup.sh
#!/usr/bin/env bash

echo "Initializing .NET user secrets..."
cd backend/src/BudgetBridge.Api

# Generate random DB password
DB_PASSWORD=$(openssl rand -base64 32)

dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:DefaultConnection" \
  "Host=localhost;Database=budgetbridge;Username=postgres;Password=$DB_PASSWORD"

echo "Secrets initialized. DB password: $DB_PASSWORD"
echo "Update docker-compose.yml POSTGRES_PASSWORD if needed."
```

### Access Pattern in Code
```csharp
// Program.cs
var connectionString = builder.Configuration
    .GetConnectionString("DefaultConnection");
```

### References
- Safe storage of app secrets: learn.microsoft.com/en-us/aspnet/core/security/app-secrets

---

## 6. GitHub Actions for Container Registry Publishing

### Decision
Create separate workflows for backend (`backend-ci.yml`) and frontend (`frontend-ci.yml`). Publish to GitHub Container Registry (ghcr.io) on push to `main` or release tags.

### Rationale
- **Separation of Concerns**: Backend and frontend have independent build/test/deploy cycles
- **No External Dependencies**: GitHub Container Registry free for public repos, integrated with GitHub
- **Versioning**: Use semantic versioning tags for releases, SHA-based tags for commits
- **Multi-Architecture**: Support amd64 and arm64 for broad compatibility

### Alternatives Considered
- **Docker Hub**: Rejected—rate limiting for free tier, requires separate account
- **AWS ECR/Azure ACR**: Rejected—couples project to cloud provider, violates self-hosted principle
- **Single Workflow**: Rejected—changes to frontend shouldn't trigger backend rebuild and vice versa

### Implementation Pattern
```yaml
# .github/workflows/backend-ci.yml
name: Backend CI/CD

on:
  push:
    branches: [main]
    paths:
      - 'backend/**'
      - '.github/workflows/backend-ci.yml'
  pull_request:
    paths:
      - 'backend/**'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '9.0.x'
      - run: dotnet test backend/BudgetBridge.sln

  publish:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v5
        with:
          context: ./backend
          push: true
          tags: |
            ghcr.io/${{ github.repository }}/backend:latest
            ghcr.io/${{ github.repository }}/backend:${{ github.sha }}
```

### Tagging Strategy
- `latest`: Most recent build from `main` branch
- `sha-<commit>`: Specific commit SHA for reproducibility
- `v1.2.3`: Semantic version tags for releases
- `pr-123`: Optional PR preview builds

### References
- Publishing to GitHub Container Registry: docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry
- Docker build-push-action: github.com/docker/build-push-action

---

## 7. Code Quality Tooling (EditorConfig and dotnet-format)

### Decision
Use `.editorconfig` for cross-editor code style enforcement and `dotnet format` as pre-commit hook. Configure GitHub Actions to fail on formatting violations.

### Rationale
- **Consistency**: All contributors use same formatting rules regardless of IDE
- **Automation**: Formatting violations caught in CI before code review
- **Standard Tooling**: Built into .NET SDK, supported by Visual Studio, VS Code, Rider
- **Low Friction**: `dotnet format` auto-fixes most issues

### Alternatives Considered
- **StyleCop Analyzers**: Considered but adds NuGet dependency; EditorConfig sufficient for initial setup
- **Manual Code Review**: Rejected—wastes reviewer time on formatting nitpicks
- **Prettier for C#**: Rejected—not .NET-native, less mature than dotnet-format

### Implementation Pattern
```ini
# .editorconfig (backend/)
root = true

[*.cs]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

# Naming conventions
dotnet_naming_rule.interfaces_should_be_pascal_case.severity = warning
dotnet_naming_rule.interfaces_should_be_pascal_case.symbols = interface
dotnet_naming_rule.interfaces_should_be_pascal_case.style = begins_with_i

# Nullable reference types
csharp_nullable_reference_types = enable
```

### CI Integration
```yaml
# In backend-ci.yml
- name: Check code formatting
  run: dotnet format --verify-no-changes backend/BudgetBridge.sln
```

### Local Development
```bash
# Format all files
dotnet format backend/BudgetBridge.sln

# Check without modifying
dotnet format --verify-no-changes backend/BudgetBridge.sln
```

### References
- EditorConfig for .NET: learn.microsoft.com/en-us/dotnet/fundamentals/code-analysis/code-style-rule-options
- dotnet format: learn.microsoft.com/en-us/dotnet/core/tools/dotnet-format

---

## 8. Central Package Management (Directory.Packages.props)

### Decision
Use NuGet Central Package Management (CPM) to manage package versions in a single `Directory.Packages.props` file at solution root.

### Rationale
- **Version Consistency**: All projects use same version of shared dependencies (e.g., EF Core)
- **Easier Updates**: Update version once in central file, applies to all projects
- **Dependency Clarity**: `.csproj` files declare what packages they use, central file controls versions
- **.NET 9 Best Practice**: CPM is recommended pattern for multi-project solutions

### Alternatives Considered
- **Per-Project Package Versions**: Rejected—leads to version drift and transitive dependency conflicts
- **props/targets files**: Rejected—CPM is more purpose-built and has better tooling support

### Implementation Pattern
```xml
<!-- Directory.Packages.props -->
<Project>
  <PropertyGroup>
    <ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>
  </PropertyGroup>

  <ItemGroup>
    <PackageVersion Include="Microsoft.EntityFrameworkCore" Version="9.0.0" />
    <PackageVersion Include="Microsoft.EntityFrameworkCore.Design" Version="9.0.0" />
    <PackageVersion Include="Npgsql.EntityFrameworkCore.PostgreSQL" Version="9.0.0" />
    <PackageVersion Include="FluentValidation.AspNetCore" Version="11.3.0" />
    <PackageVersion Include="xUnit" Version="2.6.6" />
    <PackageVersion Include="Moq" Version="4.20.70" />
  </ItemGroup>
</Project>
```

```xml
<!-- In project files -->
<ItemGroup>
  <PackageReference Include="Microsoft.EntityFrameworkCore" />
  <!-- Version omitted—controlled by Directory.Packages.props -->
</ItemGroup>
```

### References
- Central Package Management: learn.microsoft.com/en-us/nuget/consume-packages/central-package-management

---

## Summary of Research Outcomes

All technical unknowns from the Technical Context section have been resolved:

| Original Question | Resolution |
|------------------|------------|
| Clean Architecture implementation in .NET 9 | Four-project structure with compile-time dependency enforcement |
| Docker multi-stage build strategy | SDK stage for build, aspnet runtime for production |
| Multi-mode orchestration | Docker Compose with profiles and unified startup script |
| Secret management | .NET user secrets for local dev, env vars for containers |
| CI/CD container publishing | GitHub Actions + GitHub Container Registry with semantic versioning |
| Code quality tooling | EditorConfig + dotnet-format enforced in CI |
| Package management | Central Package Management (Directory.Packages.props) |

These decisions provide a solid foundation for Phase 1 (Design & Contracts) to define the specific project structure, API contracts, and developer quickstart guide.
