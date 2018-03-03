
create view [srv].[vDBFiles] as
SELECT [DBFile_GUID]
      ,[Server]
      ,[Name]
      ,[Drive]
      ,[Physical_Name]
      ,[Ext]
      ,[Growth]
      ,[IsPercentGrowth]
      ,[DB_ID]
	  ,[File_ID]
      ,[DB_Name]
      ,[SizeMb]
      ,[DiffSizeMb]
	  ,round([SizeMb]/1024,3) as [SizeGb]
      ,round([DiffSizeMb]/1024,3) as [DiffSizeGb]
	  ,round([SizeMb]/1024/1024,3) as [SizeTb]
      ,round([DiffSizeMb]/1024/1024,3) as [DiffSizeTb]
	  ,round([DiffSizeMb]/([SizeMb]/100), 3) as [DiffSizePercent]
      ,[InsertUTCDate]
      ,[UpdateUTCdate]
  FROM [srv].[DBFile];

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация по файлам всех БД экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'VIEW', @level1name = N'vDBFiles';

