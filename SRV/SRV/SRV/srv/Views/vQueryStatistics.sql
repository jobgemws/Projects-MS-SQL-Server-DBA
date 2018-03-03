




CREATE view [srv].[vQueryStatistics] as
SELECT qs.[creation_time]
      ,qs.[last_execution_time]
      ,qs.[execution_count]
      ,qs.[CPU]
      ,qs.[AvgCPUTime]/1000 as [AvgCPUTimeSec]
      ,qs.[TotDuration]
      ,qs.[AvgDur]/1000 as [AvgDurSec]
      ,qs.[Reads]
      ,qs.[Writes]
      ,qs.[AggIO]
      ,qs.[AvgIO]
      ,qs.[sql_handle]
      ,qs.[plan_handle]
      ,qs.[statement_start_offset]
      ,qs.[statement_end_offset]
      ,sq.[TSQL] as [query_text]
      ,qs.[database_name]
      ,qs.[object_name]
      ,pq.[QueryPlan] as [query_plan]
      ,qs.[InsertUTCDate]
  FROM [srv].[QueryStatistics] as qs
  inner join [srv].[PlanQuery] as pq on qs.[sql_handle]=pq.[SqlHandle] and qs.[plan_handle]=pq.[PlanHandle]
  inner join [srv].[SQLQuery] as sq on sq.[SqlHandle]=pq.[SqlHandle]

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Снимки по статистикам экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'VIEW', @level1name = N'vQueryStatistics';

