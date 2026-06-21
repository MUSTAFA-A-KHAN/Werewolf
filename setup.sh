#!/bin/bash
# Local setup without exit
echo "Welcome to Werewolf for Telegram Local Setup (Linux)!"
echo "====================================================="

echo ""
echo "Select setup mode:"
echo "  1. Release / normal setup"
echo "  2. Debug / dev setup"
read -p "Enter 1 or 2 [1]: " SETUP_MODE
if [ "$SETUP_MODE" == "2" ]; then
    BUILD_CONFIG="Debug"
    API_VAR="WEREWOLF_DEBUG_API"
else
    BUILD_CONFIG="Release"
    API_VAR="WEREWOLF_PRODUCTION_API"
fi

read -p "Please enter your Telegram Bot API Token for $BUILD_CONFIG: " API_TOKEN
if [ -z "$API_TOKEN" ]; then
    echo "Error: API Token cannot be empty. Please run setup.sh again."
else
    read -p "Please enter your OpenAI API Token (optional, press Enter to skip): " OPENAI_TOKEN

    echo ""
    echo "Starting MSSQL Docker container..."
    sudo docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Werewolf@12345" -p 1433:1433 --name werewolf-sql -d mcr.microsoft.com/mssql/server:2022-latest || sudo docker start werewolf-sql

    echo "Waiting for SQL Server to initialize (30 seconds)..."
    sleep 30

    echo ""
    echo "Creating Database..."
    cp "werewolf.sql" "/tmp/werewolf_docker.sql"
    sed -i 's|C:\\Program Files\\Microsoft SQL Server\\MSSQL12.SQLEXPRESS\\MSSQL\\DATA\\|/var/opt/mssql/data/|g' "/tmp/werewolf_docker.sql"

    sudo docker cp "/tmp/werewolf_docker.sql" werewolf-sql:/var/opt/mssql/data/werewolf_docker.sql
    sleep 10
    sudo docker exec -i werewolf-sql /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U SA -P "Werewolf@12345" -i /var/opt/mssql/data/werewolf_docker.sql

    echo ""
    echo "Setting Environment Variables..."
    # We export these for the current shell session, but to persist them they would need to be added to ~/.bashrc or similar
    export $API_VAR="$API_TOKEN"
    if [ ! -z "$OPENAI_TOKEN" ]; then
        export WEREWOLF_OPENAI_API_KEY="$OPENAI_TOKEN"
        echo "OpenAI API Key configured."
    fi
    export WEREWOLF_DB_CONNECTION_STRING="metadata=res://*/WerewolfModel.csdl|res://*/WerewolfModel.ssdl|res://*/WerewolfModel.msl;provider=System.Data.SqlClient;provider connection string=\"data source=localhost,1433;initial catalog=werewolf;user id=SA;password=Werewolf@12345;MultipleActiveResultSets=True;App=EntityFramework;TrustServerCertificate=True\""
    export WEREWOLF_BOT_API_TOKEN="$API_TOKEN"

    echo ""
    echo "Compiling project in $BUILD_CONFIG mode..."
    dotnet build "Werewolf for Telegram/WerewolfForTelegram.sln" -c $BUILD_CONFIG

    echo ""
    echo "Setting up server directories..."
    ROOT_DIR="$(pwd)/Server"
    mkdir -p "$ROOT_DIR/Control"
    mkdir -p "$ROOT_DIR/Node 1"
    mkdir -p "$ROOT_DIR/Logs"
    mkdir -p "$ROOT_DIR/Languages"

    echo "Copying compiled files..."
    cp -r "Werewolf for Telegram/Werewolf Control/bin/$BUILD_CONFIG/net8.0/." "$ROOT_DIR/Control/"
    cp -r "Werewolf for Telegram/Werewolf Node/bin/$BUILD_CONFIG/net8.0/." "$ROOT_DIR/Node 1/"
    cp -r "Werewolf for Telegram/Languages/"* "$ROOT_DIR/Languages/"

    echo ""
    echo "Setup Complete! To start the applications, run:"
    echo "export $API_VAR=\"$API_TOKEN\""
    echo "export WEREWOLF_BOT_API_TOKEN=\"$API_TOKEN\""
    echo "export WEREWOLF_DB_CONNECTION_STRING=\"$WEREWOLF_DB_CONNECTION_STRING\""
    echo "cd '$ROOT_DIR/Control' && ./WerewolfControl &"
    echo "cd '$ROOT_DIR/Node 1' && ./WerewolfNode &"
fi
