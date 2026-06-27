package main

import (
	"log/slog"
	"os"
	"os/signal"
	"syscall"

	"github.com/werewolf-go/werewolf/internal/config"
	"github.com/werewolf-go/werewolf/internal/logger"
	"github.com/werewolf-go/werewolf/internal/repositories"
	"github.com/werewolf-go/werewolf/internal/telegram"
	tele "gopkg.in/telebot.v3"
)

func main() {
	// 1. Init Logger
	logger.InitLogger(os.Getenv("ENV"))
	slog.Info("Starting Werewolf Control Node...")

	// 2. Load Config
	cfg := config.LoadConfig()

	// 3. Init Database
	db, err := repositories.Connect(cfg)
	if err != nil {
		slog.Error("Failed to connect to MongoDB", "error", err)
		os.Exit(1)
	}
	defer db.Disconnect()

	// 4. Init Telegram Bot
	bot, err := telegram.NewBot(cfg)
	if err != nil {
		slog.Error("Failed to init Telegram Bot", "error", err)
		os.Exit(1)
	}

	// Basic route registration
	bot.Client.Handle("/start", func(c tele.Context) error {
		return c.Send("Welcome to Werewolf for Telegram! (Go Edition)")
	})

    bot.Client.Handle("/ping", func(c tele.Context) error {
		return c.Send("pong")
	})

	// 5. Start Bot in background
	go bot.Start()

	// 6. Graceful Shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	slog.Info("Shutting down Control Node...")
	bot.Stop()
	slog.Info("Control Node stopped gracefully.")
}
