# Run the app with MySQL (no H2). Requires MySQL installed and running.
# Usage: .\run-mysql.ps1
# Before running: create DB and set password in src\main\resources\application.properties

Set-Location $PSScriptRoot

# Ensure we use a JDK (not JRE)
function Find-Jdk17 {
    if ($env:JAVA_HOME) {
        $javac = Join-Path $env:JAVA_HOME "bin\javac.exe"
        if (Test-Path $javac) { return $env:JAVA_HOME }
    }
    $fixedPaths = @(
        "C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot"
    )
    foreach ($p in $fixedPaths) {
        $javac = Join-Path $p "bin\javac.exe"
        if (Test-Path $javac) { return $p }
    }
    $searchPaths = @(
        "C:\Program Files\Eclipse Adoptium",
        "C:\Program Files\Java",
        "C:\Program Files\Microsoft",
        "C:\Program Files (x86)\Eclipse Adoptium",
        "C:\Program Files (x86)\Java"
    )
    foreach ($base in $searchPaths) {
        if (-not (Test-Path $base)) { continue }
        Get-ChildItem $base -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $javac = Join-Path $_.FullName "bin\javac.exe"
            if (Test-Path $javac) { return $_.FullName }
        }
    }
    $javaExe = (Get-Command java -ErrorAction SilentlyContinue).Source
    if ($javaExe) {
        $binDir = Split-Path $javaExe -Parent
        $javac = Join-Path $binDir "javac.exe"
        if (Test-Path $javac) { return (Split-Path $binDir -Parent) }
    }
    return $null
}

$jdk = Find-Jdk17
if ($jdk) {
    $env:JAVA_HOME = $jdk
    $env:PATH = "$jdk\bin;$env:PATH"
} else {
    Write-Host "ERROR: No JDK found. Install JDK 17 from https://adoptium.net/" -ForegroundColor Red
    exit 1
}

$wrapperJar = ".mvn\wrapper\maven-wrapper.jar"
if (-not (Test-Path $wrapperJar)) {
    Write-Host "Downloading Maven Wrapper..."
    New-Item -ItemType Directory -Force -Path .mvn\wrapper | Out-Null
    try {
        Invoke-WebRequest -Uri "https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.2.0/maven-wrapper-3.2.0.jar" -OutFile $wrapperJar -UseBasicParsing
    } catch {
        Write-Host "Download failed." -ForegroundColor Red
        exit 1
    }
}

Write-Host "Starting Smart Crop Recommendation System (MySQL mode)..." -ForegroundColor Cyan
Write-Host "Ensure MySQL is running and crop_recommendation_db exists. Set spring.datasource.password in application.properties." -ForegroundColor Yellow
Write-Host "App: http://localhost:8080  |  Login: farmer@crop.com / password123" -ForegroundColor Green
Write-Host ""

$projectDir = (Get-Location).Path
# No profile = use application.properties (MySQL)
$javaArgs = @(
    "-Dmaven.multiModuleProjectDirectory=$projectDir",
    "-classpath", $wrapperJar,
    "org.apache.maven.wrapper.MavenWrapperMain",
    "spring-boot:run"
)
& java $javaArgs
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "App exited with an error. Scroll UP for the exception." -ForegroundColor Yellow
    Write-Host "MySQL checklist: 1) MySQL service running  2) CREATE DATABASE crop_recommendation_db;  3) spring.datasource.password in src\main\resources\application.properties" -ForegroundColor Gray
    exit $LASTEXITCODE
}
