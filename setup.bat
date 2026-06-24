@echo off
setlocal enabledelayedexpansion

:: 1. Request Administrator Privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Ensure working directory is the script location after elevation
cd /d "%~dp0"

echo Welcome to Werewolf for Telegram Local Setup!
echo ===============================================

:: 2. Choose Build Mode
echo.
echo Select setup mode:
echo   1. Release / normal setup
echo   2. Debug / dev setup
set /p SETUP_MODE="Enter 1 or 2 [1]: "
if "%SETUP_MODE%"=="2" (
    set BUILD_CONFIG=Debug
    set API_REG_VALUE=DebugAPI
) else (
    set BUILD_CONFIG=Release
    set API_REG_VALUE=ProductionAPI
)

:: 2. Prompt for Telegram API Token
set /p API_TOKEN="Please enter your Telegram Bot API Token for %BUILD_CONFIG%: "
if "%API_TOKEN%"=="" (
    echo Error: API Token cannot be empty.
    pause
    exit /b
)

:: 3. Prompt for OpenAI API Token (Optional)
echo.
set /p OPENAI_TOKEN="Please enter your OpenAI API Token (optional, press Enter to skip): "
if not "%OPENAI_TOKEN%"=="" (
    echo OpenAI API Token will be configured.
) else (
    echo Skipping OpenAI API Token configuration.
)
echo.
echo Starting MongoDB Docker container...
docker run -p 27017:27017 --name werewolf-mongo -d mongo:latest >nul 2>&1
if errorlevel 1 docker start werewolf-mongo

:: 5. Set Registry Keys
echo.
echo Setting Windows Registry Keys...
reg add "HKLM\SOFTWARE\Werewolf" /v %API_REG_VALUE% /t REG_SZ /d "%API_TOKEN%" /f
if not "%OPENAI_TOKEN%"=="" (
    reg add "HKLM\SOFTWARE\Werewolf" /v OpenAIAPIKey /t REG_SZ /d "%OPENAI_TOKEN%" /f
    echo OpenAI API Key configured.
)
set DB_CONN="mongodb://localhost:27017/werewolf"
reg add "HKLM\SOFTWARE\Werewolf" /v MongoConnectionString /t REG_SZ /d %DB_CONN% /f
reg add "HKLM\SOFTWARE\Werewolf" /v BotConnectionString /t REG_SZ /d %DB_CONN% /f

:: 6. Build the Solution
echo.
echo Downloading NuGet...
if not exist "nuget.exe" (
    powershell -Command "Invoke-WebRequest -Uri 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe' -OutFile 'nuget.exe'"
)

echo Locating MSBuild...
set MSBUILD_PATH=
for /f "usebackq tokens=1* delims=: " %%i in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe`) do (
  set "MSBUILD_PATH=%%i:%%j"
)

if "%MSBUILD_PATH%"=="" (
    echo MSBuild not found using vswhere. Trying default paths...
    if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" set "MSBUILD_PATH=%ProgramFiles%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
    if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe" set "MSBUILD_PATH=%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
    if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe" set "MSBUILD_PATH=%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe"
)

if "%MSBUILD_PATH%"=="" (
    echo Error: Could not find MSBuild. Please ensure Visual Studio or Build Tools is installed.
    pause
    exit /b
)

echo MSBuild found: "%MSBUILD_PATH%"
echo Restoring NuGet packages...
nuget.exe restore "Werewolf for Telegram\WerewolfForTelegram.sln" -PackagesDirectory "Werewolf for Telegram\packages"

echo Compiling project in %BUILD_CONFIG% mode...
"%MSBUILD_PATH%" "Werewolf for Telegram\WerewolfForTelegram.sln" /p:Configuration=%BUILD_CONFIG% /t:Build /m /p:RestorePackagesConfig=true
if %errorLevel% neq 0 (
    echo Build failed.
    pause
    exit /b
)

:: 7. Setup Directory Structure
echo.
echo Setting up server directories...
set ROOT_DIR=%~dp0Server
mkdir "%ROOT_DIR%\Control" 2>nul
mkdir "%ROOT_DIR%\Node 1" 2>nul
mkdir "%ROOT_DIR%\Logs" 2>nul
mkdir "%ROOT_DIR%\Languages" 2>nul

echo Copying compiled files...
xcopy /s /y "Werewolf for Telegram\Werewolf Control\bin\%BUILD_CONFIG%\*" "%ROOT_DIR%\Control\"
xcopy /s /y "Werewolf for Telegram\Werewolf Node\bin\%BUILD_CONFIG%\*" "%ROOT_DIR%\Node 1\"
xcopy /s /y "Werewolf for Telegram\Languages\*" "%ROOT_DIR%\Languages\"

:: 8. Start the applications
echo.
echo Setup Complete! Starting Werewolf Bot in %BUILD_CONFIG% mode...
start "" "%ROOT_DIR%\Control\Werewolf Control.exe"
start "" "%ROOT_DIR%\Node 1\Werewolf Node.exe"

echo Both Control and Node have been launched.
pause
