
CREATE view [srv].[vDBSizeStatistics] as 
SELECT [ServerName]
      ,[DBName]
      ,SUM([MinCountRows])			as [MinCountRows]
      ,SUM([MaxCountRows])			as [MaxCountRows]
      ,SUM([AvgCountRows])			as [AvgCountRows]
      ,SUM([MinDataKB])				as [MinDataKB]
      ,SUM([MaxDataKB])				as [MaxDataKB]
      ,SUM([AvgDataKB])				as [AvgDataKB]
      ,SUM([MinIndexSizeKB])		as [MinIndexSizeKB]
      ,SUM([MaxIndexSizeKB])		as [MaxIndexSizeKB]
      ,SUM([AvgIndexSizeKB])		as [AvgIndexSizeKB]
      ,SUM([MinUnusedKB])			as [MinUnusedKB]
      ,SUM([MaxUnusedKB])			as [MaxUnusedKB]
      ,SUM([AvgUnusedKB])			as [AvgUnusedKB]
      ,SUM([MinReservedKB])			as [MinReservedKB]
      ,SUM([MaxReservedKB])			as [MaxReservedKB]
      ,SUM([AvgReservedKB])			as [AvgReservedKB]
	  ,SUM([MinTotalPageSizeKB])	as [MinTotalPageSizeKB]
      ,SUM([MaxTotalPageSizeKB])	as [MaxTotalPageSizeKB]
      ,SUM([AvgTotalPageSizeKB])	as [AvgTotalPageSizeKB]
      ,SUM([CountRowsStatistic])	as [CountRowsStatistic]
      ,MIN([StartInsertUTCDate])	as [StartInsertUTCDate]
      ,MAX([FinishInsertUTCDate])	as [FinishInsertUTCDate]
  FROM [srv].[vTableStatistics]
  group by [ServerName], [DBName]

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация по размерам всех БД по собранным данным экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'VIEW', @level1name = N'vDBSizeStatistics';

