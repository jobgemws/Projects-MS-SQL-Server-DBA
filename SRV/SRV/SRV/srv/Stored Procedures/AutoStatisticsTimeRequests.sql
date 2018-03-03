
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[AutoStatisticsTimeRequests]
AS
BEGIN
	/*
		Сбор данных о временах выполнения запросов
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    delete from [srv].[TSQL_DAY_Statistics]
	where [DATE]<=DateAdd(day,-180,GetUTCDate());
	
	INSERT INTO [srv].[TSQL_DAY_Statistics]
	           ([command]
	           ,[DBName]
			   ,[PlanHandle]
	           ,[SqlHandle]
			   ,[execution_count]
	           ,[min_wait_timeSec]
	           ,[min_estimated_completion_timeSec]
	           ,[min_cpu_timeSec]
	           ,[min_total_elapsed_timeSec]
	           ,[min_lock_timeoutSec]
	           ,[max_wait_timeSec]
	           ,[max_estimated_completion_timeSec]
	           ,[max_cpu_timeSec]
	           ,[max_total_elapsed_timeSec]
	           ,[max_lock_timeoutSec]
			   ,[DATE])
	SELECT [command]
	      ,[DBName]
	      ,[plan_handle]
		  ,[sql_handle]
		  ,count(*) as [execution_count]
	      ,min([wait_timeSec])					as [min_wait_timeSec]
	      ,min([estimated_completion_timeSec])	as [min_estimated_completion_timeSec]
	      ,min([cpu_timeSec])					as [min_cpu_timeSec]
	      ,min([total_elapsed_timeSec])			as [min_total_elapsed_timeSec]
	      ,min([lock_timeoutSec])				as [min_lock_timeoutSec]
		  ,max([wait_timeSec])					as [max_wait_timeSec]
	      ,max([estimated_completion_timeSec])	as [max_estimated_completion_timeSec]
	      ,max([cpu_timeSec])					as [max_cpu_timeSec]
	      ,max([total_elapsed_timeSec])			as [max_total_elapsed_timeSec]
	      ,max([lock_timeoutSec])				as [max_lock_timeoutSec]
		  ,cast([InsertUTCDate] as [DATE])		as [DATE]
	  FROM [srv].[vRequestStatistics] with(readuncommitted)
	  where cast([InsertUTCDate] as date) = DateAdd(day,-1,cast(GetUTCDate() as date))
		and [command]  in (
								'UPDATE',
								'TRUNCATE TABLE',
								'SET OPTION ON',
								'SET COMMAND',
								'SELECT INTO',
								'SELECT',
								'NOP',
								'INSERT',
								'EXECUTE',
								'DELETE',
								'DECLARE',
								'CONDITIONAL',
								'BULK INSERT',
								'BEGIN TRY',
								'BEGIN CATCH',
								'AWAITING COMMAND',
								'ASSIGN',
								'ALTER TABLE'
							  )
			--and [database_id] in (
			--						DB_ID(N'bp_corp'),
			--						DB_ID(N'bp_corp_150517'),
			--						DB_ID(N'bp_corp_170216'),
			--						DB_ID(N'bp_corp_UMFO'),
			--						DB_ID(N'MSCRM_CONFIG'),
			--						DB_ID(N'PROFICD-LIVE-RU'),
			--						DB_ID(N'ProficreditRU_MSCRM'),
			--						DB_ID(N'ProficreditRU_REPORTS'),
			--						DB_ID(N'ProficreditRU_RM')
			--					 )
			and [DBName] is not null
	group by [command]
	      ,[DBName]
	      ,[plan_handle]
		  ,[sql_handle]
		  ,cast([InsertUTCDate] as [DATE]);

	declare @inddt int=1;

	;with tbl11 as (
		select [SqlHandle], max([max_total_elapsed_timeSec]) as [max_total_elapsed_timeSec]
		,min([max_total_elapsed_timeSec]) as [min_max_total_elapsed_timeSec]
		,avg([max_total_elapsed_timeSec]) as [avg_max_total_elapsed_timeSec]
		,sum([execution_count]) as [execution_count]
		from [srv].[TSQL_DAY_Statistics]
		where [max_total_elapsed_timeSec]>=0.001
			and [DATE]<cast(DateAdd(day,-@inddt,cast(GetUTCDate() as date)) as date)
		group by [SqlHandle]
	)
	, tbl12 as (
		select [SqlHandle], max([max_total_elapsed_timeSec]) as [max_total_elapsed_timeSec]
		,min([max_total_elapsed_timeSec]) as [min_max_total_elapsed_timeSec]
		,avg([max_total_elapsed_timeSec]) as [avg_max_total_elapsed_timeSec]
		,sum([execution_count]) as [execution_count]
		,[DATE]
		from [srv].[TSQL_DAY_Statistics]
		where [max_total_elapsed_timeSec]>=0.001
			and [DATE]=cast(DateAdd(day,-@inddt,cast(GetUTCDate() as date)) as date)
		group by [SqlHandle], [DATE]
	)
	, tbl11_sum as (select sum([execution_count]) as [sum_execution_count] from tbl11)
	, tbl12_sum as (select sum([execution_count]) as [sum_execution_count] from tbl12)
	, tbl21 as (
		select top(100000) [sql_handle], max([AvgDur]) as [AvgDur]
		,min([AvgDur]) as [min_AvgDur]
		,avg([AvgDur]) as [avg_AvgDur]
		,sum([execution_count]) as [execution_count]
		from [srv].[QueryStatistics]
		where [AvgDur]>=0.001
			and cast([InsertUTCDate] as date)<cast(DateAdd(day,-@inddt,cast(GetUTCDate() as date)) as date)
		group by [sql_handle]
	)
	, tbl22 as (
		select top(100000) [sql_handle], max([AvgDur]) as [AvgDur]
		,min([AvgDur]) as [min_AvgDur]
		,avg([AvgDur]) as [avg_AvgDur]
		,sum([execution_count]) as [execution_count]
		,cast(DateAdd(hour,-DateDiff(hour,GetDate(),GetUTCDate()),[InsertUTCDate]) as date) as [DATE]
		from [srv].[QueryStatistics]
		where [AvgDur]>=0.001
			and cast([InsertUTCDate] as date)=cast(DateAdd(day,-@inddt,cast(GetUTCDate() as date)) as date)
		group by [sql_handle], cast(DateAdd(hour,-DateDiff(hour,GetDate(),GetUTCDate()),[InsertUTCDate]) as date)
	)
	, tbl21_sum as (select sum([execution_count]) as [sum_execution_count] from tbl21)
	, tbl22_sum as (select sum([execution_count]) as [sum_execution_count] from tbl22)
	, tbl1_total as (
		select (select [sum_execution_count] from tbl12_sum) as [execution_count]
		 , sum(tbl11.[max_total_elapsed_timeSec]*tbl11.[execution_count])/(select [sum_execution_count] from tbl11_sum) as [max_total_elapsed_timeSec]
		 , sum(tbl12.[max_total_elapsed_timeSec]*tbl11.[execution_count])/(select [sum_execution_count] from tbl12_sum) as [max_total_elapsed_timeLastSec]
	     , tbl12.[DATE]
	from tbl11
	inner join tbl12 on tbl11.[SqlHandle]=tbl12.[SqlHandle]
	group by tbl12.[DATE]
	)
	, tbl2_total as (
		select (select [sum_execution_count] from tbl22_sum) as [execution_countStatistics]
		 , sum(tbl21.[AvgDur]*tbl21.[execution_count])/(select [sum_execution_count] from tbl21_sum) as [max_AvgDur_timeSec]
		 , sum(tbl22.[AvgDur]*tbl21.[execution_count])/(select [sum_execution_count] from tbl22_sum) as [max_AvgDur_timeLastSec]
	     , tbl22.[DATE]
	from tbl21
	inner join tbl22 on tbl21.[sql_handle]=tbl22.[sql_handle]
	group by tbl22.[DATE]
	)
	INSERT INTO [srv].[IndicatorStatistics]
	           ([DATE]
			   ,[execution_count]
	           ,[max_total_elapsed_timeSec]
	           ,[max_total_elapsed_timeLastSec]
			   ,[execution_countStatistics]
			   ,[max_AvgDur_timeSec]
			   ,[max_AvgDur_timeLastSec]
	           )
	select t1.[DATE]
		  ,t1.[execution_count]
		  ,t1.[max_total_elapsed_timeSec]
		  ,t1.[max_total_elapsed_timeLastSec]
		  ,t2.[execution_countStatistics]
		  ,t2.[max_AvgDur_timeSec]/1000
		  ,t2.[max_AvgDur_timeLastSec]/1000
	from tbl1_total as t1
	inner join tbl2_total as t2 on t1.[DATE]=t2.[DATE];

	declare @dt datetime=DateAdd(day,-2,GetUTCDate());

	INSERT INTO [srv].[RequestStatisticsArchive]
           ([session_id]
           ,[request_id]
           ,[start_time]
           ,[status]
           ,[command]
           ,[sql_handle]
           ,[statement_start_offset]
           ,[statement_end_offset]
           ,[plan_handle]
           ,[database_id]
           ,[user_id]
           ,[connection_id]
           ,[blocking_session_id]
           ,[wait_type]
           ,[wait_time]
           ,[last_wait_type]
           ,[wait_resource]
           ,[open_transaction_count]
           ,[open_resultset_count]
           ,[transaction_id]
           ,[context_info]
           ,[percent_complete]
           ,[estimated_completion_time]
           ,[cpu_time]
           ,[total_elapsed_time]
           ,[scheduler_id]
           ,[task_address]
           ,[reads]
           ,[writes]
           ,[logical_reads]
           ,[text_size]
           ,[language]
           ,[date_format]
           ,[date_first]
           ,[quoted_identifier]
           ,[arithabort]
           ,[ansi_null_dflt_on]
           ,[ansi_defaults]
           ,[ansi_warnings]
           ,[ansi_padding]
           ,[ansi_nulls]
           ,[concat_null_yields_null]
           ,[transaction_isolation_level]
           ,[lock_timeout]
           ,[deadlock_priority]
           ,[row_count]
           ,[prev_error]
           ,[nest_level]
           ,[granted_query_memory]
           ,[executing_managed_code]
           ,[group_id]
           ,[query_hash]
           ,[query_plan_hash]
           ,[most_recent_session_id]
           ,[connect_time]
           ,[net_transport]
           ,[protocol_type]
           ,[protocol_version]
           ,[endpoint_id]
           ,[encrypt_option]
           ,[auth_scheme]
           ,[node_affinity]
           ,[num_reads]
           ,[num_writes]
           ,[last_read]
           ,[last_write]
           ,[net_packet_size]
           ,[client_net_address]
           ,[client_tcp_port]
           ,[local_net_address]
           ,[local_tcp_port]
           ,[parent_connection_id]
           ,[most_recent_sql_handle]
           ,[login_time]
           ,[host_name]
           ,[program_name]
           ,[host_process_id]
           ,[client_version]
           ,[client_interface_name]
           ,[security_id]
           ,[login_name]
           ,[nt_domain]
           ,[nt_user_name]
           ,[memory_usage]
           ,[total_scheduled_time]
           ,[last_request_start_time]
           ,[last_request_end_time]
           ,[is_user_process]
           ,[original_security_id]
           ,[original_login_name]
           ,[last_successful_logon]
           ,[last_unsuccessful_logon]
           ,[unsuccessful_logons]
           ,[authenticating_database_id]
           ,[InsertUTCDate]
           ,[EndRegUTCDate])
	SELECT	[session_id]
           ,[request_id]
           ,[start_time]
           ,[status]
           ,[command]
           ,[sql_handle]
           ,[statement_start_offset]
           ,[statement_end_offset]
           ,[plan_handle]
           ,[database_id]
           ,[user_id]
           ,[connection_id]
           ,[blocking_session_id]
           ,[wait_type]
           ,[wait_time]
           ,[last_wait_type]
           ,[wait_resource]
           ,[open_transaction_count]
           ,[open_resultset_count]
           ,[transaction_id]
           ,[context_info]
           ,[percent_complete]
           ,[estimated_completion_time]
           ,[cpu_time]
           ,[total_elapsed_time]
           ,[scheduler_id]
           ,[task_address]
           ,[reads]
           ,[writes]
           ,[logical_reads]
           ,[text_size]
           ,[language]
           ,[date_format]
           ,[date_first]
           ,[quoted_identifier]
           ,[arithabort]
           ,[ansi_null_dflt_on]
           ,[ansi_defaults]
           ,[ansi_warnings]
           ,[ansi_padding]
           ,[ansi_nulls]
           ,[concat_null_yields_null]
           ,[transaction_isolation_level]
           ,[lock_timeout]
           ,[deadlock_priority]
           ,[row_count]
           ,[prev_error]
           ,[nest_level]
           ,[granted_query_memory]
           ,[executing_managed_code]
           ,[group_id]
           ,[query_hash]
           ,[query_plan_hash]
           ,[most_recent_session_id]
           ,[connect_time]
           ,[net_transport]
           ,[protocol_type]
           ,[protocol_version]
           ,[endpoint_id]
           ,[encrypt_option]
           ,[auth_scheme]
           ,[node_affinity]
           ,[num_reads]
           ,[num_writes]
           ,[last_read]
           ,[last_write]
           ,[net_packet_size]
           ,[client_net_address]
           ,[client_tcp_port]
           ,[local_net_address]
           ,[local_tcp_port]
           ,[parent_connection_id]
           ,[most_recent_sql_handle]
           ,[login_time]
           ,[host_name]
           ,[program_name]
           ,[host_process_id]
           ,[client_version]
           ,[client_interface_name]
           ,[security_id]
           ,[login_name]
           ,[nt_domain]
           ,[nt_user_name]
           ,[memory_usage]
           ,[total_scheduled_time]
           ,[last_request_start_time]
           ,[last_request_end_time]
           ,[is_user_process]
           ,[original_security_id]
           ,[original_login_name]
           ,[last_successful_logon]
           ,[last_unsuccessful_logon]
           ,[unsuccessful_logons]
           ,[authenticating_database_id]
           ,[InsertUTCDate]
           ,[EndRegUTCDate]
	FROM [srv].[RequestStatistics]
	where [InsertUTCDate]<=@dt;

	delete from [srv].[RequestStatistics]
	where [InsertUTCDate]<=@dt;

END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сбор данных о временах выполнения запросов', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoStatisticsTimeRequests';

