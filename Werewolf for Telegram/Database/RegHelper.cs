using System;

namespace Database
{
    public static class RegHelper
    {
        public static string GetRegValue(string key)
        {
            return Environment.GetEnvironmentVariable(key) ?? "";
        }
        public static string DBConnString => GetRegValue("WEREWOLF_DB_CONNECTION_STRING");
    }
}
