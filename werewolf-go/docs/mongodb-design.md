# MongoDB Collection Design

## Introduction
The system is migrating from Microsoft SQL Server to MongoDB Atlas. We will model our collections to take advantage of document-based persistence while maintaining all business requirements.

## Proposed Collections

### 1. `players`
Stores individual player information, their statistics, and global status.
* `_id` / `telegram_id` (int64)
* `name` (string)
* `username` (string)
* `banned` (bool)
* `is_admin` (bool)
* `stats` (subdocument)
  * `games_played`
  * `games_won`
  * `games_lost`
  * `games_survived`
  * `kills`
  * `deaths`
* `created_at` (timestamp)
* `updated_at` (timestamp)

### 2. `groups`
Stores telegram group information where the bot operates.
* `_id` / `telegram_id` (int64)
* `name` (string)
* `language` (string)
* `preferred_game_mode` (string)
* `stats` (subdocument)
  * `total_games`
  * `total_players`
* `group_admins` (array of int64)
* `created_at` (timestamp)

### 3. `games`
Stores historical data about a single game played in a group.
* `_id` (ObjectID)
* `group_id` (int64)
* `language` (string)
* `started_at` (timestamp)
* `ended_at` (timestamp)
* `duration_seconds` (int)
* `winner` (string - e.g., "village", "wolf", "serial_killer")
* `players` (array of subdocuments)
  * `player_id` (int64)
  * `role` (string)
  * `won` (bool)
  * `survived` (bool)
* `kills` (array of subdocuments)
  * `killer_id` (int64)
  * `victim_id` (int64)
  * `method` (string)
  * `day` (int)

### 4. `system_stats`
Global tracking for daily counts and top-level stats.
* `_id` (ObjectID)
* `date` (string/date)
* `games_played` (int)
* `players_active` (int)
* `messages_processed` (int)

### 5. `web_users`
User accounts for the administration and stats website (Replaces AspNetUsers).
* `_id` (ObjectID)
* `username` (string)
* `email` (string)
* `password_hash` (string)
* `roles` (array of strings)

### 6. `localization`
Replaces LangPackGif and DB-stored language mappings if applicable (we may also just use the XML files as requested initially, but can store meta-information here).

## Notes
- We eliminate joining tables like `GamePlayer` or `GroupAdmin` by embedding them into their parent documents (`games.players` and `groups.group_admins`).
- High volume analytics like `DailyCount` or `RefreshDate` can be moved to standard MongoDB time-series collections or `system_stats` collections.
