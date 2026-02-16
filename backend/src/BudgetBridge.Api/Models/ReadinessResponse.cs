namespace BudgetBridge.Api.Models;

/// <summary>
/// Response model for readiness probe endpoint.
/// </summary>
public class ReadinessResponse
{
    public string Status { get; set; } = string.Empty;
    public string Version { get; set; } = string.Empty;
    public DateTime Timestamp { get; set; }
    public Dictionary<string, string> Dependencies { get; set; } = new();
}
