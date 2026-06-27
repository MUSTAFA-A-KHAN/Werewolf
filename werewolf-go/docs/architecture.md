# Architecture Document

## Overview
The "Werewolf for Telegram" bot is a large distributed application designed to handle highly concurrent chat game sessions. The system consists of multiple components communicating together.

## System Components (Current vs Go Target)

1. **Werewolf Control (Router/Manager)**
   - *Current:* C# TCP Server. Receives webhooks/updates from Telegram, routes them to available Node instances based on load, manages Node lifecycle.
   - *Go Target:* `cmd/control`. Acts as the Telegram webhook entrypoint (or long polling if used in dev). Monitors Node health via gRPC/TCP/Redis. Forwards traffic.

2. **Werewolf Node (Game Engine)**
   - *Current:* C# Worker. Runs the massive `Werewolf.cs` state machine for each game instance. Communicates with Control via custom TCP protocol.
   - *Go Target:* `cmd/node`. Executes the core game loop for multiple groups. State stored in memory during runtime, saved to MongoDB upon game conclusion. Heavy use of Go channels and context for game lifecycle management.

3. **Werewolf Website (Admin/Stats)**
   - *Current:* ASP.NET MVC / WebAPI for managing bans, stats, and configuration.
   - *Go Target:* `cmd/website`. A Go HTTP server (e.g., using Gin or Fiber) serving JSON APIs and potentially HTML templates.

4. **Donation Site**
   - *Current:* ASP.NET Webhook receiver for Xsolla and Stripe.
   - *Go Target:* `cmd/donation`. Dedicated Go microservice handling payment webhooks and inserting premium status into the DB.

5. **Build Automation & Stats Rotation**
   - *Current:* C# background jobs/scripts.
   - *Go Target:* Replaced by background goroutines (`internal/scheduler`) or small cron binaries.

## Communication Pattern
- The Go implementation will retain the Control -> Node architecture.
- Communication between Control and Nodes can be implemented via **gRPC** for efficient, strongly-typed internal RPC, or standard Go net/rpc if simpler.
- Web services will communicate with the database (MongoDB) and optionally the Control node to send broadcast messages.

## Infrastructure
- **Language:** Go 1.22+
- **Database:** MongoDB Atlas (official `go.mongodb.org/mongo-driver`)
- **Logging:** `slog` or `zap` for structured logging.
- **Deployment:** Docker / Docker Compose for simple orchestrations.
