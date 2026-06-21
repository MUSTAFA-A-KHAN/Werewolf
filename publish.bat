@echo off
setlocal

echo Publishing Werewolf Control...
dotnet publish "Werewolf for Telegram\Werewolf Control\WerewolfControl.csproj" -c Release -r win-x64 --self-contained false -o "publish\win-x64\Werewolf Control"
dotnet publish "Werewolf for Telegram\Werewolf Control\WerewolfControl.csproj" -c Release -r win-x64 --self-contained true -o "publish\win-x64-standalone\Werewolf Control"

echo Publishing Werewolf Node...
dotnet publish "Werewolf for Telegram\Werewolf Node\WerewolfNode.csproj" -c Release -r win-x64 --self-contained false -o "publish\win-x64\Werewolf Node"
dotnet publish "Werewolf for Telegram\Werewolf Node\WerewolfNode.csproj" -c Release -r win-x64 --self-contained true -o "publish\win-x64-standalone\Werewolf Node"

echo Publishing for Linux...
dotnet publish "Werewolf for Telegram\Werewolf Control\WerewolfControl.csproj" -c Release -r linux-x64 --self-contained false -o "publish\linux-x64\Werewolf Control"
dotnet publish "Werewolf for Telegram\Werewolf Control\WerewolfControl.csproj" -c Release -r linux-x64 --self-contained true -o "publish\linux-x64-standalone\Werewolf Control"

dotnet publish "Werewolf for Telegram\Werewolf Node\WerewolfNode.csproj" -c Release -r linux-x64 --self-contained false -o "publish\linux-x64\Werewolf Node"
dotnet publish "Werewolf for Telegram\Werewolf Node\WerewolfNode.csproj" -c Release -r linux-x64 --self-contained true -o "publish\linux-x64-standalone\Werewolf Node"

echo Done.
