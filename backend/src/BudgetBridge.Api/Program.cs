using BudgetBridge.Infrastructure.Configuration;

var builder = WebApplication.CreateBuilder(args);

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
