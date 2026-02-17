using BudgetBridge.Infrastructure.Configuration;

var builder = WebApplication.CreateBuilder(args);

// Validate required configuration
ValidateConfiguration(builder.Configuration);

// Add services to the container
builder.Services.AddControllers();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddOpenApi();

// Add Infrastructure services (DbContext, repositories)
builder.Services.AddInfrastructure(builder.Configuration);

// Configure CORS
var corsOrigins = builder.Configuration.GetValue<string>("CORS_ORIGINS") ?? "http://localhost:5173";
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.WithOrigins(corsOrigins.Split(',', StringSplitOptions.RemoveEmptyEntries))
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

// Add health checks
builder.Services.AddHealthChecks();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.UseDeveloperExceptionPage();
}

app.UseCors();

app.UseAuthorization();

app.MapControllers();
app.MapHealthChecks("/health");

app.Run();

// Validates required configuration on startup
static void ValidateConfiguration(IConfiguration configuration)
{
    var errors = new List<string>();

    // Validate database connection string
    var connectionString = configuration.GetConnectionString("DefaultConnection");
    if (string.IsNullOrWhiteSpace(connectionString))
    {
        errors.Add("ConnectionStrings:DefaultConnection is required. " +
                   "Set it in appsettings.json, user secrets, or environment variables.");
    }

    // Validate CORS origins (warn if using default)
    var corsOrigins = configuration.GetValue<string>("CORS_ORIGINS");
    if (string.IsNullOrWhiteSpace(corsOrigins))
    {
        Console.WriteLine("⚠️  CORS_ORIGINS not set, using default: http://localhost:5173");
    }

    // If any critical errors, fail fast
    if (errors.Count > 0)
    {
        Console.Error.WriteLine("❌ Configuration validation failed:");
        foreach (var error in errors)
        {
            Console.Error.WriteLine($"   - {error}");
        }
        Environment.Exit(1);
    }
}
