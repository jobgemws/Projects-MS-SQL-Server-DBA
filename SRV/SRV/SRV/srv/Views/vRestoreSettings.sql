create view [srv].[vRestoreSettings]
as
SELECT [DBName]
      ,[FullPathRestore]
      ,[DiffPathRestore]
      ,[LogPathRestore]
      ,[InsertUTCDate]
  FROM [srv].[RestoreSettings]

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Настройки по восстановлению БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'VIEW', @level1name = N'vRestoreSettings';

