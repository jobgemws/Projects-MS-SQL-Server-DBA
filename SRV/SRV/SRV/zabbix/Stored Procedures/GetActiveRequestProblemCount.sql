

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [zabbix].[GetActiveRequestProblemCount]
	@diffSec    int       =20 --20 секунд на мониториг долгих запросов ctr'SELECT', 'INSERT', 'UPDATE', 'DELETE'
	,@diffSecBackUp    int       =300 --операции бэкпирования, анализ перестроение индексов
	,@Wait_Duration_ms int = 3000
	,@Wait_Duration_semaphore_ms int = 500
AS
BEGIN
	/*
		Количество проблемных запросов в режиме реального времени
	*/

	--SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @data datetime=getdate();

	declare @server_name nvarchar(255)=cast(SERVERPROPERTY(N'ComputerNamePhysicalNetBIOS') as nvarchar(255));
 
	select case when ((left(@server_name, 3) in (N'PRD', N'COM')) or (@server_name like N'SQL_SERVICES%')) then count(distinct ER.session_id) 
				else case when (count(distinct ER.session_id)>3) then 3 else count(distinct ER.session_id) end
		   end as [count]
	from sys.dm_exec_requests ER with(readuncommitted)
	inner join sys.dm_exec_sessions ES with(readuncommitted) on ES.session_id = ER.session_id
	left outer join sys.dm_os_waiting_tasks AS t with(readuncommitted) on(ER.session_id=t.blocking_session_id)
	where ER.connection_id is not null and
	((left(last_wait_type,3) ='LCK'/*локи*/ OR last_wait_type='AWAITING COMMAND' /*скорее всего косяк в коде разрабов или триггер, ожидание внешнее от приложений*/)
	  AND t.wait_duration_ms > @Wait_Duration_ms)
	    OR (last_wait_type in('RESOURCE_SEMAPHORE','RESOURCE_SEMAPHORE_QUERY_COMPILE' /*Нехватка RAM под запрос, утечки RAM*/,'PAGEIOLATCH_UP'
	  /*задача ожидает кратковременной блокировки буфера, находящегося в состоянии запроса ввода-вывода (часто связанно с tempdb)*/)
	  and ER.[start_time]<=DateAdd(ms, -@Wait_Duration_semaphore_ms, @data))
	   OR (ER.[start_time]<=DateAdd(second, -@diffSec, @data) AND ER.command in('SELECT', 'INSERT', 'UPDATE', 'DELETE')
	   OR (ER.[start_time]<=DateAdd(second, -@diffSecBackUp, @data) AND ER.command in('BACKUP LOG', 'BACKUP DATABASE', 'DBCC')
	   OR (ER.last_wait_type='CXPACKET' and ER.[start_time]<=DateAdd(second, -@diffSec, @data)))
	  ) and ER.session_id>50;
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает количество проблемных запросов в режиме реального времени', @level0type = N'SCHEMA', @level0name = N'zabbix', @level1type = N'PROCEDURE', @level1name = N'GetActiveRequestProblemCount';

