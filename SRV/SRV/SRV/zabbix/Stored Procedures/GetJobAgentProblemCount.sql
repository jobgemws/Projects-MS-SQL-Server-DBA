



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [zabbix].[GetJobAgentProblemCount]
	@run_minutes int = 30 --максимальное время работы задания Агента
AS
BEGIN
	/*
		Количество проблемных заданий Агента (завершившиеся с ошибкой за последние 24 часа или которые выполняются на текущий момент времени более установленных минут)
	*/

	--SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET XACT_ABORT ON;

	if(@run_minutes<60) set @run_minutes=60;

	;with tbl as (
		SELECT [Job_GUID]
		      ,[Job_Name]
		  FROM [inf].[vJobStepRunShortInfo]
		  where ([LastRunOutcome]<>1 or [LastRunOutcomeStep]<>1)
			 and [LastDateTime]>=DateAdd(day,-1,GetDate())
			 and [LastDateTimeStep]>=DateAdd(day,-1,GetDate())
		union all
		select [job_id]
			  ,[name]
		from [inf].[vJobActivity]
		where [start_execution_date]<=DateAdd(minute, -@run_minutes, GetDate())
	)
	select count(*) as [count]
	from tbl;
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает количество проблемных заданий Агента (завершившиеся с ошибкой за последние 24 часа или которые выполняются на текущий момент времени более установленных минут)', @level0type = N'SCHEMA', @level0name = N'zabbix', @level1type = N'PROCEDURE', @level1name = N'GetJobAgentProblemCount';

