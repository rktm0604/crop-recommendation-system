# Run SmartCrop Full Stack (MySQL + Spring Boot)
# Usage: .\run.ps1

Set-Location $PSScriptRoot

# --- Find JDK 17 ---
function Find-Jdk17 {
    if ($env:JAVA_HOME) {
        $javac = Join-Path $env:JAVA_HOME "bin\javac.exe"
        if (Test-Path $javac) { return $env:JAVA_HOME }
    }
    $searchPaths = @("C:\Program Files\Eclipse Adoptium", "C:\Program Files\Java")
    foreach ($base in $searchPaths) {
        if (-not (Test-Path $base)) { continue }
        Get-ChildItem $base -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $javac = Join-Path $_.FullName "bin\javac.exe"
            if (Test-Path $javac) { return $_.FullName }
        }
    }
    return $null
}

$jdk = Find-Jdk17
if ($jdk) {
    $env:JAVA_HOME = $jdk
    $env:PATH = "$jdk\bin;$env:PATH"
} else {
    Write-Host "ERROR: JDK 17 not found. Please install JDK 17." -ForegroundColor Red
    exit 1
}

# --- Start MySQL if needed ---
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting FULL STACK (MySQL + Spring Boot)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Check if MySQL container is already running
$mysqlRunning = docker ps --filter "name=crop-mysql" --format "{{.Names}}" 2>$null
if ($mysqlRunning -ne "crop-mysql") {
    Write-Host "Starting MySQL container..." -ForegroundColor Yellow
    docker rm -f crop-mysql 2>$null | Out-Null
    docker run -d --name crop-mysql -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=crop_recommendation_db -p 3306:3306 mysql:8.0
    Write-Host "Waiting for MySQL to be ready..." -ForegroundColor Yellow
    Start-Sleep -Seconds 15
} else {
    Write-Host "MySQL already running." -ForegroundColor Green
}

Write-Host "MySQL ready on localhost:3306" -ForegroundColor Green

# --- Start Spring Boot ---
Write-Host ""
Write-Host "Starting Spring Boot app..." -ForegroundColor Cyan
Write-Host ""
Write-Host "App: http://localhost:8080" -ForegroundColor Green
Write-Host "Login: farmer@crop.com / password123" -ForegroundColor Green
Write-Host ""

$projectDir = (Get-Location).Path
$wrapperJar = ".mvn\wrapper\maven-wrapper.jar"

$javaArgs = @(
    "-Dmaven.multiModuleProjectDirectory=$projectDir",
    "-classpath", $wrapperJar,
    "org.apache.maven.wrapper.MavenWrapperMain",
    "spring-boot:run"
)

& java $javaArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Error starting app. Check MySQL is running." -ForegroundColor Red
    exit $LASTEXITCODE
}