# ==========================================================
#          Werewolf for Telegram - Start Windows
# ==========================================================

Write-Host "Please make sure you have built the application."
Write-Host "Running the bots in new windows."
Write-Host ""

$ControlExe = ".\Werewolf Control\bin\Release\Werewolf Control.exe"
$NodeExe = ".\Werewolf Node\bin\Release\Werewolf Node.exe"

If (!(Test-Path -Path $ControlExe)) {
    Write-Host "Could not find Werewolf Control. Please build the application first."
    Exit 1
}

If (!(Test-Path -Path $NodeExe)) {
    Write-Host "Could not find Werewolf Node. Please build the application first."
    Exit 1
}

Write-Host "Starting Werewolf Control..."
Start-Process -FilePath $ControlExe

Write-Host "Starting Werewolf Node..."
Start-Process -FilePath $NodeExe

Write-Host "Bots are running."