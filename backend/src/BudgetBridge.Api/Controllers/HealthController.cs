using BudgetBridge.Api.Models;
using BudgetBridge.Infrastructure.Persistence;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Reflection;

namespace BudgetBridge.Api.Controllers;

/// <summary>
/// Health check and diagnostic endpoints.
/// </summary>
[ApiController]
[Route("[controller]")]
public class HealthController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<HealthController> _logger;

    public HealthController(ApplicationDbContext context, ILogger<HealthController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Basic health check endpoint - returns service health without checking dependencies.
    /// </summary>
    /// <returns>Health status response</returns>
    [HttpGet]
    [ProducesResponseType(typeof(HealthResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(HealthResponse), StatusCodes.Status503ServiceUnavailable)]
    public IActionResult GetHealth()
    {
        try
        {
            var version = Assembly.GetExecutingAssembly()
                .GetCustomAttribute<AssemblyInformationalVersionAttribute>()
                ?.InformationalVersion ?? "1.0.0";

            var response = new HealthResponse
            {
                Status = "Healthy",
                Version = version,
                Timestamp = DateTime.UtcNow
            };

            return Ok(response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Health check failed");

            var response = new HealthResponse
            {
                Status = "Unhealthy",
                Version = "1.0.0",
                Timestamp = DateTime.UtcNow,
                Error = "Service initialization failed"
            };

            return StatusCode(StatusCodes.Status503ServiceUnavailable, response);
        }
    }

    /// <summary>
    /// Readiness probe endpoint - checks service readiness including all dependencies.
    /// Suitable for Kubernetes readiness probes and load balancer health checks.
    /// </summary>
    /// <returns>Readiness status response</returns>
    [HttpGet("ready")]
    [ProducesResponseType(typeof(ReadinessResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ReadinessResponse), StatusCodes.Status503ServiceUnavailable)]
    public async Task<IActionResult> GetReadiness(CancellationToken cancellationToken)
    {
        var version = Assembly.GetExecutingAssembly()
            .GetCustomAttribute<AssemblyInformationalVersionAttribute>()
            ?.InformationalVersion ?? "1.0.0";

        var dependencies = new Dictionary<string, string>();

        try
        {
            // Check database connectivity
            var canConnect = await _context.Database.CanConnectAsync(cancellationToken);
            dependencies["database"] = canConnect ? "Healthy" : "Unhealthy";

            // Check migration status
            var pendingMigrations = await _context.Database.GetPendingMigrationsAsync(cancellationToken);
            var hasPendingMigrations = pendingMigrations.Any();
            dependencies["migration_status"] = hasPendingMigrations ? "Pending" : "Up-to-date";

            // If all checks pass
            if (canConnect && !hasPendingMigrations)
            {
                var response = new ReadinessResponse
                {
                    Status = "Ready",
                    Version = version,
                    Timestamp = DateTime.UtcNow,
                    Dependencies = dependencies
                };

                return Ok(response);
            }
            else
            {
                var response = new ReadinessResponse
                {
                    Status = "NotReady",
                    Version = version,
                    Timestamp = DateTime.UtcNow,
                    Dependencies = dependencies
                };

                return StatusCode(StatusCodes.Status503ServiceUnavailable, response);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Readiness check failed");

            dependencies["database"] = "Unhealthy";

            var response = new ReadinessResponse
            {
                Status = "NotReady",
                Version = version,
                Timestamp = DateTime.UtcNow,
                Dependencies = dependencies
            };

            return StatusCode(StatusCodes.Status503ServiceUnavailable, response);
        }
    }
}
