using System;

namespace Werewolf_Control.Helpers
{
    public static class RegHelper
    {
        public static string GetRegValue(string key)
        {
            return Environment.GetEnvironmentVariable(key) ?? "";
        }
    }
}
