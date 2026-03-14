using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Win32;

namespace Database
{
    public static class RegHelper
    {
        private static RegistryKey _key = null;
        static RegHelper()
        {
            if (Environment.OSVersion.Platform == PlatformID.Win32NT)
            {
                _key = RegistryKey.OpenBaseKey(RegistryHive.LocalMachine, RegistryView.Registry64).OpenSubKey("SOFTWARE\\Werewolf");
            }
        }
        public static string GetRegValue(string key)
        {
            var env = Environment.GetEnvironmentVariable(key);
            if (!string.IsNullOrEmpty(env))
            {
                return env;
            }
            if (_key != null)
            {
                var val = _key.GetValue(key, "");
                if (val != null)
                    return val.ToString();
            }
            return "";
        }
        public static string DBConnString => GetRegValue("DBConnectionString");
    }
}
