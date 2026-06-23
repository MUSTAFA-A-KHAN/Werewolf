#!/bin/bash

set -e

echo "Welcome to Werewolf for Telegram Local Setup (Linux)!"
echo "====================================================="

echo ""
echo "Select setup mode:"
echo "  1. Release / normal setup"
echo "  2. Debug / dev setup"
read -p "Enter 1 or 2 [1]: " SETUP_MODE

if [ "$SETUP_MODE" = "2" ]; then
    BUILD_CONFIG="Debug"
    API_VAR="WEREWOLF_DEBUG_API"
else
    BUILD_CONFIG="Release"
    API_VAR="WEREWOLF_PRODUCTION_API"
fi

read -p "Telegram Bot Token: " API_TOKEN

if [ -z "$API_TOKEN" ]; then
    echo "API token is required."
    exit 1
fi

read -p "OpenAI API Key (optional): " OPENAI_TOKEN

read -p "MongoDB Atlas Connection String: " MONGO_CONN_STR

if [ -z "$MONGO_CONN_STR" ]; then
    echo "MongoDB Atlas connection string is required."
    return 1 2>/dev/null || exit 1
fi

echo ""

echo ""
echo "Writing .env..."

cat > .env <<EOF
$API_VAR=$API_TOKEN
WEREWOLF_BOT_API_TOKEN=$API_TOKEN
WEREWOLF_OPENAI_API_KEY=$OPENAI_TOKEN
WEREWOLF_DB_CONNECTION_STRING="$MONGO_CONN_STR"
WEREWOLF_MONGO_CONNECTION_STRING="$MONGO_CONN_STR"
EOF

echo ""
echo "Restoring packages..."

dotnet restore \
  "Werewolf for Telegram/WerewolfForTelegram.sln" \
  -r linux-x64

set -a
source .env
set +a

echo ""
echo "Publishing solution..."

dotnet publish \
  "Werewolf for Telegram/Werewolf Control/WerewolfControl.csproj" \
  -c "$BUILD_CONFIG" \
  -r linux-x64 \
  --self-contained true

dotnet publish \
  "Werewolf for Telegram/Werewolf Node/WerewolfNode.csproj" \
  -c "$BUILD_CONFIG" \
  -r linux-x64 \
  --self-contained true \
  --no-restore

echo ""
echo "Preparing deployment..."

ROOT_DIR="$(pwd)/Server"

mkdir -p "$ROOT_DIR/Control"
mkdir -p "$ROOT_DIR/Node 1"
mkdir -p "$ROOT_DIR/Logs"
mkdir -p "$ROOT_DIR/Languages"

rm -rf "$ROOT_DIR/Control"/*
rm -rf "$ROOT_DIR/Node 1"/*

cp -r \
  "Werewolf for Telegram/Werewolf Control/bin/$BUILD_CONFIG/net8.0/linux-x64/publish/." \
  "$ROOT_DIR/Control/"

cp -r \
  "Werewolf for Telegram/Werewolf Node/bin/$BUILD_CONFIG/net8.0/linux-x64/publish/." \
  "$ROOT_DIR/Node 1/"

cp -r \
  "Werewolf for Telegram/Languages/"* \
  "$ROOT_DIR/Languages/"

echo ""
echo "Starting Control..."

(
    cd "$ROOT_DIR/Control"
    nohup ./WerewolfControl > control.log 2>&1 &
)

sleep 3

echo "Starting Node..."

(
    cd "$ROOT_DIR/Node 1"
    nohup ./WerewolfNode > node.log 2>&1 &
)

sleep 5

if ! pgrep -f WerewolfControl >/dev/null; then
    echo ""
    echo "WerewolfControl failed to start."
    tail -50 "$ROOT_DIR/Control/control.log"
    exit 1
fi

if ! pgrep -f WerewolfNode >/dev/null; then
    echo ""
    echo "WerewolfNode failed to start."
    tail -50 "$ROOT_DIR/Node 1/node.log"
    exit 1
fi

echo ""
echo "Setup complete."
echo ""
echo "Logs:"
echo "  Server/Control/control.log"
echo "  Server/Node 1/node.log"