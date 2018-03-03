


CREATE view [srv].[vTableIndexStatistics] as
SELECT [ServerName]
	  ,[DBName]
      ,[SchemaName]
      ,[TableName]
      ,[IndexUsedForCounts]
      ,MIN([CountRows]) as MinCountRows
	  ,MAX([CountRows]) as MaxCountRows
	  ,AVG([CountRows]) as AvgCountRows
	  ,MAX([CountRows])-MIN([CountRows]) as AbsDiffCountRows
	  ,count(*) as CountRowsStatistic
	  ,MIN(InsertUTCDate) as StartInsertUTCDate
	  ,MAX(InsertUTCDate) as FinishInsertUTCDate
  FROM [srv].[TableIndexStatistics]
  group by [ServerName]
	  ,[DBName]
      ,[SchemaName]
      ,[TableName]
      ,[IndexUsedForCounts]



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация об изменении размеров индексов таблиц по собранным данным', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'VIEW', @level1name = N'vTableIndexStatistics';

