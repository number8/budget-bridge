# BudgetBridge Backend

.NET 9 Web API using Clean Architecture principles for the BudgetBridge self-hosted budgeting application.

## Architecture Overview

This backend follows Clean Architecture with four distinct layers:

### 1. **Domain Layer** (`BudgetBridge.Domain`)
- **Purpose**: Core business entities and domain rules
- **Dependencies**: None (pure C#)
- **Contents**:
  - `Entities/`: Domain entities with factory methods and validation
  - `Interfaces/`: Repository and service contracts
  - Value objects and domain exceptions

### 2. **Application Layer** (`BudgetBridge.Application`)
- **Purpose**: Use cases and business logic orchestration
- **Dependencies**: Domain only
- **Contents**:
  - `Services/`: Application services implementing business workflows
  - `DTOs/`: Data transfer objects for cross-layer communication
  - `Common/`: Shared application concerns

### 3. **Infrastructure Layer** (`BudgetBridge.Infrastructure`)
- **Purpose**: External dependencies and data access
- **Dependencies**: Domain, Application
- **Contents**:
  - `Persistence/`: EF Core DbContext, migrations, repository implementations
  - `Configuration/`: Dependency injection setup

### 4. **API Layer** (`BudgetBridge.Api`)
- **Purpose**: HTTP endpoints and request/response handling
- **Dependencies**: Application, Infrastructure
- **Contents**:
  - `Controllers/`: API controllers
  - `Middleware/`: Request pipeline components
  - `Program.cs`: Application entry point and service registration
  - `appsettings.json`: Configuration

## Getting Started

### Prerequisites

- [.NET SDK 9.0+](https://dotnet.microsoft.com/download)
- [Docker](https://www.docker.com/get-started) (for PostgreSQL)
- [PostgreSQL 16+](https://www.postgresql.org/) (or use Docker container)

### Initial Setup

1. **Clone the repository** (if not already done):
   ```bash
   git clone https://github.com/mmorales/budget-bridge.git
   cd budget-bridge/backend
   ```

2. **Run automated setup** (from repository root):
   ```bash
   cd ..
   ./scripts/setup.sh
   ```
   
   This will automatically:
   - Load safe development passwords from committed `.env` files
   - Initialize .NET user secrets with connection string
   - Install frontend dependencies
   - Build the solution
   
   **Note**: The `.env` files contain safe dummy passwords for local development.
   To override any values, create `.env.local` (never committed).

### Running the Backend

**For unified startup scripts** (recommended for most users), see the [root README.md](../README.md#getting-started) which covers all run modes including full-stack development.

For **backend-only development**, you can run the API directly:

```bash
# Start PostgreSQL (if not already running)
docker run -d --name budgetbridge-db \
  -e POSTGRES_USER=budgetbridge \
  -e POSTGRES_PASSWORD=your_password \
  -e POSTGRES_DB=budgetbridge \
  -p 5432:5432 \
  postgres:16-alpine

# Run backend with hot reload
cd src/BudgetBridge.Api
export ASPNETCORE_ENVIRONMENT=Development
dotnet watch run
```

Backend available at: http://localhost:8080

### Database Migrations

```bash
# Add a new migration
cd src/BudgetBridge.Infrastructure
dotnet ef migrations add MigrationName --startup-project ../BudgetBridge.Api

# Apply migrations
dotnet ef database update --startup-project ../BudgetBridge.Api

# Rollback migration
dotnet ef database update PreviousMigrationName --startup-project ../BudgetBridge.Api
```

## Development

### Running Tests

```bash
# Run all tests
dotnet test

# Run specific test project
dotnet test tests/BudgetBridge.Domain.Tests

# Run with coverage
dotnet test --collect:"XPlat Code Coverage"
```

### Code Quality

```bash
# Format code
dotnet format

# Check formatting (CI)
dotnet format --verify-no-changes

# Build with warnings as errors
dotnet build -c Release
```

### Project Structure

```
backend/
├── src/
│   ├── BudgetBridge.Domain/          # Core domain entities
│   ├── BudgetBridge.Application/     # Business logic
│   ├── BudgetBridge.Infrastructure/  # Data access & external services
│   └── BudgetBridge.Api/             # HTTP API endpoints
├── tests/
│   ├── BudgetBridge.Domain.Tests/
│   ├── BudgetBridge.Application.Tests/
│   ├── BudgetBridge.Infrastructure.Tests/
│   └── BudgetBridge.Api.Tests/
├── BudgetBridge.sln                  # Solution file
├── .editorconfig                     # Code style rules
├── Directory.Build.props             # Shared MSBuild properties
└── Directory.Packages.props          # Central package management
```

## API Documentation

Once running, API documentation is available at:
- Swagger UI: http://localhost:8080/swagger (future)
- Health Check: http://localhost:8080/health
- Readiness Probe: http://localhost:8080/health/ready

## Configuration

Configuration sources (in order of precedence):
1. Command-line arguments
2. Environment variables
3. User secrets (`dotnet user-secrets`)
4. `appsettings.{Environment}.json`
5. `appsettings.json`

### Key Configuration Settings

| Setting | Description | Default |
|---------|-------------|---------|
| `ConnectionStrings:DefaultConnection` | PostgreSQL connection string | (required) |
| `ASPNETCORE_ENVIRONMENT` | Environment name (Development/Production) | Development |
| `ASPNETCORE_URLS` | HTTP endpoints | http://+:8080 |
| `Logging:LogLevel:Default` | Default log level | Information |
| `CORS_ORIGINS` | Allowed CORS origins | http://localhost:5173 |

## Troubleshooting

### Database Connection Issues

```bash
# Test PostgreSQL connection
docker exec -it budgetbridge-db psql -U budgetbridge -d budgetbridge

# Check logs
docker logs budgetbridge-db
```

### Port Already in Use

```bash
# Find process using port 8080
lsof -i :8080

# Kill process (macOS/Linux)
kill -9 <PID>
```

### Migration Issues

```bash
# Drop database and recreate
dotnet ef database drop --startup-project src/BudgetBridge.Api
dotnet ef database update --startup-project src/BudgetBridge.Api
```

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) in the repository root for contribution guidelines.

## License

MIT License - see [LICENSE](../LICENSE) for details.
