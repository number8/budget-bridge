namespace BudgetBridge.Api.Models;

/// <summary>
/// Response model for basic health check endpoint.
/// </summary>
public class HealthResponse
{
    public string Status { get; set; } = string.Empty;
    public string Version { get; set; } = string.Empty;
    public DateTime Timestamp { get; set; }
    public string? Error { get; set; }
}
