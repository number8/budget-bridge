
# BudgetBridge – Remaining Task Breakdown (Expanded for AI Coding Agents)

This document contains **all remaining tasks not yet created as GitHub issues**.
Each task is written to be **AI‑agent friendly**, especially on the **frontend**, with
clear interaction flows, layout guidance, UI components, and behavior.

General UI conventions (unless stated otherwise):
- Layout: responsive, desktop‑first
- Design system: shadcn/ui + Tailwind
- Color scheme: neutral base (slate/zinc), primary accent for actions, destructive red only for deletes
- Tables preferred for transactional data, lists for configuration entities
- Primary actions on the top‑right, secondary actions inline

---

# Backend (.NET) Tasks

## [BE] Transaction Normalization Pipeline

### Functional Requirements
- Convert parsed statement rows into canonical `Transaction` records.
- Determine inflow vs outflow automatically.
- Normalize merchant, description, and memo fields.
- Assign currency per row with fallback to account default.
- Reject invalid or incomplete rows gracefully.

### Technical Requirements
- Application-layer service.
- Idempotent per statement.
- EF Core persistence.
- Unit tests for edge cases.

---

## [BE] Transaction Deduplication & Reconciliation

### Functional Requirements
- Detect duplicates across overlapping statements.
- Prevent double imports.
- Allow future manual resolution.

### Technical Requirements
- Composite matching strategy.
- Store deduplication fingerprints.
- Pluggable detection logic.

---

## [BE] Category Domain Model & CRUD APIs

### Functional Requirements
- Users can create, rename, delete categories.
- Categories belong to optional groups.
- Categories are user‑scoped.

### Technical Requirements
- REST endpoints.
- EF entities.
- Ownership enforcement.

---

## [BE] Rule-Based Categorization Engine

### Functional Requirements
- Apply deterministic rules before AI.
- Rules match on description or merchant.
- Priority‑based evaluation.

### Technical Requirements
- Rule engine service.
- Regex support.
- Fully testable.

---

## [BE] Category Feedback Capture

### Functional Requirements
- Capture user category corrections.
- Persist old vs new category.
- Enable learning workflows.

### Technical Requirements
- `CategoryFeedback` entity.
- Triggered from transaction update API.

---

## [BE] AI Client Abstraction

### Functional Requirements
- Unified AI interface for parsing and categorization.
- Support future providers.

### Technical Requirements
- `IAiClient` interface.
- Infrastructure implementations.

---

## [BE] OpenAI Client (BYO Key)

### Functional Requirements
- Enable AI features using user‑provided keys.
- No shared or baked‑in secrets.

### Technical Requirements
- Secure per-user key storage.
- HTTP client with retries and limits.

---

## [BE] Export Profile Domain & APIs

### Functional Requirements
- Users define export targets (YNAB, Monarch, EveryDollar).
- Profiles store mapping preferences.

### Technical Requirements
- ExportProfile entity.
- CRUD endpoints.

---

## [BE] YNAB CSV Exporter

### Functional Requirements
- Export selected transactions as YNAB‑compatible CSV.
- Respect date ranges.

### Technical Requirements
- Implement `IExportFormat`.
- Strict column ordering.

---

## [BE] Monarch CSV Exporter

### Functional Requirements
- Export Monarch‑compatible CSV.

### Technical Requirements
- Independent exporter.
- Unit‑tested output.

---

## [BE] EveryDollar CSV Exporter

### Functional Requirements
- Export transactions for EveryDollar import.
- Support inflow/outflow mapping.

### Technical Requirements
- CSV format per EveryDollar spec.
- Date filtering.

---

## [BE] Background Worker Infrastructure

### Functional Requirements
- Execute long‑running jobs.
- Report progress.

### Technical Requirements
- Hosted service.
- Job abstraction.

---

# Frontend (React) Tasks – Expanded

## [FE] ✅ Frontend Project Scaffold (COMPLETED)

### Implementation Details
The frontend scaffold has been successfully implemented with:

**Technology Stack:**
- React 19.2.0 + TypeScript 5.9.3
- Vite 7.3.1 (build tool)
- TanStack Router 1.120.2 (file-based routing)
- TanStack Query 5.75.5 (server state management)
- Tailwind CSS 4.1.7 (styling)
- shadcn/ui components (ready for installation)
- Lucide React (icons)
- Biome 1.9.4 (formatting/linting)
- Vitest + React Testing Library (testing)

**Project Structure:**
- `/src/routes/` - File-based routing with TanStack Router
- `/src/lib/` - Utility functions
- `/src/styles/` - Global styles with Tailwind
- `/src/__tests__/` - Component tests
- Complete TypeScript configuration with path aliases (`@/*`)
- Docker multi-stage build with Nginx
- Development scripts: dev, build, preview, lint, format, test

**Current Pages:**
- Landing page at `/` with BudgetBridge branding
- Root layout with React Query provider configured

**Next Steps:**
- Install shadcn/ui components as needed
- Implement authentication UI
- Build app shell with navigation

---

## [FE] Authentication UI

### Functional Requirements
- Login and registration forms.
- Email + password inputs.
- Submit button (primary).
- Inline validation errors.
- Loading spinner on submit.

### Layout & UI
- Centered card layout.
- Single column.
- Primary button at bottom.
- Subtle muted background.

### Technical Requirements
- API integration.
- JWT handling.

---

## [FE] App Shell & Navigation

### Functional Requirements
- Persistent top navigation.
- Sidebar or top tabs for:
  - Dashboard
  - Transactions
  - Categories
  - Exports
  - Settings

### Layout & UI
- Desktop: sidebar left.
- Mobile: collapsible drawer.
- Active route highlighting.

### Technical Requirements
- React Router.
- Protected routes.

---

## [FE] Statement Upload & Parsing UI

### Functional Requirements
- Upload CSV/QIF/PDF.
- Show parsing progress.
- Display success or error state.
- Allow retry.

### Layout & UI
- Drag‑and‑drop zone.
- Upload button.
- Status badge.
- Parsed preview table (read‑only).

### Technical Requirements
- File upload API.
- Polling for status.

---

## [FE] Transactions Table & Filters

### Functional Requirements
- Display transactions in table.
- Columns:
  - Date
  - Description
  - Amount
  - Currency
  - Category
  - Confidence
- Inline category editing.
- Filters by date, account, category.

### Layout & UI
- Table with sticky header.
- Filter bar above table.
- Dropdowns and date pickers.
- Color:
  - Outflows red‑tinted
  - Inflows green‑tinted

### Technical Requirements
- Virtualized table.
- Optimistic updates.

---

## [FE] Category & Rule Management UI

### Functional Requirements
- Category list management.
- Rule editor:
  - Match field selector
  - Pattern input
  - Target category selector
- Enable/disable rules.

### Layout & UI
- Two‑column layout:
  - Categories (list)
  - Rules (table)
- Modal dialogs for create/edit.

### Technical Requirements
- Form handling.
- Validation.

---

## [FE] Export Wizard UI

### Functional Requirements
- Select export profile.
- Select date range.
- Select accounts.
- Download CSV.

### Layout & UI
- Step‑based wizard.
- Primary action bottom‑right.
- Summary screen before export.

### Technical Requirements
- Export APIs.
- File download handling.

---

## [FE] Reports & Budgets UI

### Functional Requirements
- Monthly summaries.
- Category breakdown charts.
- Trend comparisons.

### Layout & UI
- Cards with charts.
- Tabs for time ranges.
- Neutral colors with accent highlights.

### Technical Requirements
- Charting library.
- Data aggregation.

---

## Cross‑Cutting

## README – OSS Collaboration Rules

### Functional Requirements
- Explain PR‑based workflow.
- Require issue discussion before large changes.
- Encourage Slack collaboration.
- Define AI‑agent usage expectations.

### Technical Requirements
- Concise.
- Optimized for AI reading.

---

