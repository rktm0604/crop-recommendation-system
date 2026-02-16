@echo off
setlocal
set DIR=%~dp0
cd /d "%DIR%"

REM Use JDK (not JRE) - ensure JAVA_HOME points to a JDK (has javac.exe)
if defined JAVA_HOME if not exist "%JAVA_HOME%\bin\javac.exe" set "JAVA_HOME="
if not defined JAVA_HOME (
    for /d %%d in ("C:\Program Files\Eclipse Adoptium\jdk-17*") do set "JAVA_HOME=%%d" & goto :jdk_ok
    for /d %%d in ("C:\Program Files\Java\jdk-17*") do set "JAVA_HOME=%%d" & goto :jdk_ok
    for /d %%d in ("C:\Program Files\Microsoft\jdk-17*") do set "JAVA_HOME=%%d" & goto :jdk_ok
    for /d %%d in ("C:\Program Files\Eclipse Adoptium\jdk-21*") do set "JAVA_HOME=%%d" & goto :jdk_ok
)
:jdk_ok
if defined JAVA_HOME set "PATH=%JAVA_HOME%\bin;%PATH%"
where javac >nul 2>&1
if errorlevel 1 (
    echo ERROR: No JDK found. Install JDK 17 from https://adoptium.net/ and set JAVA_HOME
    exit /b 1
)

set WRAPPER_JAR=.mvn\wrapper\maven-wrapper.jar
if not exist "%WRAPPER_JAR%" (
    echo Downloading Maven Wrapper...
    if not exist ".mvn\wrapper" mkdir ".mvn\wrapper"
    powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.2.0/maven-wrapper-3.2.0.jar' -OutFile '%WRAPPER_JAR%' -UseBasicParsing"
    if errorlevel 1 (
        echo Download failed. Install Maven from https://maven.apache.org and run: mvn spring-boot:run
        exit /b 1
    )
)

set "MAVEN_PROJECTBASEDIR=%DIR:~0,-1%"
java "-Dmaven.multiModuleProjectDirectory=%MAVEN_PROJECTBASEDIR%" "-classpath" "%WRAPPER_JAR%" "org.apache.maven.wrapper.MavenWrapperMain" %*
