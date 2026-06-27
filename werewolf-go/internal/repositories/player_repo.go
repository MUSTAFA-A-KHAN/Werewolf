package repositories

import (
	"context"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type Player struct {
	TelegramID int64  `bson:"telegram_id"`
	Name       string `bson:"name"`
	Username   string `bson:"username"`
	Banned     bool   `bson:"banned"`
	IsAdmin    bool   `bson:"is_admin"`
}

type PlayerRepository struct {
	collection *mongo.Collection
}

func NewPlayerRepository(db *Database) *PlayerRepository {
	return &PlayerRepository{
		collection: db.Db.Collection("players"),
	}
}

func (r *PlayerRepository) GetPlayerByTelegramID(ctx context.Context, id int64) (*Player, error) {
	var player Player
	err := r.collection.FindOne(ctx, bson.M{"telegram_id": id}).Decode(&player)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, nil // Return nil if not found
		}
		return nil, err
	}
	return &player, nil
}

func (r *PlayerRepository) UpsertPlayer(ctx context.Context, player *Player) error {
    // Basic upsert logic
    opts := options.Update().SetUpsert(true)
    filter := bson.M{"telegram_id": player.TelegramID}
    update := bson.M{"$set": player}

    _, err := r.collection.UpdateOne(ctx, filter, update, opts)
    return err
}
