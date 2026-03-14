#!/bin/bash

echo "=========================================================="
echo "          Werewolf for Telegram - Linux Setup"
echo "=========================================================="
echo ""
echo "This script provides instructions and required packages to"
echo "build and run Werewolf for Telegram on Linux using Mono."
echo ""

if [[ "$EUID" -ne 0 ]]; then
  echo "Please run this script as root to install prerequisites."
  exit 1
fi

echo "[1] Updating package manager..."
apt-get update

echo "[2] Installing Mono, MSBuild, and NuGet..."
apt-get install -y apt-transport-https dirmngr gnupg ca-certificates
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | tee /etc/apt/sources.list.d/mono-official-stable.list
apt-get update
apt-get install -y mono-complete msbuild nuget

echo "[3] Environment Variables Configuration"
echo "The application requires certain Environment Variables to be set."
echo "You can set these in your ~/.bashrc or create a start.sh script:"
echo ""
echo "export BotConnectionString=\"Your DB Connection String\""
echo "export DBConnectionString=\"Your DB Connection String (for website)\""
echo "export ProductionAPI=\"Your Telegram Bot Token\""
echo "export DebugAPI=\"Your Debug Telegram Bot Token\""
echo "export BetaAPI=\"Your Beta Telegram Bot Token\""
echo "export NodeId=\"A Unique GUID for this Node\""
echo "export QueueAPI=\"Your Queue Telegram Bot Token\""
echo ""

echo "[4] Building the application..."
echo "To build the application, navigate to the repository root and run:"
echo "  nuget restore 'Werewolf for Telegram.sln'"
echo "  msbuild 'Werewolf for Telegram.sln' /p:Configuration=Release"
echo ""

echo "[5] Running the application..."
echo "After a successful build, you can run the application with Mono:"
echo "  mono 'Werewolf Control/bin/Release/Werewolf Control.exe'"
echo "  mono 'Werewolf Node/bin/Release/Werewolf Node.exe'"
echo ""
echo "Setup complete. Please remember to set your environment variables."