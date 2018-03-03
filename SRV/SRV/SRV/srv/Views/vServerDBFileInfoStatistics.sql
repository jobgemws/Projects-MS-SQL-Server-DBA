

CREATE view [srv].[vServerDBFileInfoStatistics] as
SELECT [ServerName]
	  ,[DBName]
      ,[File_id]
      ,[Type_desc]
      ,[FileName]
      ,[Drive]
      ,[Ext]
      ,MIN([CountPage]) as MinCountPage
	  ,MAX([CountPage]) as MaxCountPage
	  ,AVG([CountPage]) as AvgCountPage
	  ,MAX([CountPage])-MIN([CountPage]) as AbsDiffCountPage
	  ,MIN([SizeMb]) as MinSizeMb
	  ,MAX([SizeMb]) as MaxSizeMb
	  ,AVG([SizeMb]) as AvgSizeMb
	  ,MAX([SizeMb])-MIN([SizeMb]) as AbsDiffSizeMb
	  ,MIN([SizeGb]) as MinIndexSizeGb
	  ,MAX([SizeGb]) as MaxIndexSizeGb
	  ,AVG([SizeGb]) as AvgIndexSizeGb
	  ,MAX([SizeGb])-MIN([SizeGb]) as AbsDiffIndexSizeGb
	  ,count(*) as CountRowsStatistic
	  ,MIN(InsertUTCDate) as StartInsertUTCDate
	  ,MAX(InsertUTCDate) as FinishInsertUTCDate
  FROM [srv].[ServerDBFileInfoStatistics]
  group by [ServerName]
	  ,[DBName]
      ,[File_id]
      ,[Type_desc]
      ,[FileName]
      ,[Drive]
      ,[Ext]


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация по изменению размеров всех файлов всех БД экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'VIEW', @level1name = N'vServerDBFileInfoStatistics';

