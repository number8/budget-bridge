namespace BudgetBridge.Domain.Entities;

/// <summary>
/// Represents a budget period with allocated amount and date range.
/// Example domain entity demonstrating Clean Architecture patterns.
/// </summary>
public class Budget
{
    public Guid Id { get; private set; }
    public string Name { get; private set; } = string.Empty;
    public decimal Amount { get; private set; }
    public DateTime StartDate { get; private set; }
    public DateTime EndDate { get; private set; }
    public DateTime CreatedAt { get; private set; }
    public DateTime? UpdatedAt { get; private set; }

    // EF Core constructor
    private Budget() { }

    /// <summary>
    /// Factory method to create a new Budget with validation.
    /// </summary>
    public static Budget Create(string name, decimal amount, DateTime startDate, DateTime endDate)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Budget name cannot be empty", nameof(name));

        if (name.Length > 200)
            throw new ArgumentException("Budget name cannot exceed 200 characters", nameof(name));

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

    /// <summary>
    /// Update budget name and amount with validation.
    /// </summary>
    public void Update(string name, decimal amount)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Budget name cannot be empty", nameof(name));

        if (name.Length > 200)
            throw new ArgumentException("Budget name cannot exceed 200 characters", nameof(name));

        if (amount <= 0)
            throw new ArgumentException("Budget amount must be positive", nameof(amount));

        Name = name;
        Amount = amount;
        UpdatedAt = DateTime.UtcNow;
    }
}
