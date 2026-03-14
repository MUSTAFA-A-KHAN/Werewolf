#!/bin/bash

echo "=========================================================="
echo "          Werewolf for Telegram - Start Linux"
echo "=========================================================="
echo ""
echo "Please make sure you have built the application."
echo "Running the bots in the background using Mono."
echo ""

# Make sure mono is installed
if ! [ -x "$(command -v mono)" ]; then
  echo 'Error: mono is not installed. Run setup_linux.sh first.' >&2
  exit 1
fi

CONTROL_EXE="Werewolf Control/bin/Release/Werewolf Control.exe"
NODE_EXE="Werewolf Node/bin/Release/Werewolf Node.exe"

if [ ! -f "$CONTROL_EXE" ]; then
    echo "Could not find Werewolf Control. Please build the application first."
    exit 1
fi

if [ ! -f "$NODE_EXE" ]; then
    echo "Could not find Werewolf Node. Please build the application first."
    exit 1
fi

echo "Starting Werewolf Control..."
nohup mono "$CONTROL_EXE" > control.log 2>&1 &
echo "Control started with PID $!"

echo "Starting Werewolf Node..."
nohup mono "$NODE_EXE" > node.log 2>&1 &
echo "Node started with PID $!"

echo "Bots are running in the background. Check control.log and node.log for details."