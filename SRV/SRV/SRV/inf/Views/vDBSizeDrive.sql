create view [inf].[vDBSizeDrive] as
SELECT [Server], [DBName], [Drive]
      ,SUM([SizeMb]) as [SizeMb]
      ,SUM([GrowthMb]) as [GrowthMb]
      ,cast([InsertUTCDate] as date) as [DATE]
  FROM [SRV].[srv].[DBFileStatistics]
  where [Server] not like 'HLT%'
  and [Server] not like 'STG%'
  group by [Server], [DBName], [Drive], cast([InsertUTCDate] as date)
