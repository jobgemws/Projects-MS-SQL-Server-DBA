
CREATE view [inf].[vSizeCache] as
--Текущий размер всего кэша планов и кэша планов запросов (https://club.directum.ru/post/1125)
with tbl as (
	select
	  TotalCacheSize = SUM(CAST(size_in_bytes as bigint)) / 1048576,
	  QueriesCacheSize = SUM(CAST((case 
									  when objtype in ('Adhoc', 'Prepared') 
									  then size_in_bytes else 0 
									end) as bigint)) / 1048576,
	  QueriesUseMultiCountCacheSize = SUM(CAST((case 
									  when ((objtype in ('Adhoc', 'Prepared')) and (usecounts>1))
									  then size_in_bytes else 0 
									end) as bigint)) / 1048576,
	  QueriesUseOneCountCacheSize = SUM(CAST((case 
									  when ((objtype in ('Adhoc', 'Prepared')) and (usecounts=1))
									  then size_in_bytes else 0 
									end) as bigint)) / 1048576
	from sys.dm_exec_cached_plans
)
select 
  'Queries' as 'Cache', 
  (select top(1) QueriesCacheSize from tbl) as 'Cache Size (MB)', 
  CAST((select top(1) QueriesCacheSize from tbl) * 100 / (select top(1) TotalCacheSize from tbl) as int) as 'Percent of Total/Queries'
union all
select 
  'Total' as 'Cache', 
  (select top(1) TotalCacheSize from tbl) as 'Cache Size (MB)', 
  100 as 'Percent of Total/Queries'
union all
select 
  'Queries UseMultiCount' as 'Cache', 
  (select top(1) QueriesUseMultiCountCacheSize from tbl) as 'Cache Size (MB)', 
  CAST((select top(1) QueriesUseMultiCountCacheSize from tbl) * 100 / (select top(1) QueriesCacheSize from tbl) as int) as 'Percent of Queries/Queries'
union all
select 
  'Queries UseOneCount' as 'Cache', 
  (select top(1) QueriesUseOneCountCacheSize from tbl) as 'Cache Size (MB)', 
  CAST((select top(1) QueriesUseOneCountCacheSize from tbl) * 100 / (select top(1) QueriesCacheSize from tbl) as int) as 'Percent of Queries/Queries'
--option(recompile)

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация о текущих размерах всего кэша планов и кэша планов запросов экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vSizeCache';

