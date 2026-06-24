using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using MongoDB.Driver;

namespace Database
{
    public static class MongoCollectionExtensions
    {
        public static T FirstOrDefault<T>(this IMongoCollection<T> collection, Expression<Func<T, bool>> predicate)
        {
            return collection.Find(predicate).FirstOrDefault();
        }

        public static void Add<T>(this IMongoCollection<T> collection, T document)
        {
            collection.InsertOne(document);
        }

        public static void Remove<T>(this IMongoCollection<T> collection, T document) where T : class
        {
            var filter = Builders<T>.Filter.Eq("Id", document.GetType().GetProperty("Id")?.GetValue(document));
            if (filter != null)
                collection.DeleteOne(filter);
        }

        public static T Find<T>(this IMongoCollection<T> collection, int id)
        {
            var filter = Builders<T>.Filter.Eq("Id", id);
            return collection.Find(filter).FirstOrDefault();
        }

        public static T Find<T>(this IMongoCollection<T> collection, long id)
        {
            var filter = Builders<T>.Filter.Eq("Id", id);
            return collection.Find(filter).FirstOrDefault();
        }

        public static IEnumerable<T> Where<T>(this IMongoCollection<T> collection, Expression<Func<T, bool>> predicate)
        {
            return collection.Find(predicate).ToEnumerable();
        }

        public static bool Any<T>(this IMongoCollection<T> collection, Expression<Func<T, bool>> predicate)
        {
            return collection.Find(predicate).Any();
        }

        public static IEnumerable<T> ToList<T>(this IMongoCollection<T> collection)
        {
            return collection.Find(x => true).ToEnumerable();
        }

        public static IQueryable<T> AsQueryable<T>(this IMongoCollection<T> collection)
        {
            return MongoDB.Driver.IMongoCollectionExtensions.AsQueryable(collection);
        }

        public static long Count<T>(this IMongoCollection<T> collection)
        {
            return collection.CountDocuments(x => true);
        }
    }
}
