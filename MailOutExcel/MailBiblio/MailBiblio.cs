using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;

namespace MailBiblio
{
    public static class Mail
    {
        /// <summary>
        /// Отправка письма
        /// </summary>
        /// <param name="server">Почтовый сервер</param>
        /// <param name="to">Кому через ;</param>
        /// <param name="from">От кого</param>
        /// <param name="title">Заголовок</param>
        /// <param name="text">Текст письма</param>
        /// <param name="filenames">Коллекция полных имён файлов</param>
        /// <param name="isBodyHtml">Признак того, что текст должен быть обработан как HTML</param>
        /// <returns>Исключение</returns>
        public static Exception RunMailMessage(string server, string to, string from, string title, string text, IEnumerable<string> filenames = null, bool isBodyHtml = false)
        {
            Exception exp = null;
            MailMessage message = new MailMessage();
            message.From = new MailAddress(from);

            string[] strmas = to.Split(new string[] { ";" }, StringSplitOptions.RemoveEmptyEntries);

            for (int i = 0; i < strmas.Length; i++)
            {
                message.To.Add(strmas[i].Trim());
            }

            message.Subject = title;
            message.Body = text;
            message.IsBodyHtml = isBodyHtml;

            if (filenames != null)
            {
                var ie = filenames.GetEnumerator();
                ie.Reset();

                while (ie.MoveNext())
                {
                    message.Attachments.Add(new Attachment(ie.Current));
                }
            }

            SmtpClient client = new SmtpClient(server);

            client.UseDefaultCredentials = true;

            try
            {
                client.Send(message);
            }
            catch (Exception ex)
            {
                exp = ex;
            }
            finally
            {
                for (int i = 0; i < message.Attachments.Count; i++)
                {
                    message.Attachments[i].Dispose();
                }
            }

            return exp;
        }
    }
}
