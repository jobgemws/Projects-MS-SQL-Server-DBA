using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ServiceProcess;

namespace FileZabbixInServers
{
    class Program
    {
        static void Main(string[] args)
        {
            var sett = Properties.Settings.Default;
            string[] servers = sett.Servers.Split(new string[] { ";", "\r", "\n", "\t", " " }, StringSplitOptions.RemoveEmptyEntries);
            string sourcePath = sett.SourceDirectory;
            string targetPath = sett.TargetDirectory;
            string sourceFileConf = sett.SourceFileConf;
            string targetFileConf = sett.TargetFileConf;

            using (Stream st_log = new FileStream(sett.FileLog, FileMode.Create, FileAccess.Write))
            {
                using (TextWriter tw_log = new StreamWriter(st_log, Encoding.UTF8))
                {
                    tw_log.WriteLine($"{DateTime.Now} Параметры: Каталог источника: {sourcePath} конфигурационный файл источника: {sourceFileConf}");

                    Sync(tw_log, sourcePath, targetPath, sourceFileConf, targetFileConf, servers);

                    tw_log.WriteLine($"Конец {DateTime.Now}");
                }
            }

            Console.WriteLine("Конец");

            Console.ReadKey();
        }

        /// <summary>
        /// Синхронизация настроек
        /// </summary>
        /// <param name="tw_log">Файл лога</param>
        /// <param name="sourcePath">Путь источника</param>
        /// <param name="targetPath">Путь приемника</param>
        /// <param name="sourceFileConf">Полное название файла конфигурации источника</param>
        /// <param name="targetFileConf">Полное название файла конфигурации приемника</param>
        /// <param name="servers">Коллекция серверов-приемников</param>
        public static void Sync(TextWriter tw_log, string sourcePath, string targetPath, string sourceFileConf, string targetFileConf, string[] servers)
        {
            string server;
            string targetPath2;
            string targetFileConf2;

            for (int i = 0; i < servers.Length; i++)
            {
                server = servers[i];
                targetPath2 = $@"\\" + server + $@"\" + targetPath;
                targetFileConf2 = $@"\\" + server + $@"\" + targetFileConf;

                SyncServer(tw_log, sourcePath, targetPath2, sourceFileConf, targetFileConf2, server);
            }
        }

        /// <summary>
        /// Синхронизация настроек по заданному серверу серверу
        /// </summary>
        /// <param name="tw_log">Файл лога</param>
        /// <param name="sourcePath">Путь источника</param>
        /// <param name="targetPath">Путь приемника</param>
        /// <param name="sourceFileConf">Полное название файла конфигурации источника</param>
        /// <param name="targetFileConf">Полное название файла конфигурации приемника</param>
        /// <param name="server">Заданный сервер</param>
        public static void SyncServer(TextWriter tw_log, string sourcePath, string targetPath, string sourceFileConf, string targetFileConf, string server)
        {
            int modify = 0;

            tw_log.WriteLine($"{DateTime.Now} Server: {server} начало проверки каталога {targetPath}");

            try
            {
                modify = FileOperations.SyncElements(sourcePath, targetPath);
                tw_log.WriteLine($"{DateTime.Now} Server: {server} успешное окончание проверки каталога {targetPath}");

                if (modify > 0)
                {
                    tw_log.WriteLine($"{DateTime.Now} Server: {server} всего произведено изменений не менее {modify}. Старт процесса копирования конфигурационного файла с источника в {targetFileConf}");

                    try
                    {
                        File.Copy(sourceFileConf, targetFileConf, true);
                        tw_log.WriteLine($"{DateTime.Now} Server: {server} успешное окончание процесса копирования конфигурационного файла с источника в {targetFileConf}. Старт процесса перезапуска службы Zabbix Agent");

                        try
                        {
                            ServiceController sc = new ServiceController("Zabbix Agent", server);
                            sc.Stop();
                            sc.Start();

                            tw_log.WriteLine($"{DateTime.Now} Server: {server} успешное окончание процесса перезапуска службы Zabbix Agent");
                        }
                        catch(Exception exp)
                        {
                            tw_log.WriteLine($"{DateTime.Now} Server: {server} неуспешное окончание процесса перезапуска службы Zabbix Agent Exception: {exp.Message}");
                        }
                    }
                    catch (Exception exp)
                    {
                        tw_log.WriteLine($"{DateTime.Now} Server: {server} неуспешное окончание процесса копирования конфигурационного файла с источника в {targetFileConf} Exception: {exp.Message}");
                    }
                }
                else
                {
                    tw_log.WriteLine($"{DateTime.Now} Server: {server} не было выявлено различий в каталоге {targetPath}");
                }
            }
            catch (Exception exp)
            {
                tw_log.WriteLine($"{DateTime.Now} Server: {server} неуспешное окончание проверки каталога {targetPath} Exception: {exp.Message}");
            }
        }
    }
}
