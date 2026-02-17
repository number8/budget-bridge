using BudgetBridge.Domain.Entities;

namespace BudgetBridge.Domain.Interfaces;

/// <summary>
/// Repository contract for Budget entity.
/// Demonstrates dependency inversion - Domain defines contract, Infrastructure implements.
/// </summary>
public interface IBudgetRepository
{
    Task<Budget?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IEnumerable<Budget>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<Budget> AddAsync(Budget budget, CancellationToken cancellationToken = default);
    Task UpdateAsync(Budget budget, CancellationToken cancellationToken = default);
    Task DeleteAsync(Guid id, CancellationToken cancellationToken = default);
}
