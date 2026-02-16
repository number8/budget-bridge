# Contributing to BudgetBridge

Thank you for your interest in contributing to BudgetBridge! This document provides guidelines and instructions to help you contribute effectively.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Standards](#code-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Guidelines](#issue-guidelines)
- [Code of Conduct](#code-of-conduct)

## Getting Started

### Prerequisites

Before contributing, ensure you have:

- [.NET SDK 9.0+](https://dotnet.microsoft.com/download)
- [Docker Desktop](https://www.docker.com/get-started)
- [pnpm 9.0+](https://pnpm.io/installation)
- [Git](https://git-scm.com/)
- A code editor (VS Code recommended)

### Initial Setup

1. **Fork the repository** on GitHub

2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/budget-bridge.git
   cd budget-bridge
   ```

3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/mmorales/budget-bridge.git
   ```

4. **Run setup script**:
   ```bash
   ./scripts/setup.sh
   ```

5. **Verify setup**:
   ```bash
   ./scripts/start.sh --mode=local
   curl http://localhost:8080/health
   ./scripts/stop.sh
   ```

## Development Workflow

### Branch Naming Conventions

Use descriptive branch names following these patterns:

- **Features**: `feature/short-description`
  - Example: `feature/budget-export-csv`
  
- **Bug Fixes**: `bugfix/issue-number-short-description`
  - Example: `bugfix/123-fix-date-parsing`
  
- **Documentation**: `docs/what-is-being-documented`
  - Example: `docs/api-endpoints`
  
- **Refactoring**: `refactor/what-is-being-refactored`
  - Example: `refactor/budget-repository`
  
- **Tests**: `test/what-is-being-tested`
  - Example: `test/budget-validation`

### Creating a Feature Branch

```bash
# Ensure main is up to date
git checkout main
git pull upstream main

# Create and switch to feature branch
git checkout -b feature/your-feature-name
```

### Making Changes

1. **Write code** following our [code standards](#code-standards)
2. **Add tests** for new functionality
3. **Run tests locally**:
   ```bash
   # Backend tests
   cd backend && dotnet test
   
   # Frontend tests
   cd frontend && pnpm test
   ```
4. **Format code**:
   ```bash
   # Backend
   cd backend && dotnet format
   
   # Frontend
   cd frontend && pnpm format
   ```
5. **Commit changes** following [commit guidelines](#commit-guidelines)

## Code Standards

### Backend (.NET)

#### General Principles
- Follow Clean Architecture with strict layer dependencies
- Use dependency injection for all services
- Write testable, loosely coupled code
- Enable nullable reference types for all projects
- Treat warnings as errors

#### Code Organization
- **One public class per file** (enforced in constitution)
- Use factory methods for entity creation with validation
- Repository pattern for data access
- DTOs for cross-layer communication
- FluentValidation for input validation

#### Naming Conventions
- PascalCase for classes, methods, properties
- camelCase for local variables and parameters
- Prefix interfaces with `I` (e.g., `IBudgetRepository`)
- Use descriptive names (avoid abbreviations)

#### Example Entity
```csharp
public class Budget
{
    // Private constructor for EF Core
    private Budget() { }
    
    // Factory method with validation
    public static Budget Create(string name, decimal amount, 
        DateTime startDate, DateTime endDate)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Name is required");
        
        if (amount <= 0)
            throw new ArgumentException("Amount must be positive");
        
        if (endDate <= startDate)
            throw new ArgumentException("End date must be after start date");
            
        return new Budget
        {
            Name = name,
            Amount = amount,
            StartDate = startDate,
            EndDate = endDate
        };
    }
    
    public int Id { get; private set; }
    public string Name { get; private set; } = string.Empty;
    public decimal Amount { get; private set; }
    public DateTime StartDate { get; private set; }
    public DateTime EndDate { get; private set; }
}
```

#### Testing Standards
- Use xUnit for all tests
- Use Moq for mocking dependencies
- Use Testcontainers for integration tests
- Arrange-Act-Assert pattern
- One assertion per test when possible

### Frontend (React + TypeScript)

#### General Principles
- Use TypeScript strict mode
- Follow shadcn/ui component patterns
- Use Tailwind CSS for styling
- Implement responsive designs (mobile-first)
- Ensure accessibility (ARIA labels, keyboard navigation)

#### Component Structure
- Functional components with hooks
- Extract custom hooks for reusable logic
- Keep components focused (single responsibility)
- Use React.memo for performance optimization when needed

#### Naming Conventions
- PascalCase for components (e.g., `BudgetList`)
- camelCase for functions and variables
- Prefix custom hooks with `use` (e.g., `useBudget`)
- Suffix test files with `.test.tsx`

#### Testing Standards
- Use Vitest for unit tests
- Use React Testing Library for component tests
- Test user interactions, not implementation details
- Aim for 80%+ code coverage

### Code Style and Linting

#### Backend
```bash
# Format code
cd backend
dotnet format

# Verify formatting (CI check)
dotnet format --verify-no-changes

# Build with warnings as errors
dotnet build -c Release
```

#### Frontend
```bash
# Format code
cd frontend
pnpm format

# Lint code
pnpm lint

# Type check
pnpm type-check
```

## Commit Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, missing semicolons, etc.)
- **refactor**: Code refactoring (no functional changes)
- **perf**: Performance improvements
- **test**: Adding or updating tests
- **chore**: Maintenance tasks (dependencies, build config, etc.)
- **ci**: CI/CD configuration changes

### Examples

```bash
# Feature with scope
git commit -m "feat(budget): add CSV export functionality"

# Bug fix with issue reference
git commit -m "fix(api): correct date parsing in budget controller

Fixes date format inconsistency when parsing ISO 8601 dates.

Closes #123"

# Breaking change
git commit -m "feat(auth)!: implement OAuth2 authentication

BREAKING CHANGE: Removes basic auth support. Clients must use OAuth2."

# Documentation
git commit -m "docs(readme): update setup instructions for macOS"

# Chore
git commit -m "chore(deps): update Entity Framework Core to 9.0.3"
```

### Commit Best Practices

- Use the imperative mood ("add feature" not "added feature")
- Keep subject line under 72 characters
- Separate subject from body with a blank line
- Use the body to explain what and why (not how)
- Reference issues and pull requests in the footer

## Pull Request Process

### Before Submitting

1. **Update your branch** with latest main:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run all tests**:
   ```bash
   cd backend && dotnet test
   cd ../frontend && pnpm test
   ```

3. **Check code formatting**:
   ```bash
   cd backend && dotnet format --verify-no-changes
   cd ../frontend && pnpm lint
   ```

4. **Build the project**:
   ```bash
   cd backend && dotnet build -c Release
   cd ../frontend && pnpm build
   ```

### Creating a Pull Request

1. **Push your branch** to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Open a pull request** on GitHub

3. **Fill out the PR template** completely:
   - Describe what changed and why
   - List testing steps
   - Check all applicable boxes in the checklist
   - Link related issues

4. **Respond to review feedback** promptly

### Pull Request Guidelines

- **Title**: Use conventional commit format (e.g., `feat(budget): add CSV export`)
- **Description**: Explain the motivation, approach, and impact
- **Size**: Keep PRs focused and reasonably sized (< 500 lines when possible)
- **Tests**: Include tests for new functionality
- **Documentation**: Update docs if behavior changes
- **Breaking changes**: Clearly mark and explain in PR description

### Review Process

- Maintainers will review PRs within 2-3 business days
- Address review comments with new commits (don't force push during review)
- PR must pass all CI checks before merging
- At least one maintainer approval required
- Squash and merge is the default merge strategy

### After Merge

1. **Delete your feature branch**:
   ```bash
   git branch -d feature/your-feature-name
   git push origin --delete feature/your-feature-name
   ```

2. **Update your main branch**:
   ```bash
   git checkout main
   git pull upstream main
   ```

## Issue Guidelines

### Before Creating an Issue

1. **Search existing issues** to avoid duplicates
2. **Check documentation** for solutions
3. **Try the latest version** to see if issue is already fixed

### Bug Reports

Use the bug report template and include:

- **Environment**: OS, .NET version, browser, etc.
- **Steps to reproduce**: Detailed, step-by-step instructions
- **Expected behavior**: What should happen
- **Actual behavior**: What actually happens
- **Screenshots/logs**: Visual aids or error messages
- **Workarounds**: Any temporary solutions you've found

### Feature Requests

Use the feature request template and include:

- **Problem statement**: What problem does this solve?
- **Proposed solution**: How should it work?
- **Alternatives considered**: Other approaches you've thought about
- **Additional context**: Use cases, mockups, references

### Questions and Discussions

- Use **GitHub Discussions** for questions and ideas
- Use **Issues** only for actionable bugs or features
- Search discussions before posting

## Code of Conduct

### Our Standards

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Accept constructive criticism gracefully
- Focus on what's best for the community
- Show empathy towards others

### Unacceptable Behavior

- Harassment or discriminatory language
- Trolling, insulting, or personal attacks
- Public or private harassment
- Publishing others' private information
- Unprofessional conduct

### Enforcement

Violations may result in:
1. Warning
2. Temporary ban
3. Permanent ban

Report issues to project maintainers.

## Questions?

- **Documentation**: Check [README.md](README.md) and [backend/README.md](backend/README.md)
- **Discussions**: Use [GitHub Discussions](https://github.com/mmorales/budget-bridge/discussions)
- **Issues**: Create an issue for bugs or feature requests

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to BudgetBridge! 🎉
