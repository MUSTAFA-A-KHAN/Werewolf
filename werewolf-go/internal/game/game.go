package game

import (
	"context"
	"log/slog"
	"sync"
	"time"

	"github.com/werewolf-go/werewolf/internal/models"
)

// GameState represents the state machine logic from Werewolf.cs
type GameState string

const (
	StateJoining GameState = "Joining"
	StateRunning GameState = "Running"
	StateEnded   GameState = "Ended"
)

type Game struct {
	ID        string
	GroupID   int64
	Language  string
	State     GameState
	Players   []*models.GamePlayer
	StartedAt time.Time

	mu        sync.RWMutex
}

func NewGame(groupID int64, lang string) *Game {
	return &Game{
		GroupID:  groupID,
		Language: lang,
		State:    StateJoining,
	}
}

// Start transitions from joining to running, and begins the game loops.
func (g *Game) Start(ctx context.Context) {
	g.mu.Lock()
	if g.State != StateJoining {
		g.mu.Unlock()
		return
	}
	g.State = StateRunning
	g.StartedAt = time.Now()
	g.mu.Unlock()

	slog.Info("Game Started", "group_id", g.GroupID)

	// Stub out the day/night loop using channels
	go g.gameLoop(ctx)
}

func (g *Game) gameLoop(ctx context.Context) {
	ticker := time.NewTicker(1 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			slog.Info("Game Context Cancelled", "group_id", g.GroupID)
			g.End()
			return
		case <-ticker.C:
			// Handle tick - check if we should transition day->night, kill timers, etc.
			// This replaces the C# Timer.
		}
	}
}

func (g *Game) End() {
	g.mu.Lock()
	defer g.mu.Unlock()
	g.State = StateEnded
	slog.Info("Game Ended", "group_id", g.GroupID)
}
