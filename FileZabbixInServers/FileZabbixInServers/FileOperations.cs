using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace FileZabbixInServers
{
    public static class FileOperations
    {
        /// <summary>
        /// Синхронизация папок и их содержимое в приемнике
        /// </summary>
        /// <param name="sourcePath">Путь папки на источнике</param>
        /// <param name="targetPath">Путь папки на приемнике</param>
        /// <returns>Количество произведенных изменений
        /// <para>При удалении на приемнике лишней директории такое изменение считается за единицу</para>
        /// <para>При копировании на приемник недостающей директории будет считаться сама директория+все ее вложенные элементы как файлы, так и директории</para></returns>
        public static int SyncElements (string sourcePath, string targetPath)
        {
            int res = 0;

            DirectoryInfo sdr = Directory.CreateDirectory(sourcePath);
            DirectoryInfo tdr = Directory.CreateDirectory(targetPath);

            FileInfo[] sfiles = sdr.GetFiles();
            FileInfo[] tfiles = tdr.GetFiles();

            string sourceFile;
            string targetFile;

            var lfiles_st = (from sf in sfiles
                           join tf in tfiles on sf.Name equals tf.Name into tbl
                           from t in tbl.DefaultIfEmpty()
                           where (sf?.Length != t?.Length) || (t is null)
                             select new { SourceFile = sf.Name}).ToList();

            var lfiles_ts = (from tf in tfiles
                           join sf in sfiles on tf.Name equals sf.Name into tbl
                           from t in tbl.DefaultIfEmpty()
                           where (t == null)
                           select new { TargetFile = tf.Name }).ToList();

            res = lfiles_st.Count + lfiles_ts.Count;

            for (int i = 0; i < lfiles_st.Count; i++)
            {
                sourceFile = sourcePath + $@"\" + lfiles_st[i].SourceFile;
                targetFile = targetPath + $@"\" + lfiles_st[i].SourceFile;
                File.Copy(sourceFile, targetFile, true);
            }

            for (int i = 0; i < lfiles_ts.Count; i++)
            {
                targetFile = targetPath + $@"\" + lfiles_ts[i].TargetFile;
                File.Delete(targetFile);
            }

            DirectoryInfo[] sdirs = sdr.GetDirectories();
            DirectoryInfo[] tdirs = tdr.GetDirectories();

            string sourceDirectory;
            string targetDirectory;

            var ldirs_st = (from sd in sdirs
                           join td in tdirs on sd.Name equals td.Name into tbl
                           from t in tbl.DefaultIfEmpty()
                           //where (t is null)
                           select new { SourceDirectory = sd.Name }).ToList();

            var ldirs_ts = (from td in tdirs
                            join sd in sdirs on td.Name equals sd.Name into tbl
                           from t in tbl.DefaultIfEmpty()
                           where (t == null)
                           select new { TargetDirectory = td.Name }).ToList();

            res += ldirs_st.Count + ldirs_ts.Count;

            for (int i = 0; i < ldirs_st.Count; i++)
            {
                sourceDirectory = sourcePath + $@"\" + ldirs_st[i].SourceDirectory;
                targetDirectory = targetPath + $@"\" + ldirs_st[i].SourceDirectory;

                res += SyncElements(sourceDirectory, targetDirectory);
            }

            for (int i = 0; i < ldirs_ts.Count; i++)
            {
                targetDirectory = targetPath + $@"\" + ldirs_ts[i].TargetDirectory;
                Directory.Delete(targetDirectory, true);
            }

            return res;
        }
    }
}
