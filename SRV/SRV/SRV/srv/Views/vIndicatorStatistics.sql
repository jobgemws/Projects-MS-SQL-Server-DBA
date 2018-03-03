CREATE view [srv].[vIndicatorStatistics] as
SELECT [DATE]
	  ,[execution_count]
      ,[max_total_elapsed_timeSec]
      ,[max_total_elapsed_timeLastSec]
	  ,[max_total_elapsed_timeLastSec]-[max_total_elapsed_timeSec] as [DiffSnapshot]
	  ,([max_total_elapsed_timeLastSec]-[max_total_elapsed_timeSec])*100/[max_total_elapsed_timeSec] as [% Snapshot]
	  , case when ([max_total_elapsed_timeLastSec]<[max_total_elapsed_timeSec]) then N'УЛУЧШИЛАСЬ'
		else case when ([max_total_elapsed_timeLastSec]>[max_total_elapsed_timeSec]) then N'УХУДШИЛАСЬ'
		else N'НЕ ИЗМЕНИЛАСЬ' end
	   end as 'IndicatorSnapshot'
      ,[execution_countStatistics]
      ,[max_AvgDur_timeSec]
      ,[max_AvgDur_timeLastSec]
	  ,[max_AvgDur_timeLastSec]-[max_AvgDur_timeSec] as [DiffStatistics]
	  ,([max_AvgDur_timeLastSec]-[max_AvgDur_timeSec])*100/[max_AvgDur_timeSec] as [% Statistics]
	  , case when ([max_AvgDur_timeLastSec]<[max_AvgDur_timeSec]) then N'УЛУЧШИЛАСЬ'
		else case when ([max_AvgDur_timeLastSec]>[max_AvgDur_timeSec]) then N'УХУДШИЛАСЬ'
		else N'НЕ ИЗМЕНИЛАСЬ' end
	   end as 'IndicatorStatistics'
  FROM [srv].[IndicatorStatistics]

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индикатор производительности экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'VIEW', @level1name = N'vIndicatorStatistics';

