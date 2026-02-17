# Multi-stage build for .NET 9 backend
# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy project files for restore (leverage Docker layer caching)
COPY ["src/BudgetBridge.Domain/BudgetBridge.Domain.csproj", "src/BudgetBridge.Domain/"]
COPY ["src/BudgetBridge.Application/BudgetBridge.Application.csproj", "src/BudgetBridge.Application/"]
COPY ["src/BudgetBridge.Infrastructure/BudgetBridge.Infrastructure.csproj", "src/BudgetBridge.Infrastructure/"]
COPY ["src/BudgetBridge.Api/BudgetBridge.Api.csproj", "src/BudgetBridge.Api/"]
COPY ["Directory.Build.props", "./"]
COPY ["Directory.Packages.props", "./"]

# Restore dependencies
RUN dotnet restore "src/BudgetBridge.Api/BudgetBridge.Api.csproj"

# Copy remaining source files
COPY . .

# Build and publish
WORKDIR "/src/src/BudgetBridge.Api"
RUN dotnet publish "BudgetBridge.Api.csproj" -c Release -o /app/publish --no-restore

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app

# Create non-root user for security
RUN groupadd -r budgetbridge && useradd -r -g budgetbridge budgetbridge

# Copy published app from build stage
COPY --from=build /app/publish .

# Change ownership to non-root user
RUN chown -R budgetbridge:budgetbridge /app

# Switch to non-root user
USER budgetbridge

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Set entry point
ENTRYPOINT ["dotnet", "BudgetBridge.Api.dll"]
