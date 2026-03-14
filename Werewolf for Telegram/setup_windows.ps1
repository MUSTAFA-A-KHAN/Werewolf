# ==========================================================
#          Werewolf for Telegram - Windows Setup
# ==========================================================

Write-Host "This script provides instructions to build and run Werewolf for Telegram on Windows."
Write-Host ""

# [1] Prerequisites
Write-Host "[1] Checking Prerequisites..."
Write-Host "Please make sure you have installed:"
Write-Host "- Visual Studio 2017/2019/2022 with .NET desktop development"
Write-Host "- SQL Server (Express is fine)"
Write-Host "- NuGet"
Write-Host ""

# [2] Environment Variables Configuration
Write-Host "[2] Configuration via Environment Variables"
Write-Host "The application has been updated to support Environment Variables (as well as Windows Registry)."
Write-Host "To configure, you can use PowerShell to set Environment Variables."
Write-Host "Example commands:"
Write-Host "[Environment]::SetEnvironmentVariable('ProductionAPI', 'Your Telegram Bot Token', 'User')"
Write-Host "[Environment]::SetEnvironmentVariable('DebugAPI', 'Your Debug Telegram Bot Token', 'User')"
Write-Host "[Environment]::SetEnvironmentVariable('BetaAPI', 'Your Beta Telegram Bot Token', 'User')"
Write-Host "[Environment]::SetEnvironmentVariable('BotConnectionString', 'Your DB Connection String', 'User')"
Write-Host "[Environment]::SetEnvironmentVariable('DBConnectionString', 'Your DB Connection String (for website)', 'User')"
Write-Host "[Environment]::SetEnvironmentVariable('NodeId', [guid]::NewGuid().ToString(), 'User')"
Write-Host "[Environment]::SetEnvironmentVariable('QueueAPI', 'Your Queue Telegram Bot Token', 'User')"
Write-Host ""
Write-Host "Alternatively, you can still use the Windows Registry:"
Write-Host "HKLM\SOFTWARE\Werewolf"
Write-Host ""

# [3] Building the Application
Write-Host "[3] Building the application..."
Write-Host "To build the application, navigate to the repository root and run:"
Write-Host "  nuget restore 'Werewolf for Telegram.sln'"
Write-Host "  msbuild 'Werewolf for Telegram.sln' /p:Configuration=Release"
Write-Host ""

# [4] Running the Application
Write-Host "[4] Running the application..."
Write-Host "After a successful build, you can run the application:"
Write-Host "  .\'Werewolf Control\bin\Release\Werewolf Control.exe'"
Write-Host "  .\'Werewolf Node\bin\Release\Werewolf Node.exe'"
Write-Host ""
Write-Host "Setup instructions complete. Please remember to set your environment variables."