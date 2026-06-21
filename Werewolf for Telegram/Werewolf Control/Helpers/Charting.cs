using System;
using System.Collections.Generic;
using System.Data;

using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Database;
using Telegram.Bot;
using Telegram.Bot.Types;
using Werewolf_Control.Handler;
using Werewolf_Control.Models;


namespace Werewolf_Control.Helpers
{
    public static class Charting
    {
        public static void TeamWinChart(string input, Update u) { Bot.Api.SendTextMessageAsync(chatId: u.Message.Chat.Id, text: "Charting is disabled in cross-platform version.", messageThreadId: u.Message.MessageThreadId); }

        private static void SendImage(string path, long id)
        {
            var fs = new FileStream(path, FileMode.Open);
            //Bot.Api.SendPhotoAsync(id, new FileToSend("chart.png", fs));
        }
    }

    class TeamWinResult
    {

        public int Players { get; set; }
        public Decimal Wins { get; set; }
        public int Games { get; set; }
        public string Team { get; set; }
        
    }
}
