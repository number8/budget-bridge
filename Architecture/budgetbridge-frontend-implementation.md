# BudgetBridge – Frontend Implementation Details
Version: 0.1 (Current Scaffold)
Last Updated: February 16, 2026

## 1. Overview

This document provides comprehensive details about the BudgetBridge frontend implementation. The frontend is a modern React single-page application (SPA) built with TypeScript, designed to provide a fast, responsive, and maintainable user interface for personal finance management.

---

## 2. Technology Stack

### 2.1 Core Framework & Language
- **React 19.2.0** - Latest stable release with improved concurrent features
- **TypeScript 5.9.3** - Static typing for improved developer experience and code quality
- **JSX/TSX** - Component templating

### 2.2 Build Tools & Development
- **Vite 7.3.1** - Ultra-fast development server and optimized production builds
  - Hot Module Replacement (HMR) for instant feedback
  - Optimized dependency pre-bundling
  - ES modules in development
- **pnpm** - Fast, disk space efficient package manager
  - Lock file: `pnpm-lock.yaml`
  - Only built dependencies configured: `@biomejs/biome`, `esbuild`

### 2.3 Routing
- **TanStack Router 1.120.2** - Type-safe, file-based routing
  - Automatic route tree generation
  - Code splitting per route
  - Type-safe navigation and parameters
  - Auto-generated `routeTree.gen.ts`
  - Plugin: `@tanstack/router-plugin/vite`

### 2.4 State Management
- **TanStack Query 5.75.5** (formerly React Query)
  - Server state synchronization
  - Automatic caching, refetching, and background updates
  - Optimistic updates support
  - Default configuration:
    - Stale time: 5 minutes
    - Retry: 1 attempt

### 2.5 Styling & Design System
- **Tailwind CSS 4.1.7** - Utility-first CSS framework
  - Integration via `@tailwindcss/vite` plugin
  - Responsive design utilities
  - Dark mode support ready
  - Animation utilities via `tw-animate-css`
- **shadcn/ui 3.8.5** - Re-usable component library
  - Built on Radix UI primitives
  - Customizable, accessible components
  - Copy-paste component installation
  - Configuration in `components.json`
- **Lucide React 0.564.0** - Icon library
  - Tree-shakeable icons
  - Consistent design language
- **Utilities:**
  - `class-variance-authority` - Component variant management
  - `clsx` - Conditional className construction
  - `tailwind-merge` - Intelligent Tailwind class merging

### 2.6 Code Quality Tools
- **Biome 1.9.4** - Fast, unified toolchain for formatting and linting
  - **Formatter:** 
    - Tab indentation (width: 2)
    - Line width: 100 characters
    - Double quotes for JavaScript/TypeScript
    - Semicolons required
  - **Linter:** Recommended rules enabled
  - **Organizer:** Automatic import sorting
  - **VCS Integration:** Git-aware, uses `.gitignore`
  - Ignored files: `node_modules`, `dist`, `src/routeTree.gen.ts`

### 2.7 Testing
- **Vitest 3.2.1** - Fast unit test framework (Vite-native)
  - Configuration in `vitest.config.ts`
  - Coverage reporting support
- **React Testing Library 16.3.0** - Component testing utilities
  - User-centric testing approach
  - Accessibility-focused queries
- **@testing-library/jest-dom 6.6.3** - Custom matchers for DOM assertions
- **jsdom 26.1.0** - Headless browser environment for tests
- **Test setup:** `src/test/setup.ts`

### 2.8 Containerization
- **Docker** - Multi-stage build for production
- **Nginx (Alpine)** - Lightweight web server for serving static files
  - SPA-friendly configuration in `nginx.conf`
  - Gzip compression
  - Fallback routing for client-side navigation

---

## 3. Project Structure

```
frontend/
├── public/                      # Static assets (favicon, images, etc.)
│
├── src/
│   ├── __tests__/              # Component and integration tests
│   │   └── home.test.tsx       # Example home page test
│   │
│   ├── lib/                    # Shared utilities and helpers
│   │   └── utils.ts            # Common functions (e.g., cn for classNames)
│   │
│   ├── routes/                 # TanStack Router file-based routes
│   │   ├── __root.tsx          # Root layout component
│   │   └── index.tsx           # Home page (/)
│   │
│   ├── styles/                 # Global styles
│   │   └── globals.css         # Tailwind directives and custom CSS
│   │
│   ├── test/                   # Test configuration
│   │   └── setup.ts            # Vitest setup file
│   │
│   ├── main.tsx                # Application entry point
│   └── routeTree.gen.ts        # Auto-generated route tree (do not edit)
│
├── biome.json                  # Biome configuration
├── components.json             # shadcn/ui configuration
├── Dockerfile                  # Production container definition
├── index.html                  # HTML entry point
├── nginx.conf                  # Nginx server configuration
├── package.json                # Dependencies and scripts
├── pnpm-lock.yaml             # Dependency lock file
├── README.md                   # Frontend documentation
├── tsconfig.json               # Base TypeScript configuration
├── tsconfig.app.json           # App-specific TypeScript config
├── tsconfig.node.json          # Build tools TypeScript config
├── vite.config.ts              # Vite bundler configuration
└── vitest.config.ts            # Vitest test runner configuration
```

---

## 4. Configuration Details

### 4.1 TypeScript Configuration

**`tsconfig.json`** - Base configuration
- References to app and node configs
- Path aliases: `@/*` → `./src/*`

**`tsconfig.app.json`** - Application code
- Target: ESNext
- Module: ESNext
- JSX: react-jsx
- Strict mode enabled
- Module resolution: bundler

**`tsconfig.node.json`** - Build tools
- For Vite config and other Node scripts

### 4.2 Vite Configuration

**`vite.config.ts`**
```typescript
import path from "node:path";
import tailwindcss from "@tailwindcss/vite";
import { tanstackRouter } from "@tanstack/router-plugin/vite";
import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [
    tanstackRouter({
      target: "react",
      autoCodeSplitting: true,  // Automatic route-based code splitting
    }),
    react(),
    tailwindcss(),
  ],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
});
```

### 4.3 Biome Configuration

**`biome.json`** highlights:
- VCS enabled with Git integration
- Organizes imports automatically
- Recommended linting rules
- Tab indentation, 100-char lines
- Double quotes, semicolons required
- Special handling for `tsconfig*.json` (allows comments and trailing commas)

### 4.4 React Query Configuration

**In `src/routes/__root.tsx`:**
```typescript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5,  // 5 minutes
      retry: 1,                   // Retry failed requests once
    },
  },
});
```

---

## 5. Available npm Scripts

Defined in `package.json`:

```json
{
  "dev": "vite",                           // Start development server
  "build": "tsc -b && vite build",        // Type check and build for production
  "preview": "vite preview",               // Preview production build locally
  "lint": "biome lint --write .",         // Lint and auto-fix
  "format": "biome format --write .",     // Format code
  "check": "biome check --write .",       // Lint + format + organize imports
  "test": "vitest run",                    // Run tests once
  "test:watch": "vitest",                  // Run tests in watch mode
  "test:coverage": "vitest run --coverage" // Run tests with coverage report
}
```

### Common Workflows

**Development:**
```bash
pnpm dev
# Opens http://localhost:5173 (or next available port)
```

**Production Build:**
```bash
pnpm build
# Output: dist/ directory
```

**Code Quality:**
```bash
pnpm check        # Fix all formatting, linting, and imports
pnpm test         # Run test suite
```

---

## 6. Current Implementation

### 6.1 Entry Point (`src/main.tsx`)

- Creates router with generated route tree
- Registers router types for TypeScript
- Renders app in strict mode
- Mounts to `#root` element

### 6.2 Root Layout (`src/routes/__root.tsx`)

- Creates and configures React Query client
- Wraps app in `QueryClientProvider`
- Provides base styling container with:
  - `min-h-screen` - Full viewport height
  - `bg-background` - Theme-aware background
  - `text-foreground` - Theme-aware text color
- Renders child routes via `<Outlet />`

### 6.3 Home Page (`src/routes/index.tsx`)

- Landing page at `/`
- Centered layout with:
  - BudgetBridge title (4xl font, bold)
  - Tagline: "Simplify your personal finance management"
  - Muted foreground text for subtitle

### 6.4 Utilities (`src/lib/utils.ts`)

Expected to contain:
- `cn()` function for conditional className merging
- Other shared utility functions

---

## 7. Docker Configuration

### 7.1 Multi-Stage Dockerfile

**Stage 1: Build**
- Node.js base image
- Install pnpm
- Install dependencies
- Run production build

**Stage 2: Production**
- Nginx Alpine base (lightweight)
- Copy built assets from build stage
- Copy custom `nginx.conf`
- Expose port 80
- Run Nginx

### 7.2 Nginx Configuration

**Key features in `nginx.conf`:**
- Serves static files from `/usr/share/nginx/html`
- Gzip compression enabled
- SPA fallback: All non-file routes → `index.html`
- Security headers ready for addition

---

## 8. Routing Architecture

### 8.1 TanStack Router Concepts

**File-based routing:**
- Routes are defined by file structure in `src/routes/`
- `__root.tsx` - Root layout
- `index.tsx` - Index route (`/`)
- `about.tsx` would create `/about`
- `posts/$id.tsx` would create `/posts/:id`

**Auto-generated route tree:**
- Plugin generates `src/routeTree.gen.ts`
- Never edit manually
- Provides full type safety

**Code splitting:**
- `autoCodeSplitting: true` in config
- Each route bundle loaded on-demand
- Optimizes initial load time

### 8.2 Planned Routes

Based on architecture documents, planned routes:

```
/                           - Landing/Dashboard
/auth/login                 - Login page
/auth/register              - Registration page
/transactions               - Transaction list
/transactions/:id           - Transaction detail
/categories                 - Category management
/rules                      - Categorization rules
/exports                    - Export wizard
/reports                    - Reports and insights
/settings                   - User settings
/settings/ai                - AI configuration
```

---

## 9. Testing Strategy

### 9.1 Test Setup

**`src/test/setup.ts`:**
- Imports jest-dom matchers
- Can add global test configuration
- Runs before all tests

### 9.2 Example Test Structure

**`src/__tests__/home.test.tsx`:**
```typescript
import { render, screen } from '@testing-library/react';
import { expect, test } from 'vitest';

test('renders home page', () => {
  // Arrange & Act
  render(<HomePage />);
  
  // Assert
  expect(screen.getByText('BudgetBridge')).toBeInTheDocument();
});
```

### 9.3 Testing Best Practices

- Test user behavior, not implementation
- Use semantic queries (getByRole, getByLabelText)
- Test accessibility
- Mock API calls with React Query
- Integration tests for critical flows

---

## 10. Development Guidelines

### 10.1 Component Creation

1. Create in appropriate directory (e.g., `src/components/`)
2. Use TypeScript with proper prop types
3. Export as named export
4. Add tests in `__tests__/` nearby

### 10.2 Adding a New Route

1. Create file in `src/routes/` following naming convention
2. Import `createFileRoute` from `@tanstack/react-router`
3. Export route with `export const Route = createFileRoute('/path')({...})`
4. Route tree regenerates automatically

### 10.3 Installing shadcn/ui Components

```bash
npx shadcn@latest add button
npx shadcn@latest add card
npx shadcn@latest add table
# etc.
```

Components are copied to project (not installed as dependency).

### 10.4 Code Style

- Run `pnpm check` before committing
- Use double quotes for strings
- Use tabs for indentation (width 2)
- Add semicolons
- Keep lines under 100 characters
- Organize imports automatically with Biome

### 10.5 State Management Patterns

**Server State (TanStack Query):**
- Use for API data
- `useQuery` for reads
- `useMutation` for writes
- Automatic caching and synchronization

**Client State (React Hooks):**
- `useState` for component-local state
- `useReducer` for complex state logic
- Context for deeply shared state (sparingly)

---

## 11. Performance Optimization

### 11.1 Built-in Optimizations

- **Vite:** Fast HMR, optimized bundling
- **TanStack Router:** Automatic code splitting per route
- **React 19:** Improved concurrent rendering
- **Nginx:** Gzip compression, efficient static serving

### 11.2 Future Optimizations

- Lazy loading for heavy components
- React.memo for expensive re-renders
- Virtual scrolling for large lists (e.g., transactions)
- Image optimization
- Web Workers for heavy computations
- Service Worker for offline support (PWA)

---

## 12. Accessibility (a11y)

### 12.1 Current Foundation

- **Radix UI (via shadcn/ui):** Accessibility built-in
  - Keyboard navigation
  - ARIA attributes
  - Focus management
- **Semantic HTML:** Use proper elements
- **Testing Library:** Encourages accessible queries

### 12.2 Accessibility Checklist

- [ ] Keyboard navigation for all interactive elements
- [ ] Sufficient color contrast (WCAG AA)
- [ ] Alt text for images
- [ ] Form labels and error messages
- [ ] Focus indicators
- [ ] Screen reader testing
- [ ] ARIA labels where needed
- [ ] Responsive text sizing

---

## 13. Next Steps (Priority Order)

### 13.1 Immediate Tasks

1. **Install core shadcn/ui components**
   - Button, Card, Input, Label, Table, Dialog, Select, etc.

2. **Implement authentication UI**
   - Login page (`/auth/login`)
   - Registration page (`/auth/register`)
   - Form validation
   - JWT storage strategy

3. **Build app shell**
   - Top navigation bar
   - Sidebar navigation
   - User menu
   - Mobile responsive menu

4. **Connect to backend API**
   - Configure base URL
   - Create API client with fetch/axios
   - Set up React Query queries and mutations
   - Handle authentication headers

### 13.2 Feature Development

5. **Dashboard page**
   - Summary cards
   - Recent transactions
   - Quick actions

6. **Transaction management**
   - List view with filters
   - Detail view
   - Category assignment
   - Bulk operations

7. **Category and rule management**
   - Category CRUD
   - Rule builder
   - Rule suggestions

8. **Export functionality**
   - Export wizard
   - Format selection
   - Date range picker
   - Download handling

9. **Reports and insights**
   - Charts and graphs
   - Spending trends
   - Budget recommendations

10. **Settings pages**
    - User profile
    - AI configuration
    - Currency preferences
    - Advanced options

---

## 14. Known Limitations & Future Enhancements

### 14.1 Current Limitations

- No authentication implemented yet
- No API integration
- No backend connection
- No actual data displayed
- No shadcn/ui components installed yet

### 14.2 Planned Enhancements

- **Internationalization (i18n):** Multi-language support
- **Dark mode:** Full theme switching
- **PWA features:** Offline support, install prompt
- **Real-time updates:** WebSocket for live transaction updates
- **Keyboard shortcuts:** Power user features
- **Data export:** CSV/JSON export of reports
- **Drag-and-drop:** File uploads, reordering
- **Advanced filtering:** Saved filters, complex queries

---

## 15. Troubleshooting

### 15.1 Common Issues

**Port already in use:**
```bash
# Vite will automatically try next available port
# Or specify a port:
vite --port 3000
```

**Type errors in routeTree.gen.ts:**
- File is auto-generated, don't edit
- Delete and restart dev server to regenerate

**Biome formatting conflicts:**
```bash
# Run the unified check command:
pnpm check
```

**Slow initial build:**
- First build pre-bundles dependencies (normal)
- Subsequent builds are much faster

**Tests failing:**
- Ensure test setup file is loaded
- Check for missing @testing-library utilities
- Verify component imports

### 15.2 Debugging Tips

- Use React DevTools browser extension
- Use TanStack Query DevTools (can be added)
- Check Vite dev server console for build errors
- Use browser DevTools Network tab for API debugging
- Add `console.log` statements (temporary)
- Use VS Code debugger with launch configuration

---

## 16. Resources & Documentation

### 16.1 Official Documentation

- **React:** https://react.dev/
- **TypeScript:** https://www.typescriptlang.org/docs/
- **Vite:** https://vitejs.dev/
- **TanStack Router:** https://tanstack.com/router
- **TanStack Query:** https://tanstack.com/query
- **Tailwind CSS:** https://tailwindcss.com/docs
- **shadcn/ui:** https://ui.shadcn.com/
- **Biome:** https://biomejs.dev/
- **Vitest:** https://vitest.dev/
- **React Testing Library:** https://testing-library.com/react

### 16.2 Internal Documentation

- [Architecture Overview](./budgetbridge-architecture-v0.1.md)
- [Architecture Decisions](./budgetbridge-architecture-decisions-v0.1.md)
- [Remaining Tasks](./budgetbridge_remaining_tasks.md)
- [Frontend README](../frontend/README.md)

---

## 17. Maintenance Notes

### 17.1 Dependency Updates

- Review updates regularly (monthly)
- Test thoroughly after major version bumps
- Check for breaking changes in changelogs
- Update lock file: `pnpm update`

### 17.2 Generated Files

**Never manually edit:**
- `src/routeTree.gen.ts` - Auto-generated by TanStack Router
- `pnpm-lock.yaml` - Managed by pnpm

**Safe to modify:**
- All other source files
- Configuration files (with caution)

---

## Appendix A: Package Versions Reference

```json
{
  "dependencies": {
    "@tanstack/react-query": "^5.75.5",
    "@tanstack/react-router": "^1.120.2",
    "class-variance-authority": "^0.7.1",
    "clsx": "^2.1.1",
    "lucide-react": "^0.564.0",
    "radix-ui": "^1.4.3",
    "react": "^19.2.0",
    "react-dom": "^19.2.0",
    "tailwind-merge": "^3.4.1"
  },
  "devDependencies": {
    "@biomejs/biome": "^1.9.4",
    "@tailwindcss/vite": "^4.1.7",
    "@tanstack/router-plugin": "^1.120.2",
    "@testing-library/jest-dom": "^6.6.3",
    "@testing-library/react": "^16.3.0",
    "@types/node": "^24.10.1",
    "@types/react": "^19.2.7",
    "@types/react-dom": "^19.2.3",
    "@vitejs/plugin-react": "^5.1.1",
    "jsdom": "^26.1.0",
    "shadcn": "^3.8.5",
    "tailwindcss": "^4.1.7",
    "tw-animate-css": "^1.4.0",
    "typescript": "~5.9.3",
    "vite": "^7.3.1",
    "vitest": "^3.2.1"
  }
}
```

---

**Document Status:** Current (reflects scaffolded state)  
**Next Review:** After authentication implementation  
**Maintained By:** Development Team
