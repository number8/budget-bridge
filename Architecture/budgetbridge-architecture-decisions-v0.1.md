# BudgetBridge – Architectural Alternatives & Decisions
Version: 0.1 (Draft)

This document captures **key architectural alternatives considered (or implicitly possible) and why they were not chosen** for the initial version of BudgetBridge. It’s meant to serve as context for architectural discussions and future revisits, not as a permanent rejection of these options.

---

## 1. Application Form Factor

### 1.1 Desktop Electron App (Electron + React + Local .NET API)

**Alternative:**  
Package BudgetBridge as a desktop application using Electron, with a React UI running in a Chromium shell and a local .NET API process running behind it.

**Why it was attractive:**
- Strong “local-only” privacy story.
- Familiar frontend stack (React) with desktop distribution.
- Easy access to local filesystem and OS features.

**Why we did not choose it for v1:**
- **No real privacy gain vs local web app:**  
  We still need a local .NET backend process and a local DB regardless. Running everything via a browser connecting to `localhost` provides essentially the same privacy properties, without Electron’s additional complexity.
- **Heavier distribution & maintenance:**  
  Electron bundles Chromium, leading to larger binaries and more complex build pipelines for Windows/macOS/Linux packaging.
- **Dev & contributor friction:**  
  Many contributors are more familiar with a standard web stack + Docker than with Electron’s multi-process model (main vs renderer vs preload). Keeping the backend as a normal web API lowers the learning curve.
- **Unclear added value for our use case:**  
  We don’t need deep OS integrations (system tray, global shortcuts, offline-first beyond what a local web app already provides).

**Decision:**  
Use a **standard web app** (React SPA + .NET Web API + DB) running locally or on a self-hosted server, avoiding Electron for v1.

---

### 1.2 Native Desktop UI (WPF / WinUI / Avalonia) + Embedded WebView

**Alternative:**  
Use a .NET UI framework (WPF, WinUI, or Avalonia) for a native desktop shell and embed the React UI within a WebView, or build the UI entirely in XAML.

**Why it was attractive:**
- Rich native desktop experience, especially on Windows.
- Potentially lighter than Electron.
- Single tech stack (all .NET) if we forgo React.

**Why we did not choose it for v1:**
- **Cross-platform cost:**  
  WPF/WinUI are predominantly Windows-focused. Avalonia is cross-platform, but adds its own layer of complexity and a new UI paradigm for contributors.
- **Community familiarity:**  
  React + web is vastly more familiar to a broad open-source contributor base than any specific .NET desktop UI framework.
- **Scope creep:**  
  Introducing a completely different UI stack (XAML-based) would complicate the architecture and docs. The React SPA approach is simpler and more portable.

**Decision:**  
Standardize on **React SPA** for UI and **.NET Web API** for backend, keeping the entire UI in the web space.

---

## 2. Hosting & Deployment Model

### 2.1 Pure Cloud SaaS (Multi-tenant, Hosted by Us)

**Alternative:**  
Host BudgetBridge as a multi-tenant SaaS platform (e.g., on a cloud provider), with all user data stored in our managed cloud DB and users accessing it through the public internet.

**Why it was attractive:**
- Easier onboarding (no need for users to run Docker).
- Centralized updates and operations.
- Potential business model if commercialized later.

**Why we did not choose it for v1:**
- **Privacy and trust concerns:**  
  Core use case involves sensitive financial data. Users are more likely to trust a tool they can run locally/on their own server, where they control the data.
- **Compliance burden:**  
  Cloud-hosted multi-tenant finance-related data brings questions of GDPR/PCI/PII, which would significantly raise the bar for initial release.
- **Open source alignment:**  
  A self-hosted architecture aligns better with an open-source project where users/organizations can run their own instance without sending data to a central operator.

**Decision:**  
Design BudgetBridge as **self-hosted by default** (local or personal server via Docker Compose). SaaS can be revisited later, but is not the primary deployment model.

---

### 2.2 Serverless / FaaS Backend (e.g., Azure Functions, AWS Lambda)

**Alternative:**  
Use a serverless backend architecture, with stateless HTTP functions and a managed database, instead of a long-running web API service.

**Why it was attractive:**
- Automatic scaling and potentially lower operational overhead for a hosted version.
- Fine-grained deployment of functions.

**Why we did not choose it for v1:**
- **Poor fit for self-hosting:**  
  Self-hosting serverless environments is complex and not as straightforward as running a containerized web API.
- **Unnecessary complexity for local setups:**  
  For a local-only or single-server deployment, a traditional web API process is simpler and more predictable.
- **Stateful workflows:**  
  We need long-running processes (parsing large PDFs, reclassification batches) and tight integration with local jobs. These are more naturally modeled with a standard web API + optional background workers.

**Decision:**  
Use a **traditional ASP.NET Core Web API** service with optional background workers, rather than a serverless/FaaS design.

---

## 3. Backend & Data Store Alternatives

### 3.1 SQLite as Primary Database

**Alternative:**  
Use SQLite as the primary database for BudgetBridge, storing everything in a single local file.

**Why it was attractive:**
- Extremely simple for local usage.
- No separate DB service to manage.
- Portable & easy to back up (single file).

**Why we did not choose it as the main DB for v1:**
- **Future feature needs:**  
  We anticipate potential use of **pgvector** or similar capabilities for semantic search / embeddings. PostgreSQL has mature support for this.
- **Multi-user / server deployment:**  
  While SQLite can be used on a server, PostgreSQL is more robust for concurrent/multi-user access if some deployments choose to run it multi-user.
- **Extensibility:**  
  PostgreSQL offers richer SQL and indexing features that are likely to be useful as the project grows.

**Decision:**  
Standardize on **PostgreSQL** as the primary DB for v1. SQLite remains a possible future option for a “lightweight mode,” but is not the main target initially.

---

### 3.2 Other Relational Databases (MySQL/MariaDB/SQL Server)

**Alternative:**  
Use MySQL, MariaDB, or SQL Server instead of PostgreSQL.

**Why they were considered (implicitly):**
- Many environments already run MySQL/MariaDB.
- SQL Server familiarity among .NET developers.

**Why we did not choose them for v1:**
- **pgvector & ecosystem:**  
  PostgreSQL has first-class support for vector extensions (e.g., pgvector), which is highly aligned with future AI/embedding needs.
- **Open-source and cross-platform maturity:**  
  PostgreSQL is widely recognized, stable, and well-supported in containerized, cross-platform scenarios.
- **Focus:**  
  Supporting multiple DB engines adds complexity. Starting with one high-quality choice keeps the architecture focused.

**Decision:**  
Use **PostgreSQL only** in v1, with a clear subset of SQL features and EF Core mappings to keep open the possibility of future DB options if needed.

---

## 4. Frontend Stack Alternatives

### 4.1 Material UI (MUI) vs shadcn/ui

**Alternative:**  
Use Material UI (MUI) as the main component library for the React frontend.

**Why it was attractive:**
- Mature, widely used component library.
- Good documentation and rich ecosystem.
- Familiar to many front-end developers.

**Why we did not choose it:**
- **Design direction:**  
  We chose **shadcn/ui** to get a more “headless + primitives + Tailwind” approach that is more flexible, composable, and modern for our design goals.
- **Consistency with Tailwind:**  
  shadcn/ui is built on Radix UI primitives and Tailwind, which integrates nicely into utility-first styling and custom design systems.

**Decision:**  
Use **React + TypeScript + shadcn/ui + Tailwind** as the primary UI stack.

---

### 4.2 Next.js or Remix (SSR/Fullstack Framework)

**Alternative:**  
Use Next.js or Remix to implement a combined frontend/backend monorepo, potentially with server-side rendering (SSR) and API routes.

**Why it was attractive:**
- Rich developer experience.
- Built-in routing and SSR/ISR capabilities.
- Integrated API routes for small backend tasks.

**Why we did not choose it for v1:**
- **Clear separation of concerns:**  
  We intentionally want a **.NET backend** (for domain logic, persistence, AI integration) and a **React SPA** frontend. Mixing backend logic into a Node.js environment via Next/Remix would fragment server-side logic across two runtimes.
- **Skill alignment:**  
  The team wants .NET for backend and React for frontend. A pure SPA + .NET API model is straightforward for this skill mix.
- **Self-hosting simplicity:**  
  Deploying two separate containers (API + SPA) behind a simple reverse proxy is clean and predictable.

**Decision:**  
Use a **SPA architecture** with React for the frontend and ASP.NET Core Web API for the backend, rather than a fullstack JS framework.

---

## 5. Authentication & Identity Alternatives

### 5.1 OAuth / OIDC Providers (Google, Microsoft, GitHub, Auth0, etc.)

**Alternative:**  
Use external identity providers or an IDaaS platform for user authentication via OAuth/OIDC.

**Why it was attractive:**
- No passwords stored in our DB.
- Familiar login UX (Sign in with Google/Microsoft, etc.).
- Easy account management for SaaS scenarios.

**Why we did not choose it:**
- **Self-hosted environment:**  
  Many self-hosted users prefer not to depend on external identity providers for a local/private finance tool.
- **Configuration overhead:**  
  Each self-hosted deployment would need to configure OAuth clients, redirect URIs, etc., which complicates setup.
- **Scope:**  
  For v1, simple username/password with JWT is sufficient and easier to manage.

**Decision:**  
Use **JWT-based authentication** with locally-managed user accounts (email + password). External identity providers can be reconsidered later if there is a strong demand.

---

## 6. AI & LLM Integration Alternatives

### 6.1 Single Shared API Key (Centralized AI Billing)

**Alternative:**  
Ship BudgetBridge configured with a single, centrally-managed API key (e.g., for OpenAI) so users do not need to bring their own key.

**Why it was attractive:**
- Zero setup for AI features.
- Lower friction to try categorization and parsing features.

**Why we did not choose it:**
- **Not compatible with OSS / self-hosted model:**  
  A shared key would either need to be embedded (unsafe) or proxied through our own servers (which contradicts the privacy-first, local model).
- **Cost and abuse control:**  
  Central billing and abuse protection for an open-source project would be complex and expensive.
- **Trust:**  
  Users are more likely to trust a system where they control if and how their data is sent to any AI provider, including billing and terms.

**Decision:**  
Require **user-provided API keys** for any cloud LLM provider. The backend never uses a shared or baked-in key.

---

### 6.2 AI-First / Fully Automated Categorization with No Manual Rules

**Alternative:**  
Rely exclusively on AI for categorization and statement parsing, without a rule-based or deterministic layer.

**Why it was attractive:**
- Simpler conceptual model (“the AI does everything”).
- Less custom logic to maintain.

**Why we did not choose it:**
- **Determinism and control:**  
  For recurring patterns (e.g., “Uber Eats” → “Eating Out”), deterministic rules offer predictable behavior and can be tuned by the user.
- **Cost & latency:**  
  Offloading everything to an LLM can be expensive and slow, especially for large statements or repeated historical runs.
- **Quality & correctness:**  
  Combining AI with simple rules improves reliability and provides a fallback when AI is unavailable or limited.

**Decision:**  
Use a **hybrid approach**: rule-based classification first, then AI suggestions and refinement. This balances consistency, cost, and flexibility.

---

## 7. File Parsing & Privacy Alternatives

### 7.1 Strict Frontend-Only Parsing for All Formats

**Alternative:**  
Perform all parsing (CSV/QIF/PDF) exclusively in the browser (frontend), sending only already-normalized transactions to the backend.

**Why it was attractive:**
- Maximizes privacy (backend never sees any raw statement files).
- Reduces backend responsibilities around file handling.

**Why we did not choose it for v1:**
- **Complexity of PDF parsing:**  
  Robust parsing of arbitrary bank statement PDFs is significantly easier to implement and iterate on in a backend environment.
- **LLM integration:**  
  LLM-based parsing is usually easier to orchestrate from the backend, where we can manage tokens, retries, logging, and batching more robustly.
- **Already local and self-hosted:**  
  Since the backend runs locally/self-hosted, there is less incremental privacy gain from purely frontend-only parsing, compared to the effort cost.

**Decision:**  
Allow the **backend to handle parsing**, including LLM-based parsing of PDFs and complex CSVs. We maintain the option of client-side parsing for simpler cases, but it is not a hard requirement.

---

## 8. Summary

For BudgetBridge v1, we deliberately chose:

- **Form factor:** Local/self-hosted **web app**, not a desktop wrapper (Electron or native UI).
- **Backend:** Traditional **ASP.NET Core Web API** rather than serverless or JS-based backends.
- **Database:** **PostgreSQL** (with future pgvector support) rather than SQLite/MySQL/SQL Server as the primary DB.
- **Frontend:** **React + TypeScript + shadcn/ui + Tailwind**, not MUI or Next.js/Remix fullstack models.
- **Auth:** **JWT with local users**, not external OAuth/OIDC providers.
- **AI usage:** **User-provided keys** and a **hybrid rule + AI model**, instead of shared keys or AI-only classification.
- **Parsing:** **Backend parsing** for all formats (CSV/QIF/PDF), including LLM-based parsing, instead of strict frontend-only parsing.

These decisions are not permanent; they provide a **focused, coherent v1 architecture** that we can explain, implement, and evolve. Future versions can revisit any of these choices as the project, community, and requirements grow.
