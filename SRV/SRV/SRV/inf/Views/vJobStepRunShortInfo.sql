






CREATE view [inf].[vJobStepRunShortInfo] as
SELECT sj.[job_id] as Job_GUID
      ,j.[name] as Job_Name
      ,case sj.[last_run_outcome]
		when 0 then 'Ошибка'
		when 1 then 'Успешно'
		when 3 then 'Отменено'
		else case when sj.[last_run_date] is not null and len(sj.[last_run_date])=8 then 'Неопределенное состояние'
				else NULL
				end
	   end as LastFinishRunState
	  ,sj.[last_run_outcome] as LastRunOutcome
	  ,case when sj.[last_run_date] is not null and len(sj.[last_run_date])=8 then
		DATETIMEFROMPARTS(
							substring(cast(sj.[last_run_date] as nvarchar(255)),1,4),
							substring(cast(sj.[last_run_date] as nvarchar(255)),5,2),
							substring(cast(sj.[last_run_date] as nvarchar(255)),7,2),
							case when len(cast(sj.[last_run_time] as nvarchar(255)))>=5 then substring(cast(sj.[last_run_time] as nvarchar(255)),1,len(cast(sj.[last_run_time] as nvarchar(255)))-4)
								else 0
							end,
							case when len(right(cast(sj.[last_run_time] as nvarchar(255)),4))>=4 then substring(right(cast(sj.[last_run_time] as nvarchar(255)),4),1,2)
								 when len(right(cast(sj.[last_run_time] as nvarchar(255)),4))=3  then substring(right(cast(sj.[last_run_time] as nvarchar(255)),4),1,1)
								 else 0
							end,
							right(cast(sj.[last_run_duration] as nvarchar(255)),2),
							0
						)
		else NULL
	   end as LastDateTime
       ,case when len(cast(sj.[last_run_duration] as nvarchar(255)))>5 then substring(cast(sj.[last_run_duration] as nvarchar(255)),1,len(cast(sj.[last_run_duration] as nvarchar(255)))-4)
		    when len(cast(sj.[last_run_duration] as nvarchar(255)))=5 then '0'+substring(cast(sj.[last_run_duration] as nvarchar(255)),1,len(cast(sj.[last_run_duration] as nvarchar(255)))-4)
		    else '00'
	   end
	   +':'
	   +case when len(cast(sj.[last_run_duration] as nvarchar(255)))>=4 then substring(right(cast(sj.[last_run_duration] as nvarchar(255)),4),1,2)
			 when len(cast(sj.[last_run_duration] as nvarchar(255)))=3  then '0'+substring(right(cast(sj.[last_run_duration] as nvarchar(255)),4),1,1)
			 else '00'
	   end
	   +':'
	   +case when len(cast(sj.[last_run_duration] as nvarchar(255)))>=2 then substring(right(cast(sj.[last_run_duration] as nvarchar(255)),2),1,2)
			 when len(cast(sj.[last_run_duration] as nvarchar(255)))=2  then '0'+substring(right(cast(sj.[last_run_duration] as nvarchar(255)),2),1,1)
			 else '00'
	   end as [LastRunDurationString]
	  ,sj.last_run_duration as LastRunDurationInt
	  ,sj.[last_outcome_message] as LastOutcomeMessage
	  ,j.[enabled] as [Enabled]
	  ,sj.[trg_server] as [TargetServer]
	  ,js.[step_id]
	  ,js.[step_name]
	  ,case js.[last_run_outcome]
		when 0 then 'Ошибка'
		when 1 then 'Успешно'
		when 3 then 'Отменено'
		else case when sj.[last_run_date] is not null and len(sj.[last_run_date])=8 then 'Неопределенное состояние'
				else NULL
				end
	   end as LastFinishRunStateStep
	  ,js.[last_run_outcome] as LastRunOutcomeStep
	  ,case when (js.[last_run_date] is not null) and len(js.[last_run_date])=8 then
		DATETIMEFROMPARTS(
							substring(cast(js.[last_run_date] as nvarchar(255)),1,4),
							substring(cast(js.[last_run_date] as nvarchar(255)),5,2),
							substring(cast(js.[last_run_date] as nvarchar(255)),7,2),
							case when len(cast(js.[last_run_time] as nvarchar(255)))>=5 then substring(cast(js.[last_run_time] as nvarchar(255)),1,len(cast(js.[last_run_time] as nvarchar(255)))-4)
								else 0
							end,
							case when len(right(cast(js.[last_run_time] as nvarchar(255)),4))>=4 then substring(right(cast(js.[last_run_time] as nvarchar(255)),4),1,2)
								 when len(right(cast(js.[last_run_time] as nvarchar(255)),4))=3  then substring(right(cast(js.[last_run_time] as nvarchar(255)),4),1,1)
								 else 0
							end,
							right(cast(js.[last_run_duration] as nvarchar(255)),2),
							0
						)
		else NULL
	   end as LastDateTimeStep
       ,case when len(cast(js.[last_run_duration] as nvarchar(255)))>5 then substring(cast(js.[last_run_duration] as nvarchar(255)),1,len(cast(js.[last_run_duration] as nvarchar(255)))-4)
		    when len(cast(js.[last_run_duration] as nvarchar(255)))=5 then '0'+substring(cast(js.[last_run_duration] as nvarchar(255)),1,len(cast(js.[last_run_duration] as nvarchar(255)))-4)
		    else '00'
	   end
	   +':'
	   +case when len(cast(js.[last_run_duration] as nvarchar(255)))>=4 then substring(right(cast(js.[last_run_duration] as nvarchar(255)),4),1,2)
			 when len(cast(js.[last_run_duration] as nvarchar(255)))=3  then '0'+substring(right(cast(js.[last_run_duration] as nvarchar(255)),4),1,1)
			 else '00'
	   end
	   +':'
	   +case when len(cast(js.[last_run_duration] as nvarchar(255)))>=2 then substring(right(cast(js.[last_run_duration] as nvarchar(255)),2),1,2)
			 when len(cast(js.[last_run_duration] as nvarchar(255)))=2  then '0'+substring(right(cast(js.[last_run_duration] as nvarchar(255)),2),1,1)
			 else '00'
	   end as [LastRunDurationStringStep]
	   ,js.last_run_duration as LastRunDurationIntStep
  FROM [inf].[vJobServers] as sj
  inner join [inf].[vJOBS] as j on j.job_id=sj.job_id
  inner join [inf].[vJobSteps] as js on j.job_id=js.job_id





GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Краткая информация о последних выполнениях заданий и их шагов Агента экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vJobStepRunShortInfo';

