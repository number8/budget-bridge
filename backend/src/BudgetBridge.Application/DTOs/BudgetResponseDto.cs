namespace BudgetBridge.Application.DTOs;

/// <summary>
/// Data transfer object representing a budget response.
/// </summary>
/// <param name="Id">The unique identifier of the budget.</param>
/// <param name="Name">The name of the budget.</param>
/// <param name="Amount">The budget amount.</param>
/// <param name="StartDate">The start date of the budget period.</param>
/// <param name="EndDate">The end date of the budget period.</param>
/// <param name="CreatedAt">The timestamp when the budget was created.</param>
/// <param name="UpdatedAt">The timestamp when the budget was last updated (null if never updated).</param>
public record BudgetResponseDto(
    Guid Id,
    string Name,
    decimal Amount,
    DateTime StartDate,
    DateTime EndDate,
    DateTime CreatedAt,
    DateTime? UpdatedAt
);
