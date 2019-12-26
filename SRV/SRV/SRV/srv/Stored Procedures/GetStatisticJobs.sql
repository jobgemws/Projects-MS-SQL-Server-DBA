







--Данные по выполнению заданий на сервере
--Автор: Прилепа Б.А. - АБД
--Дата создания: 16.01.2017
--exec [dbo].[GetStatisticJobs] @srv='1csrv'

CREATE   procedure [srv].[GetStatisticJobs]
as
begin
	set nocount on;
	set xact_abort on;

	declare @servername nvarchar(255)=cast(SERVERPROPERTY(N'MachineName') as nvarchar(255));
	
	select @servername as SERVERNAME
	,[name]
	,[count]
	,[srv].[ReturnTime](avg_run_duration) avg_run_duration
	,[srv].[ReturnTime](min_run_duration) min_run_duration
	,[srv].[ReturnTime](max_run_duration) max_run_duration
	,[srv].[ReturnTime](sum_run_duration) sum_run_duration
	,[enabled]
	,cast(cast(run_date as nvarchar(255)) as date) as run_date
	,last_run=(
				case when len(last_run)=5 then N'0'+left(last_run,1)+N':'+right(left(last_run,3),2)+N':'+right(last_run,2)
					 when len(last_run)=6 then left(last_run,2)+N':'+right(left(last_run,4),2)+N':'+right(last_run,2)
				end
			  )
	,last_duration=[srv].[ReturnTime](last_duration)
	,last_run_status=case when last_run_status=0 then N'Неуспех' 
						  when last_run_status=1 then N'Успех' 
						  when last_run_status=2 then N'Повтор'
						  when last_run_status=3 then N'Отмена'
					 end
	,Неуспехов
	,date_created
	from
	(
		select top(1000)
		b.job_id
		,MAX([enabled]) as [enabled]
		,b.[name]
		,b.date_created
		,run_date
		,max(run_time) as last_run
		,AVG(run_duration) as avg_run_duration
		,MIN(run_duration) as min_run_duration
		,MAX(run_duration) as max_run_duration
		,SUM(run_duration) as sum_run_duration
		,SUM(case when run_status=0 then 1 else 0 end) as Неуспехов
		,last_run_status=(select top 1 run_status from msdb.dbo.sysjobhistory j where b.job_id=j.job_id order by run_date desc,run_time desc)
		,last_duration=(select top 1 run_duration=case when run_duration>=100 then cast(left(run_duration,len(run_duration)-2)*60 as int)+cast(right(run_duration,2) as int) 
		else run_duration end from msdb.dbo.sysjobhistory j where b.job_id=j.job_id order by run_date desc,run_time desc)
		,count(*)  [count]
		from msdb.dbo.sysjobs b
		left join (
					select job_id, run_duration=case when run_duration>=100 then cast(left(run_duration,len(run_duration)-2)*60 as int)+cast(right(run_duration,2) as int) 
												else run_duration
												end,run_date,
						   run_time,
						   run_status,
						   ROW_NUMBER() over (partition by job_id order by run_date desc) as k  
						   from msdb.dbo.sysjobhistory
				  ) as a on (a.job_id=b.job_id)
		where cast(cast(run_date as nvarchar(255)) as date)=cast(getdate() as date) or k=1
		group by b.job_id, b.[name], b.date_created, run_date
		order by sum(run_duration) desc,count(*) *avg(run_duration) desc
	) as a;
end






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Данные по выполнению заданий на сервере', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'GetStatisticJobs';

