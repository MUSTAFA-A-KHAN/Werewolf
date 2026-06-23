using System;
using System.Collections.Generic;
using System.Linq;
using MongoDB.Driver;
using MongoDB.Bson;

namespace Database
{
    public class v_GroupRanking
    {
        public long GroupId { get; set; }
        public string Name { get; set; }
        public string Language { get; set; }
        public long? Ranking { get; set; }
        public DateTime? LastRefresh { get; set; }
        public int Id { get; set; }
    }

    public partial class WWContext
    {
        public IEnumerable<int?> GetIdleKills24Hours(long? userid) => new List<int?>();
        public int RestoreAccount(long? oldTGId, long? newTGId)
        {
            if (oldTGId.HasValue && newTGId.HasValue)
            {
                var filter = Builders<Player>.Filter.Eq(x => x.TelegramId, oldTGId.Value);
                var update = Builders<Player>.Update.Set(x => x.TelegramId, newTGId.Value);
                Players.UpdateOne(filter, update);
            }
            return 1;
        }
        public IEnumerable<int?> GetGroupIdleKills24Hours(long? userid, long? groupid) => new List<int?>();

        public IEnumerable<v_GroupRanking> v_GroupRanking
        {
            get
            {
                var rankings = GroupRanking.Find(x => true).ToList();
                var groups = Groups.Find(x => true).ToList();
                var result = new List<v_GroupRanking>();
                foreach (var r in rankings)
                {
                    var g = groups.FirstOrDefault(x => x.Id == r.GroupId);
                    if (g != null)
                    {
                        result.Add(new v_GroupRanking
                        {
                            Id = r.Id,
                            GroupId = g.GroupId,
                            Name = g.Name,
                            Language = r.Language,
                            Ranking = (long?)r.Ranking,
                            LastRefresh = null
                        });
                    }
                }
                return result;
            }
        }

        // Mock result classes
        public class getPlayTime_Result { public int? Average { get; set; } public int? Minimum { get; set; } public int? Maximum { get; set; } }
        public class getRoles_Result { public string name { get; set; } public string role { get; set; } }
        public class PlayerMostKilled_Result { public string Name { get; set; } public long TelegramId { get; set; } public int? times { get; set; } }
        public class PlayerMostKilledBy_Result { public string Name { get; set; } public long TelegramId { get; set; } public int? times { get; set; } }
        public class PlayerRoles_Result { public int? times { get; set; } public string role { get; set; } }
        public class GlobalDay1Death_Result1 { public int? pct { get; set; } public string Name { get; set; } public long TelegramId { get; set; } }
        public class GlobalDay1Lynch_Result1 { public int? pct { get; set; } public string Name { get; set; } public long TelegramId { get; set; } }
        public class GlobalNight1Death_Result1 { public int? pct { get; set; } public string Name { get; set; } public long TelegramId { get; set; } }
        public class GlobalSurvivor_Result1 { public decimal? pct { get; set; } public string Name { get; set; } public long TelegramId { get; set; } }
        public class GroupDay1Death_Result1 { public int? pct { get; set; } public string Name { get; set; } public long TelegramId { get; set; } }
        public class GroupDay1Lynch_Result1 { public int? pct { get; set; } public string Name { get; set; } public long TelegramId { get; set; } }
        public class GroupNight1Death_Result1 { public int? pct { get; set; } public string Name { get; set; } public long TelegramId { get; set; } }
        public class GroupSurvivor_Result1 { public int? pct { get; set; } public string Name { get; set; } public long TelegramId { get; set; } }
        public class getDailyCounts_Result { public DateTime? Date { get; set; } public int? Count { get; set; } }

        public IEnumerable<getPlayTime_Result> getPlayTime(int? playerCount) => new List<getPlayTime_Result>();
        public IEnumerable<getRoles_Result> getRoles(string groupName) => new List<getRoles_Result>();
        public IEnumerable<PlayerMostKilled_Result> PlayerMostKilled(long? pid) => new List<PlayerMostKilled_Result>();
        public IEnumerable<PlayerMostKilledBy_Result> PlayerMostKilledBy(long? pid) => new List<PlayerMostKilledBy_Result>();
        public IEnumerable<PlayerRoles_Result> PlayerRoles(long? pid) => new List<PlayerRoles_Result>();
        public IEnumerable<GlobalDay1Death_Result1> GlobalDay1Death() => new List<GlobalDay1Death_Result1>();
        public IEnumerable<GlobalDay1Lynch_Result1> GlobalDay1Lynch() => new List<GlobalDay1Lynch_Result1>();
        public IEnumerable<GlobalNight1Death_Result1> GlobalNight1Death() => new List<GlobalNight1Death_Result1>();
        public IEnumerable<GlobalSurvivor_Result1> GlobalSurvivor() => new List<GlobalSurvivor_Result1>();
        public IEnumerable<GroupDay1Death_Result1> GroupDay1Death(long? groupid) => new List<GroupDay1Death_Result1>();
        public IEnumerable<GroupDay1Lynch_Result1> GroupDay1Lynch(long? groupid) => new List<GroupDay1Lynch_Result1>();
        public IEnumerable<GroupNight1Death_Result1> GroupNight1Death(long? groupid) => new List<GroupNight1Death_Result1>();
        public IEnumerable<GroupSurvivor_Result1> GroupSurvivor(long? groupid) => new List<GroupSurvivor_Result1>();
        public IEnumerable<getDailyCounts_Result> getDailyCounts() => new List<getDailyCounts_Result>();
    }
}
