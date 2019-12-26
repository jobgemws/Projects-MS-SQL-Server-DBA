
--Мониторинг использования ресурсов ОП(RAM),cpu,reads,writes по текущим исполняемым сессиям на SQL Server-е
--Прилепа Б.А. - АБД
--22.05.2017

CREATE   procedure [srv].[Used_resouces_by_sessions]
as
begin
	set nocount on;
	set xact_abort on;

	SELECT	spid,
			[percent],
			required_memory_kb,
			used_memory_kb,
			[status],
			sum(writes) writes,
			loginame=(case when max(loginame)=min(loginame) then max(loginame) else max(loginame)+' '+min(loginame) end),
			[db_name],[hostname],client_net_address,[program_name]
			,start_time
			,wait_time
			,last_wait_type
			,command
			,[statement]
			,[text]
	FROM
		(SELECT 
				distinct r.session_id             AS spid,r.percent_complete       AS [percent],required_memory_kb,used_memory_kb,
				r.[status]
				,r.writes
				,DB_NAME(r.database_id)   AS [db_name]
				,s.[hostname]
				,dmec.client_net_address,
				s.[program_name],s.loginame,r.start_time,r.wait_time,r.last_wait_type,r.command,
				(SELECT SUBSTRING(text, statement_start_offset / 2 + 1,

				(CASE WHEN statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX),text)) * 2 
				ELSE statement_end_offset END - statement_start_offset) / 2)
					FROM sys.dm_exec_sql_text(r.sql_handle)) AS [statement]
				,t.[text]
				FROM sys.dm_exec_requests r

				INNER JOIN sys.dm_exec_connections dmec ON r.session_id = dmec.session_id

				INNER JOIN sys.sysprocesses s ON s.spid = r.session_id

				CROSS APPLY sys.dm_exec_sql_text (r.sql_handle) t

				LEFT JOIN sys.dm_exec_query_memory_grants p on(r.session_id=p.session_id) --Использование ОП по сессиям

				) tbl 
	GROUP BY spid,[percent],required_memory_kb,used_memory_kb,[status],[db_name],[hostname],client_net_address,[program_name],start_time,wait_time,last_wait_type,command,[statement],[text]
	ORDER BY used_memory_kb desc,required_memory_kb desc,sum(writes) desc
end

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Мониторинг использования ресурсов ОП(RAM),cpu,reads,writes по текущим исполняемым сессиям на SQL Server-е', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'Used_resouces_by_sessions';

