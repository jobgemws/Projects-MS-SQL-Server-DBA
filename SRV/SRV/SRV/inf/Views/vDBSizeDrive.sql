CREATE   view [inf].[vDBSizeDrive] as
SELECT [Server], [DBName], [Drive]
      ,SUM([SizeMb]) as [SizeMb]
      ,SUM([GrowthMb]) as [GrowthMb]
      ,cast([InsertUTCDate] as date) as [DATE]
  FROM [srv].[DBFileStatistics]
  where [Server] not like 'HLT%'
  and [Server] not like 'STG%'
  group by [Server], [DBName], [Drive], cast([InsertUTCDate] as date)

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация по размерам БД в разрезе логических дисков по собранным заранее статистикам', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vDBSizeDrive';

