using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using MailBiblio;

namespace LogShipping
{
    using DBFileFunctions;
    class Program
    {
        static void Main(string[] args)
        {
            var sett = Properties.Settings.Default;
            string SourceServer = sett.SourceServer;
            string TargetServer = sett.TargetServer;
            string SourceFolderShared = sett.SourceFolderShared;
            string TargetFolderShared = sett.TargetFolderShared;
            bool IsSourceServer = sett.IsSourceServer;
            var SourceFileList = sett.SourceFile;
            string SourceFile;
            string SourceDB = "TEST";//sett.ListDB;
            string TargetDB = "TEST2";//sett.TargetDB;
            var list = sett.ListDB;
            bool IsDeleteSourceBackup = sett.IsDeleteSourceBackup;
            bool IsDeleteTargetBackup = sett.IsDeleteTargetBackup;
            string MoveTo = sett.MoveTo;
            string MailServer = sett.MailServer;
            string MailAddressTo = sett.MailAddressTo;
            string MailAddressFrom = sett.MailAddressFrom;
            bool IsMail = sett.IsMail;
            bool IsCopySource = sett.IsCopySource;
            bool IsRestoreTarget = sett.IsRestoreTarget;
            bool IsLogShipping = sett.IsLogShipping;
            int FileRetentionPeriodMin = sett.FileRetentionPeriodMin;
            int ThresholdMin = sett.ThresholdMin;
            int HistoryRetentionPeriodMin = sett.HistoryRetentionPeriodMin;
            bool IsSQLLogin = sett.IsSQLLogin;
            string MonitorServer = sett.MonitorServer;
            string login = sett.Login;
            string password = sett.Password;
            int RunMin = sett.RunMin;
            string FileLog = sett.FileLog;
            bool isrun = false;
            DateTime dt = DateTime.Now;
            string file_end = dt.Year.ToString() + "_" + dt.Month.ToString() + "_" + dt.Day.ToString() + "_" + dt.Hour.ToString() + "_" + dt.Minute.ToString() + "_" + dt.Second.ToString();
            string backup_name = null;
            string filesource = null;
            string filetarget = null;
            List<string[]> db_files = new List<string[]>();
            string temp;
            string[] strs;
            string source_version = null;
            string target_version = null;
            DBFileFunctions.DBTypeEndRestore DBTypeEndRestore = DBFileFunctions.DBTypeEndRestore.NORECOVERY;
            bool IsRestoreModeStandby = false;

            if(!IsSQLLogin)
            {
                login = null;
                password = null;
            }

            using (Stream st_log = new FileStream(FileLog, FileMode.Create, FileAccess.Write))
            {
                using (TextWriter tw_log = new StreamWriter(st_log, Encoding.Unicode))
                {
                    isrun = DBFileFunctions.GetVersionServer(SourceServer, tw_log, ref source_version, login, password);
                    if (isrun) isrun = DBFileFunctions.GetVersionServer(TargetServer, tw_log, ref target_version, login, password);
                    if (isrun)
                    {
                        if (source_version == target_version)
                        {
                            DBTypeEndRestore = DBFileFunctions.DBTypeEndRestore.STANDBY;
                            IsRestoreModeStandby = true;
                        }

                        for (int i = 0; i < list.Count; i++)
                        {
                            temp = list[i];
                            strs = temp.Split(new string[] { ";" }, StringSplitOptions.RemoveEmptyEntries);

                            SourceDB = strs[0];
                            TargetDB = strs[1];

                            if (!IsSourceServer) SourceFile = SourceFileList[i];
                            else SourceFile = null;

                            tw_log.WriteLine($"Начало {SourceDB}->{TargetDB} {DateTime.Now}");
                            tw_log.Flush();

                            isrun = DBFileFunctions.RunRestoreModelDB(SourceServer, SourceDB, tw_log, DBFileFunctions.DBTypeRestoreModel.FULL, login, password);

                            if (isrun)
                            {
                                isrun = DBFileFunctions.RunBackupCopyRestoreBD(SourceDB, SourceServer, SourceFolderShared, tw_log,
                                    IsSourceServer, file_end, TargetFolderShared, SourceFile, IsDeleteSourceBackup, IsDeleteTargetBackup,
                                    TargetDB, TargetServer, MoveTo, ref backup_name, IsCopySource, IsRestoreTarget, DBTypeEndRestore, login, password);
                            }

                            if (IsLogShipping)
                            {
                                if (isrun)
                                {
                                    isrun = false;

                                    isrun = DBFileFunctions.RunLogShipping(SourceServer, TargetServer, SourceFolderShared, TargetFolderShared,
                                                    tw_log, SourceDB, TargetDB, IsDeleteSourceBackup, IsDeleteTargetBackup, FileRetentionPeriodMin,
                                                    ThresholdMin, HistoryRetentionPeriodMin, MonitorServer, RunMin, IsRestoreModeStandby, login, password);

                                }
                            }

                            if (!isrun) tw_log.WriteLine($"{DateTime.Now} операция прервана с ошибкой!");
                            tw_log.WriteLine($"Конец {SourceDB}->{TargetDB} {DateTime.Now}");
                            tw_log.Flush();
                        }
                    }
                }
            }

            if (!isrun)
            {
                if (IsMail)
                {
                    Mail.RunMailMessage(MailServer, MailAddressTo, MailAddressFrom,
                                    "BackupRefreshDB", "Операция завершена неудачно. Подробности во вложении." +
                                    "\r\nСоощение сформировано: " + DateTime.Now.ToString(), new string[] { FileLog });
                }

                Console.WriteLine($"{DateTime.Now} операция прервана с ошибкой!");
            }
            else
            {
                if (IsMail)
                {
                    Mail.RunMailMessage(MailServer, MailAddressTo, MailAddressFrom,
                                    "BackupRefreshDB", "Операция завершена успешно. Подробности во вложении." +
                                    "\r\nСоощение сформировано: " + DateTime.Now.ToString(), new string[] { FileLog });
                }
            }

            Console.WriteLine("Конец");

            Console.ReadKey();
        }
    }
}