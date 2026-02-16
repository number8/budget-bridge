<!--
SYNC IMPACT REPORT
==================
Version Change: [TEMPLATE] → 1.0.0
Modified Principles: Initial creation - all principles new
Added Sections: All sections (Core Principles, Technology Standards, Development Workflow, Governance)
Removed Sections: None
Templates Status:
  ✅ plan-template.md - Reviewed, aligns with constitution
  ✅ spec-template.md - Reviewed, user story approach aligns
  ✅ tasks-template.md - Reviewed, phased approach aligns
  ⚠️ commands/*.md - To be reviewed as they are created
Follow-up TODOs: None - all placeholders filled
Rationale: MINOR version bump (1.0.0) - initial constitution establishment for new project
-->

# BudgetBridge Constitution

## Core Principles

### I. Privacy-First & Self-Hosted
**All financial data MUST remain under user control.**

- **Self-hosted by default**: BudgetBridge runs locally or on user-controlled servers; no central SaaS required
- **Local-first data**: All persistent data stored in user's own PostgreSQL instance
- **Transparent AI usage**: Users explicitly configure AI providers; clear documentation of what data is sent to AI services
- **Optional cloud**: Cloud/SaaS deployment is possible but not the primary model
- **No telemetry**: No usage data collection without explicit opt-in

**Rationale**: Financial data is sensitive. Users must trust the tool completely. Self-hosting provides strongest privacy guarantees and aligns with open-source values.

### II. API-First Architecture
**All functionality MUST be accessible via documented REST APIs.**

- **Backend API completeness**: Every feature exposed through REST endpoints before UI implementation
- **OpenAPI documentation**: All endpoints documented with request/response schemas
- **Versioned contracts**: API versioning (v1, v2) with deprecation policy (minimum 2 minor versions notice)
- **JSON protocol**: Standard JSON request/response format with consistent error structures
- **Authentication**: JWT-based authentication for all protected endpoints

**Rationale**: API-first enables testing, automation, third-party integrations, and separates concerns between frontend and backend. Critical for maintainability.

### III. Test-Driven Development (NON-NEGOTIABLE)
**Tests MUST be written before implementation.**

- **TDD workflow**: Write test → Test fails → Implement → Test passes → Refactor
- **No untested code**: PRs without tests for new functionality will be rejected
- **Test types required**:
  - **Unit tests**: All business logic, services, utilities
  - **Integration tests**: API endpoints, database interactions, AI service calls
  - **Component tests**: React components (Frontend)
- **Coverage targets**: Minimum 80% code coverage for backend, 70% for frontend
- **Tests must be runnable**: `pnpm test` (frontend) and `dotnet test` (backend) must work in CI/CD

**Rationale**: TDD catches bugs early, documents behavior, enables confident refactoring, and ensures reliability for financial data.

### IV. Type Safety & Static Analysis
**Leverage type systems to prevent runtime errors.**

- **TypeScript strict mode**: Frontend MUST use TypeScript with `strict: true`
- **C# nullable reference types**: Backend MUST enable nullable reference types
- **No `any` types**: TypeScript `any` requires explicit justification in PR comments
- **Type-safe routing**: TanStack Router provides compile-time route safety
- **Schema validation**: Runtime validation for API boundaries (e.g., FluentValidation in .NET, Zod in TypeScript)
- **Code quality tools**: Biome (frontend), built-in analyzers (backend) enforced in CI

**Rationale**: Financial calculations and data transformations require correctness. Type systems catch entire classes of bugs at compile time.

### V. Incremental Learning & AI Assistance
**System MUST learn from user corrections without compromising privacy.**

- **Pluggable AI**: Support multiple AI providers (OpenAI, local LLMs, etc.) via abstraction layer
- **Deterministic rules first**: Rule-based categorization takes precedence over AI suggestions
- **Feedback loops**: User corrections inform rule suggestions and improve AI prompts (few-shot examples)
- **Confidence scores**: AI suggestions include confidence metrics; user reviews low-confidence items
- **No forced AI**: All AI features optional; system functions without AI provider configured

**Rationale**: AI improves user experience but must not create vendor lock-in or compromise privacy. Deterministic rules provide predictability.

### VI. Extensibility & Pluggability
**New formats, banks, and export targets MUST be addable without core changes.**

- **Parser abstraction**: Statement parsers implement `IStatementParser` interface
- **Export abstraction**: Export formats implement `IExportFormat` interface
- **Provider abstraction**: AI providers implement `IAIProvider` interface
- **Clear extension points**: Documentation shows how to add new parsers/exporters
- **Community contributions**: Lower barrier to adding support for new banks/tools

**Rationale**: BudgetBridge cannot support every bank or budgeting tool out of the box. Extensibility enables community to fill gaps.

### VII. Simplicity & YAGNI (You Aren't Gonna Need It)
**Avoid premature optimization and speculative features.**

- **Start simple**: Implement the simplest solution that solves the immediate problem
- **Prove need first**: New features require clear use case or user request
- **No overengineering**: Avoid complex patterns until complexity is justified
- **Refactor when needed**: Prefer simple code now, refactor to patterns when requirements emerge
- **Delete unused code**: Remove dead code and unused dependencies aggressively

**Rationale**: Complexity is the enemy of maintainability. Financial software must be understandable and auditable.

## Technology Standards

### Frontend Stack (MUST)
- **Framework**: React 19.2+ with TypeScript 5.9+
- **Build tool**: Vite 7.3+
- **Routing**: TanStack Router (file-based, type-safe)
- **State management**: TanStack Query for server state, React hooks for local state
- **Styling**: Tailwind CSS 4.1+ with shadcn/ui components
- **Code quality**: Biome 1.9+ (formatting, linting, import organization)
- **Testing**: Vitest 3.2+ with React Testing Library
- **Package manager**: pnpm

### Backend Stack (MUST)
- **Runtime**: .NET 9+ (ASP.NET Core Web API)
- **Database**: PostgreSQL 16+
- **ORM**: Entity Framework Core (code-first migrations)
- **Architecture**: Clean Architecture (Domain, Application, Infrastructure, API layers)
- **Authentication**: JWT tokens with secure storage
- **Testing**: xUnit with Moq/NSubstitute for mocking

### Deployment (MUST)
- **Containerization**: Docker with multi-stage builds
- **Orchestration**: Docker Compose for local/self-hosted deployments
- **Reverse proxy**: Nginx for serving frontend and routing API requests
- **Environment config**: Environment variables for secrets and configuration (never hardcoded)

### Prohibited (MUST NOT)
- **No hardcoded secrets**: API keys, passwords, connection strings in code
- **No vendor lock-in**: Avoid cloud-specific services that prevent self-hosting
- **No breaking changes**: Within same major version (follow semantic versioning)

## Development Workflow

### Issue & PR Process
1. **Issues first**: Significant changes require issue discussion before PR
2. **Focused PRs**: One PR addresses one issue; small, reviewable changes preferred
3. **Branch naming**: `{issue-number}-brief-description` (e.g., `42-add-pdf-parser`)
4. **Commit messages**: Conventional Commits format (`feat:`, `fix:`, `docs:`, `test:`, `refactor:`)
5. **Tests required**: All PRs with code changes must include/update tests
6. **Documentation updates**: Update relevant docs (README, architecture docs, inline comments)
7. **Review required**: At least one maintainer approval before merge

### Code Review Checklist
- ✅ Tests pass locally and in CI
- ✅ Code coverage meets minimums (80% backend, 70% frontend)
- ✅ Constitution principles followed (privacy, API-first, TDD, type safety, simplicity)
- ✅ Documentation updated (if user-facing changes)
- ✅ No hardcoded secrets or magic numbers
- ✅ Error handling appropriate
- ✅ Performance acceptable (no obvious bottlenecks)
- ✅ Accessibility considered (frontend changes)

### Architecture Decision Records (ADRs)
- **When required**: Major architectural choices (database, framework, deployment model)
- **Format**: Problem, alternatives considered, decision, rationale, consequences
- **Location**: `architecture/` directory or inline in architecture docs
- **Reference**: See `budgetbridge-architecture-decisions-v0.1.md` for examples

### AI Agent Friendliness
- **Task descriptions**: Write issues and tasks in clear, unambiguous language with context
- **Examples provided**: Include examples of expected behavior in specs
- **File paths explicit**: Always specify exact file paths and line ranges when referencing code
- **Acceptance criteria**: Use Given/When/Then format for testable outcomes

## Governance

### Constitutional Authority
- **Supersedes practices**: This constitution takes precedence over individual preferences or local conventions
- **Binding on PRs**: All pull requests must demonstrate compliance with core principles
- **Enforcement**: Maintainers may reject PRs that violate principles, with clear explanation

### Amendment Process
1. **Proposal**: Open GitHub issue with `constitution-amendment` label
2. **Discussion**: Allow minimum 7 days for community input
3. **Approval**: Requires maintainer consensus (all active maintainers agree or majority with no strong objections)
4. **Documentation**: Update constitution with new version, rationale, and sync impact report
5. **Migration**: If amendment affects existing code, create migration plan and timeline
6. **Communication**: Announce changes in discussions and contributing guide

### Version Semantics
- **MAJOR** (X.0.0): Backward-incompatible changes (e.g., removing/redefining core principle)
- **MINOR** (1.X.0): New principles, sections, or material expansions (e.g., new technology standard)
- **PATCH** (1.0.X): Clarifications, wording improvements, typo fixes (no semantic change)

### Compliance Review
- **PR review**: Every PR review includes constitution compliance check
- **Quarterly audit**: Maintainers review codebase for drift from principles
- **Issue triage**: Issues labeled with relevant principles (e.g., `principle: privacy`, `principle: tdd`)
- **Retrospectives**: Team discusses constitution adherence in retrospectives; propose amendments if principles no longer serve project

### Living Document
- **Not dogma**: Principles can evolve with project needs
- **Reasoned exceptions**: Exceptional circumstances may warrant principle exceptions with documented justification
- **Learn and improve**: Failed experiments inform constitution updates

### Related Documentation
- **Architecture**: `architecture/budgetbridge-architecture-v0.1.md` - System design and components
- **Decisions**: `architecture/budgetbridge-architecture-decisions-v0.1.md` - Alternatives considered and rationale
- **Frontend**: `architecture/budgetbridge-frontend-implementation.md` - Frontend details and standards
- **Contributing**: `README.md` (Contributing section) - Workflow and expectations

**Version**: 1.0.0 | **Ratified**: 2026-02-16 | **Last Amended**: 2026-02-16
