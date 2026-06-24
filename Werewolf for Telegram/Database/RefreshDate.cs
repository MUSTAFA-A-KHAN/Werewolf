namespace Database
{
    using System;
    using MongoDB.Bson;
    using MongoDB.Bson.Serialization.Attributes;

    [BsonIgnoreExtraElements]
    public partial class RefreshDate
    {
        [BsonId]
        public ObjectId MongoId { get; set; }

        public string Lock { get; set; }
        public DateTime Date { get; set; }
    }
}