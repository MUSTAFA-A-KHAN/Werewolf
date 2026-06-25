package main

import (
	"fmt"
	"log/slog"
	"net/http"
	"os"

	"github.com/werewolf-go/werewolf/internal/config"
	"github.com/werewolf-go/werewolf/internal/logger"
)

func main() {
	logger.InitLogger(os.Getenv("ENV"))
	slog.Info("Starting Werewolf Website API...")

	cfg := config.LoadConfig()

	mux := http.NewServeMux()

	// Admin API Status
	mux.HandleFunc("/api/admin/status", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprintf(w, `{"status": "ok", "nodes": 1}`)
	})

	// Add more routes for AccountManagement, GlobalBans, etc.

	addr := ":" + cfg.Port
	slog.Info("Listening on " + addr)
	if err := http.ListenAndServe(addr, mux); err != nil {
		slog.Error("Server failed", "error", err)
	}
}
