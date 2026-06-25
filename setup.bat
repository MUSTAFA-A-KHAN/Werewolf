@echo off
echo Welcome to Werewolf for Telegram Local Setup (Go Edition Windows)!
echo ================================================================

set /p API_TOKEN="Telegram Bot Token: "
if "%API_TOKEN%"=="" (
    echo API token is required.
    goto :eof
)

set /p MONGO_URL="MongoDB Atlas Connection String (e.g. mongodb+srv://...): "
if "%MONGO_URL%"=="" (
    echo MongoDB connection string is required.
    goto :eof
)

set /p OPENAI_TOKEN="OpenAI API Key (optional): "

echo.
echo Writing .env for Go applications...
(
    echo WEREWOLF_BOT_API_TOKEN=%API_TOKEN%
    echo WEREWOLF_OPENAI_API_KEY=%OPENAI_TOKEN%
    echo WEREWOLF_MONGO_CONNECTION_STRING=%MONGO_URL%
    echo WEREWOLF_DB_NAME=werewolf
    echo PORT=8080
    echo ENV=development
) > werewolf-go\.env

echo.
echo Building Go applications...
cd werewolf-go

go mod tidy
if not exist bin mkdir bin
go build -o bin\control.exe cmd\control\main.go
go build -o bin\node.exe cmd\node\main.go
go build -o bin\website.exe cmd\website\main.go
go build -o bin\donation.exe cmd\donation\main.go

echo.
echo Preparing deployment...
cd ..

set ROOT_DIR=%cd%\Server
if not exist "%ROOT_DIR%\Control" mkdir "%ROOT_DIR%\Control"
if not exist "%ROOT_DIR%\Node 1" mkdir "%ROOT_DIR%\Node 1"
if not exist "%ROOT_DIR%\Logs" mkdir "%ROOT_DIR%\Logs"
if not exist "%ROOT_DIR%\Languages" mkdir "%ROOT_DIR%\Languages"
if not exist "%ROOT_DIR%\Website" mkdir "%ROOT_DIR%\Website"

copy /y werewolf-go\bin\control.exe "%ROOT_DIR%\Control\"
copy /y werewolf-go\bin\node.exe "%ROOT_DIR%\Node 1\"
copy /y werewolf-go\bin\website.exe "%ROOT_DIR%\Website\"
copy /y werewolf-go\.env "%ROOT_DIR%\"

if exist "Werewolf for Telegram\Languages" (
    xcopy /e /y "Werewolf for Telegram\Languages\*" "%ROOT_DIR%\Languages\"
)

echo.
echo Starting Services...
cd "%ROOT_DIR%\Control"
copy /y ..\.env .env
start "Werewolf Control Node" control.exe

cd "%ROOT_DIR%\Node 1"
copy /y ..\.env .env
start "Werewolf Worker Node" node.exe

cd "%ROOT_DIR%\Website"
copy /y ..\.env .env
start "Werewolf Website" website.exe

echo.
echo Services started. Check Server folder for logs and binaries.
