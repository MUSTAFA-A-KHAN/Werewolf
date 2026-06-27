package config

import (
	"os"
    "github.com/joho/godotenv"
    "log"
)

type Config struct {
	TelegramBotToken string
	MongoURI         string
	DatabaseName     string
	OpenAIAPIKey     string
	Port             string
}

func LoadConfig() *Config {
    // Attempt to load .env file if it exists
    err := godotenv.Load()
    if err != nil {
        log.Println("No .env file found, relying on environment variables.")
    }

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	dbName := os.Getenv("WEREWOLF_DB_NAME")
	if dbName == "" {
		dbName = "werewolf"
	}

	return &Config{
		TelegramBotToken: os.Getenv("WEREWOLF_BOT_API_TOKEN"),
		MongoURI:         os.Getenv("WEREWOLF_MONGO_CONNECTION_STRING"),
		DatabaseName:     dbName,
		OpenAIAPIKey:     os.Getenv("WEREWOLF_OPENAI_API_KEY"),
		Port:             port,
	}
}
