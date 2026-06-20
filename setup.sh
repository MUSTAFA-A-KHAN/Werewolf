#!/bin/bash
set -e

# Ensure working directory is the script location
cd "$(dirname "$0")"

echo "Welcome to Werewolf for Telegram Local Setup (Linux)!"
echo "====================================================="

# 1. Ensure Dependencies
if ! command -v docker &> /dev/null; then
    echo "Error: docker is not installed."
    exit 1
fi
if ! command -v mono &> /dev/null; then
    echo "Error: mono is not installed. Please install mono-complete."
    exit 1
fi
if ! command -v msbuild &> /dev/null; then
    echo "Error: msbuild is not installed. Please install mono-devel/msbuild."
    exit 1
fi
if ! command -v nuget &> /dev/null; then
    echo "Warning: nuget not found in PATH, will try to download it."
    if [ ! -f "nuget.exe" ]; then
        curl -o nuget.exe https://dist.nuget.org/win-x86-commandline/latest/nuget.exe
    fi
    NUGET_CMD="mono nuget.exe"
else
    NUGET_CMD="nuget"
fi

# 2. Choose Build Mode
echo ""
echo "Select setup mode:"
echo "  1. Release / normal setup"
echo "  2. Debug / dev setup"
read -p "Enter 1 or 2 [1]: " SETUP_MODE
if [ "$SETUP_MODE" == "2" ]; then
    export BUILD_CONFIG=Debug
    export API_ENV_NAME=DebugAPI
else
    export BUILD_CONFIG=Release
    export API_ENV_NAME=ProductionAPI
fi

# 3. Prompt for Telegram API Token
read -p "Please enter your Telegram Bot API Token for $BUILD_CONFIG: " API_TOKEN
if [ -z "$API_TOKEN" ]; then
    echo "Error: API Token cannot be empty."
    exit 1
fi

# 4. Setup Docker MSSQL Container
echo ""
echo "Starting MSSQL Docker container..."
if ! docker ps -a | grep -q werewolf-sql; then
    docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Werewolf@12345" -p 1433:1433 --name werewolf-sql -d mcr.microsoft.com/mssql/server:2022-latest
else
    docker start werewolf-sql
fi

echo "Waiting for SQL Server to initialize (30 seconds)..."
sleep 30

# 5. Initialize Database
echo ""
echo "Creating Database..."
sed "s|C:\\\Program Files\\\Microsoft SQL Server\\\MSSQL12.SQLEXPRESS\\\MSSQL\\\DATA\\\|/var/opt/mssql/data/|g" werewolf.sql > /tmp/werewolf_docker.sql
docker cp /tmp/werewolf_docker.sql werewolf-sql:/var/opt/mssql/data/werewolf_docker.sql

sleep 10
docker exec -i werewolf-sql /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U SA -P "Werewolf@12345" -i /var/opt/mssql/data/werewolf_docker.sql || echo "Database may already be initialized."

# 6. Set Environment Variables
echo ""
echo "Setting Environment Variables for runtime..."
export $API_ENV_NAME="$API_TOKEN"
export BotConnectionString="metadata=res://*/WerewolfModel.csdl|res://*/WerewolfModel.ssdl|res://*/WerewolfModel.msl;provider=System.Data.SqlClient;provider connection string=\"data source=localhost,1433;initial catalog=werewolf;user id=SA;password=Werewolf@12345;MultipleActiveResultSets=True;App=EntityFramework;TrustServerCertificate=True\""
export DBConnectionString="$BotConnectionString"

# Create a shell script to run the bot with the correct environment variables later
cat << RUNSCRIPT > run_werewolf.sh
#!/bin/bash
export $API_ENV_NAME="$API_TOKEN"
export BotConnectionString="$BotConnectionString"
export DBConnectionString="$DBConnectionString"

cd Server/Control
mono "Werewolf Control.exe" &
cd ../Node\ 1
mono "Werewolf Node.exe" &

echo "Both Control and Node have been launched in the background."
wait
RUNSCRIPT
chmod +x run_werewolf.sh

# 7. Build the Solution
echo ""
echo "Restoring NuGet packages..."
$NUGET_CMD restore "Werewolf for Telegram/WerewolfForTelegram.sln" -PackagesDirectory "Werewolf for Telegram/packages"

echo "Compiling project in $BUILD_CONFIG mode..."
msbuild "Werewolf for Telegram/WerewolfForTelegram.sln" /p:Configuration=$BUILD_CONFIG /t:Build /m /p:RestorePackagesConfig=true

# 8. Setup Directory Structure
echo ""
echo "Setting up server directories..."
ROOT_DIR="$(pwd)/Server"
mkdir -p "$ROOT_DIR/Control"
mkdir -p "$ROOT_DIR/Node 1"
mkdir -p "$ROOT_DIR/Logs"
mkdir -p "$ROOT_DIR/Languages"

echo "Copying compiled files..."
cp -R "Werewolf for Telegram/Werewolf Control/bin/$BUILD_CONFIG/"* "$ROOT_DIR/Control/" || true
cp -R "Werewolf for Telegram/Werewolf Node/bin/$BUILD_CONFIG/"* "$ROOT_DIR/Node 1/" || true
cp -R "Werewolf for Telegram/Languages/"* "$ROOT_DIR/Languages/" || true

# 9. Start the applications
echo ""
echo "Setup Complete! Starting Werewolf Bot in $BUILD_CONFIG mode..."
./run_werewolf.sh
