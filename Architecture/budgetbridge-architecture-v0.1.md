# BudgetBridge – Architecture Proposal
Version: 0.1 (Draft)

## 1. Overview

**BudgetBridge** is a self‑hosted web application that runs entirely on the user’s own machine or server. It ingests bank and credit card statements, normalizes transactions (including multi‑currency support), uses AI to assist with categorization and insights, and exports data in formats compatible with popular budgeting tools (e.g., YNAB, Monarch).

The system is designed for:

- **Local-first, privacy-focused** operation (all persistent data is stored locally).
- **Incremental learning** from historical data and user corrections.
- **Pluggable AI** (user-provided API keys or local LLM endpoints).
- **Extensibility** (new banks, formats, and budgeting tool exports).

At a high level, BudgetBridge consists of:

- A **React SPA frontend** (with shadcn/ui) for all user interactions.
- A **.NET 9 Web API backend** with JWT authentication and application services.
- A **PostgreSQL database** for all persisted data (users, statements, transactions, rules, etc.).
- Optional **background workers** for heavy or long‑running tasks (bulk parsing, reclassification, reports).

Everything is orchestrated via **Docker Compose** for easy setup and self-hosting.

---

## 2. High-Level Architecture

### 2.1 Logical Components

1. **Frontend (Web UI)**
   - Authentication (JWT-based).
   - Statement upload, parsing workflows, and mapping confirmation.
   - Transaction review, categorization, and corrections.
   - Rules management (e.g., merchant → category).
   - Budget insights and reports (charts, summaries, trends).
   - Export configuration and date‑range export workflows.

2. **Backend (Web API)**
   - JWT authentication and user management.
   - Statement ingestion pipeline (CSV/QIF/PDF).
   - Transaction normalization (including multi‑currency handling).
   - AI orchestration (LLM parsing, categorization, summarization).
   - Export engines (YNAB, Monarch, etc.) with date-range filters.
   - Domain logic for budgets, reports, and historical enrichment.

3. **Data Layer**
   - PostgreSQL database (core transactional storage).
   - Optional pgvector (for semantic search / embeddings in later versions).
   - Strong separation between domain entities and persistence models.

4. **Background Processing (optional, v1-ready)**
   - Runs long‑running or heavy tasks:
     - Bulk parsing of large PDFs/CSVs.
     - Bulk categorization / re-categorization.
     - Monthly report generation.

5. **AI Provider Layer**
   - Pluggable client interface (e.g., OpenAI, local LLM endpoints).
   - Responsible for LLM-based parsing of unstructured statements (PDF/complex CSV) and categorization assistance.

---

## 3. Deployment & Runtime Topology

### 3.1 Runtime Topology

For a standard self‑hosted deployment (local machine or single server):

```text
Browser (React SPA)
  → Nginx reverse proxy
      → /          → Frontend static files (built React bundle)
      → /api/*     → ASP.NET Core Web API
          → PostgreSQL database
          → External AI APIs (OpenAI, local LLM endpoint, etc.)
```

### 3.2 Docker Compose

The application is delivered as a multi‑container setup using Docker Compose, with the following services:

- `db` – PostgreSQL database
- `api` – .NET 9 Web API (Kestrel)
- `web` – Built React frontend (served via lightweight web server, e.g. Nginx)
- `proxy` – Nginx reverse proxy exposing a single HTTP(S) entrypoint

Example (simplified) service list:

- **db:** `postgres:16`
- **api:** `budgetbridge-api` (built from `backend/Dockerfile`)
- **web:** `budgetbridge-web` (built from `frontend/Dockerfile`)
- **proxy:** `nginx:alpine` with routing:
  - `/` → `web`
  - `/api` → `api`

Users run:

```bash
docker compose up -d
```

and then access the app at `http://localhost:8080` (or configured host/port).

---

## 4. Backend Architecture (.NET)

### 4.1 Technology Stack

- **Runtime:** .NET 9
- **Framework:** ASP.NET Core Web API
- **Architecture style:** Clean Architecture / Hexagonal

Proposed project structure:

```text
backend/
  src/
    BudgetBridge.Api
    BudgetBridge.Application
    BudgetBridge.Domain
    BudgetBridge.Infrastructure
  tests/
    BudgetBridge.Api.Tests
    BudgetBridge.Application.Tests
    BudgetBridge.Domain.Tests
    BudgetBridge.Infrastructure.Tests
```

### 4.2 Authentication & Authorization

- **Auth mechanism:** JWT-based authentication
  - Users authenticate with username/password.
  - API returns a JWT used for subsequent requests.
  - Token includes user ID and minimal claims.
- No external identity providers are required (no Google/OIDC/etc.).
- Simple role model initially:
  - `User` (default, single-tenant scenario).
  - `Admin` (optional, for multi-user instances).

### 4.3 Persistence & Database

- **Database:** PostgreSQL
- **ORM:** EF Core (code‑first migrations)
- Connection string provided via environment variables & Docker Compose.

#### Schema (high-level, first pass)

Core entities and relationships (simplified):

- `User`
  - `Id`, email, password hash, created/updated timestamps
- `BankAccount`
  - `Id`, `UserId`, name/alias, institution name, account type, default currency
- `Statement`
  - `Id`, `UserId`, `BankAccountId`, source file metadata, format (CSV/QIF/PDF), import date, parsing status
- `Transaction`
  - `Id`, `UserId`, `BankAccountId`, `StatementId`
  - Date, description, merchant
  - Amount (decimal), Currency (ISO code), Direction (inflow/outflow)
  - Normalized fields (e.g., payee, memo)
  - `CategoryId` (nullable for uncategorized)
  - AI metadata: confidence score, classification source (Rule/AI/Manual)
- `Category`
  - `Id`, `UserId`, name, group (e.g., “Housing”, “Food”), notes
- `CategoryRule`
  - `Id`, `UserId`, pattern type (contains, regex, equals, etc.), field (description/merchant/etc.), pattern value
  - Target `CategoryId`, priority, enabled flag
- `CategoryFeedback`
  - `Id`, `UserId`, `TransactionId`, old category, new category, timestamp
- `ExportProfile`
  - `Id`, `UserId`, target tool (YNAB, Monarch, etc.), format type (CSV, API).
  - Field mapping settings, default date range behavior (e.g., current month).
- `BudgetProfile`
  - `Id`, `UserId`, name, effective date range
  - Category targets per month (stored in a related table)
- `Report`
  - `Id`, `UserId`, type (monthly summary, annual summary, etc.), period (year/month),
  - Generated timestamp, JSON snapshot payload.

Later versions can add:

- Embeddings / semantic hints stored via pgvector tables.
- Audit/change logs for transaction category changes if needed.

### 4.4 Application Layer

The `Application` project contains use‑case services (application services) and DTOs, such as:

- `StatementIngestionService`
- `TransactionService`
- `CategoryService`
- `ExportService`
- `BudgetService`
- `ReportService`
- `AiOrchestrationService`

Each service exposes methods that are used by controllers in `Api`, but never directly by UI.

### 4.5 Multi-Currency Handling

Transactions may exist in multiple currencies, even within a single statement file. The system will:

- Store **amounts and currency code per transaction** (e.g., `Amount=100.00`, `Currency=USD`).
- Maintain a **default currency per bank account** for reporting purposes.
- For analytical views (budgets, reports):
  - Optionally convert amounts to a reporting currency using:
    - Static or user-provided exchange rates, or
    - A pluggable FX rate provider (added later).
- Parsing pipeline for CSV/PDF will leverage LLM and heuristics to detect:
  - Per-row currency, based on columns, symbols, or text patterns.
  - Mixed currency scenarios (e.g., EUR and USD in a single file).

### 4.6 Statement Ingestion & Parsing

**Supported formats:**

- Structured: CSV, QIF
- Semi/Unstructured: PDF, “messy” CSVs

**Pipeline (simplified):**

1. **Upload**
   - User uploads a file to `/api/statements/upload`.
   - Backend stores file temporarily and creates a `Statement` record with status `PendingParsing`.

2. **Format Detection**
   - Based on file extension and lightweight sniffing -> CSV/QIF/PDF detection.
   - For CSV: detect delimiters, headers, and common column names.

3. **Parsing**
   - **QIF/structured CSV:**
     - Deterministic parser extracts rows, dates, amounts, currencies (if present), descriptions.
   - **Complex CSV/PDF:**
     - Use a combination of:
       - Rule-based extraction (e.g., text layout, regex patterns).
       - LLM-assisted parsing:
         - Extract raw text/rows.
         - Prompt an LLM to map them into a structured JSON schema, including:
           - `date`, `description`, `amount`, `currency`, `balance` (if present).
         - Validate and sanitize parsed data (e.g., column mapping confirmation).
         - When using LLM-assisted parsing, consider using the LLM to extract only the regular expressions that I can use to extract the direct data. I do not want to trust actual money data from the LLM. I want the LLM to assist in the extraction of the money data from the file.

4. **Normalization**
   - Map raw fields into internal transaction schema.
   - Resolve currencies per row, defaulting to account currency when ambiguous.
   - Deduplicate transactions (e.g., overlapping statements) using:
     - Composite keys (date, amount, description, account) with fuzzy matching as needed.

5. **Classification**
   - Immediately attempt initial category assignment:
     - Apply deterministic `CategoryRule`s first.
     - Use AI-based categorization for transactions without clear rule-based classification.
   - Store AI confidence and mark uncertain cases for UI review.

6. **Persistence**
   - Store normalized `Transaction` records linked to `Statement` and `BankAccount`.

### 4.7 Export Engine & Date-Range Support

The export engine allows exporting subsets of transactions to external tools (e.g., YNAB, Monarch) while the full history remains in BudgetBridge.

**Key principles:**

- A **single, continuously growing transaction history** per user in BudgetBridge.
- **Exports are always date‑range based**, e.g.:
  - “Export all uncategorized transactions from last month.”
  - “Export all transactions between 2025‑01‑01 and 2025‑01‑31 for account X.”
- **Export profiles** define target tool and mapping rules; the user chooses:
  - Date range (from/to).
  - Accounts (single or multiple).
  - Whether to mark exported transactions as “exported” for future filtering.

**Integration model:**

- Phase 1:
  - Only **file-based exports**:
    - `YNAB CSV` format.
    - `Monarch CSV` format.
  - User downloads file and imports it into external tools manually.
- Phase 2:
  - Optional API-based integrations (YNAB API, etc.) with user-provided authorization tokens, stored encrypted.

### 4.8 AI & LLM Integration

The backend exposes a pluggable AI interface:

```csharp
public interface IAiClient
{
    Task<ParsedStatementResult> ParseUnstructuredStatementAsync(StatementAiRequest request);
    Task<IReadOnlyList<TransactionCategorySuggestion>> SuggestCategoriesAsync(CategorySuggestionRequest request);
    Task<SpendingSummary> SummarizeSpendingAsync(SpendingSummaryRequest request);
    Task<BudgetSuggestion> SuggestBudgetAsync(BudgetSuggestionRequest request);
    Task<ChatResponse> ChatBudgetAssistantAsync(ChatRequest request);
}
```

Implementations (in `Infrastructure`):

- `OpenAiClient` (calling OpenAI models via HTTPS).
- Future: `LocalLlmClient` (e.g., Ollama, LM Studio HTTP endpoints).

**AI responsibilities:**

- Parsing unstructured/mixed-format statements (especially PDF and irregular CSV) into structured transactions, including per-row currency.
- Suggesting transaction categories based on:
  - Description, merchant, historical categorized transactions.
- Summarizing spending patterns and trends.
- Suggesting budgets and savings buckets.
- Providing a natural-language assistant for planning and “what‑if” questions.

User-provided API keys and provider selection are stored per user in a secure fashion and never shared between users.

### 4.9 Learning from User Corrections

When users correct categories in the UI:

- A `CategoryFeedback` entry is recorded.
- The system may:
  - Propose new or updated deterministic rules (e.g., “Merchant contains UBER → Transportation > Rideshare”).
  - Use feedback as additional training examples for AI prompts (few-shot examples).
- Periodic or on-demand reclassification:
  - Re-run categorization on transactions with low confidence using updated rules + history.

---

## 5. Frontend Architecture (React + shadcn/ui)

### 5.1 Technology Stack

- **React 18 + TypeScript**
- **Build tool:** Vite
- **Routing:** React Router
- **Server state:** TanStack Query
- **Design system:** shadcn/ui (Radix UI primitives + Tailwind)
- **Styling:** Tailwind CSS

### 5.2 Key UI Modules

1. **Authentication**
   - Login / registration pages (JWT issued by backend).
   - Persist JWT in memory + secure storage strategies (e.g., httpOnly cookie or secure storage pattern depending on deployment).

2. **Dashboard**
   - High-level overview of:
     - Recent imports, categorization status.
     - Key metrics (total spending, top categories).
     - Action shortcuts (e.g., “Review uncategorized transactions”).

3. **Statement Upload & Parsing**
   - File upload UI (CSV/QIF/PDF).
   - Visual indicators for parsing status.
   - For ambiguous mappings, a “column mapping confirmation” step.
   - Preview and confirmation of parsed transactions before final import (optional configuration).

4. **Transactions View**
   - Filterable, sortable table of transactions:
     - Filters: account, date range, category, currency, amount, export status.
   - Category assignment/changing inline (e.g., select dropdown or quick-pick chips).
   - Confidence indicators for AI-suggested categories.

5. **Category & Rule Management**
   - Category list and group management.
   - Rule editor:
     - If description contains/regex/etc. → apply category.
   - Suggested rules based on frequent user corrections.

6. **Exports**
   - Export wizard:
     - Select export profile (YNAB, Monarch, etc.).
     - Choose date range.
     - Choose account(s).
     - Option to mark included transactions as “exported”.
   - Download file (CSV) ready for import.

7. **Reports & Budgets**
   - Monthly and custom-period summaries.
   - Charts for category spending, trends, comparisons (e.g., month over month).
   - Smart budget suggestions (generated by AI) with ability to accept/modify.

8. **Settings**
   - User profile.
   - AI provider configuration (OpenAI/local LLM):
     - API base URL, model, API key.
   - Currency preferences & default reporting currency.
   - Advanced options (e.g., whether to store raw statements).

---

## 6. Security & Privacy Considerations

- **Local-first / self-hosted:** All data is stored in the user’s own database instance under their control.
- **JWT-based auth:** Ensures API access is limited to authenticated users; JWT lifetime and refresh policies configurable.
- **Transport security:** Deployments should use HTTPS via reverse proxy (TLS termination in Nginx or similar) for remote/server installs.
- **AI usage transparency:**
  - Clear configuration for enabling/disabling AI features.
  - Explicit messaging that transaction text may be sent to the chosen AI provider when enabled.
- **Data minimization (configurable):**
  - Option to delete raw statement files after successful parsing.
  - Option to only keep normalized transaction data.

---

## 7. Extensibility & OSS Friendliness

The architecture is designed to allow contributors to work on isolated areas:

- **New formats:** Add additional parsers for specific banks/CSV layouts/PDF templates.
- **New export targets:** Implement new `IExportFormat` handlers and frontend export profiles.
- **New AI providers:** Implement additional `IAiClient` backends.
- **Background tasks:** Add workers for more advanced analytics or scheduled jobs (e.g., monthly rollups).

The clear separation between `Domain`, `Application`, `Infrastructure`, and `Api` projects helps keep contributions focused and testable.

---

## 8. Summary

This architecture:

- Uses a familiar and modern stack: **React + shadcn/ui** on the frontend, **.NET 9 Web API + PostgreSQL** on the backend.
- Fully supports **local history**, **multi‑account**, and **multi‑currency** transaction management.
- Provides **date‑range controlled exports** so users can export months or custom periods while still keeping a full internal history.
- Leverages AI for parsing and categorization via a pluggable provider layer, with user-owned API keys and clear privacy boundaries.
- Ships as a **single Docker Compose bundle** to simplify self‑hosting and experimentation, while remaining friendly to standard local development workflows.
