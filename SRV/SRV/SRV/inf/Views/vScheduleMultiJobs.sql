



CREATE view [inf].[vScheduleMultiJobs] as
/*
	ГЕМ: расписания, у которых несколько задач
*/
with sh as(
  SELECT schedule_id
  FROM [inf].[vJobSchedules]
  group by schedule_id
  having count(*)>1
)
select *
from msdb.dbo.sysschedules as s
where exists(select top(1) 1 from sh where sh.schedule_id=s.schedule_id)




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Расписания, у которых несколько задач экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vScheduleMultiJobs';

