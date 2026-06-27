package main

import (
	"log/slog"
	"os"
	"os/signal"
	"syscall"

	"github.com/werewolf-go/werewolf/internal/config"
	"github.com/werewolf-go/werewolf/internal/logger"
	"github.com/werewolf-go/werewolf/internal/repositories"
)

func main() {
	// 1. Init Logger
	logger.InitLogger(os.Getenv("ENV"))
	slog.Info("Starting Werewolf Node (Game Engine)...")

	// 2. Load Config
	cfg := config.LoadConfig()

	// 3. Init Database
	db, err := repositories.Connect(cfg)
	if err != nil {
		slog.Error("Failed to connect to MongoDB", "error", err)
		os.Exit(1)
	}
	defer db.Disconnect()

	// 4. Here we would connect to the Control Node via gRPC/TCP
	// and register this worker to receive game messages.
    // For now, we stub the worker loop.

	// 6. Graceful Shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	slog.Info("Shutting down Node...")
	slog.Info("Node stopped gracefully.")
}
