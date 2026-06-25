#!/bin/bash

echo "Welcome to Werewolf for Telegram Local Setup (Go Edition Linux)!"
echo "================================================================"

echo ""
read -p "Telegram Bot Token: " API_TOKEN

if [ -z "$API_TOKEN" ]; then
    echo "API token is required."
    exit 1
fi

read -p "MongoDB Atlas Connection String (e.g. mongodb+srv://...): " MONGO_URL

if [ -z "$MONGO_URL" ]; then
    echo "MongoDB connection string is required."
    exit 1
fi

read -p "OpenAI API Key (optional): " OPENAI_TOKEN

echo ""
echo "Writing .env for Go applications..."

cat > werewolf-go/.env <<ENV_EOF
WEREWOLF_BOT_API_TOKEN=$API_TOKEN
WEREWOLF_OPENAI_API_KEY=$OPENAI_TOKEN
WEREWOLF_MONGO_CONNECTION_STRING=$MONGO_URL
WEREWOLF_DB_NAME=werewolf
PORT=8080
ENV=development
ENV_EOF

echo ""
echo "Building Go applications..."
cd werewolf-go

# Download modules
go mod tidy

# Build binaries
mkdir -p bin
go build -o bin/control cmd/control/main.go
go build -o bin/node cmd/node/main.go
go build -o bin/website cmd/website/main.go
go build -o bin/donation cmd/donation/main.go

echo ""
echo "Preparing deployment..."
cd ..

ROOT_DIR="$(pwd)/Server"
mkdir -p "$ROOT_DIR/Control"
mkdir -p "$ROOT_DIR/Node 1"
mkdir -p "$ROOT_DIR/Logs"
mkdir -p "$ROOT_DIR/Languages"
mkdir -p "$ROOT_DIR/Website"

rm -rf "$ROOT_DIR/Control"/*
rm -rf "$ROOT_DIR/Node 1"/*

# Copy binaries
cp werewolf-go/bin/control "$ROOT_DIR/Control/"
cp werewolf-go/bin/node "$ROOT_DIR/Node 1/"
cp werewolf-go/bin/website "$ROOT_DIR/Website/"
cp werewolf-go/.env "$ROOT_DIR/"

# Copy Languages (if they still exist)
if [ -d "Werewolf for Telegram/Languages" ]; then
    cp -r "Werewolf for Telegram/Languages/"* "$ROOT_DIR/Languages/"
fi

echo ""
echo "Starting Services..."

(
    cd "$ROOT_DIR/Control"
    ln -sf ../.env .env
    ./control > control.log 2>&1 &
)

sleep 3

(
    cd "$ROOT_DIR/Node 1"
    ln -sf ../.env .env
    ./node > node.log 2>&1 &
)

sleep 3

(
    cd "$ROOT_DIR/Website"
    ln -sf ../.env .env
    ./website > website.log 2>&1 &
)

sleep 3

echo ""
echo "Checking service status..."
if ! pgrep -f control >/dev/null; then
    echo "Control Node failed to start."
    tail -50 "$ROOT_DIR/Control/control.log"
    exit 1
fi

if ! pgrep -f node >/dev/null; then
    echo "Worker Node failed to start."
    tail -50 "$ROOT_DIR/Node 1/node.log"
    exit 1
fi

echo "Services are running."
echo "Logs:"
echo "  Server/Control/control.log"
echo "  Server/Node 1/node.log"
echo "  Server/Website/website.log"
