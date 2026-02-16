# Build JAR then run with Docker Compose
# Usage: .\build-and-run.ps1

Set-Location $PSScriptRoot

Write-Host "Step 1: Building JAR with Maven..." -ForegroundColor Cyan
& mvn clean package -DskipTests -q
if ($LASTEXITCODE -ne 0) {
    Write-Host "Maven build failed. Fix errors above, then run again." -ForegroundColor Red
    exit 1
}

Write-Host "Step 2: Starting Docker (app + MySQL)..." -ForegroundColor Cyan
& docker compose up -d --build
if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker Compose failed." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Done. App: http://localhost:8080" -ForegroundColor Green
Write-Host "Login: farmer@crop.com / password123" -ForegroundColor Green
