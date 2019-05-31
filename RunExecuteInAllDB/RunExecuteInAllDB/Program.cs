using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.IO;

namespace RunExecuteInAllDB
{
    class Program
    {
        static void Main(string[] args)
        {
            var sett = Properties.Settings.Default;
            string[] servers = sett.Servers.Split(new string[] { ";", "\r", "\n", "\t", " " }, StringSplitOptions.RemoveEmptyEntries);
            string sql = null;

            using (Stream st_log = new FileStream(sett.FileLog, FileMode.Create, FileAccess.Write))
            {
                using (TextWriter tw_log = new StreamWriter(st_log, Encoding.UTF8))
                {

                    using (Stream st = new FileStream(sett.FileQuery, FileMode.Open, FileAccess.Read))
                    {
                        using (TextReader tr = new StreamReader(st, Encoding.Default))
                        {
                            sql = tr.ReadToEnd();
                        }
                    }

                    for (int i = 0; i < servers.Length; i++)
                    {
                        RunQueryInAllDBServer(servers[i], sql, tw_log);
                    }

                    tw_log.WriteLine($"Конец {DateTime.Now}");
                }
            }

            Console.WriteLine("Конец");

            Console.ReadKey();
        }

        /// <summary>
        /// Отправка запроса ко всем БД указанного сервера
        /// </summary>
        /// <param name="server">имя указанного сервера (экземпляра MS SQL Server)</param>
        /// <param name="sql">T-SQL-запрос</param>
        /// <param name="tw_log">Поток для логирования</param>
        static void RunQueryInAllDBServer(string server, string sql, TextWriter tw_log)
        {
            SqlConnectionStringBuilder scsb = null;

            //список имен всех баз данных на сервере
            List<string> ldbs = new List<string>();

            //настройка строки подключения
            scsb = new SqlConnectionStringBuilder();
            scsb.ApplicationName = "RunExecuteInAllDB";
            scsb.InitialCatalog = "master";
            scsb.IntegratedSecurity = true;
            scsb.DataSource = server;

            //вывод в лог текущего времени и названия экземпляра сервера MS SQL Server
            tw_log.WriteLine($"{DateTime.Now} ServerName: {server}:");

            //создание подключения с запросом для получения имен всех БД на сервере
            using (SqlConnection conn = new SqlConnection())
            {
                conn.ConnectionString = scsb.ConnectionString;

                SqlCommand comm = new SqlCommand("select [name] from sys.databases where [state]=0 and [user_access]=0 and [is_read_only]=0 and [is_in_standby]=0");
                comm.CommandType = System.Data.CommandType.Text;
                comm.Connection = conn;

                conn.Open();
                var result = comm.ExecuteReader();

                while (result.Read())
                {
                    ldbs.Add(result.GetString(0).ToString());
                }
            }

            //выполнение запроса sql на каждой БД сервера
            for (int i = 0; i < ldbs.Count; i++)
            {
                using (SqlConnection conn = new SqlConnection())
                {
                    scsb.InitialCatalog = ldbs[i];
                    conn.ConnectionString = scsb.ConnectionString;

                    SqlCommand comm = new SqlCommand(sql);
                    comm.CommandType = System.Data.CommandType.Text;
                    comm.Connection = conn;

                    conn.Open();
                    try
                    {
                        comm.ExecuteNonQuery();
                        tw_log.WriteLine($"{DateTime.Now} DBName: {ldbs[i]} успешно выполнен запрос");
                    }
                    catch(Exception exp)
                    {
                        tw_log.WriteLine($"{DateTime.Now} DBName: {ldbs[i]} Exception: {exp.Message}");
                    }
                }
            }
        }
    }
}
