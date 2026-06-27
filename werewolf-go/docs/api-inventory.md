# API & Background Job Inventory

## External APIs (Consumed)
- **Telegram Bot API:** Used by Control (fetching updates) and Nodes (sending messages, editing keyboards).
- **OpenAI API:** Consumed by Node (`DummyDefense.cs`) to generate AI responses for dummy players.

## Internal APIs (Provided)
- **Control TCP Server:** Custom binary/TCP protocol currently used by Worker nodes to register themselves and receive messages. (Target: gRPC).
- **Admin API (`AdminApiController.cs`):**
  - `GET /api/admin/status`
  - `POST /api/admin/broadcast`
  - `POST /api/admin/ban`
- **Donation Webhooks:**
  - `POST /webhook/stripe`
  - `POST /webhook/xsolla`
  - `POST /xsolla`

## Background Jobs
- **Node Monitor:** `Werewolf Control/Program.cs` monitors Node memory, CPU, and game count to dynamically spawn or kill processes.
- **Stats Rotation:** Runs periodically to finalize daily counts and update global leaderboards.
- **Game Timers:** Each running `Werewolf.cs` instance has active timers (`Timer` or loops) to handle day/night transitions if users don't vote in time.
- **Clear Updates:** Small script to clear the Telegram update queue if it gets stuck.

## Web Application Routes
- Account management (Login, Register, Roles).
- Group list / Player stats pages.
- Global bans management.
