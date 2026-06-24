@echo off
setlocal enabledelayedexpansion

title Werewolf Final Working Setup

REM ==================================================
REM ADMIN
REM ==================================================
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

echo =========================================
echo WEREWOLF FINAL WORKING SETUP
echo =========================================
echo.

REM ==================================================
REM SOLUTION
REM ==================================================
set "SOLUTION=Werewolf for Telegram\WerewolfForTelegram.sln"

if not exist "%SOLUTION%" (
    echo ERROR: Solution file not found.
    pause
    exit /b 1
)

REM ==================================================
REM BUILD MODE
REM ==================================================
echo Select setup mode:
echo   1. Release
echo   2. Debug
set /p SETUP_MODE="Enter 1 or 2 [1]: "

if "%SETUP_MODE%"=="2" (
    set "BUILD_CONFIG=Debug"
    set "API_REG_VALUE=DebugAPI"
) else (
    set "BUILD_CONFIG=Release"
    set "API_REG_VALUE=ProductionAPI"
)

echo.

REM ==================================================
REM TELEGRAM TOKEN
REM ==================================================
set /p API_TOKEN="Enter Telegram Bot API Token: "

if "%API_TOKEN%"=="" (
    echo ERROR: Telegram token required.
    pause
    exit /b 1
)

echo.

REM ==================================================
REM OPENAI TOKEN (OPTIONAL)
REM ==================================================
set /p OPENAI_TOKEN="Enter OpenAI API Token (optional, press Enter to skip): "

echo.

REM ==================================================
REM MONGODB CONNECTION STRING
REM ==================================================
set /p MONGO_CONN_STR="Please enter your MongoDB Atlas Connection String: "

if "%MONGO_CONN_STR%"=="" (
    echo Error: MongoDB Atlas Connection String cannot be empty.
    pause
    exit /b 1
)
echo.



REM ==================================================
REM REGISTRY SETUP
REM ==================================================
echo Writing registry configuration...

reg delete "HKLM\SOFTWARE\Werewolf" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Werewolf" /f >nul

REM ==================================================
REM TELEGRAM TOKEN
REM ==================================================
reg add "HKLM\SOFTWARE\Werewolf" ^
/v %API_REG_VALUE% ^
/t REG_SZ ^
/d "%API_TOKEN%" ^
/f

REM ==================================================
REM OPENAI TOKEN
REM ==================================================
if not "%OPENAI_TOKEN%"=="" (
    reg add "HKLM\SOFTWARE\Werewolf" ^
    /v OpenAIAPIKey ^
    /t REG_SZ ^
    /d "%OPENAI_TOKEN%" ^
    /f
)

REM ==================================================
REM DATABASE CONNECTION STRING
REM ==================================================
reg add "HKLM\SOFTWARE\Werewolf" ^
/v BotConnectionString ^
/t REG_SZ ^
/d "%MONGO_CONN_STR%" ^
/f

reg add "HKLM\SOFTWARE\Werewolf" ^
/v WEREWOLF_DB_CONNECTION_STRING ^
/t REG_SZ ^
/d "%MONGO_CONN_STR%" ^
/f

reg add "HKLM\SOFTWARE\Werewolf" ^
/v WEREWOLF_MONGO_CONNECTION_STRING ^
/t REG_SZ ^
/d "%MONGO_CONN_STR%" ^
/f

echo.
echo Registry configured successfully.
echo.

reg query "HKLM\SOFTWARE\Werewolf"

echo.

REM ==================================================
REM DOWNLOAD NUGET
REM ==================================================
if not exist "nuget.exe" (

    echo Downloading NuGet...

    powershell -Command "Invoke-WebRequest https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -OutFile nuget.exe"

    if not exist "nuget.exe" (
        echo Failed to download NuGet.
        pause
        exit /b 1
    )
)

echo.
echo Restoring NuGet packages...

.\nuget.exe restore "%SOLUTION%"

if %errorlevel% neq 0 (
    echo NuGet restore failed.
    pause
    exit /b 1
)

echo.
echo NuGet restore successful.
echo.

REM ==================================================
REM LOCATE MSBUILD
REM ==================================================
set "MSBUILD="

REM Visual Studio 18 BuildTools
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\18\BuildTools\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD=%ProgramFiles(x86)%\Microsoft Visual Studio\18\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
)

if exist "%ProgramFiles%\Microsoft Visual Studio\18\BuildTools\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD=%ProgramFiles%\Microsoft Visual Studio\18\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
)

REM Visual Studio 2022 BuildTools
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD=%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
)

if exist "%ProgramFiles%\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD=%ProgramFiles%\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
)

REM Visual Studio Community
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD=%ProgramFiles%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
)

if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD=%ProgramFiles(x86)%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
)

REM Visual Studio Enterprise
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD=%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
)

if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD=%ProgramFiles(x86)%\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
)

if "%MSBUILD%"=="" (
    echo Could not find MSBuild.
    pause
    exit /b 1
)

echo Using MSBuild:
echo %MSBUILD%
echo.

REM ==================================================
REM BUILD
REM ==================================================
echo Building solution...

"%MSBUILD%" "%SOLUTION%" /p:Configuration=%BUILD_CONFIG% /m

if %errorlevel% neq 0 (
    echo.
    echo BUILD FAILED.
    pause
    exit /b 1
)

echo.
echo =========================================
echo BUILD SUCCESSFUL
echo =========================================
echo.

REM ==================================================
REM SERVER DIRECTORY SETUP
REM ==================================================
echo Creating deployment directories...

set "ROOT_DIR=%~dp0Server"

mkdir "%ROOT_DIR%" 2>nul
mkdir "%ROOT_DIR%\Control" 2>nul
mkdir "%ROOT_DIR%\Node 1" 2>nul
mkdir "%ROOT_DIR%\Logs" 2>nul
mkdir "%ROOT_DIR%\Languages" 2>nul

echo.
echo Copying compiled files...

xcopy /s /e /y "Werewolf for Telegram\Werewolf Control\bin\%BUILD_CONFIG%\*" "%ROOT_DIR%\Control\"
xcopy /s /e /y "Werewolf for Telegram\Werewolf Node\bin\%BUILD_CONFIG%\*" "%ROOT_DIR%\Node 1\"
xcopy /s /e /y "Werewolf for Telegram\Languages\*" "%ROOT_DIR%\Languages\"

echo.
echo Files copied successfully.
echo.

REM ==================================================
REM LAUNCH APPLICATIONS
REM ==================================================
echo Launching Werewolf applications...

if exist "%ROOT_DIR%\Control\Werewolf Control.exe" (
    start "" "%ROOT_DIR%\Control\Werewolf Control.exe"
) else (
    echo WARNING: Werewolf Control.exe not found.
)

if exist "%ROOT_DIR%\Node 1\Werewolf Node.exe" (
    start "" "%ROOT_DIR%\Node 1\Werewolf Node.exe"
) else (
    echo WARNING: Werewolf Node.exe not found.
)

echo.
echo =========================================
echo SETUP COMPLETE
echo =========================================
echo.

pause