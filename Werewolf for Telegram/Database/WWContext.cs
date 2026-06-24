using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using MongoDB.Driver;

namespace Database
{
    public partial class WWContext : IDisposable
    {
        private readonly IMongoDatabase _database;

        public WWContext()
        {
            var connectionString = Environment.GetEnvironmentVariable("WEREWOLF_MONGO_CONNECTION_STRING")
                ?? Environment.GetEnvironmentVariable("WEREWOLF_DB_CONNECTION_STRING")
                ?? RegHelper.DBConnString;

            if (string.IsNullOrWhiteSpace(connectionString))
            {
                connectionString = "mongodb://localhost:27017/werewolf";
            }
            var client = new MongoClient(connectionString);
            _database = client.GetDatabase("werewolf");
        }

        public IMongoCollection<Admin> Admins => _database.GetCollection<Admin>("Admins");
        public IMongoCollection<Game> Games => _database.GetCollection<Game>("Games");
        public IMongoCollection<Group> Groups => _database.GetCollection<Group>("Groups");
        public IMongoCollection<KillMethod> KillMethods => _database.GetCollection<KillMethod>("KillMethods");
        public IMongoCollection<Player> Players => _database.GetCollection<Player>("Players");
        public IMongoCollection<NotifyGame> NotifyGames => _database.GetCollection<NotifyGame>("NotifyGames");
        public IMongoCollection<GlobalStat> GlobalStats => _database.GetCollection<GlobalStat>("GlobalStats");
        public IMongoCollection<PlayerStat> PlayerStats => _database.GetCollection<PlayerStat>("PlayerStats");
        public IMongoCollection<GroupStat> GroupStats => _database.GetCollection<GroupStat>("GroupStats");
        public IMongoCollection<DailyCount> DailyCounts => _database.GetCollection<DailyCount>("DailyCounts");
        public IMongoCollection<GlobalBan> GlobalBans => _database.GetCollection<GlobalBan>("GlobalBans");
        public IMongoCollection<BotStatu> BotStatus => _database.GetCollection<BotStatu>("BotStatus");
        public IMongoCollection<ContestTerm> ContestTerms => _database.GetCollection<ContestTerm>("ContestTerms");
        public IMongoCollection<Language> Language => _database.GetCollection<Language>("Language");
        public IMongoCollection<GameKill> GameKills => _database.GetCollection<GameKill>("GameKills");
        public IMongoCollection<GamePlayer> GamePlayers => _database.GetCollection<GamePlayer>("GamePlayers");
        public IMongoCollection<RefreshDate> RefreshDate => _database.GetCollection<RefreshDate>("RefreshDate");
        public IMongoCollection<GroupRanking> GroupRanking => _database.GetCollection<GroupRanking>("GroupRanking");

        public void SaveChanges() { }
        public Task SaveChangesAsync() => Task.CompletedTask;
        public void Dispose() { }
    }
}
