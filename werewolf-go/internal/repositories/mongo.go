package repositories

import (
	"context"
	"log"
	"time"

	"github.com/werewolf-go/werewolf/internal/config"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type Database struct {
	Client *mongo.Client
	Db     *mongo.Database
}

func Connect(cfg *config.Config) (*Database, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	clientOptions := options.Client().ApplyURI(cfg.MongoURI)
	client, err := mongo.Connect(ctx, clientOptions)
	if err != nil {
		return nil, err
	}

	err = client.Ping(ctx, nil)
	if err != nil {
		return nil, err
	}

	log.Println("Connected to MongoDB Atlas!")

	return &Database{
		Client: client,
		Db:     client.Database(cfg.DatabaseName),
	}, nil
}

func (d *Database) Disconnect() {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := d.Client.Disconnect(ctx); err != nil {
		log.Printf("Error disconnecting from database: %v", err)
	}
}
