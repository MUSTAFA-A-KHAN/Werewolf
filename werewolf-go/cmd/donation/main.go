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
	slog.Info("Starting Donation Site Webhooks...")

	cfg := config.LoadConfig()

	mux := http.NewServeMux()

	mux.HandleFunc("/webhook/stripe", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
			return
		}
		slog.Info("Received Stripe Webhook")
		w.WriteHeader(http.StatusOK)
		fmt.Fprintf(w, `{"status": "processed"}`)
	})

	mux.HandleFunc("/webhook/xsolla", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
			return
		}
		slog.Info("Received Xsolla Webhook")
		w.WriteHeader(http.StatusOK)
		fmt.Fprintf(w, `{"status": "processed"}`)
	})

	addr := ":" + cfg.Port
	slog.Info("Listening on " + addr)
	if err := http.ListenAndServe(addr, mux); err != nil {
		slog.Error("Server failed", "error", err)
	}
}
