package models

import "time"

// Models definition for basic entities
type PlayerStats struct {
	GamesPlayed   int `bson:"games_played"`
	GamesWon      int `bson:"games_won"`
	GamesLost     int `bson:"games_lost"`
	GamesSurvived int `bson:"games_survived"`
	Kills         int `bson:"kills"`
	Deaths        int `bson:"deaths"`
}

type Group struct {
	TelegramID        int64     `bson:"telegram_id"`
	Name              string    `bson:"name"`
	Language          string    `bson:"language"`
	PreferredGameMode string    `bson:"preferred_game_mode"`
	GroupAdmins       []int64   `bson:"group_admins"`
	CreatedAt         time.Time `bson:"created_at"`
}

type Game struct {
	ID              string        `bson:"_id,omitempty"`
	GroupID         int64         `bson:"group_id"`
	Language        string        `bson:"language"`
	StartedAt       time.Time     `bson:"started_at"`
	EndedAt         time.Time     `bson:"ended_at"`
	DurationSeconds int           `bson:"duration_seconds"`
	Winner          string        `bson:"winner"`
	Players         []GamePlayer  `bson:"players"`
}

type GamePlayer struct {
	PlayerID int64  `bson:"player_id"`
	Role     string `bson:"role"`
	Won      bool   `bson:"won"`
	Survived bool   `bson:"survived"`
}
