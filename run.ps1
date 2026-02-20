# Run the app without installing Maven (uses Maven Wrapper).
# Requires: JDK 17 installed (script will try to find it).
# Usage: .\run.ps1

Set-Location $PSScriptRoot

# Ensure we use a JDK (not JRE) so Maven can compile
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
    # Where java.exe lives (from PATH) - use its parent\.. as JAVA_HOME if javac is there
    $javaExe = (Get-Command java -ErrorAction SilentlyContinue).Source
    if ($javaExe) {
        $binDir = Split-Path $javaExe -Parent
        $javac = Join-Path $binDir "javac.exe"
        if (Test-Path $javac) {
            return (Split-Path $binDir -Parent)
        }
    }
    return $null
}

$jdk = Find-Jdk17
if ($jdk) {
    $env:JAVA_HOME = $jdk
    $env:PATH = "$jdk\bin;$env:PATH"
}
else {
    Write-Host "ERROR: No JDK found (need JDK, not JRE - must have bin\javac.exe)." -ForegroundColor Red
    Write-Host "Searched: Program Files\Eclipse Adoptium, Java, Microsoft." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "If JDK 17 is already installed, set JAVA_HOME and run again:" -ForegroundColor Yellow
    Write-Host '  $env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.13"   # use your actual path' -ForegroundColor Cyan
    Write-Host "  .\run.ps1" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To find your JDK folder: open File Explorer and look in C:\Program Files\Eclipse Adoptium\ or C:\Program Files\Java\" -ForegroundColor Yellow
    exit 1
}

$wrapperJar = ".mvn\wrapper\maven-wrapper.jar"
if (-not (Test-Path $wrapperJar)) {
    Write-Host "Downloading Maven Wrapper..."
    New-Item -ItemType Directory -Force -Path .mvn\wrapper | Out-Null
    try {
        Invoke-WebRequest -Uri "https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.2.0/maven-wrapper-3.2.0.jar" -OutFile $wrapperJar -UseBasicParsing
    }
    catch {
        Write-Host "Download failed. Install Maven from https://maven.apache.org and run: mvn spring-boot:run" -ForegroundColor Red
        exit 1
    }
}

# --- Mode Selection ---
# Default: MySQL (production). Use .\run.ps1 -Demo for H2 in-memory database.
$demoMode = $false
if ($args -contains "-Demo") { $demoMode = $true }

if ($demoMode) {
    Write-Host "Starting Smart Crop Recommendation System (DEMO - H2 database)..." -ForegroundColor Yellow
    Write-Host "App will be at http://localhost:8080 (Login: farmer@crop.com / password123)" -ForegroundColor Green
}
else {
    Write-Host "Starting Smart Crop Recommendation System (MySQL)..." -ForegroundColor Cyan
    Write-Host "App will be at http://localhost:8080 (Login: farmer@crop.com / password123)" -ForegroundColor Green
    Write-Host "Requires: MySQL running on localhost:3306 (see application.properties)" -ForegroundColor DarkGray
}
Write-Host ""

$projectDir = (Get-Location).Path
$javaArgs = @(
    "-Dmaven.multiModuleProjectDirectory=$projectDir",
    "-classpath", $wrapperJar,
    "org.apache.maven.wrapper.MavenWrapperMain",
    "spring-boot:run"
)
if ($demoMode) {
    $javaArgs += "-Dspring-boot.run.profiles=demo"
}
& java $javaArgs
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "App exited with an error. Scroll UP to see the first red/exception message." -ForegroundColor Yellow
    Write-Host "Common causes:" -ForegroundColor Yellow
    Write-Host "  1) MySQL not running - start MySQL service, or use: .\run.ps1 -Demo" -ForegroundColor Gray
    Write-Host "  2) Wrong password - edit src\main\resources\application.properties" -ForegroundColor Gray
    Write-Host "  3) Port 8080 in use - close the other app or change server.port in application.properties" -ForegroundColor Gray
    exit $LASTEXITCODE
}
