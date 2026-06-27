# Migration Status Report

## Current State
We have successfully set up the foundation for the "Werewolf for Telegram" Go migration.

### Completed:
1. **Architecture & Design Phase:** Analyzed the `script.sql` (1200+ tables/objects) and the 30k+ line C# repository. Generated `architecture.md`, `mongodb-design.md`, `service-dependencies.md`, and `api-inventory.md`.
2. **Go Project Structure:** Scaffolded the `werewolf-go` repository.
3. **Core Infrastructure:** Implemented environment config loading, `slog` structured logging, and MongoDB Atlas connection utilities.
4. **Shared Libs:** Implemented XML parser for legacy language files. Integrated `telebot.v3` for the Telegram API.
5. **Control Node:** Scaffolded `cmd/control` as the webhook/routing entrypoint with graceful shutdown.
6. **Worker Node / Game Engine:** Scaffolded `cmd/node` and created the `internal/game` package. Redesigned the C# `Timer` logic to use idiomatic Go channels and contexts for the day/night lifecycle.
7. **Auxiliary Services:** Scaffolded standard Go HTTP servers for the admin website and the donation webhooks.

### Remaining Tasks for Full Implementation:
1. **Database Mappers:** Finish converting EF queries from `Database/` to Go MongoDB queries (`bson.M` filters) inside `internal/repositories/`.
2. **Game Logic Porting (Massive):** Translate the 6,600+ lines of `Werewolf.cs` into modular files within `internal/game`. Create specific structs/methods for each role (Wolf, Seer, etc.) instead of huge `switch` statements.
3. **OpenAI Defense:** Re-implement the GPT text-generation calls in `internal/openai`.
4. **Control-Node RPC:** Implement the network connection (e.g. gRPC) between `cmd/control` and `cmd/node` to replace the custom TCP protocol.
5. **Full Web API:** Translate all legacy ASP.NET MVC controllers to Go HTTP handlers.
6. **Dockerization:** Create `Dockerfile` and `docker-compose.yml` configurations for deployment.
