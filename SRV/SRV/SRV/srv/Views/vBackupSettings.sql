CREATE view [srv].[vBackupSettings]
as
SELECT [DBID]
      ,DB_Name([DBID]) as [DBName]
	  ,[FullPathBackup]
      ,[DiffPathBackup]
      ,[LogPathBackup]
      ,[InsertUTCDate]
  FROM [srv].[BackupSettings]

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Настройки резервного копирования', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'VIEW', @level1name = N'vBackupSettings';

