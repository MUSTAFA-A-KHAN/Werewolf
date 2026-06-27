package telegram

import (
	"log/slog"
	"time"

	"github.com/werewolf-go/werewolf/internal/config"
	tele "gopkg.in/telebot.v3"
)

type Bot struct {
	Client *tele.Bot
}

func NewBot(cfg *config.Config) (*Bot, error) {
	pref := tele.Settings{
		Token:  cfg.TelegramBotToken,
		Poller: &tele.LongPoller{Timeout: 10 * time.Second},
	}

	b, err := tele.NewBot(pref)
	if err != nil {
		return nil, err
	}

	return &Bot{
		Client: b,
	}, nil
}

func (b *Bot) Start() {
	slog.Info("Starting Telegram Bot...")
	b.Client.Start()
}

func (b *Bot) Stop() {
	slog.Info("Stopping Telegram Bot...")
	b.Client.Stop()
}
