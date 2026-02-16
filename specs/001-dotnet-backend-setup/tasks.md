# Tasks: .NET Backend Development Environment Setup

**Input**: Design documents from `/specs/001-dotnet-backend-setup/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/health-api.yaml

**Tests**: NOT requested in specification - test tasks omitted per requirements

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

This is a web application with separate backend and frontend:
- Backend: `backend/src/`, `backend/tests/`
- Frontend: `frontend/` (already exists)
- Root orchestration: Repository root for Docker Compose and startup scripts

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [X] T001 Create backend directory structure per plan.md (Domain, Application, Infrastructure, Api layers)
- [X] T002 Create backend/BudgetBridge.sln solution file
- [X] T003 Create backend/src/BudgetBridge.Domain/BudgetBridge.Domain.csproj project with no external dependencies
- [X] T004 Create backend/src/BudgetBridge.Application/BudgetBridge.Application.csproj project with reference to Domain
- [X] T005 Create backend/src/BudgetBridge.Infrastructure/BudgetBridge.Infrastructure.csproj project with EF Core 9.0+ and references to Domain and Application
- [X] T006 Create backend/src/BudgetBridge.Api/BudgetBridge.Api.csproj project with ASP.NET Core 9.0, FluentValidation, and references to Application and Infrastructure
- [X] T007 [P] Create backend/tests/BudgetBridge.Domain.Tests/BudgetBridge.Domain.Tests.csproj with xUnit and Moq
- [X] T008 [P] Create backend/tests/BudgetBridge.Application.Tests/BudgetBridge.Application.Tests.csproj with xUnit and Moq
- [X] T009 [P] Create backend/tests/BudgetBridge.Infrastructure.Tests/BudgetBridge.Infrastructure.Tests.csproj with xUnit, Moq, and Testcontainers
- [X] T010 [P] Create backend/tests/BudgetBridge.Api.Tests/BudgetBridge.Api.Tests.csproj with xUnit and Microsoft.AspNetCore.Mvc.Testing
- [X] T011 [P] Create backend/.editorconfig with C# formatting rules and nullable reference types enabled
- [X] T012 [P] Create backend/Directory.Build.props with TreatWarningsAsErrors=true and common MSBuild properties
- [X] T013 [P] Create backend/Directory.Packages.props for central package management
- [X] T014 [P] Create backend/.env.example template file with DB_PASSWORD and ASPNETCORE_ENVIRONMENT variables
- [X] T015 [P] Create backend/README.md explaining Clean Architecture layers and navigation guide

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T016 Create backend/src/BudgetBridge.Domain/Entities/.gitkeep placeholder
- [X] T017 Create backend/src/BudgetBridge.Domain/Interfaces/IRepository.cs generic repository interface
- [X] T018 Create backend/src/BudgetBridge.Application/Common/.gitkeep placeholder
- [X] T019 Create backend/src/BudgetBridge.Application/DTOs/.gitkeep placeholder
- [X] T020 Create backend/src/BudgetBridge.Application/Services/.gitkeep placeholder
- [X] T021 Create backend/src/BudgetBridge.Infrastructure/Persistence/ApplicationDbContext.cs with DbContext base setup
- [X] T022 Create backend/src/BudgetBridge.Infrastructure/Persistence/Migrations/.gitkeep placeholder
- [X] T023 Create backend/src/BudgetBridge.Infrastructure/Persistence/Configurations/.gitkeep placeholder
- [X] T024 Create backend/src/BudgetBridge.Infrastructure/Configuration/DependencyInjection.cs for service registration
- [X] T025 Create backend/src/BudgetBridge.Api/Program.cs with minimal ASP.NET Core setup and DI registration
- [X] T026 Create backend/src/BudgetBridge.Api/appsettings.json with logging and Kestrel configuration
- [X] T027 Create backend/src/BudgetBridge.Api/appsettings.Development.json with development-specific settings
- [X] T028 Create backend/src/BudgetBridge.Api/Middleware/.gitkeep placeholder for future error handling middleware
- [X] T029 Create backend/Dockerfile with multi-stage build (SDK 9.0 for build, aspnet 9.0 for runtime)
- [X] T030 Create docker-compose.yml at repository root with PostgreSQL 16 service and backend service using profiles
- [X] T031 Create docker-compose.dev.yml at repository root with development overrides for hot reload
- [X] T032 Add frontend service to docker-compose.yml with profile configuration and backend dependency
- [X] T033 Create .env.example at repository root with DB_PASSWORD, POSTGRES_USER, POSTGRES_DB variables
- [X] T034 Create scripts/setup.sh for initializing .NET user secrets, .env file, and running pnpm install
- [X] T035 Create scripts/db-init.sh for database initialization with secrets management
- [X] T036 [P] Create .vscode/tasks.json with VS Code tasks for setup.sh and db-init.sh scripts

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Initial Backend Project Setup (Priority: P1) 🎯 MVP

**Goal**: Enable developers to clone the repository and run a single command to get the backend environment running locally with a health check endpoint responding successfully.

**Independent Test**: Clone repository on fresh machine with prerequisites installed, run documented startup command (scripts/start.sh local), verify backend responds to GET /health with 200 status and valid JSON containing status, version, and timestamp fields.

### Implementation for User Story 1

- [X] T037 [P] [US1] Create backend/src/BudgetBridge.Domain/Entities/Budget.cs placeholder entity with factory method pattern per data-model.md
- [X] T038 [P] [US1] Create backend/src/BudgetBridge.Domain/Interfaces/IBudgetRepository.cs with CRUD method signatures
- [X] T039 [US1] Create backend/src/BudgetBridge.Infrastructure/Persistence/Configurations/BudgetConfiguration.cs with EF Core entity configuration
- [X] T040 [US1] Update backend/src/BudgetBridge.Infrastructure/Persistence/ApplicationDbContext.cs to include Budget DbSet
- [X] T041 [US1] Create backend/src/BudgetBridge.Infrastructure/Persistence/Repositories/BudgetRepository.cs implementing IBudgetRepository
- [X] T042 [US1] Update backend/src/BudgetBridge.Infrastructure/Configuration/DependencyInjection.cs to register BudgetRepository
- [X] T043 [US1] Create backend/src/BudgetBridge.Api/Controllers/HealthController.cs with GET /health endpoint per contracts/health-api.yaml
- [X] T044 [US1] Create backend/src/BudgetBridge.Api/Controllers/HealthController.cs with GET /health/ready endpoint checking database connectivity
- [X] T045 [US1] Add HealthResponse and ReadinessResponse models in backend/src/BudgetBridge.Api/Models/HealthResponse.cs
- [X] T046 [US1] Update backend/src/BudgetBridge.Api/Program.cs to configure CORS for frontend origin (http://localhost:3000)
- [X] T047 [US1] Update backend/src/BudgetBridge.Api/Program.cs to enable hot reload with dotnet watch configuration
- [X] T048 [US1] Create initial EF Core migration in backend/src/BudgetBridge.Infrastructure/Persistence/Migrations/ for Budget entity
- [ ] T049 [US1] Test health endpoints return correct responses and status codes per contracts/health-api.yaml specification

**Checkpoint**: At this point, User Story 1 should be fully functional - backend starts and health endpoints respond correctly

---

## Phase 4: User Story 2 - Unified Startup Experience (Priority: P2)

**Goal**: Provide a single command that starts both frontend and backend services together so developers can test end-to-end functionality without managing multiple terminals.

**Independent Test**: Run unified startup command (scripts/start.sh) from repository root, verify both frontend (http://localhost:3000) and backend (http://localhost:5000/health) are accessible, verify frontend can make successful API calls to backend without CORS errors, stop command gracefully shuts down both services.

### Implementation for User Story 2

- [X] T050 [US2] Create scripts/start.sh with mode argument parsing (--mode=full|backend|frontend|local with default=local)
- [X] T051 [US2] Implement scripts/start.sh local mode to start PostgreSQL container, run backend via dotnet watch, run frontend via pnpm dev
- [X] T052 [US2] Implement scripts/start.sh full mode to run docker compose --profile full up
- [X] T053 [US2] Implement scripts/start.sh backend mode to run docker compose --profile backend-only up
- [X] T054 [US2] Implement scripts/start.sh frontend mode to start PostgreSQL and backend containers, with instructions to manually start frontend
- [X] T055 [US2] Add prerequisite checks to scripts/start.sh for .NET SDK, Docker, Docker Compose, and pnpm with version validation
- [X] T056 [US2] Add port conflict detection to scripts/start.sh for ports 3000, 5000, 5432 with clear error messages
- [X] T057 [US2] Create scripts/stop.sh to gracefully shut down all services based on current run mode
- [X] T058 [US2] Update scripts/setup.sh to validate all prerequisites and provide actionable error messages
- [X] T059 [US2] Update .vscode/tasks.json to add VS Code tasks for start.sh (all modes) and stop.sh scripts
- [ ] T060 [US2] Update backend/README.md with instructions for each run mode and when to use them
- [ ] T061 [US2] Test that scripts/start.sh local starts both services and CORS allows frontend-to-backend communication
- [ ] T062 [US2] Test that Ctrl+C or scripts/stop.sh gracefully stops all services without orphaned processes

**Checkpoint**: At this point, User Stories 1 AND 2 should both work - single command starts full development environment

---

## Phase 5: User Story 3 - Contributing to the Project (Priority: P3)

**Goal**: Provide clear documentation so open-source contributors can confidently submit changes and participate in discussions that align with project standards.

**Independent Test**: Review documentation as new contributor, successfully submit sample pull request following documented guidelines, verify automated checks provide immediate feedback, create GitHub issue using templates with appropriate context fields.

### Implementation for User Story 3

- [ ] T063 [P] [US3] Create CONTRIBUTING.md at repository root with branch naming conventions (feature/*, bugfix/*, docs/*)
- [ ] T064 [P] [US3] Add commit message format guidelines to CONTRIBUTING.md (conventional commits: feat:, fix:, docs:, etc.)
- [ ] T065 [P] [US3] Add pull request process to CONTRIBUTING.md including required reviewers and merge criteria
- [ ] T066 [P] [US3] Create .github/PULL_REQUEST_TEMPLATE.md with sections for description, testing, checklist
- [ ] T067 [P] [US3] Create .github/ISSUE_TEMPLATE/bug_report.md with environment, reproduction steps, expected/actual behavior
- [ ] T068 [P] [US3] Create .github/ISSUE_TEMPLATE/feature_request.md with problem statement, proposed solution, alternatives
- [ ] T069 [P] [US3] Create .github/workflows/backend-ci.yml to build, lint, and test backend on pull requests
- [ ] T070 [P] [US3] Configure backend-ci.yml to run dotnet format --verify-no-changes for code style enforcement
- [ ] T071 [P] [US3] Configure backend-ci.yml to build Docker image and push to ghcr.io/mmorales/budget-bridge/backend
- [ ] T072 [P] [US3] Update frontend CI workflow at .github/workflows/frontend-ci.yml to push to ghcr.io/mmorales/budget-bridge/frontend
- [ ] T073 [US3] Add code style and linting checks section to CONTRIBUTING.md with dotnet format usage
- [ ] T074 [US3] Test that pull request triggers CI workflow and provides feedback on build, format, and test results

**Checkpoint**: All user stories should now be independently functional - full development workflow with contribution guidelines

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories and final validation

- [ ] T075 [P] Create backend/src/BudgetBridge.Application/DTOs/CreateBudgetDto.cs and BudgetResponseDto.cs per data-model.md
- [ ] T076 [P] Add XML documentation comments to all public APIs in backend/src/BudgetBridge.Api/Controllers/
- [ ] T077 [P] Add XML documentation comments to all domain entities in backend/src/BudgetBridge.Domain/Entities/
- [ ] T078 Update root README.md with quick start instructions referencing scripts/start.sh
- [ ] T079 Update root README.md with architecture overview and links to backend/README.md and frontend/README.md
- [ ] T080 [P] Add environment variable validation on backend startup with clear error messages for missing required values
- [ ] T081 [P] Add structured logging configuration in backend/src/BudgetBridge.Api/appsettings.json
- [ ] T082 Validate quickstart.md scenarios can be executed successfully (setup, start, health check, stop)
- [ ] T083 Verify solution builds with zero warnings using TreatWarningsAsErrors=true
- [ ] T084 Run dotnet format across entire solution to ensure consistent code style
- [ ] T085 Verify backend can be stopped and restarted 10 consecutive times without errors or port conflicts

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-5)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Phase 6)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - Requires US1 backend to exist for unified startup, but can be independently tested
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - No dependencies on other stories (documentation only)

### Within Each User Story

**User Story 1 (Initial Backend Project Setup)**:
1. Entity and repository interface can be created in parallel (T037, T038)
2. EF Core configuration and DbContext updates follow entities (T039, T040)
3. Repository implementation follows interfaces (T041, T042)
4. Health controller and models can be created in parallel (T043, T044, T045)
5. Program.cs updates for CORS and hot reload (T046, T047)
6. Migration and testing are final steps (T048, T049)

**User Story 2 (Unified Startup)**:
1. Core start.sh script with mode parsing (T050)
2. Each mode implementation can proceed in parallel (T051-T054)
3. Prerequisite checks and port detection (T055, T056)
4. Stop script and setup validation (T057, T058)
5. VS Code tasks configuration (T059)
6. Documentation and testing (T060-T062)

**User Story 3 (Contributing)**:
1. All contribution docs can be created in parallel (T063-T068)
2. CI workflows can be created in parallel (T069-T072)
3. Final documentation update and testing (T073-T074)

### Parallel Opportunities

- **Phase 1 (Setup)**: T007-T010 (test projects), T011-T015 (configuration files) can all run in parallel
- **Phase 2 (Foundational)**: T016-T023 (layer placeholders) can run in parallel, T026-T028 (API config) can run in parallel, T036 (VS Code tasks) can run in parallel with other config
- **User Story 1**: T037-T038 can run in parallel (entity and interface), T043-T045 can run in parallel (controllers and models)
- **User Story 2**: T051-T054 can run in parallel (mode implementations), T055-T056 can run in parallel (checks)
- **User Story 3**: T063-T068 can run in parallel (all documentation), T069-T072 can run in parallel (all CI workflows)
- **Phase 6 (Polish)**: T075-T077 can run in parallel (DTOs and docs), T080-T081 can run in parallel (validation and logging)

---

## Parallel Example: User Story 1

```bash
# Launch entity and interface creation together:
Developer A: "Create backend/src/BudgetBridge.Domain/Entities/Budget.cs" (T037)
Developer B: "Create backend/src/BudgetBridge.Domain/Interfaces/IBudgetRepository.cs" (T038)

# Launch controller and models together:
Developer A: "Create HealthController.cs with GET /health endpoint" (T043)
Developer B: "Create HealthController.cs with GET /health/ready endpoint" (T044)
Developer C: "Add HealthResponse and ReadinessResponse models" (T045)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T015) - ~2 hours
2. Complete Phase 2: Foundational (T016-T036) - ~3-4 hours (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (T037-T049) - ~4-5 hours
4. **STOP and VALIDATE**: Test User Story 1 independently
   - Run scripts/setup.sh
   - Run backend with dotnet run
   - Verify GET /health returns 200
   - Verify GET /health/ready checks database
5. Deploy/demo if ready - **HAVE A WORKING BACKEND** ✅

### Incremental Delivery

1. Complete Setup + Foundational (T001-T036) → Foundation ready (~5-6 hours)
2. Add User Story 1 (T037-T049) → Test independently → Deploy/Demo (MVP! ~4-5 hours)
   - **Value delivered**: Developers can start backend work
3. Add User Story 2 (T050-T062) → Test independently → Deploy/Demo (~3-4 hours)
   - **Value delivered**: Full-stack development workflow enabled
4. Add User Story 3 (T063-T074) → Test independently → Deploy/Demo (~2-3 hours)
   - **Value delivered**: Open-source collaboration enabled
5. Complete Phase 6: Polish (T075-T085) → Final validation (~2-3 hours)
6. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together (T001-T036)
2. Once Foundational is done:
   - Developer Team A: User Story 1 (T037-T049) - Backend health endpoints
   - Developer Team B: User Story 3 (T063-T074) - Contribution guidelines (no code dependencies)
   - Developer Team C: Prepare User Story 2 scripts structure (can start T050, T057, T058)
3. After User Story 1 completes:
   - Developer Team B moves to User Story 2 completion (T051-T062)
4. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies, can run in parallel
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Tests NOT included per spec (no TDD requirement in functional requirements)
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Total estimated effort: ~20-25 hours for full implementation
- MVP (Setup + Foundational + US1): ~10-12 hours
- Path format: backend/src/BudgetBridge.Api/... (web app structure per plan.md)
- VS Code tasks allow running scripts directly from Tasks menu (Run Task command)
