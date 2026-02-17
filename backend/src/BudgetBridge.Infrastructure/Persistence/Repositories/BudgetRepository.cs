using BudgetBridge.Domain.Entities;
using BudgetBridge.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace BudgetBridge.Infrastructure.Persistence.Repositories;

/// <summary>
/// Budget repository implementation using Entity Framework Core.
/// </summary>
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
            .AsNoTracking()
            .FirstOrDefaultAsync(b => b.Id == id, cancellationToken);
    }

    public async Task<IEnumerable<Budget>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _context.Budgets
            .AsNoTracking()
            .OrderByDescending(b => b.StartDate)
            .ToListAsync(cancellationToken);
    }

    public async Task<Budget> AddAsync(Budget budget, CancellationToken cancellationToken = default)
    {
        await _context.Budgets.AddAsync(budget, cancellationToken);
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
        var budget = await _context.Budgets.FindAsync(new object[] { id }, cancellationToken);
        if (budget != null)
        {
            _context.Budgets.Remove(budget);
            await _context.SaveChangesAsync(cancellationToken);
        }
    }
}
