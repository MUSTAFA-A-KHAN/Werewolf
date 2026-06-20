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
        public static string GetRegValue(string key)
        {
            var envValue = Environment.GetEnvironmentVariable(key);
            if (!string.IsNullOrEmpty(envValue))
                return envValue;

            try
            {
                var regKey = RegistryKey.OpenBaseKey(RegistryHive.LocalMachine, RegistryView.Registry64).OpenSubKey("SOFTWARE\\Werewolf");
                if (regKey != null)
                {
                    return regKey.GetValue(key, "").ToString();
                }
            }
            catch (Exception)
            {
                // Ignore exception on non-Windows platforms
            }

            return "";
        }
        public static string DBConnString => GetRegValue("DBConnectionString");
    }
}
