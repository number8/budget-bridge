namespace BudgetBridge.Application.DTOs;

/// <summary>
/// Data transfer object for creating a new budget.
/// </summary>
/// <param name="Name">The name of the budget (required, max 200 characters).</param>
/// <param name="Amount">The budget amount (must be positive).</param>
/// <param name="StartDate">The start date of the budget period.</param>
/// <param name="EndDate">The end date of the budget period (must be after StartDate).</param>
public record CreateBudgetDto(
    string Name,
    decimal Amount,
    DateTime StartDate,
    DateTime EndDate
);
