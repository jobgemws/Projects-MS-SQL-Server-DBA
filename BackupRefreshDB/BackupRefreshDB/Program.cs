using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using MailBiblio;

namespace BackupRefreshDB
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
            string TargetServerMirror = sett.TargetServerMirror;
            string TargetFolderSharedMirror = sett.TargetFolderSharedMirror;
            bool IsMirror = sett.IsMirror;
            string SourceDB = "TEST";//sett.ListDB;
            string TargetDB = "TEST2";//sett.TargetDB;
            var list = sett.ListDB;
            bool IsDeleteSourceBackup = sett.IsDeleteSourceBackup;
            bool IsDeleteTargetBackup = sett.IsDeleteTargetBackup;
            string MoveTo = sett.MoveTo;
            string MoveToMirror = sett.MoveToMirror;
            string MailServer = sett.MailServer;
            string MailAddressTo = sett.MailAddressTo;
            string MailAddressFrom = sett.MailAddressFrom;
            bool IsMail = sett.IsMail;
            string SourceStringTCP_Mirror = sett.SourceStringTCP_Mirror;
            string TargetStringTCP_Mirror = sett.TargeStringTCP_Mirror;
            bool IsMirrorAsync = sett.IsMirrorAsync;
            bool IsCopySource = sett.IsCopySource;
            bool IsRestoreTarget = sett.IsRestoreTarget;
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

            using (Stream st_log = new FileStream(FileLog, FileMode.Create, FileAccess.Write))
            {
                using (TextWriter tw_log = new StreamWriter(st_log, Encoding.Unicode))
                {
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

                        isrun = DBFileFunctions.RunBackupCopyRestoreBD(SourceDB, SourceServer, SourceFolderShared, tw_log,
                            IsSourceServer, file_end, TargetFolderShared, SourceFile, IsDeleteSourceBackup, IsDeleteTargetBackup,
                            TargetDB, TargetServer, MoveTo, ref backup_name, IsCopySource, IsRestoreTarget);

                        if (IsMirror)
                        {
                            if (isrun)
                            {
                                isrun = false;

                                db_files.Clear();

                                filesource = TargetFolderShared + @"\" + backup_name; ;
                                filetarget = TargetFolderSharedMirror + @"\" + backup_name;

                                isrun = DBFileFunctions.RunMirror(filesource, filetarget, TargetServer, tw_log, TargetDB, IsDeleteSourceBackup, IsDeleteTargetBackup,
                                    TargetServerMirror, MoveToMirror, SourceStringTCP_Mirror, TargetStringTCP_Mirror, IsMirrorAsync, file_end);

                            }
                        }

                        if (!isrun) tw_log.WriteLine($"{DateTime.Now} операция прервана с ошибкой!");
                        tw_log.WriteLine($"Конец {SourceDB}->{TargetDB} {DateTime.Now}");
                        tw_log.Flush();
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