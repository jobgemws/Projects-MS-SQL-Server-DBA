create view [srv].[vDBSizeShortStatistics] as
with tbl1 as (
SELECT [DBName]
      ,cast([MinTotalPageSizeKB] as decimal(18,3))/1024 as [MinTotalPageSizeMB]
      ,cast([MaxTotalPageSizeKB] as decimal(18,3))/1024 as [MaxTotalPageSizeMB]
	  ,cast(([MaxTotalPageSizeKB]-[MinTotalPageSizeKB]) as decimal(18,3))/1024 as [DiffTotalPageSizeMB]
      ,cast([StartInsertUTCDate] as DATE) as [StartDate]
      ,cast([FinishInsertUTCDate] as DATE) as [FinishDate]
  FROM [srv].[vDBSizeStatistics]
  where [ServerName]=@@SERVERNAME
)
SELECT [DB_Name] as [DBName]
      ,sum([SizeMb]) as [CurrentSizeMb]
      ,sum([SizeGb]) as [CurrentSizeGb]
	  ,min([MinTotalPageSizeMB]) as [MinTotalPageSizeMB]
	  ,min([MaxTotalPageSizeMB]) as [MaxTotalPageSizeMB]
	  ,min([DiffTotalPageSizeMB]) as [DiffTotalPageSizeMB]
	  ,min([StartDate]) as [StartDate]
	  ,min([FinishDate]) as [FinishDate]
  FROM tbl1
  inner join [inf].[ServerDBFileInfo] as tbl2 on tbl1.[DBName]=tbl2.[DB_Name]
  group by [DB_Name]

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сокращенная информация по размерам всех БД по собранным данным экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'VIEW', @level1name = N'vDBSizeShortStatistics';

