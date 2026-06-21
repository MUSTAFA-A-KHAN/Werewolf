using System;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System;
using Newtonsoft.Json;
using System.Collections.Generic;

namespace Werewolf_Node.Services
{
    public static class OpenAIService
    {
        private static readonly HttpClient _httpClient = new HttpClient();
        private static string _apiKey;
        private const string OpenAIUrl = "https://api.openai.com/v1/chat/completions";

        static OpenAIService()
        {
            // Load API key from registry, similar to other API keys in the application
            try
            {

                _apiKey = Environment.GetEnvironmentVariable("WEREWOLF_OPENAI_API_KEY");
            }
            catch (Exception ex)
            {
                // Log error but don't crash - fallback will handle missing key
                Console.WriteLine($"Error loading OpenAI API key: {ex.Message}");
            }

            if (!string.IsNullOrEmpty(_apiKey))
            {
                _httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {_apiKey}");
            }
        }

        public static async Task<string> GenerateDummyDefenseStatement(string playerName, string playerRole, bool isBadRole, string suspectName)
        {
            if (string.IsNullOrEmpty(_apiKey))
            {
                // Fallback to hardcoded responses if API key is not configured
                return GenerateFallbackStatement(playerName, isBadRole, suspectName);
            }

            try
            {
                var prompt = BuildPrompt(playerName, playerRole, isBadRole, suspectName);

                var requestBody = new
                {
                    model = "gpt-4",
                    messages = new[]
                    {
                        new { role = "system", content = "You are generating defense statements for a Werewolf game dummy player. Keep responses short, in-character, and create confusion." },
                        new { role = "user", content = prompt }
                    },
                    max_tokens = 100,
                    temperature = 0.7
                };

                var json = JsonConvert.SerializeObject(requestBody);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                var response = await _httpClient.PostAsync(OpenAIUrl, content);
                response.EnsureSuccessStatusCode();

                var responseString = await response.Content.ReadAsStringAsync();
                var responseObject = JsonConvert.DeserializeObject<dynamic>(responseString);

                var generatedText = responseObject.choices[0].message.content.ToString().Trim();
                return $"{playerName} says: \"{generatedText}\"";
            }
            catch (Exception ex)
            {
                // Fallback to hardcoded responses if AI fails
                Console.WriteLine($"AI generation failed: {ex.Message}");
                return GenerateFallbackStatement(playerName, isBadRole, suspectName);
            }
        }

        private static string BuildPrompt(string playerName, string playerRole, bool isBadRole, string suspectName)
        {
            var roleDescription = isBadRole ? "a suspicious role" : "an innocent villager";
            return $"Generate a short defense statement for {playerName} who has the role of {playerRole} ({roleDescription}) in a Werewolf game. " +
                   $"They should defend themselves and possibly accuse {suspectName} to create confusion. " +
                   $"Make it sound like they're speaking in the game chat. Keep it under 50 words.";
        }

        private static string GenerateFallbackStatement(string playerName, bool isBadRole, string suspectName)
        {
            var templates = isBadRole
                ? new[]
                {
                    $"{playerName} says: \"I'm safe. Don't lynch me, I'm not the wolf.\"",
                    $"{playerName} says: \"Trust me, I'm innocent. If you kill me, you'll regret it.\"",
                    $"{playerName} says: \"I think {suspectName} is lying, not me.\"",
                    $"{playerName} says: \"I'm telling the truth. I'm safe.\"",
                    $"{playerName} says: \"Don't trust {suspectName}. They're the suspicious one.\""
                }
                : new[]
                {
                    $"{playerName} says: \"I'm safe. I'm a normal villager. Don't vote for me.\"",
                    $"{playerName} says: \"I feel fine. I'm not a wolf.\"",
                    $"{playerName} says: \"I think {suspectName} is acting suspicious.\"",
                    $"{playerName} says: \"I'm telling the truth. I'm innocent.\"",
                    $"{playerName} says: \"Please don't lynch me. I'm safe.\""
                };

            var random = new Random();
            return templates[random.Next(templates.Length)];
        }
    }
}