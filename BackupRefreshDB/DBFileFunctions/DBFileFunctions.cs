using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DBFileFunctions
{
    /// <summary>
    /// Основные функции для работы с БД
    /// </summary>
    public static class DBFileFunctions
    {
        /// <summary>
        /// Перечисление типов моделей восстановления БД
        /// </summary>
        public enum DBTypeRestoreModel :byte
        {
            FULL=1,
            BULK_LOGGED = 2,
            SIMPLE=3
        };
        /// <summary>
        /// Перечисление режимов в конце операции восстановления БД
        /// </summary>
        public enum DBTypeEndRestore:byte
        {
            RECOVERY=1,
            NORECOVERY=2,
            STANDBY=3
        };
        /// <summary>
        /// Запуск создания резервной копии БД
        /// </summary>
        /// <param name="Server">Экземпляр MS SQL Server</param>
        /// <param name="db">Название БД</param>
        /// <param name="file_backup">Полный путь к будущему файлу резервной копии БД</param>
        /// <param name="tw_log">Журнал лога</param>
        /// <param name="IsDifferential">Признак того, что будет создана разностная резервная копия</param>
        /// <returns>Признак успешного выполнения (true-успешно)</returns>
        public static bool RunBackup(string Server, string db, string file_backup, TextWriter tw_log, bool IsDifferential = false, string login = null, string password=null)
        {
            bool isrun = false;

            //настройка строки подключения
            SqlConnectionStringBuilder scsb = new SqlConnectionStringBuilder();
            scsb.ApplicationName = "BackupRefreshDB";
            scsb.InitialCatalog = db;
            if (login == null) scsb.IntegratedSecurity = true;
            else
            {
                scsb.UserID = login;
                scsb.Password = password;
                scsb.IntegratedSecurity = false;
            }
            scsb.DataSource = Server;

            //создание подключения для создания резервного копирования БД
            using (SqlConnection conn = new SqlConnection())
            {
                conn.ConnectionString = scsb.ConnectionString;

                string sql = $@"BACKUP DATABASE [{db}] TO DISK = N'{file_backup}' " +
                        $@"WITH " + ((IsDifferential) ? "DIFFERENTIAL, " : "") + $@" NOFORMAT, NOINIT,  NAME = N'{db}', SKIP, NOREWIND, NOUNLOAD,  STATS = 10";

                SqlCommand comm = new SqlCommand(sql);
                comm.CommandType = System.Data.CommandType.Text;
                comm.Connection = conn;
                comm.CommandTimeout = 60000; //1000 минут

                try
                {
                    conn.Open();
                    try
                    {
                        comm.ExecuteNonQuery();
                        tw_log.WriteLine($"{DateTime.Now} ServerName: {Server} DBName: {db} успешно выполнено резервное копирование в {file_backup}");
                        isrun = true;
                    }
                    catch (Exception exp)
                    {
                        tw_log.WriteLine($"{DateTime.Now} ServerName: {Server} не удалось выполнить резервное копирование в {file_backup} DBName: {db} Exception: {exp.Message}");
                    }
                }
                catch (Exception exp)
                {
                    tw_log.WriteLine($"{DateTime.Now} ServerName: {Server} не удалось подключиться к DBName: {db} Exception: {exp.Message}");
                }
            }

            tw_log.Flush();

            return isrun;
        }
        /// <summary>
        /// Запуск создания резервной копии журнала транзакций БД
        /// </summary>
        /// <param name="Server">Экземпляр MS SQL Server</param>
        /// <param name="db">Название БД</param>
        /// <param name="file_backup">Полный путь к будущему файлу резервной копии БД</param>
        /// <param name="tw_log">Журнал лога</param>
        /// <returns>Признак успешного выполнения (true-успешно)</returns>
        public static bool RunBackupLog(string Server, string db, string file_backup, TextWriter tw_log, string login = null, string password = null)
        {
            bool isrun = false;

            SqlConnectionStringBuilder scsb = new SqlConnectionStringBuilder();
            //настройка строки подключения
            scsb.ApplicationName = "BackupRefreshDB";
            scsb.InitialCatalog = db;
            if (login == null) scsb.IntegratedSecurity = true;
            else
            {
                scsb.UserID = login;
                scsb.Password = password;
                scsb.IntegratedSecurity = false;
            }
            scsb.DataSource = Server;

            using (SqlConnection conn = new SqlConnection())
            {
                conn.ConnectionString = scsb.ConnectionString;

                string sql = $@"BACKUP LOG [{db}] TO  DISK = N'{file_backup}' " +
                        $@"WITH NOFORMAT, NOINIT,  NAME = N'{db}', SKIP, NOREWIND, NOUNLOAD,  STATS = 10";

                SqlCommand comm = new SqlCommand(sql);
                comm.CommandType = System.Data.CommandType.Text;
                comm.Connection = conn;
                comm.CommandTimeout = 60000; //1000 минут

                try
                {
                    conn.Open();
                    try
                    {
                        comm.ExecuteNonQuery();
                        tw_log.WriteLine($"{DateTime.Now} DBName: {db} успешно выполнено резервное копирование журнала транзакций в {file_backup}");
                        isrun = true;
                    }
                    catch (Exception exp)
                    {
                        tw_log.WriteLine($"{DateTime.Now} не удалось выполнить резервное копирование журнала транзакций в {file_backup} DBName: {db} Exception: {exp.Message}");
                    }
                }
                catch (Exception exp)
                {
                    tw_log.WriteLine($"{DateTime.Now} не удалось подключиться к DBName: {db} Exception: {exp.Message}");
                }
            }

            tw_log.Flush();

            return isrun;
        }
        /// <summary>
        /// Получение данных о файлах БД
        /// </summary>
        /// <param name="Server">Экземпляр MS SQL Server</param>
        /// <param name="db">Название БД</param>
        /// <param name="tw_log">Журнал лога</param>
        /// <param name="db_files">информация о файлах БД (0-это тип файла, 1-логическое имя файла)</param>
        /// <returns>Признак успешного выполнения (true-успешно)</returns>
        public static bool GetFilesDB(string Server, string db, TextWriter tw_log, ref List<string[]> db_files, string login = null, string password = null)
        {
            bool isrun = false;

            //настройка строки подключения
            SqlConnectionStringBuilder scsb = new SqlConnectionStringBuilder();
            scsb.ApplicationName = "BackupRefreshDB";
            scsb.InitialCatalog = db;
            if (login == null) scsb.IntegratedSecurity = true;
            else
            {
                scsb.UserID = login;
                scsb.Password = password;
                scsb.IntegratedSecurity = false;
            }
            scsb.DataSource = Server;

            //создание подключения для определения файлов БД
            using (SqlConnection conn = new SqlConnection())
            {
                conn.ConnectionString = scsb.ConnectionString;

                string sql = @"select case when ([type_desc]='ROWS') then 'mdf' else 'ldf' end as ext, [name] " +
                                    @"from sys.database_files";

                SqlCommand comm = new SqlCommand(sql);
                comm.CommandType = System.Data.CommandType.Text;
                comm.Connection = conn;
                comm.CommandTimeout = 60000; //1000 минут

                try
                {
                    conn.Open();
                    try
                    {
                        var result = comm.ExecuteReader();

                        while (result.Read())
                        {
                            db_files.Add(new string[] { result.GetString(0).ToString(), result.GetString(1).ToString() });
                        }

                        tw_log.WriteLine($"{DateTime.Now} ServerName: {Server} DBName: {db} удалось считать данные по файлам БД");
                        isrun = true;
                    }
                    catch (Exception exp)
                    {
                        tw_log.WriteLine($"{DateTime.Now} ServerName: {Server} не удалось считать данные по файлам БД DBName: {db} Exception: {exp.Message}");
                    }
                }
                catch (Exception exp)
                {
                    tw_log.WriteLine($"{DateTime.Now} ServerName: {Server} не удалось подключиться к DBName: {db} Exception: {exp.Message}");
                }
            }

            tw_log.Flush();

            return isrun;
        }
        /// <summary>
        /// Запуск копирования файла с перезаписью на получателе
        /// </summary>
        /// <param name="filesource">Полный путь к файлу-источнику</param>
        /// <param name="filetarget">Полный путь к файлу-получателю</param>
        /// <param name="tw_log">Журнал лога</param>
        /// <returns>Признак успешного выполнения (true-успешно)</returns>
        public static bool RunCopyFile(string filesource, string filetarget, TextWriter tw_log)
        {
            bool isrun = false;

            try
            {
                //копируем с перезаписью
                File.Copy(filesource, filetarget, true);
                tw_log.WriteLine($"{DateTime.Now} успешно выполнено копирование файла из {filesource} в {filetarget}");
                isrun = true;
            }
            catch (Exception exp)
            {
                tw_log.WriteLine($"{DateTime.Now} не удалось выполнить копирование файла из {filesource} в {filetarget} Exception: {exp.Message}");
            }

            tw_log.Flush();

            return isrun;
        }
        /// <summary>
        /// Запуск удаления файла
        /// </summary>
        /// <param name="file">Полный путь к файлу</param>
        /// <param name="tw_log">Журнал лога</param>
        /// <returns>Признак успешного выполнения (true-успешно)</returns>
        public static bool RunDeleteFile(string file, TextWriter tw_log)
        {
            bool isrun = false;

            try
            {
                //то удаляем этот файл
                File.Delete(file);
                tw_log.WriteLine($"{DateTime.Now} успешно удален файл {file}");
                isrun = true;
            }
            catch (Exception exp)
            {
                tw_log.WriteLine($"{DateTime.Now} не удалось выполнить удаление файла {file} Exception: {exp.Message}");
            }

            tw_log.Flush();

            return isrun;
        }
        /// <summary>
        /// Запуск проверки существования БД на сервере
        /// </summary>
        /// <param name="Server">Экземпляр MS SQL Server</param>
        /// <param name="db">Название БД</param>
        /// <param name="tw_log">Журнал лога</param>
        /// <returns>Признак успешного выполнения (true-успешно)</returns>
        public static bool RunExistsDB(string Server, string db, TextWriter tw_log, string login = null, string password = null)
        {
            bool isrun = false;

            SqlConnectionStringBuilder scsb = new SqlConnectionStringBuilder();

            //настройка строки подключения
            scsb.ApplicationName = "BackupRefreshDB";
            scsb.InitialCatalog = "master";
            if (login == null) scsb.IntegratedSecurity = true;
            else
            {
                scsb.UserID = login;
                scsb.Password = password;
                scsb.IntegratedSecurity = false;
            }
            scsb.DataSource = Server;

            using (SqlConnection conn = new SqlConnection())
            {
                conn.ConnectionString = scsb.ConnectionString;

                string sql = $@"select count(*) from sys.databases where [name]='{db}'";

                SqlCommand comm = new SqlCommand(sql);
                comm.CommandType = System.Data.CommandType.Text;
                comm.Connection = conn;
                comm.CommandTimeout = 60000; //1000 минут

                try
                {
                    conn.Open();
                    try
                    {
                        var result = comm.ExecuteReader();
                        int count = 0;

                        while (result.Read())
                        {
                            count = result.GetInt32(0);
                        }

                        if (count > 0)
                        {
                            tw_log.WriteLine($"{DateTime.Now} ServerName: {Server} DBName: master БД {db} уже существует!");
                            isrun = false;
                        }
                        else isrun = true;
                    }
                    catch (Exception exp)
                    {
                        tw_log.WriteLine($"{DateTime.Now} ServerName: {Server} не удалось определить существование БД DBName: {db} Exception: {exp.Message}");
                    }
                }
                catch (Exception exp)
                {
                    tw_log.WriteLine($"{DateTime.Now} ServerName: {Server} не удалось подключиться к DBName: master Exception: {exp.Message}");
                }
            }

            tw_log.Flush();

            return isrun;
        }
        /// <summary>
        /// Получить версию экземпляра MS SQL Server
        /// </summary>
        /// <param name="Server">Экземпляр MS SQL Server</param>
        /// <param name="tw_log">Журнал лога</param>
        /// <returns>Признак успешного выполнения (true-успешно)</returns>
        public static bool GetVersionServer(string Server, TextWriter tw_log, ref string version, string login = null, string password = null)
        {
            bool isrun = false;

            SqlConnectionStringBuilder scsb = new SqlConnectionStringBuilder();

            //настройка строки подключения
            scsb.ApplicationName = "BackupRefreshDB";
            scsb.InitialCatalog = "master";
            if (login == null) scsb.IntegratedSecurity = true;
            else
            {
                scsb.UserID = login;
                scsb.Password = password;
                scsb.IntegratedSecurity = false;
            }
            scsb.DataSource = Server;

            using (SqlConnection conn = new SqlConnection())
            {
                conn.ConnectionString = scsb.ConnectionString;

                string sql = $@"SELECT @@VERSION";

                SqlCommand comm = new SqlCommand(sql);
                comm.CommandType = System.Data.CommandType.Text;
                comm.Connection = conn;
                comm.CommandTimeout = 60000; //1000 минут

                try
                {
                    conn.Open();
                    try
                    {
                        var result = comm.ExecuteReader();

                        while (result.Read())
                        {
                            version = result.GetString(0);
                        }

                        isrun = true;
                    }
                    catch (Exception exp)
                    {
                        tw_log.WriteLine($"{DateTime.Now} ServerName: {Server} не удалось определить версию экземпляра MS SQL Server Exception: {exp.Message}");
                    }
                }
                catch (Exception exp)
                {
                    tw_log.WriteLine($"{DateTime.Now} ServerName: {Server} не удалось подключиться к DBName: master Exception: {exp.Message}");
                }
            }

            tw_log.Flush();

            return isrun;
        }
        /// <summary>
        /// Запуск восстановления БД
        /// </summary>
        /// <param name="Server">Экземпляр MS SQL Server</param>
        /// <param name="db">Название БД</param>
        /// <param name="file_backup">Полный путь к файлу резервной копии БД</param>
        /// <param name="file_end">Окончание названия файла</param>
        /// <param name="MoveTo">Полный путь к папке, куда будут перемещаться файлы БД</param>
        /// <param name="db_files">Информация о файлах БД</param>
        /// <param name="tw_log">Журнал лога</param>
        /// <param name="IsNorecovery">Признак выставления режима восстановления в NORECOVERY</param>
        /// <returns>Признак успешного выполнения (true-успешно)</returns>
        public static bool RunRestoreDB(string Server, string db, string file_backup, string file_end, string MoveTo, List<string[]> db_files, TextWriter tw_log, DBTypeEndRestore DBTypeEndRestore = DBTypeEndRestore.RECOVERY, string login = null, string password = null)
        {
            bool isrun = false;

            SqlConnectionStringBuilder scsb = new SqlConnectionStringBuilder();

            //настройка строки подключения
            scsb.ApplicationName = "BackupRefreshDB";
            scsb.InitialCatalog = "master";
            if (login == null) scsb.IntegratedSecurity = true;
            else
            {
                scsb.UserID = login;
                scsb.Password = password;
                scsb.IntegratedSecurity = false;
            }
            scsb.DataSource = Server;

            using (SqlConnection conn = new SqlConnection())
            {
                conn.ConnectionString = scsb.ConnectionString;

                StringBuilder str = new StringBuilder();
                string file;
                string file_ext;
                string fileDB;

                str.AppendLine($@"RESTORE DATABASE [{db}] FROM DISK = N'{file_backup}' WITH FILE = 1");

                for (int i = 0; i < db_files.Count; i++)
                {
                    file = db_files[i][1];
                    file_ext = db_files[i][0];
                    fileDB = MoveTo + @"\" + file + "_" + file_end + "." + file_ext;
                    str.AppendLine($@", MOVE N'{file}' TO N'{fileDB}'");
                }

                str.Append($@", {DBTypeEndRestore}");
                if (DBTypeEndRestore == DBTypeEndRestore.STANDBY) str.Append($@"=N'{file_backup}'");
                str.AppendLine(@", NOUNLOAD, STATS = 10");

                string sql = str.ToString();

                SqlCommand comm = new SqlCommand(sql);
                comm.CommandType = System.Data.CommandType.Text;
                comm.Connection = conn;
                comm.CommandTimeout = 60000; //1000 минут

                try
                {
                    conn.Open();
                    try
                    {
                        comm.ExecuteNonQuery();
                        tw_log.WriteLine($"{DateTime.Now} ServerName: {Server} DBName: {db} успешно выполнено восстановление резервной копии из {file_backup}");
                        isrun = true;
                    }
                    catch (Exception exp)
                    {
                        tw_log.WriteLine($"{DateTime.Now} ServerName: {Server} не удалось выполнить восстановление резервной копии из {file_backup} DBName: {db} Exception: {exp.Message}");
                    }
                }
                catch (Exception exp)
                {
                    tw_log.WriteLine($"{DateTime.Now} ServerName: {Server} не удалось подключиться к DBName: master Exception: {exp.Message}");
                }
            }

            tw_log.Flush();

            return isrun;
        }
        /// <summary>
        /// Запуск восстановления журнала транзакций БД
        /// </summary>
        /// <param name="Server">Экземпляр MS SQL Server</param>
        /// <param name="db">Название БД</param>
        /// <param name="file_backup">Полный путь к файлу резервной копии БД</param>
        /// <param name="tw_log">Журнал лога</param>
        /// <param name="IsNorecovery">Признак выставления режима восстановления в NORECOVERY</param>
        /// <returns>Признак успешного выполнения (true-успешно)</returns>
        public static bool RunRestoreLog(string Server, string db, string file_backup, TextWriter tw_log, DBTypeEndRestore DBTypeEndRestore = DBTypeEndRestore.RECOVERY, string login = null, string password = null)
        {
            bool isrun = false;

            SqlConnectionStringBuilder scsb = new SqlConnectionStringBuilder();

            //настройка строки подключения
            scsb.ApplicationName = "BackupRefreshDB";
            scsb.InitialCatalog = "master";
            if (login == null) scsb.IntegratedSecurity = true;
            else
            {
                scsb.UserID = login;
                scsb.Password = password;
                scsb.IntegratedSecurity = false;
            }
            scsb.DataSource = Server;

            using (SqlConnection conn = new SqlConnection())
            {
                conn.ConnectionString = scsb.ConnectionString;

                StringBuilder str = new StringBuilder();

                str.AppendLine($@"RESTORE LOG [{db}] FROM DISK = N'{file_backup}' WITH FILE = 1");

                str.Append($@", {DBTypeEndRestore}");
                if (DBTypeEndRestore == DBTypeEndRestore.STANDBY) str.Append($@"=N'{file_backup}'");

                str.AppendLine(@", NOUNLOAD, STATS = 10");

                string sql = str.ToString();

                SqlCommand comm = new SqlCommand(sql);
                comm.CommandType = System.Data.CommandType.Text;
                comm.Connection = conn;
                comm.CommandTimeout = 60000; //1000 минут

                try
                {
                    conn.Open();
                    try
                    {
                        comm.ExecuteNonQuery();
                        tw_log.WriteLine($"{DateTime.Now} DBName: {db} успешно выполнено восстановление резервной копии журнала транзакций из {file_backup}");
                        isrun = true;
                    }
                    catch (Exception exp)
                    {
                        tw_log.WriteLine($"{DateTime.Now} не удалось выполнить восстановление резервной копии журнала транзакций из {file_backup} DBName: {db} Exception: {exp.Message}");
                    }
                }
                catch (Exception exp)
                {
                    tw_log.WriteLine($"{DateTime.Now} не удалось подключиться к DBName: master Exception: {exp.Message}");
                }
            }

            tw_log.Flush();

            return isrun;
        }
        /// <summary>
        /// Запуск установки конечной точки
        /// </summary>
        /// <param name="Server">Экземпляр MS SQL Server</param>
        /// <param name="db">Название БД</param>
        /// <param name="StringTCP_Mirror">Конечная точка</param>
        /// <param name="tw_log">Журнал лога</param>
        /// <returns>Признак успешного выполнения (true-успешно)</returns>
        public static bool RunMirrorSetPoint(string Server, string db, string StringTCP_Mirror, TextWriter tw_log, string login = null, string password = null)
        {
            bool isrun = false;

            //настройка строки подключения
            SqlConnectionStringBuilder scsb = new SqlConnectionStringBuilder();
            scsb.ApplicationName = "BackupRefreshDB";
            scsb.InitialCatalog = "master";
            if (login == null) scsb.IntegratedSecurity = true;
            else
            {
                scsb.UserID = login;
                scsb.Password = password;
                scsb.IntegratedSecurity = false;
            }
            scsb.DataSource = Server;

            using (SqlConnection conn = new SqlConnection())
            {
                conn.ConnectionString = scsb.ConnectionString;

                StringBuilder str = new StringBuilder();

                string sql = $@"ALTER DATABASE [{db}] SET PARTNER = '{StringTCP_Mirror}'";

                SqlCommand comm = new SqlCommand(sql);
                comm.CommandType = System.Data.CommandType.Text;
                comm.Connection = conn;
                comm.CommandTimeout = 60000; //1000 минут

                try
                {
                    conn.Open();
                    try
                    {
                        comm.ExecuteNonQuery();
                        tw_log.WriteLine($"{DateTime.Now} DBName: {db} успешно выполнена установка конечной точки {StringTCP_Mirror}");
                        isrun = true;
                    }
                    catch (Exception exp)
                    {
                        tw_log.WriteLine($"{DateTime.Now} не удалось выполнить установку конечной точки {StringTCP_Mirror} DBName: {db} Exception: {exp.Message}");
                    }
                }
                catch (Exception exp)
                {
                    tw_log.WriteLine($"{DateTime.Now} не удалось подключиться к DBName: master Exception: {exp.Message}");
                }
            }

            tw_log.Flush();

            return isrun;
        }
        /// <summary>
        /// Запуск установки режима зеркалирования
        /// </summary>
        /// <param name="Server">Экземпляр MS SQL Server</param>
        /// <param name="db">Название БД</param>
        /// <param name="tw_log">Журнал лога</param>
        /// <param name="IsAsyncMode">Признак выставления режима зеркалирования в асинхронный режим</param>
        /// <returns>Признак успешного выполнения (true-успешно)</returns>
        public static bool RunMirrorAsync(string Server, string db, TextWriter tw_log, bool IsAsyncMode = true, string login = null, string password = null)
        {
            bool isrun = false;

            //настройка строки подключения
            SqlConnectionStringBuilder scsb = new SqlConnectionStringBuilder();
            scsb.ApplicationName = "BackupRefreshDB";
            scsb.InitialCatalog = "master";
            if (login == null) scsb.IntegratedSecurity = true;
            else
            {
                scsb.UserID = login;
                scsb.Password = password;
                scsb.IntegratedSecurity = false;
            }
            scsb.DataSource = Server;

            using (SqlConnection conn = new SqlConnection())
            {
                conn.ConnectionString = scsb.ConnectionString;

                StringBuilder str = new StringBuilder();

                string sql = $@"ALTER DATABASE [{db}] SET SAFETY " + ((IsAsyncMode) ? "OFF" : "FULL");

                SqlCommand comm = new SqlCommand(sql);
                comm.CommandType = System.Data.CommandType.Text;
                comm.Connection = conn;
                comm.CommandTimeout = 60000; //1000 минут

                try
                {
                    conn.Open();
                    try
                    {
                        comm.ExecuteNonQuery();
                        tw_log.WriteLine($"{DateTime.Now} DBName: {db} успешно выполнен переход на асинхронный режим зеркалирования");
                        isrun = true;
                    }
                    catch (Exception exp)
                    {
                        tw_log.WriteLine($"{DateTime.Now} не удалось выполнить переход на асинхронный режим зеркалирования DBName: {db} Exception: {exp.Message}");
                    }
                }
                catch (Exception exp)
                {
                    tw_log.WriteLine($"{DateTime.Now} не удалось подключиться к DBName: master Exception: {exp.Message}");
                }
            }

            tw_log.Flush();

            return isrun;
        }
        /// <summary>
        /// Запуск изменения типа модели восстановления БД
        /// </summary>
        /// <param name="Server">Экземпляр MS SQL Server</param>
        /// <param name="db">Название БД</param>
        /// <param name="tw_log">Журнал лога</param>
        /// <param name="typemodelrestore">Тип модели восстановления БД</param>
        /// <returns>Признак успешного выполнения (true-успешно)</returns>
        public static bool RunRestoreModelDB(string Server, string db, TextWriter tw_log, DBTypeRestoreModel typemodelrestore, string login = null, string password = null)
        {
            bool isrun = false;

            SqlConnectionStringBuilder scsb = new SqlConnectionStringBuilder();

            //настройка строки подключения
            scsb.ApplicationName = "BackupRefreshDB";
            scsb.InitialCatalog = "master";
            if (login == null) scsb.IntegratedSecurity = true;
            else
            {
                scsb.UserID = login;
                scsb.Password = password;
                scsb.IntegratedSecurity = false;
            }
            scsb.DataSource = Server;

            using (SqlConnection conn = new SqlConnection())
            {
                conn.ConnectionString = scsb.ConnectionString;

                string sql = $@"ALTER DATABASE [{db}] SET RECOVERY "+ typemodelrestore.ToString()+ " WITH NO_WAIT";

                SqlCommand comm = new SqlCommand(sql);
                comm.CommandType = System.Data.CommandType.Text;
                comm.Connection = conn;
                comm.CommandTimeout = 60000; //1000 минут

                try
                {
                    conn.Open();
                    try
                    {
                        comm.ExecuteNonQuery();
                        tw_log.WriteLine($"{DateTime.Now} DBName: {db} переведена в режим полного восстановления");
                        isrun = true;
                    }
                    catch (Exception exp)
                    {
                        tw_log.WriteLine($"{DateTime.Now} не удалось перевести в режим полного восстановления БД БД DBName: {db} Exception: {exp.Message}");
                    }
                }
                catch (Exception exp)
                {
                    tw_log.WriteLine($"{DateTime.Now} не удалось подключиться к DBName: master Exception: {exp.Message}");
                }
            }

            tw_log.Flush();

            return isrun;
        }
        /// <summary>
        /// Запуск отработки отказа при зеркалировании
        /// </summary>
        /// <param name="Server">Экземпляр MS SQL Server</param>
        /// <param name="db">Название БД</param>
        /// <param name="tw_log">Журнал лога</param>
        /// <returns>Признак успешного выполнения (true-успешно)</returns>
        public static bool RunFailoverMirrorDB(string Server, string db, TextWriter tw_log, string login = null, string password = null)
        {
            bool isrun = false;

            SqlConnectionStringBuilder scsb = new SqlConnectionStringBuilder();

            //настройка строки подключения
            scsb.ApplicationName = "BackupRefreshDB";
            scsb.InitialCatalog = "master";
            if (login == null) scsb.IntegratedSecurity = true;
            else
            {
                scsb.UserID = login;
                scsb.Password = password;
                scsb.IntegratedSecurity = false;
            }
            scsb.DataSource = Server;

            using (SqlConnection conn = new SqlConnection())
            {
                conn.ConnectionString = scsb.ConnectionString;

                string sql = $@"ALTER DATABASE [{db}] SET PARTNER FAILOVER";

                SqlCommand comm = new SqlCommand(sql);
                comm.CommandType = System.Data.CommandType.Text;
                comm.Connection = conn;
                comm.CommandTimeout = 60000; //1000 минут

                try
                {
                    conn.Open();
                    try
                    {
                        comm.ExecuteNonQuery();
                        tw_log.WriteLine($"{DateTime.Now} DBName: {db} отработан отказ системы при зеркалировании");
                        isrun = true;
                    }
                    catch (Exception exp)
                    {
                        tw_log.WriteLine($"{DateTime.Now} не удалось отработать отказ при зеркалировании БД DBName: {db} Exception: {exp.Message}");
                    }
                }
                catch (Exception exp)
                {
                    tw_log.WriteLine($"{DateTime.Now} не удалось подключиться к DBName: master Exception: {exp.Message}");
                }
            }

            tw_log.Flush();

            return isrun;
        }
        /// <summary>
        /// Запуск процесса копирования БД с источника на получателя
        /// <para>1) Исходя из флага делает резервную копию БД на источнике или берет уже готовую резервную копию</para>
        /// <para>2) Копирует резервную копию на сервер-получатель с перезаписью</para>
        /// <para>3) Проверяет сущещствования БД с таким же именем на сервере-получателе</para>
        /// <para>4) Восстанавливает БД на сервере-получателе</para>
        /// </summary>
        /// <param name="SourceDB">Название БД на источнике</param>
        /// <param name="SourceServer">Источник-экземпляр MS SQL Server</param>
        /// <param name="SourceFolderShared">Полный путь к доступной папке для общего использования на сервере-источнике</param>
        /// <param name="tw_log">Журнал лога</param>
        /// <param name="IsSourceServer">Признак того, что необходимо сделать полную резервную копию БД на источнике, а не брать готовую резервную копию</param>
        /// <param name="file_end">Окончание в имени файла</param>
        /// <param name="TargetFolderShared">Полный путь к доступной папке для общего использования на сервере-получателе</param>
        /// <param name="SourceFile">Полный путь к файлу резервной копии БД на источнике (путь должен быть доступен для общего использования). Актуально при IsSourceServer=false</param>
        /// <param name="IsDeleteSourceBackup">Признак того, что необходимо удалить файл-источник после процедуры переноса этого файла на сервер-получатель</param>
        /// <param name="IsDeleteTargetBackup">Признак того, что необходимо удалить файл-приемник после процедуры восстановления БД или журнала из этого файла</param>
        /// <param name="TargetDB">Название БД на источнике при восстановлении</param>
        /// <param name="TargetServer">Получатель-экземпляр MS SQL Server</param>
        /// <param name="MoveTo">Полный путь к папке, куда будут перенесены файлы БД при восстановлении на сервере-получателе</param>
        /// <param name="backup_name">Имя файла резервной копии БД</param>
        /// <param name="IsCopySource">Признак того, что нужно копировать БД с источника</param>
        /// <param name="IsRestoreTarget">Признак того, что необходимо восстанавливать БД на получателе</param>
        /// <returns>Признак успешного выполнения (true-успешно)</returns>
        public static bool RunBackupCopyRestoreBD(string SourceDB, string SourceServer, string SourceFolderShared, TextWriter tw_log,
            bool IsSourceServer, string file_end, string TargetFolderShared, string SourceFile, bool IsDeleteSourceBackup, bool IsDeleteTargetBackup,
            string TargetDB, string TargetServer, string MoveTo, ref string backup_name, bool IsCopySource, bool IsRestoreTarget, DBTypeEndRestore DBTypeEndRestore = DBTypeEndRestore.RECOVERY, string login = null, string password = null)
        {
            bool isrun = false;
            List<string[]> db_files = new List<string[]>();

            backup_name = SourceDB + "_" + file_end + ".bak";

            //определяем полные имена файла (источника и получателя)
            string filesource = SourceFolderShared + @"\" + backup_name;

            //вывод в лог текущего времени и названия экземпляра сервера MS SQL Server
            tw_log.WriteLine($"{DateTime.Now} ServerName: {SourceServer}:");
            tw_log.Flush();

            //если указано, что нужно сделать резервную копию с источника
            if (IsSourceServer)
            {
                isrun = RunBackup(SourceServer, SourceDB, filesource, tw_log, false, login, password);
            }
            else
            {
                backup_name = SourceFile;//иначе-просто берем указанный файл
                isrun = true;
            }

            filesource = SourceFolderShared + @"\" + backup_name;
            string filetarget = TargetFolderShared + @"\" + backup_name;

            //если выставлен флаг восстановления БД на получателе
            if (IsRestoreTarget)
            {
                //определяем файлы БД на источнике
                if (isrun)
                {
                    isrun = GetFilesDB(SourceServer, SourceDB, tw_log, ref db_files, login, password);
                }

                //если выставлен флаг копирования БД с источника
                if (IsCopySource)
                {
                    //копируем резервную копию БД на получатель
                    if (isrun)
                    {
                        isrun = RunCopyFile(filesource, filetarget, tw_log);
                    }

                    //если флаг продолжить выставлен, то продолжаем
                    if (isrun)
                    {
                        //если выставлен флаг на удаление резервной копии на источнике, то удаляем этот файл
                        if (IsDeleteSourceBackup)
                        {
                            isrun = RunDeleteFile(filesource, tw_log);
                        }
                    }
                }

                //определяем есть ли БД с таким же именем на получателе
                if (isrun)
                {
                    isrun = RunExistsDB(TargetServer, TargetDB, tw_log, login, password);
                }

                //восстанавливаем БД на получателе
                if (isrun)
                {
                    isrun = RunRestoreDB(TargetServer, TargetDB, filetarget, file_end, MoveTo, db_files, tw_log, DBTypeEndRestore, login, password);
                }

                //если флаг продолжить выставлен, то продолжаем
                if (isrun)
                {
                    //если выставлен флаг на удаление резервной копии на получателе, то удаляем этот файл
                    if (IsDeleteTargetBackup)
                    {
                        isrun = RunDeleteFile(filetarget, tw_log);
                    }
                }
            }

            return isrun;
        }
        /// <summary>
        /// Запуск процесса зеркалирования
        /// </summary>
        /// <param name="filesource">Полный путь к файлу резервной копии на источнике</param>
        /// <param name="filetarget">Полный путь к файлу резервной копии на получателе (куда будет произведено копирование)</param>
        /// <param name="TargetServer">Основной сервер для зеркалирования-экземпляр MS SQL Server</param>
        /// <param name="tw_log">Журнал лога</param>
        /// <param name="TargetDB">Название БД</param>
        /// <param name="IsDeleteSourceBackup">Признак того, что необходимо удалить файл-источник после процедуры переноса этого файла на сервер-получатель</param>
        /// <param name="IsDeleteTargetBackup">Признак того, что необходимо удалить файл-приемник после процедуры восстановления БД или журнала из этого файла</param>
        /// <param name="TargetServerMirror">Зеркальный сервер-экземпляр MS SQL Server</param>
        /// <param name="MoveToMirror">Полный путь к папке, куда будут перенесены файлы БД при восстановлении на зеркальном сервере</param>
        /// <param name="SourceStringTCP_Mirror">Конечная точка основного сервера, устанавливающаяся на зеркальном сервере</param>
        /// <param name="TargetStringTCP_Mirror">Конечная точка зеркального сервера, устанавливающаяся на основном сервере</param>
        /// <param name="IsMirrorAsync">Признак того, что будет установлен асинхронный режим зеркалирования</param>
        /// <param name="file_end">Окончание в имени файла</param>
        /// <returns>Признак успешного выполнения (true-успешно)</returns>
        public static bool RunMirror(string filesource, string filetarget, string TargetServer, TextWriter tw_log,
            string TargetDB, bool IsDeleteSourceBackup, bool IsDeleteTargetBackup, string TargetServerMirror, string MoveToMirror,
            string SourceStringTCP_Mirror, string TargetStringTCP_Mirror, bool IsMirrorAsync, string file_end, string login = null, string password = null)
        {
            string sql;
            bool isrun = false;

            List<string[]> db_files = new List<string[]>();

            int ind = filesource.IndexOf('.');
            string filesource_log = filesource.Substring(0, ind) + "LOG." + filesource.Substring(ind + 1, filesource.Length - ind - 1);
            ind = filetarget.IndexOf('.');
            string filetarget_log = filetarget.Substring(0, ind) + "LOG." + filetarget.Substring(ind + 1, filetarget.Length - ind - 1);

            tw_log.WriteLine($"{DateTime.Now} начало настройки зеркалирования");

            //вывод в лог текущего времени и названия экземпляра сервера MS SQL Server
            tw_log.WriteLine($"{DateTime.Now} ServerName: {TargetServer}:");
            tw_log.Flush();

            isrun = RunRestoreModelDB(TargetServer, TargetDB, tw_log, DBTypeRestoreModel.FULL, login, password);

            //делаем полную резернвую копию БД
            if (isrun)
            {
                isrun = RunBackup(TargetServer, TargetDB, filesource, tw_log, false, login, password);
            }

            //делаем резервную копию журнала транзакций
            if (isrun)
            {
                isrun = RunBackupLog(TargetServer, TargetDB, filesource_log, tw_log, login, password);
            }

            //определяем файлы БД
            if (isrun)
            {
                isrun = GetFilesDB(TargetServer, TargetDB, tw_log, ref db_files, login, password);
            }

            //копируем резервную копию на зеркало
            if (isrun)
            {
                isrun = RunCopyFile(filesource, filetarget, tw_log);
            }

            //если флаг продолжить выставлен, то продолжаем
            if (isrun)
            {
                //если выставлен флаг на удаление резервной копии на источнике, то удаляем этот файл
                if (IsDeleteSourceBackup)
                {
                    isrun = RunDeleteFile(filesource, tw_log);
                }
            }

            //копируем резервную копию журнала транзакций на зеркало
            if (isrun)
            {
                isrun = RunCopyFile(filesource_log, filetarget_log, tw_log);
            }

            //если флаг продолжить выставлен, то продолжаем
            if (isrun)
            {
                //если выставлен флаг на удаление резервной копии журнала транзакций на источнике, то удаляем этот файл
                if (IsDeleteSourceBackup)
                {
                    isrun = RunDeleteFile(filesource_log, tw_log);
                }
            }

            //определяем есть БД с таким же именем на зеркале
            if (isrun)
            {
                isrun = RunExistsDB(TargetServerMirror, TargetDB, tw_log, login, password);
            }

            //Восстанавливаем БД на зеркале с флагом NORECOVERY
            if (isrun)
            {
                isrun = RunRestoreDB(TargetServerMirror, TargetDB, filetarget, file_end, MoveToMirror, db_files, tw_log, DBTypeEndRestore.NORECOVERY, login, password);
            }

            //Восстанавливаем журнал транзакций на зеркале с флагом NORECOVERY
            if (isrun)
            {
                isrun = RunRestoreLog(TargetServerMirror, TargetDB, filetarget_log, tw_log, DBTypeEndRestore.NORECOVERY, login, password);
            }

            //если флаг продолжить выставлен, то продолжаем
            if (isrun)
            {
                //если выставлен флаг на удаление резервной копии на получателе, то удаляем этот файл
                if (IsDeleteTargetBackup)
                {
                    isrun = RunDeleteFile(filetarget, tw_log);
                }
            }

            //если флаг продолжить выставлен, то продолжаем
            if (isrun)
            {
                //если выставлен флаг на удаление резервной копии журнала транзакций на получателе, то удаляем этот файл
                if (IsDeleteTargetBackup)
                {
                    isrun = RunDeleteFile(filetarget_log, tw_log);
                }
            }

            //устанавливаем конечную точку на зеркале
            if (isrun)
            {
                isrun = RunMirrorSetPoint(TargetServerMirror, TargetDB, SourceStringTCP_Mirror, tw_log, login, password);
            }

            //устанавливаем конечную тоучку на источнике
            if (isrun)
            {
                isrun = RunMirrorSetPoint(TargetServer, TargetDB, TargetStringTCP_Mirror, tw_log, login, password);
            }

            //выставляем нужный режим зеркалирования
            if (isrun)
            {
                isrun = RunMirrorAsync(TargetServer, TargetDB, tw_log, IsMirrorAsync, login, password);
            }

            tw_log.WriteLine($"{DateTime.Now} окончание настройки зеркалирования");
            tw_log.Flush();

            return isrun;
        }

        public static bool RunLogShipping(string SourceServer, string TargetServer, string SourceFolderShared, string TargetFolderShared, TextWriter tw_log,
            string SourceDB, string TargetDB, bool IsDeleteSourceBackup, bool IsDeleteTargetBackup, int FileRetentionPeriodMin, int ThresholdMin, int HistoryRetentionPeriodMin,
            string MonitorServer, int RunMin=5, bool IsRestoreModeStandby = true, string login = null, string password = null)
        {
            bool isrun = false;

            tw_log.WriteLine($"{DateTime.Now} начало настройки доставки журналов транзакций");

            //вывод в лог текущего времени и названия экземпляра сервера MS SQL Server
            tw_log.WriteLine($"{DateTime.Now} ServerName: {SourceServer}->{TargetServer}:");
            tw_log.Flush();

            isrun = RunLogShippingRegistretionSource(SourceServer, TargetServer, SourceFolderShared, TargetFolderShared, tw_log,
                                    SourceDB, TargetDB, IsDeleteSourceBackup, IsDeleteTargetBackup,
                                    FileRetentionPeriodMin, ThresholdMin, HistoryRetentionPeriodMin,
                                    MonitorServer, RunMin, login, password);

            if(isrun)
            {
                isrun = RunLogShippingRegistretionTarget(SourceServer, TargetServer, SourceFolderShared, TargetFolderShared, tw_log,
                                    SourceDB, TargetDB, IsDeleteSourceBackup, IsDeleteTargetBackup,
                                    FileRetentionPeriodMin, ThresholdMin, HistoryRetentionPeriodMin,
                                    MonitorServer, RunMin, IsRestoreModeStandby, login, password);
            }

            tw_log.WriteLine($"{DateTime.Now} окончание настройки доставки журналов транзакций");
            tw_log.Flush();

            return isrun;
        }

        private static bool RunLogShippingRegistretionSource(string SourceServer, string TargetServer, string SourceFolderShared, string TargetFolderShared, TextWriter tw_log,
            string SourceDB, string TargetDB, bool IsDeleteSourceBackup, bool IsDeleteTargetBackup, int FileRetentionPeriodMin, int ThresholdMin, int HistoryRetentionPeriodMin,
            string MonitorServer, int RunMin=5, string login = null, string password = null)
        {
            bool isrun = false;

            //настройка строки подключения
            SqlConnectionStringBuilder scsb = new SqlConnectionStringBuilder();
            scsb.ApplicationName = "BackupRefreshDB";
            scsb.InitialCatalog = "msdb";
            if (login == null) scsb.IntegratedSecurity = true;
            else
            {
                scsb.UserID = login;
                scsb.Password = password;
                scsb.IntegratedSecurity = false;
            }
            scsb.DataSource = SourceServer;

            using (SqlConnection conn = new SqlConnection())
            {
                conn.ConnectionString = scsb.ConnectionString;

                StringBuilder str = new StringBuilder();

                string sql = $@"DECLARE @LS_BackupJobId	AS uniqueidentifier "+
                             $@"DECLARE @LS_PrimaryId	AS uniqueidentifier " +
                             $@"DECLARE @SP_Add_RetCode	As int " +
                             $@"EXEC @SP_Add_RetCode = master.dbo.sp_add_log_shipping_primary_database  " +
                             $@"		@database = N'{SourceDB}' " +
                             $@"		,@backup_directory = N'{SourceFolderShared}' " +
                             $@"		,@backup_share = N'{SourceFolderShared}' " +
                             $@"		,@backup_job_name = N'LSBackup_{SourceDB}' " +
                             $@"		,@backup_retention_period = {FileRetentionPeriodMin} " +
                             $@"		,@backup_compression = 2 " +
                             $@"		,@monitor_server = N'{MonitorServer}' " +
                             $@"		,@monitor_server_security_mode = {((login == null)?"1":"0")} " +
                             ((login == null)?"":$@"		,@monitor_server_login = N'{login}' ") +
                             ((login == null)?"":$@"		,@monitor_server_password = N'{password}' ") +
                             $@"		,@backup_threshold = {ThresholdMin} " +
                             $@"		,@threshold_alert_enabled = 1 " +
                             $@"		,@history_retention_period = {HistoryRetentionPeriodMin} " +
                             $@"		,@backup_job_id = @LS_BackupJobId OUTPUT " +
                             $@"		,@primary_id = @LS_PrimaryId OUTPUT " +
                             $@"		,@overwrite = 1 " +
                             $@"IF (@@ERROR = 0 AND @SP_Add_RetCode = 0) " +
                             $@"BEGIN " +
                             $@"DECLARE @LS_BackUpScheduleUID	As uniqueidentifier "+ 
                             $@"DECLARE @LS_BackUpScheduleID	AS int " +
                             $@"EXEC msdb.dbo.sp_add_schedule " +
                             $@"		@schedule_name =N'LSBackupSchedule_{SourceServer}_{SourceDB}' " +
                             $@"		,@enabled = 1 " +
                             $@"		,@freq_type = 4 " +
                             $@"		,@freq_interval = 1 " +
                             $@"		,@freq_subday_type = 4 " +
                             $@"		,@freq_subday_interval = {RunMin} " +
                             $@"		,@freq_recurrence_factor = 0 " +
                             $@"		,@active_start_date = 20171013 " +
                             $@"		,@active_end_date = 99991231 " +
                             $@"		,@active_start_time = 0 " +
                             $@"		,@active_end_time = 235900 " +
                             $@"		,@schedule_uid = @LS_BackUpScheduleUID OUTPUT " +
                             $@"		,@schedule_id = @LS_BackUpScheduleID OUTPUT " +
                             $@"EXEC msdb.dbo.sp_attach_schedule " +
                             $@"		@job_id = @LS_BackupJobId " +
                             $@"		,@schedule_id = @LS_BackUpScheduleID " +
                             $@"EXEC msdb.dbo.sp_update_job "+ 
                             $@"		@job_id = @LS_BackupJobId " +
                             $@"		,@enabled = 1 " +
                             $@"END " +
                             $@"EXEC master.dbo.sp_add_log_shipping_primary_secondary " +
                             $@"		@primary_database = N'{SourceDB}' " +
                             $@"		,@secondary_server = N'{TargetServer}' " +
                             $@"		,@secondary_database = N'{SourceDB}' " +
                             $@"		,@overwrite = 1 ";

                SqlCommand comm = new SqlCommand(sql);
                comm.CommandType = System.Data.CommandType.Text;
                comm.Connection = conn;
                comm.CommandTimeout = 60000; //1000 минут

                try
                {
                    conn.Open();
                    try
                    {
                        comm.ExecuteNonQuery();
                        tw_log.WriteLine($"{DateTime.Now} DBName: {SourceDB} успешно выполнена настройка доставки журналов транзакций на источнике");
                        isrun = true;
                    }
                    catch (Exception exp)
                    {
                        tw_log.WriteLine($"{DateTime.Now} не удалось выполнить настройку доставки журналов транзакций на источнике DBName: {SourceDB} Exception: {exp.Message}");
                    }
                }
                catch (Exception exp)
                {
                    tw_log.WriteLine($"{DateTime.Now} не удалось подключиться к DBName: msdb Exception: {exp.Message}");
                }
            }

            tw_log.Flush();

            return isrun;
        }

        private static bool RunLogShippingRegistretionTarget(string SourceServer, string TargetServer, string SourceFolderShared, string TargetFolderShared, TextWriter tw_log,
            string SourceDB, string TargetDB, bool IsDeleteSourceBackup, bool IsDeleteTargetBackup, int FileRetentionPeriodMin, int ThresholdMin, int HistoryRetentionPeriodMin,
            string MonitorServer, int RunMin=5, bool IsRestoreModeStandby=true, string login = null, string password = null)
        {
            bool isrun = false;

            //настройка строки подключения
            SqlConnectionStringBuilder scsb = new SqlConnectionStringBuilder();
            scsb.ApplicationName = "BackupRefreshDB";
            scsb.InitialCatalog = "msdb";
            if (login == null) scsb.IntegratedSecurity = true;
            else
            {
                scsb.UserID = login;
                scsb.Password = password;
                scsb.IntegratedSecurity = false;
            }
            scsb.DataSource = TargetServer;

            using (SqlConnection conn = new SqlConnection())
            {
                conn.ConnectionString = scsb.ConnectionString;

                StringBuilder str = new StringBuilder();

                string sql = $@"DECLARE @LS_Secondary__CopyJobId	AS uniqueidentifier "+
                             $@"DECLARE @LS_Secondary__RestoreJobId	AS uniqueidentifier " +
                             $@"DECLARE @LS_Secondary__SecondaryId	AS uniqueidentifier " +
                             $@"DECLARE @LS_Add_RetCode	As int " +
                             $@"EXEC @LS_Add_RetCode = master.dbo.sp_add_log_shipping_secondary_primary " +
                             $@"		@primary_server = N'{SourceServer}' " +
                             $@"		,@primary_database = N'{SourceDB}' " +
                             $@"		,@backup_source_directory = N'{SourceFolderShared}' " +
                             $@"		,@backup_destination_directory = N'{TargetFolderShared}' " +
                             $@"		,@copy_job_name = N'LSCopy_{SourceServer}_{TargetDB}' " +
                             $@"		,@restore_job_name = N'LSRestore_{SourceServer}_{TargetDB}' " +
                             $@"		,@file_retention_period = {FileRetentionPeriodMin} " +
                             $@"		,@monitor_server = N'{MonitorServer}' " +
                             $@"		,@monitor_server_security_mode = 0 " +
                             $@"		,@monitor_server_login = N'{login}' " +
                             $@"		,@monitor_server_password = N'{password}' " +
                             $@"		,@overwrite = 1 " +
                             $@"		,@copy_job_id = @LS_Secondary__CopyJobId OUTPUT " +
                             $@"		,@restore_job_id = @LS_Secondary__RestoreJobId OUTPUT " +
                             $@"		,@secondary_id = @LS_Secondary__SecondaryId OUTPUT " +
                             $@"IF (@@ERROR = 0 AND @LS_Add_RetCode = 0) "+ 
                             $@"BEGIN " +
                             $@"DECLARE @LS_SecondaryCopyJobScheduleUID	As uniqueidentifier "+ 
                             $@"DECLARE @LS_SecondaryCopyJobScheduleID	AS int " +
                             $@"EXEC msdb.dbo.sp_add_schedule " +
                             $@"		@schedule_name =N'DefaultCopyJobSchedule_{TargetDB}' " +
                             $@"		,@enabled = 1 " +
                             $@"		,@freq_type = 4 " +
                             $@"		,@freq_interval = 1 " +
                             $@"		,@freq_subday_type = 4 " +
                             $@"		,@freq_subday_interval = {RunMin} " +
                             $@"		,@freq_recurrence_factor = 0 " +
                             $@"		,@active_start_date = 20171013 " +
                             $@"		,@active_end_date = 99991231 " +
                             $@"		,@active_start_time = 0 " +
                             $@"		,@active_end_time = 235900 " +
                             $@"		,@schedule_uid = @LS_SecondaryCopyJobScheduleUID OUTPUT " +
                             $@"		,@schedule_id = @LS_SecondaryCopyJobScheduleID OUTPUT " +
                             $@"EXEC msdb.dbo.sp_attach_schedule "+ 
                             $@"		@job_id = @LS_Secondary__CopyJobId " +
                             $@"		,@schedule_id = @LS_SecondaryCopyJobScheduleID " +
                             $@"DECLARE @LS_SecondaryRestoreJobScheduleUID	As uniqueidentifier "+ 
                             $@"DECLARE @LS_SecondaryRestoreJobScheduleID	AS int " +
                             $@"EXEC msdb.dbo.sp_add_schedule " +
                             $@"		@schedule_name =N'DefaultRestoreJobSchedule_{TargetDB}' " +
                             $@"		,@enabled = 1 " +
                             $@"		,@freq_type = 4 " +
                             $@"		,@freq_interval = 1 " +
                             $@"		,@freq_subday_type = 4 " +
                             $@"		,@freq_subday_interval = {RunMin} " +
                             $@"		,@freq_recurrence_factor = 0 " +
                             $@"		,@active_start_date = 20171013 " +
                             $@"		,@active_end_date = 99991231 " +
                             $@"		,@active_start_time = 0 " +
                             $@"		,@active_end_time = 235900 " +
                             $@"		,@schedule_uid = @LS_SecondaryRestoreJobScheduleUID OUTPUT " +
                             $@"		,@schedule_id = @LS_SecondaryRestoreJobScheduleID OUTPUT " +
                             $@"EXEC msdb.dbo.sp_attach_schedule "+ 
                             $@"		@job_id = @LS_Secondary__RestoreJobId " +
                             $@"		,@schedule_id = @LS_SecondaryRestoreJobScheduleID " +
                             $@"END " +
                             $@"DECLARE @LS_Add_RetCode2	As int " +
                             $@"IF (@@ERROR = 0 AND @LS_Add_RetCode = 0) " +
                             $@"BEGIN " +
                             $@"EXEC @LS_Add_RetCode2 = master.dbo.sp_add_log_shipping_secondary_database "+ 
                             $@"		@secondary_database = N'{TargetDB}' " +
                             $@"		,@primary_server = N'{SourceServer}' " +
                             $@"		,@primary_database = N'{SourceDB}' " +
                             $@"		,@restore_delay = {((IsRestoreModeStandby) ? RunMin:0)}" +
                             $@"		,@restore_mode = {IsRestoreModeStandby} " +
                             $@"		,@disconnect_users	= 1 " +
                             $@"		,@restore_threshold = {ThresholdMin} " +
                             $@"		,@threshold_alert_enabled = 1 " +
                             $@"		,@history_retention_period	= {HistoryRetentionPeriodMin} " +
                             $@"		,@overwrite = 1 " +
                             $@"END "+ 
                             $@"IF (@@error = 0 AND @LS_Add_RetCode = 0) " +
                             $@"BEGIN " +
                             $@"EXEC msdb.dbo.sp_update_job "+ 
                             $@"		@job_id = @LS_Secondary__CopyJobId " +
                             $@"		,@enabled = 1 " +
                             $@"EXEC msdb.dbo.sp_update_job "+ 
                             $@"		@job_id = @LS_Secondary__RestoreJobId " +
                             $@"		,@enabled = 1 " +
                             $@"END ";

                SqlCommand comm = new SqlCommand(sql);
                comm.CommandType = System.Data.CommandType.Text;
                comm.Connection = conn;
                comm.CommandTimeout = 60000; //1000 минут

                try
                {
                    conn.Open();
                    try
                    {
                        comm.ExecuteNonQuery();
                        tw_log.WriteLine($"{DateTime.Now} DBName: {TargetDB} успешно выполнена настройка доставки журналов транзакций на принимателе");
                        isrun = true;
                    }
                    catch (Exception exp)
                    {
                        tw_log.WriteLine($"{DateTime.Now} не удалось выполнить настройку доставки журналов транзакций на принимателе DBName: {TargetDB} Exception: {exp.Message}");
                    }
                }
                catch (Exception exp)
                {
                    tw_log.WriteLine($"{DateTime.Now} не удалось подключиться к DBName: msdb Exception: {exp.Message}");
                }
            }

            tw_log.Flush();

            return isrun;
        }
    }
}
