



CREATE view [srv].[vTableStatistics] as
SELECT [ServerName]
	  ,[DBName]
      ,[SchemaName]
      ,[TableName]
      ,MIN([CountRows]) as MinCountRows
	  ,MAX([CountRows]) as MaxCountRows
	  ,AVG([CountRows]) as AvgCountRows
	  ,MAX([CountRows])-MIN([CountRows]) as AbsDiffCountRows
	  ,MIN([DataKB]) as MinDataKB
	  ,MAX([DataKB]) as MaxDataKB
	  ,AVG([DataKB]) as AvgDataKB
	  ,MAX([DataKB])-MIN([DataKB]) as AbsDiffDataKB
	  ,MIN([IndexSizeKB]) as MinIndexSizeKB
	  ,MAX([IndexSizeKB]) as MaxIndexSizeKB
	  ,AVG([IndexSizeKB]) as AvgIndexSizeKB
	  ,MAX([IndexSizeKB])-MIN([IndexSizeKB]) as AbsDiffIndexSizeKB
	  ,MIN([UnusedKB]) as MinUnusedKB
	  ,MAX([UnusedKB]) as MaxUnusedKB
	  ,AVG([UnusedKB]) as AvgUnusedKB
	  ,MAX([UnusedKB])-MIN([UnusedKB]) as AbsDiffUnusedKB
	  ,MIN([ReservedKB]) as MinReservedKB
	  ,MAX([ReservedKB]) as MaxReservedKB
	  ,AVG([ReservedKB]) as AvgReservedKB
	  ,MAX([ReservedKB])-MIN([ReservedKB]) as AbsDiffReservedKB
	  ,MIN([TotalPageSizeKB]) as MinTotalPageSizeKB
	  ,MAX([TotalPageSizeKB]) as MaxTotalPageSizeKB
	  ,AVG([TotalPageSizeKB]) as AvgTotalPageSizeKB
	  ,MAX([TotalPageSizeKB])-MIN([TotalPageSizeKB]) as AbsDiffTotalPageSizeKB
	  ,count(*) as CountRowsStatistic
	  ,MIN(InsertUTCDate) as StartInsertUTCDate
	  ,MAX(InsertUTCDate) as FinishInsertUTCDate
  FROM [srv].[TableStatistics]
  group by [ServerName]
	  ,[DBName]
      ,[SchemaName]
      ,[TableName]



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация об изменении размеров таблиц по собранным данным', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'VIEW', @level1name = N'vTableStatistics';

