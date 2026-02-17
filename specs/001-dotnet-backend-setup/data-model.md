# Data Model: .NET Backend Development Environment Setup

**Date**: February 16, 2026  
**Feature**: 001-dotnet-backend-setup  
**Phase**: 1 (Design & Contracts)

## Overview

This document defines the initial domain entities and data structures for the Clean Architecture setup. Since this feature focuses on infrastructure scaffolding rather than business domain implementation, the entities here are **placeholder examples** demonstrating the pattern. They will be replaced/extended in future features.

---

## Layer Responsibilities

### Domain Layer
- Pure business entities with no infrastructure dependencies
- Domain interfaces (repository contracts)
- Value objects and domain exceptions
- Validation rules as part of entity invariants

### Application Layer
- Data Transfer Objects (DTOs) for cross-layer communication
- Service interfaces for use cases
- No direct dependency on Infrastructure layer

### Infrastructure Layer
- Entity Framework Core DbContext
- Repository implementations
- Database-specific concerns (migrations, configurations)

### API Layer
- Request/Response models (different from DTOs—API-specific contracts)
- API versioning and routing
- HTTP-specific concerns (status codes, headers)

---

## Example Domain Entity: Budget

**Purpose**: Placeholder demonstrating domain entity pattern and EF Core configuration.

### Entity Definition

```csharp
// Domain/Entities/Budget.cs
namespace BudgetBridge.Domain.Entities;

public class Budget
{
    public Guid Id { get; private set; }
    public string Name { get; private set; }
    public decimal Amount { get; private set; }
    public DateTime StartDate { get; private set; }
    public DateTime EndDate { get; private set; }
    public DateTime CreatedAt { get; private set; }
    public DateTime? UpdatedAt { get; private set; }

    // EF Core constructor
    private Budget() { }

    // Factory method (enforces invariants)
    public static Budget Create(string name, decimal amount, DateTime startDate, DateTime endDate)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Budget name cannot be empty", nameof(name));
        
        if (amount <= 0)
            throw new ArgumentException("Budget amount must be positive", nameof(amount));
        
        if (endDate <= startDate)
            throw new ArgumentException("End date must be after start date", nameof(endDate));

        return new Budget
        {
            Id = Guid.NewGuid(),
            Name = name,
            Amount = amount,
            StartDate = startDate,
            EndDate = endDate,
            CreatedAt = DateTime.UtcNow
        };
    }

    public void Update(string name, decimal amount)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Budget name cannot be empty", nameof(name));
        
        if (amount <= 0)
            throw new ArgumentException("Budget amount must be positive", nameof(amount));

        Name = name;
        Amount = amount;
        UpdatedAt = DateTime.UtcNow;
    }
}
```

### Validation Rules
- **Name**: Required, max 200 characters
- **Amount**: Must be positive decimal
- **StartDate**: Cannot be in the past (at creation)
- **EndDate**: Must be after StartDate

---

## Example Repository Interface

**Purpose**: Demonstrates dependency inversion—Domain defines contract, Infrastructure implements.

```csharp
// Domain/Interfaces/IBudgetRepository.cs
namespace BudgetBridge.Domain.Interfaces;

public interface IBudgetRepository
{
    Task<Budget?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IEnumerable<Budget>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<Budget> AddAsync(Budget budget, CancellationToken cancellationToken = default);
    Task UpdateAsync(Budget budget, CancellationToken cancellationToken = default);
    Task DeleteAsync(Guid id, CancellationToken cancellationToken = default);
}
```

---

## Application Layer DTOs

**Purpose**: Decouple API contracts from domain entities. DTOs are data containers, entities have behavior.

### CreateBudgetDto

```csharp
// Application/DTOs/CreateBudgetDto.cs
namespace BudgetBridge.Application.DTOs;

public record CreateBudgetDto(
    string Name,
    decimal Amount,
    DateTime StartDate,
    DateTime EndDate
);
```

### BudgetResponseDto

```csharp
// Application/DTOs/BudgetResponseDto.cs
namespace BudgetBridge.Application.DTOs;

public record BudgetResponseDto(
    Guid Id,
    string Name,
    decimal Amount,
    DateTime StartDate,
    DateTime EndDate,
    DateTime CreatedAt,
    DateTime? UpdatedAt
);
```

---

## Infrastructure: EF Core Configuration

### ApplicationDbContext

```csharp
// Infrastructure/Persistence/ApplicationDbContext.cs
using Microsoft.EntityFrameworkCore;
using BudgetBridge.Domain.Entities;

namespace BudgetBridge.Infrastructure.Persistence;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public DbSet<Budget> Budgets => Set<Budget>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        // Apply configurations from separate files
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);
    }
}
```

### Entity Configuration

```csharp
// Infrastructure/Persistence/Configurations/BudgetConfiguration.cs
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using BudgetBridge.Domain.Entities;

namespace BudgetBridge.Infrastructure.Persistence.Configurations;

public class BudgetConfiguration : IEntityTypeConfiguration<Budget>
{
    public void Configure(EntityTypeBuilder<Budget> builder)
    {
        builder.HasKey(b => b.Id);
        
        builder.Property(b => b.Name)
            .IsRequired()
            .HasMaxLength(200);
        
        builder.Property(b => b.Amount)
            .HasPrecision(18, 2);
        
        builder.Property(b => b.StartDate)
            .IsRequired();
        
        builder.Property(b => b.EndDate)
            .IsRequired();
        
        builder.Property(b => b.CreatedAt)
            .IsRequired();
        
        builder.Property(b => b.UpdatedAt);
        
        // Index for common queries
        builder.HasIndex(b => b.StartDate);
    }
}
```

### Repository Implementation

```csharp
// Infrastructure/Persistence/Repositories/BudgetRepository.cs
using Microsoft.EntityFrameworkCore;
using BudgetBridge.Domain.Entities;
using BudgetBridge.Domain.Interfaces;

namespace BudgetBridge.Infrastructure.Persistence.Repositories;

public class BudgetRepository : IBudgetRepository
{
    private readonly ApplicationDbContext _context;

    public BudgetRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<Budget?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _context.Budgets
            .FirstOrDefaultAsync(b => b.Id == id, cancellationToken);
    }

    public async Task<IEnumerable<Budget>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _context.Budgets
            .OrderBy(b => b.StartDate)
            .ToListAsync(cancellationToken);
    }

    public async Task<Budget> AddAsync(Budget budget, CancellationToken cancellationToken = default)
    {
        _context.Budgets.Add(budget);
        await _context.SaveChangesAsync(cancellationToken);
        return budget;
    }

    public async Task UpdateAsync(Budget budget, CancellationToken cancellationToken = default)
    {
        _context.Budgets.Update(budget);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var budget = await GetByIdAsync(id, cancellationToken);
        if (budget != null)
        {
            _context.Budgets.Remove(budget);
            await _context.SaveChangesAsync(cancellationToken);
        }
    }
}
```

---

## Health Check Entity

**Purpose**: Minimal entity for health check endpoint. Not stored in database.

```csharp
// Application/DTOs/HealthResponseDto.cs
namespace BudgetBridge.Application.DTOs;

public record HealthResponseDto(
    string Status,
    string Version,
    DateTime Timestamp,
    Dictionary<string, string> Dependencies
);
```

**Example Response**:
```json
{
  "status": "Healthy",
  "version": "1.0.0",
  "timestamp": "2026-02-16T12:00:00Z",
  "dependencies": {
    "database": "Healthy",
    "migration_status": "Up-to-date"
  }
}
```

---

## Database Schema (Initial Migration)

### Tables

**budgets**
| Column | Type | Constraints |
|--------|------|-------------|
| id | uuid | PRIMARY KEY |
| name | varchar(200) | NOT NULL |
| amount | decimal(18,2) | NOT NULL |
| start_date | timestamp | NOT NULL |
| end_date | timestamp | NOT NULL |
| created_at | timestamp | NOT NULL |
| updated_at | timestamp | NULL |

**Indexes**:
- `idx_budgets_start_date` on `start_date` (for date range queries)

### Migrations

Initial migration will be created via:
```bash
dotnet ef migrations add InitialCreate --project src/BudgetBridge.Infrastructure \
  --startup-project src/BudgetBridge.Api
```

This creates:
- `Migrations/YYYYMMDDHHMMSS_InitialCreate.cs`: Up/Down methods
- `Migrations/ApplicationDbContextModelSnapshot.cs`: Current model state

---

## State Transitions

### Budget Lifecycle

```
[Not Exists] --Create--> [Active]
[Active] --Update--> [Active]
[Active] --Delete--> [Deleted]
[Active] --End Date Passes--> [Expired] (future feature)
```

**Notes**:
- No soft delete in initial implementation (can add later if needed)
- "Expired" state is conceptual (tracked by `EndDate` comparison)
- No audit trail in initial version (YAGNI)

---

## Future Extensions (Out of Scope for This Feature)

- **Transaction Entity**: Links to budgets, tracks income/expenses
- **Category Entity**: Hierarchical categorization system
- **AI Rule Entity**: Stores learned categorization rules
- **User Entity**: Multi-user support with authentication
- **Audit Log**: Track all entity changes for financial compliance

These will be added in subsequent features as requirements emerge.

---

## Summary

This data model demonstrates the Clean Architecture pattern without overengineering. The `Budget` entity is a realistic placeholder that:
- Shows domain entity patterns (factory methods, invariants)
- Demonstrates repository abstraction
- Provides EF Core configuration examples
- Can be extended or replaced in future features

The actual business domain will evolve based on real requirements from transaction parsing, budgeting logic, and AI categorization features.
