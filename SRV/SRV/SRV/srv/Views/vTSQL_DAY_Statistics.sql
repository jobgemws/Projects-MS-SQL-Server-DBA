


CREATE view [srv].[vTSQL_DAY_Statistics] as
SELECT tds.[DATE]
	  ,tds.[command]
      ,tds.[DBName]
	  ,tds.[execution_count]
	  ,tds.[max_total_elapsed_timeSec]
	  ,(tds.[min_total_elapsed_timeSec]+tds.[max_total_elapsed_timeSec])/2 as [avg_total_elapsed_timeSec]
	  ,tds.[max_cpu_timeSec]
	  ,(tds.[min_cpu_timeSec]+tds.[max_cpu_timeSec])/2 as [avg_cpu_timeSec]
	  ,tds.[max_wait_timeSec]
	  ,(tds.[min_wait_timeSec]+tds.[max_wait_timeSec])/2 as [avg_wait_timeSec]
      ,tds.[max_estimated_completion_timeSec]
	  ,(tds.[min_estimated_completion_timeSec]+tds.[max_estimated_completion_timeSec])/2 as [avg_estimated_completion_timeSec]
      ,tds.[max_lock_timeoutSec]
	  ,(tds.[min_lock_timeoutSec]+tds.[max_lock_timeoutSec])/2 as [avg_lock_timeoutSec]
      ,tds.[min_wait_timeSec]
      ,tds.[min_estimated_completion_timeSec]
      ,tds.[min_cpu_timeSec]
      ,tds.[min_total_elapsed_timeSec]
      ,tds.[min_lock_timeoutSec]
	  ,tds.[PlanHandle]
      ,tds.[SqlHandle]
	  ,sq.[TSQL]
	  ,pq.[QueryPlan]
  FROM [srv].[TSQL_DAY_Statistics] as tds
  inner join [srv].[PlanQuery] as pq on pq.[PlanHandle]=tds.[PlanHandle] and pq.[SQLHandle]=tds.[SqlHandle]
  inner join [srv].[SQLQuery] as sq on sq.[SqlHandle]=tds.[SqlHandle]

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индикатор производительности экземпляра MS SQL Server по снимкам активных запросов', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'VIEW', @level1name = N'vTSQL_DAY_Statistics';

