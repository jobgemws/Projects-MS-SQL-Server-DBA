-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[AutoStatisticsActiveRequests]
AS
BEGIN
	/*
		31.08.2017 ГЕМ: Сбор данных об активных запросах
		12.02.2018 ГЕМ: добавлена обработка данных по хэшу планов и о использованных ресурсов каждым запросом
		не понял зачем я группировал в #ttt-наверное пытался все впихнуть в merge, потому закомментировал
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @tbl0 table (
						[SQLHandle] [varbinary](64) NOT NULL,
						[TSQL] [nvarchar](max) NULL
					   );
	
	declare @tbl1 table (
						[PlanHandle] [varbinary](64) NOT NULL,
						[SQLHandle] [varbinary](64) NOT NULL,
						[QueryPlan] [xml] NULL
					   );

	declare @tbl2 table (
							[session_id] [smallint] NOT NULL,
							[request_id] [int] NULL,
							[start_time] [datetime] NULL,
							[status] [nvarchar](30) NULL,
							[command] [nvarchar](32) NULL,
							[sql_handle] [varbinary](64) NULL,
							[statement_start_offset] [int] NULL,
							[statement_end_offset] [int] NULL,
							[plan_handle] [varbinary](64) NULL,
							[database_id] [smallint] NULL,
							[user_id] [int] NULL,
							[connection_id] [uniqueidentifier] NULL,
							[blocking_session_id] [smallint] NULL,
							[wait_type] [nvarchar](60) NULL,
							[wait_time] [int] NULL,
							[last_wait_type] [nvarchar](60) NULL,
							[wait_resource] [nvarchar](256) NULL,
							[open_transaction_count] [int] NULL,
							[open_resultset_count] [int] NULL,
							[transaction_id] [bigint] NULL,
							[context_info] [varbinary](128) NULL,
							[percent_complete] [real] NULL,
							[estimated_completion_time] [bigint] NULL,
							[cpu_time] [int] NULL,
							[total_elapsed_time] [int] NULL,
							[scheduler_id] [int] NULL,
							[task_address] [varbinary](8) NULL,
							[reads] [bigint]  NULL,
							[writes] [bigint] NULL,
							[logical_reads] [bigint] NULL,
							[text_size] [int] NULL,
							[language] [nvarchar](128) NULL,
							[date_format] [nvarchar](3) NULL,
							[date_first] [smallint] NULL,
							[quoted_identifier] [bit] NULL,
							[arithabort] [bit] NULL,
							[ansi_null_dflt_on] [bit] NULL,
							[ansi_defaults] [bit] NULL,
							[ansi_warnings] [bit] NULL,
							[ansi_padding] [bit] NULL,
							[ansi_nulls] [bit] NULL,
							[concat_null_yields_null] [bit] NULL,
							[transaction_isolation_level] [smallint] NULL,
							[lock_timeout] [int] NULL,
							[deadlock_priority] [int] NULL,
							[row_count] [bigint] NULL,
							[prev_error] [int] NULL,
							[nest_level] [int] NULL,
							[granted_query_memory] [int]  NULL,
							[executing_managed_code] [bit]  NULL,
							[group_id] [int]  NULL,
							[query_hash] [binary](8) NULL,
							[query_plan_hash] [binary](8) NULL,
							[most_recent_session_id] [int] NULL,
							[connect_time] [datetime] NULL,
							[net_transport] [nvarchar](40) NULL,
							[protocol_type] [nvarchar](40) NULL,
							[protocol_version] [int] NULL,
							[endpoint_id] [int] NULL,
							[encrypt_option] [nvarchar](40) NULL,
							[auth_scheme] [nvarchar](40) NULL,
							[node_affinity] [smallint] NULL,
							[num_reads] [int] NULL,
							[num_writes] [int] NULL,
							[last_read] [datetime] NULL,
							[last_write] [datetime] NULL,
							[net_packet_size] [int] NULL,
							[client_net_address] [varchar](48) NULL,
							[client_tcp_port] [int] NULL,
							[local_net_address] [varchar](48) NULL,
							[local_tcp_port] [int] NULL,
							[parent_connection_id] [uniqueidentifier] NULL,
							[most_recent_sql_handle] [varbinary](64) NULL,
							[login_time] [datetime] NULL,
							[host_name] [nvarchar](128) NULL,
							[program_name] [nvarchar](128) NULL,
							[host_process_id] [int] NULL,
							[client_version] [int] NULL,
							[client_interface_name] [nvarchar](32) NULL,
							[security_id] [varbinary](85) NULL,
							[login_name] [nvarchar](128) NULL,
							[nt_domain] [nvarchar](128) NULL,
							[nt_user_name] [nvarchar](128) NULL,
							[memory_usage] [int] NULL,
							[total_scheduled_time] [int] NULL,
							[last_request_start_time] [datetime] NULL,
							[last_request_end_time] [datetime] NULL,
							[is_user_process] [bit] NULL,
							[original_security_id] [varbinary](85) NULL,
							[original_login_name] [nvarchar](128) NULL,
							[last_successful_logon] [datetime] NULL,
							[last_unsuccessful_logon] [datetime] NULL,
							[unsuccessful_logons] [bigint] NULL,
							[authenticating_database_id] [int] NULL,
							[TSQL] [nvarchar](max) NULL,
							[QueryPlan] [xml] NULL,
							[is_blocking_other_session] [int] NOT NULL,
							[dop] [smallint] NULL,
							[request_time] [datetime] NULL,
							[grant_time] [datetime] NULL,
							[requested_memory_kb] [bigint] NULL,
							[granted_memory_kb] [bigint] NULL,
							[required_memory_kb] [bigint] NULL,
							[used_memory_kb] [bigint] NULL,
							[max_used_memory_kb] [bigint] NULL,
							[query_cost] [float] NULL,
							[timeout_sec] [int] NULL,
							[resource_semaphore_id] [smallint] NULL,
							[queue_id] [smallint] NULL,
							[wait_order] [int] NULL,
							[is_next_candidate] [bit] NULL,
							[wait_time_ms] [bigint] NULL,
							[pool_id] [int] NULL,
							[is_small] [bit] NULL,
							[ideal_memory_kb] [bigint] NULL,
							[reserved_worker_count] [int] NULL,
							[used_worker_count] [int] NULL,
							[max_used_worker_count] [int] NULL,
							[reserved_node_bitmap] [bigint] NULL,
							[bucketid] [int] NULL,
							[refcounts] [int] NULL,
							[usecounts] [int] NULL,
							[size_in_bytes] [int] NULL,
							[memory_object_address] [varbinary](8) NULL,
							[cacheobjtype] [nvarchar](50) NULL,
							[objtype] [nvarchar](20) NULL,
							[parent_plan_handle] [varbinary](64) NULL,
							[creation_time] [datetime] NULL,
							[execution_count] [bigint] NULL,
							[total_worker_time] [bigint] NULL,
							[min_last_worker_time] [bigint] NULL,
							[max_last_worker_time] [bigint] NULL,
							[min_worker_time] [bigint] NULL,
							[max_worker_time] [bigint] NULL,
							[total_physical_reads] [bigint] NULL,
							[min_last_physical_reads] [bigint] NULL,
							[max_last_physical_reads] [bigint] NULL,
							[min_physical_reads] [bigint] NULL,
							[max_physical_reads] [bigint] NULL,
							[total_logical_writes] [bigint] NULL,
							[min_last_logical_writes] [bigint] NULL,
							[max_last_logical_writes] [bigint] NULL,
							[min_logical_writes] [bigint] NULL,
							[max_logical_writes] [bigint] NULL,
							[total_logical_reads] [bigint] NULL,
							[min_last_logical_reads] [bigint] NULL,
							[max_last_logical_reads] [bigint] NULL,
							[min_logical_reads] [bigint] NULL,
							[max_logical_reads] [bigint] NULL,
							[total_clr_time] [bigint] NULL,
							[min_last_clr_time] [bigint] NULL,
							[max_last_clr_time] [bigint] NULL,
							[min_clr_time] [bigint] NULL,
							[max_clr_time] [bigint] NULL,
							[min_last_elapsed_time] [bigint] NULL,
							[max_last_elapsed_time] [bigint] NULL,
							[min_elapsed_time] [bigint] NULL,
							[max_elapsed_time] [bigint] NULL,
							[total_rows] [bigint] NULL,
							[min_last_rows] [bigint] NULL,
							[max_last_rows] [bigint] NULL,
							[min_rows] [bigint] NULL,
							[max_rows] [bigint] NULL,
							[total_dop] [bigint] NULL,
							[min_last_dop] [bigint] NULL,
							[max_last_dop] [bigint] NULL,
							[min_dop] [bigint] NULL,
							[max_dop] [bigint] NULL,
							[total_grant_kb] [bigint] NULL,
							[min_last_grant_kb] [bigint] NULL,
							[max_last_grant_kb] [bigint] NULL,
							[min_grant_kb] [bigint] NULL,
							[max_grant_kb] [bigint] NULL,
							[total_used_grant_kb] [bigint] NULL,
							[min_last_used_grant_kb] [bigint] NULL,
							[max_last_used_grant_kb] [bigint] NULL,
							[min_used_grant_kb] [bigint] NULL,
							[max_used_grant_kb] [bigint] NULL,
							[total_ideal_grant_kb] [bigint] NULL,
							[min_last_ideal_grant_kb] [bigint] NULL,
							[max_last_ideal_grant_kb] [bigint] NULL,
							[min_ideal_grant_kb] [bigint] NULL,
							[max_ideal_grant_kb] [bigint] NULL,
							[total_reserved_threads] [bigint] NULL,
							[min_last_reserved_threads] [bigint] NULL,
							[max_last_reserved_threads] [bigint] NULL,
							[min_reserved_threads] [bigint] NULL,
							[max_reserved_threads] [bigint] NULL,
							[total_used_threads] [bigint] NULL,
							[min_last_used_threads] [bigint] NULL,
							[max_last_used_threads] [bigint] NULL,
							[min_used_threads] [bigint] NULL,
							[max_used_threads] [bigint] NULL
						);

	insert into @tbl2 (
						[session_id]
						,[request_id]
						,[start_time]
						,[status]
						,[command]
						,[sql_handle]
						,[TSQL]
						,[statement_start_offset]
						,[statement_end_offset]
						,[plan_handle]
						,[QueryPlan]
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
						,[is_blocking_other_session]
						,[dop]
						,[request_time]
						,[grant_time]
						,[requested_memory_kb]
						,[granted_memory_kb]
						,[required_memory_kb]
						,[used_memory_kb]
						,[max_used_memory_kb]
						,[query_cost]
						,[timeout_sec]
						,[resource_semaphore_id]
						,[queue_id]
						,[wait_order]
						,[is_next_candidate]
						,[wait_time_ms]
						,[pool_id]
						,[is_small]
						,[ideal_memory_kb]
						,[reserved_worker_count]
						,[used_worker_count]
						,[max_used_worker_count]
						,[reserved_node_bitmap]
						,[bucketid]
						,[refcounts]
						,[usecounts]
						,[size_in_bytes]
						,[memory_object_address]
						,[cacheobjtype]
						,[objtype]
						,[parent_plan_handle]
						,[creation_time]
						,[execution_count]
						,[total_worker_time]
						,[min_last_worker_time]
						,[max_last_worker_time]
						,[min_worker_time]
						,[max_worker_time]
						,[total_physical_reads]
						,[min_last_physical_reads]
						,[max_last_physical_reads]
						,[min_physical_reads]
						,[max_physical_reads]
						,[total_logical_writes]
						,[min_last_logical_writes]
						,[max_last_logical_writes]
						,[min_logical_writes]
						,[max_logical_writes]
						,[total_logical_reads]
						,[min_last_logical_reads]
						,[max_last_logical_reads]
						,[min_logical_reads]
						,[max_logical_reads]
						,[total_clr_time]
						,[min_last_clr_time]
						,[max_last_clr_time]
						,[min_clr_time]
						,[max_clr_time]
						,[min_last_elapsed_time]
						,[max_last_elapsed_time]
						,[min_elapsed_time]
						,[max_elapsed_time]
						,[total_rows]
						,[min_last_rows]
						,[max_last_rows]
						,[min_rows]
						,[max_rows]
						,[total_dop]
						,[min_last_dop]
						,[max_last_dop]
						,[min_dop]
						,[max_dop]
						,[total_grant_kb]
						,[min_last_grant_kb]
						,[max_last_grant_kb]
						,[min_grant_kb]
						,[max_grant_kb]
						,[total_used_grant_kb]
						,[min_last_used_grant_kb]
						,[max_last_used_grant_kb]
						,[min_used_grant_kb]
						,[max_used_grant_kb]
						,[total_ideal_grant_kb]
						,[min_last_ideal_grant_kb]
						,[max_last_ideal_grant_kb]
						,[min_ideal_grant_kb]
						,[max_ideal_grant_kb]
						,[total_reserved_threads]
						,[min_last_reserved_threads]
						,[max_last_reserved_threads]
						,[min_reserved_threads]
						,[max_reserved_threads]
						,[total_used_threads]
						,[min_last_used_threads]
						,[max_last_used_threads]
						,[min_used_threads]
						,[max_used_threads]
					  )
	select [session_id]
	      ,[request_id]
	      ,[start_time]
	      ,[status]
	      ,[command]
	      ,[sql_handle]
		  ,[TSQL]
	      ,[statement_start_offset]
	      ,[statement_end_offset]
	      ,[plan_handle]
		  ,[QueryPlan]
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
		  ,[is_blocking_other_session]
		  ,[dop]
		  ,[request_time]
		  ,[grant_time]
		  ,[requested_memory_kb]
		  ,[granted_memory_kb]
		  ,[required_memory_kb]
		  ,[used_memory_kb]
		  ,[max_used_memory_kb]
		  ,[query_cost]
		  ,[timeout_sec]
		  ,[resource_semaphore_id]
		  ,[queue_id]
		  ,[wait_order]
		  ,[is_next_candidate]
		  ,[wait_time_ms]
		  ,[pool_id]
		  ,[is_small]
		  ,[ideal_memory_kb]
		  ,[reserved_worker_count]
		  ,[used_worker_count]
		  ,[max_used_worker_count]
		  ,[reserved_node_bitmap]
		  ,[bucketid]
		  ,[refcounts]
		  ,[usecounts]
		  ,[size_in_bytes]
		  ,[memory_object_address]
		  ,[cacheobjtype]
		  ,[objtype]
		  ,[parent_plan_handle]
		  ,[creation_time]
		  ,[execution_count]
		  ,[total_worker_time]
		  ,[min_last_worker_time]
		  ,[max_last_worker_time]
		  ,[min_worker_time]
		  ,[max_worker_time]
		  ,[total_physical_reads]
		  ,[min_last_physical_reads]
		  ,[max_last_physical_reads]
		  ,[min_physical_reads]
		  ,[max_physical_reads]
		  ,[total_logical_writes]
		  ,[min_last_logical_writes]
		  ,[max_last_logical_writes]
		  ,[min_logical_writes]
		  ,[max_logical_writes]
		  ,[total_logical_reads]
		  ,[min_last_logical_reads]
		  ,[max_last_logical_reads]
		  ,[min_logical_reads]
		  ,[max_logical_reads]
		  ,[total_clr_time]
		  ,[min_last_clr_time]
		  ,[max_last_clr_time]
		  ,[min_clr_time]
		  ,[max_clr_time]
		  ,[min_last_elapsed_time]
		  ,[max_last_elapsed_time]
		  ,[min_elapsed_time]
		  ,[max_elapsed_time]
		  ,[total_rows]
		  ,[min_last_rows]
		  ,[max_last_rows]
		  ,[min_rows]
		  ,[max_rows]
		  ,[total_dop]
		  ,[min_last_dop]
		  ,[max_last_dop]
		  ,[min_dop]
		  ,[max_dop]
		  ,[total_grant_kb]
		  ,[min_last_grant_kb]
		  ,[max_last_grant_kb]
		  ,[min_grant_kb]
		  ,[max_grant_kb]
		  ,[total_used_grant_kb]
		  ,[min_last_used_grant_kb]
		  ,[max_last_used_grant_kb]
		  ,[min_used_grant_kb]
		  ,[max_used_grant_kb]
		  ,[total_ideal_grant_kb]
		  ,[min_last_ideal_grant_kb]
		  ,[max_last_ideal_grant_kb]
		  ,[min_ideal_grant_kb]
		  ,[max_ideal_grant_kb]
		  ,[total_reserved_threads]
		  ,[min_last_reserved_threads]
		  ,[max_last_reserved_threads]
		  ,[min_reserved_threads]
		  ,[max_reserved_threads]
		  ,[total_used_threads]
		  ,[min_last_used_threads]
		  ,[max_last_used_threads]
		  ,[min_used_threads]
		  ,[max_used_threads]
		from [inf].[vRequestDetail];

	insert into @tbl1 (
						[PlanHandle],
						[SQLHandle],
						[QueryPlan]
					  )
	select				[plan_handle],
						[sql_handle],
						(select top(1) [query_plan] from sys.dm_exec_query_plan([plan_handle])) as [QueryPlan]--cast(cast([QueryPlan] as nvarchar(max)) as XML),
	from @tbl2
	where (select top(1) [query_plan] from sys.dm_exec_query_plan([plan_handle])) is not null
	group by [plan_handle],
			 [sql_handle];--,
			 --cast([QueryPlan] as nvarchar(max)),
			 --[TSQL]

	insert into @tbl0 (
						[SQLHandle],
						[TSQL]
					  )
	select				[sql_handle],
						(select top(1) text from sys.dm_exec_sql_text([sql_handle])) as [TSQL]--[query_text]
	from @tbl2
	where (select top(1) text from sys.dm_exec_sql_text([sql_handle])) is not null
	group by [sql_handle];--,
			 --cast([query_plan] as nvarchar(max)),
			 --[query_text];
	
	;merge [srv].[SQLQuery] as trg
	using @tbl0 as src on trg.[SQLHandle]=src.[SQLHandle]
	WHEN NOT MATCHED BY TARGET THEN
	INSERT (
		 	[SQLHandle],
		 	[TSQL]
		   )
	VALUES (
		 	src.[SQLHandle],
		 	src.[TSQL]
		   );
	
	;merge [srv].[PlanQuery] as trg
	using @tbl1 as src on trg.[SQLHandle]=src.[SQLHandle] and trg.[PlanHandle]=src.[PlanHandle]
	WHEN NOT MATCHED BY TARGET THEN
	INSERT (
		 	[PlanHandle],
		 	[SQLHandle],
		 	[QueryPlan]
		   )
	VALUES (
			src.[PlanHandle],
		 	src.[SQLHandle],
		 	src.[QueryPlan]
		   );

	--select [session_id]
	--      ,[request_id]
	--      ,[start_time]
	--      ,[status]
	--      ,[command]
	--      ,[sql_handle]
	--	  ,(select top(1) 1 from @tbl0 as t where t.[SQLHandle]=tt.[sql_handle]) as [TSQL]
	--      ,[statement_start_offset]
	--      ,[statement_end_offset]
	--      ,[plan_handle]
	--	  ,(select top(1) 1 from @tbl1 as t where t.[PlanHandle]=tt.[plan_handle]) as [QueryPlan]
	--      ,[database_id]
	--      ,[user_id]
	--      ,[connection_id]
	--      ,[blocking_session_id]
	--      ,[wait_type]
	--      ,[wait_time]
	--      ,[last_wait_type]
	--      ,[wait_resource]
	--      ,[open_transaction_count]
	--      ,[open_resultset_count]
	--      ,[transaction_id]
	--      ,[context_info]
	--      ,[percent_complete]
	--      ,[estimated_completion_time]
	--      ,[cpu_time]
	--      ,[total_elapsed_time]
	--      ,[scheduler_id]
	--      ,[task_address]
	--      ,[reads]
	--      ,[writes]
	--      ,[logical_reads]
	--      ,[text_size]
	--      ,[language]
	--      ,[date_format]
	--      ,[date_first]
	--      ,[quoted_identifier]
	--      ,[arithabort]
	--      ,[ansi_null_dflt_on]
	--      ,[ansi_defaults]
	--      ,[ansi_warnings]
	--      ,[ansi_padding]
	--      ,[ansi_nulls]
	--      ,[concat_null_yields_null]
	--      ,[transaction_isolation_level]
	--      ,[lock_timeout]
	--      ,[deadlock_priority]
	--      ,[row_count]
	--      ,[prev_error]
	--      ,[nest_level]
	--      ,[granted_query_memory]
	--      ,[executing_managed_code]
	--      ,[group_id]
	--      ,[query_hash]
	--      ,[query_plan_hash]
	--	  ,[most_recent_session_id]
	--      ,[connect_time]
	--      ,[net_transport]
	--      ,[protocol_type]
	--      ,[protocol_version]
	--      ,[endpoint_id]
	--      ,[encrypt_option]
	--      ,[auth_scheme]
	--      ,[node_affinity]
	--      ,[num_reads]
	--      ,[num_writes]
	--      ,[last_read]
	--      ,[last_write]
	--      ,[net_packet_size]
	--      ,[client_net_address]
	--      ,[client_tcp_port]
	--      ,[local_net_address]
	--      ,[local_tcp_port]
	--      ,[parent_connection_id]
	--      ,[most_recent_sql_handle]
	--	  ,[login_time]
	--	  ,[host_name]
	--	  ,[program_name]
	--	  ,[host_process_id]
	--	  ,[client_version]
	--	  ,[client_interface_name]
	--	  ,[security_id]
	--	  ,[login_name]
	--	  ,[nt_domain]
	--	  ,[nt_user_name]
	--	  ,[memory_usage]
	--	  ,[total_scheduled_time]
	--	  ,[last_request_start_time]
	--	  ,[last_request_end_time]
	--	  ,[is_user_process]
	--	  ,[original_security_id]
	--	  ,[original_login_name]
	--	  ,[last_successful_logon]
	--	  ,[last_unsuccessful_logon]
	--	  ,[unsuccessful_logons]
	--	  ,[authenticating_database_id]
	--	  into #ttt
	--	  from @tbl2 as tt
	--	  group by [session_id]
	--      ,[request_id]
	--      ,[start_time]
	--      ,[status]
	--      ,[command]
	--      ,[sql_handle]
	--	  ,[TSQL]
	--      ,[statement_start_offset]
	--      ,[statement_end_offset]
	--      ,[plan_handle]
	--      ,[database_id]
	--      ,[user_id]
	--      ,[connection_id]
	--      ,[blocking_session_id]
	--      ,[wait_type]
	--      ,[wait_time]
	--      ,[last_wait_type]
	--      ,[wait_resource]
	--      ,[open_transaction_count]
	--      ,[open_resultset_count]
	--      ,[transaction_id]
	--      ,[context_info]
	--      ,[percent_complete]
	--      ,[estimated_completion_time]
	--      ,[cpu_time]
	--      ,[total_elapsed_time]
	--      ,[scheduler_id]
	--      ,[task_address]
	--      ,[reads]
	--      ,[writes]
	--      ,[logical_reads]
	--      ,[text_size]
	--      ,[language]
	--      ,[date_format]
	--      ,[date_first]
	--      ,[quoted_identifier]
	--      ,[arithabort]
	--      ,[ansi_null_dflt_on]
	--      ,[ansi_defaults]
	--      ,[ansi_warnings]
	--      ,[ansi_padding]
	--      ,[ansi_nulls]
	--      ,[concat_null_yields_null]
	--      ,[transaction_isolation_level]
	--      ,[lock_timeout]
	--      ,[deadlock_priority]
	--      ,[row_count]
	--      ,[prev_error]
	--      ,[nest_level]
	--      ,[granted_query_memory]
	--      ,[executing_managed_code]
	--      ,[group_id]
	--      ,[query_hash]
	--      ,[query_plan_hash]
	--	  ,[most_recent_session_id]
	--      ,[connect_time]
	--      ,[net_transport]
	--      ,[protocol_type]
	--      ,[protocol_version]
	--      ,[endpoint_id]
	--      ,[encrypt_option]
	--      ,[auth_scheme]
	--      ,[node_affinity]
	--      ,[num_reads]
	--      ,[num_writes]
	--      ,[last_read]
	--      ,[last_write]
	--      ,[net_packet_size]
	--      ,[client_net_address]
	--      ,[client_tcp_port]
	--      ,[local_net_address]
	--      ,[local_tcp_port]
	--      ,[parent_connection_id]
	--      ,[most_recent_sql_handle]
	--	  ,[login_time]
	--	  ,[host_name]
	--	  ,[program_name]
	--	  ,[host_process_id]
	--	  ,[client_version]
	--	  ,[client_interface_name]
	--	  ,[security_id]
	--	  ,[login_name]
	--	  ,[nt_domain]
	--	  ,[nt_user_name]
	--	  ,[memory_usage]
	--	  ,[total_scheduled_time]
	--	  ,[last_request_start_time]
	--	  ,[last_request_end_time]
	--	  ,[is_user_process]
	--	  ,[original_security_id]
	--	  ,[original_login_name]
	--	  ,[last_successful_logon]
	--	  ,[last_unsuccessful_logon]
	--	  ,[unsuccessful_logons]
	--	  ,[authenticating_database_id];

	UPDATE trg
	SET
	trg.[status]						   =case when (trg.[status]<>'suspended') then coalesce(src.[status] collate DATABASE_DEFAULT, trg.[status] collate DATABASE_DEFAULT) else trg.[status] end
	--,trg.[command]						   =coalesce(src.[command]					   collate DATABASE_DEFAULT, trg.[command]					 	  collate DATABASE_DEFAULT)
	--,trg.[sql_handle]					   =coalesce(src.[sql_handle]				                           , trg.[sql_handle]				 	                          )
	--,trg.[TSQL]							   =coalesce(src.[TSQL]						   collate DATABASE_DEFAULT, trg.[TSQL]						 	  collate DATABASE_DEFAULT)
	,trg.[statement_start_offset]		   =coalesce(src.[statement_start_offset]	                           , trg.[statement_start_offset]	 	                          )
	,trg.[statement_end_offset]			   =coalesce(src.[statement_end_offset]		                           , trg.[statement_end_offset]		 	                          )
	--,trg.[plan_handle]					   =coalesce(src.[plan_handle]				                           , trg.[plan_handle]				 	                          )
	--,trg.[QueryPlan]					   =coalesce(src.[QueryPlan]				                           , trg.[QueryPlan]				 	                          )
	--,trg.[connection_id]				   =coalesce(src.[connection_id]			                           , trg.[connection_id]			 	                          )
	,trg.[blocking_session_id]			   =coalesce(trg.[blocking_session_id]		                           , src.[blocking_session_id]		 	                          )
	,trg.[wait_type]					   =coalesce(trg.[wait_type]				   collate DATABASE_DEFAULT, src.[wait_type]				 	  collate DATABASE_DEFAULT)
	,trg.[wait_time]					   =coalesce(src.[wait_time]				                           , trg.[wait_time]				 	                          )
	,trg.[last_wait_type]				   =coalesce(src.[last_wait_type]			   collate DATABASE_DEFAULT, trg.[last_wait_type]			 	  collate DATABASE_DEFAULT)
	,trg.[wait_resource]				   =coalesce(src.[wait_resource]			   collate DATABASE_DEFAULT, trg.[wait_resource]			 	  collate DATABASE_DEFAULT)
	,trg.[open_transaction_count]		   =coalesce(src.[open_transaction_count]	                           , trg.[open_transaction_count]	 	                          )
	,trg.[open_resultset_count]			   =coalesce(src.[open_resultset_count]		                           , trg.[open_resultset_count]		 	                          )
	--,trg.[transaction_id]				   =coalesce(src.[transaction_id]			                           , trg.[transaction_id]			 	                          )
	,trg.[context_info]					   =coalesce(src.[context_info]				                           , trg.[context_info]				 	                          )
	,trg.[percent_complete]				   =coalesce(src.[percent_complete]			                           , trg.[percent_complete]			 	                          )
	,trg.[estimated_completion_time]	   =coalesce(src.[estimated_completion_time]                           , trg.[estimated_completion_time] 	                          )
	,trg.[cpu_time]						   =coalesce(src.[cpu_time]					                           , trg.[cpu_time]					 	                          )
	,trg.[total_elapsed_time]			   =coalesce(src.[total_elapsed_time]		                           , trg.[total_elapsed_time]		 	                          )
	,trg.[scheduler_id]					   =coalesce(src.[scheduler_id]				                           , trg.[scheduler_id]				 	                          )
	,trg.[task_address]					   =coalesce(src.[task_address]				                           , trg.[task_address]				 	                          )
	,trg.[reads]						   =coalesce(src.[reads]					                           , trg.[reads]					 	                          )
	,trg.[writes]						   =coalesce(src.[writes]					                           , trg.[writes]					 	                          )
	,trg.[logical_reads]				   =coalesce(src.[logical_reads]			                           , trg.[logical_reads]			 	                          )
	,trg.[text_size]					   =coalesce(src.[text_size]				                           , trg.[text_size]				 	                          )
	,trg.[language]						   =coalesce(src.[language]					   collate DATABASE_DEFAULT, trg.[language]					 	  collate DATABASE_DEFAULT)
	,trg.[date_format]					   =coalesce(src.[date_format]				                           , trg.[date_format]				 	                          )
	,trg.[date_first]					   =coalesce(src.[date_first]				                           , trg.[date_first]				 	                          )
	,trg.[quoted_identifier]			   =coalesce(src.[quoted_identifier]		                           , trg.[quoted_identifier]		 	                          )
	,trg.[arithabort]					   =coalesce(src.[arithabort]				                           , trg.[arithabort]				 	                          )
	,trg.[ansi_null_dflt_on]			   =coalesce(src.[ansi_null_dflt_on]		                           , trg.[ansi_null_dflt_on]		 	                          )
	,trg.[ansi_defaults]				   =coalesce(src.[ansi_defaults]			                           , trg.[ansi_defaults]			 	                          )
	,trg.[ansi_warnings]				   =coalesce(src.[ansi_warnings]			                           , trg.[ansi_warnings]			 	                          )
	,trg.[ansi_padding]					   =coalesce(src.[ansi_padding]				                           , trg.[ansi_padding]				 	                          )
	,trg.[ansi_nulls]					   =coalesce(src.[ansi_nulls]				                           , trg.[ansi_nulls]				 	                          )
	,trg.[concat_null_yields_null]		   =coalesce(src.[concat_null_yields_null]	                           , trg.[concat_null_yields_null]	 	                          )
	,trg.[transaction_isolation_level]	   =coalesce(src.[transaction_isolation_level]                         , trg.[transaction_isolation_level]                            )
	,trg.[lock_timeout]					   =coalesce(src.[lock_timeout]				                           , trg.[lock_timeout]				 	                          )
	,trg.[deadlock_priority]			   =coalesce(src.[deadlock_priority]		                           , trg.[deadlock_priority]		 	                          )
	,trg.[row_count]					   =coalesce(src.[row_count]				                           , trg.[row_count]				 	                          )
	,trg.[prev_error]					   =coalesce(src.[prev_error]				                           , trg.[prev_error]				 	                          )
	,trg.[nest_level]					   =coalesce(src.[nest_level]				                           , trg.[nest_level]				 	                          )
	,trg.[granted_query_memory]			   =coalesce(src.[granted_query_memory]		                           , trg.[granted_query_memory]		 	                          )
	,trg.[executing_managed_code]		   =coalesce(src.[executing_managed_code]	                           , trg.[executing_managed_code]	 	                          )
	,trg.[group_id]						   =coalesce(src.[group_id]					                           , trg.[group_id]					 	                          )
	,trg.[query_hash]					   =coalesce(src.[query_hash]				                           , trg.[query_hash]				 	                          )
	,trg.[query_plan_hash]				   =coalesce(src.[query_plan_hash]			                           , trg.[query_plan_hash]			 	                          )
	,trg.[most_recent_session_id]		   =coalesce(src.[most_recent_session_id]	                           , trg.[most_recent_session_id]	 	                          )
	,trg.[connect_time]					   =coalesce(src.[connect_time]				                           , trg.[connect_time]				 	                          )
	,trg.[net_transport]				   =coalesce(src.[net_transport]			   collate DATABASE_DEFAULT, trg.[net_transport]			 	  collate DATABASE_DEFAULT)
	,trg.[protocol_type]				   =coalesce(src.[protocol_type]			   collate DATABASE_DEFAULT, trg.[protocol_type]			 	  collate DATABASE_DEFAULT)
	,trg.[protocol_version]				   =coalesce(src.[protocol_version]			                           , trg.[protocol_version]			 	                          )
	,trg.[endpoint_id]					   =coalesce(src.[endpoint_id]				                           , trg.[endpoint_id]				 	                          )
	,trg.[encrypt_option]				   =coalesce(src.[encrypt_option]			   collate DATABASE_DEFAULT, trg.[encrypt_option]			 	  collate DATABASE_DEFAULT)
	,trg.[auth_scheme]					   =coalesce(src.[auth_scheme]				   collate DATABASE_DEFAULT, trg.[auth_scheme]				 	  collate DATABASE_DEFAULT)
	,trg.[node_affinity]				   =coalesce(src.[node_affinity]			                           , trg.[node_affinity]			 	                          )
	,trg.[num_reads]					   =coalesce(src.[num_reads]				                           , trg.[num_reads]				 	                          )
	,trg.[num_writes]					   =coalesce(src.[num_writes]				                           , trg.[num_writes]				 	                          )
	,trg.[last_read]					   =coalesce(src.[last_read]				                           , trg.[last_read]				 	                          )
	,trg.[last_write]					   =coalesce(src.[last_write]				                           , trg.[last_write]				 	                          )
	,trg.[net_packet_size]				   =coalesce(src.[net_packet_size]			                           , trg.[net_packet_size]			 	                          )
	,trg.[client_net_address]			   =coalesce(src.[client_net_address]		   collate DATABASE_DEFAULT, trg.[client_net_address]		 	  collate DATABASE_DEFAULT)
	,trg.[client_tcp_port]				   =coalesce(src.[client_tcp_port]			                           , trg.[client_tcp_port]			 	                          )
	,trg.[local_net_address]			   =coalesce(src.[local_net_address]		   collate DATABASE_DEFAULT, trg.[local_net_address]		 	  collate DATABASE_DEFAULT)
	,trg.[local_tcp_port]				   =coalesce(src.[local_tcp_port]			                           , trg.[local_tcp_port]			 	                          )
	,trg.[parent_connection_id]			   =coalesce(src.[parent_connection_id]		                           , trg.[parent_connection_id]		 	                          )
	,trg.[most_recent_sql_handle]		   =coalesce(src.[most_recent_sql_handle]	                           , trg.[most_recent_sql_handle]	 	                          )
	,trg.[login_time]					   =coalesce(src.[login_time]				                           , trg.[login_time]				 	                          )
	,trg.[host_name]					   =coalesce(src.[host_name]				   collate DATABASE_DEFAULT, trg.[host_name]				 	  collate DATABASE_DEFAULT)
	,trg.[program_name]					   =coalesce(src.[program_name]				   collate DATABASE_DEFAULT, trg.[program_name]				 	  collate DATABASE_DEFAULT)
	,trg.[host_process_id]				   =coalesce(src.[host_process_id]			                           , trg.[host_process_id]			 	                          )
	,trg.[client_version]				   =coalesce(src.[client_version]			                           , trg.[client_version]			 	                          )
	,trg.[client_interface_name]		   =coalesce(src.[client_interface_name]	   collate DATABASE_DEFAULT, trg.[client_interface_name]	 	  collate DATABASE_DEFAULT)
	,trg.[security_id]					   =coalesce(src.[security_id]				                           , trg.[security_id]				 	                          )
	,trg.[login_name]					   =coalesce(src.[login_name]				   collate DATABASE_DEFAULT, trg.[login_name]				 	  collate DATABASE_DEFAULT)
	,trg.[nt_domain]					   =coalesce(src.[nt_domain]				   collate DATABASE_DEFAULT, trg.[nt_domain]				 	  collate DATABASE_DEFAULT)
	,trg.[nt_user_name]					   =coalesce(src.[nt_user_name]				   collate DATABASE_DEFAULT, trg.[nt_user_name]				 	  collate DATABASE_DEFAULT)
	,trg.[memory_usage]					   =coalesce(src.[memory_usage]				                           , trg.[memory_usage]				 	                          )
	,trg.[total_scheduled_time]			   =coalesce(src.[total_scheduled_time]		                           , trg.[total_scheduled_time]		 	                          )
	,trg.[last_request_start_time]		   =coalesce(src.[last_request_start_time]	                           , trg.[last_request_start_time]	 	                          )
	,trg.[last_request_end_time]		   =coalesce(src.[last_request_end_time]	                           , trg.[last_request_end_time]	 	                          )
	,trg.[is_user_process]				   =coalesce(src.[is_user_process]			                           , trg.[is_user_process]			 	                          )
	,trg.[original_security_id]			   =coalesce(src.[original_security_id]		                           , trg.[original_security_id]		 	                          )
	,trg.[original_login_name]			   =coalesce(src.[original_login_name]		   collate DATABASE_DEFAULT, trg.[original_login_name]		 	  collate DATABASE_DEFAULT)
	,trg.[last_successful_logon]		   =coalesce(src.[last_successful_logon]	                           , trg.[last_successful_logon]	 	                          )
	,trg.[last_unsuccessful_logon]		   =coalesce(src.[last_unsuccessful_logon]	                           , trg.[last_unsuccessful_logon]	 	                          )
	,trg.[unsuccessful_logons]			   =coalesce(src.[unsuccessful_logons]								   , trg.[unsuccessful_logons]		 	                          )
	,trg.[authenticating_database_id]	   =coalesce(src.[authenticating_database_id]                          , trg.[authenticating_database_id]	                          )
	,trg.[is_blocking_other_session]	   =coalesce(src.[is_blocking_other_session]                           , trg.[is_blocking_other_session]	                          )
	,trg.[dop]							   =coalesce(src.[dop]							   					   , trg.[dop]							   						  )
	,trg.[request_time]					   =coalesce(src.[request_time]					   					   , trg.[request_time]					   						  )
	,trg.[grant_time]					   =coalesce(src.[grant_time]					   					   , trg.[grant_time]					   						  )
	,trg.[requested_memory_kb]			   =coalesce(src.[requested_memory_kb]			   					   , trg.[requested_memory_kb]			   						  )
	,trg.[granted_memory_kb]			   =coalesce(src.[granted_memory_kb]			   					   , trg.[granted_memory_kb]			   						  )
	,trg.[required_memory_kb]			   =coalesce(src.[required_memory_kb]			   					   , trg.[required_memory_kb]			   						  )
	,trg.[used_memory_kb]				   =coalesce(src.[used_memory_kb]				   					   , trg.[used_memory_kb]				   						  )
	,trg.[max_used_memory_kb]			   =coalesce(src.[max_used_memory_kb]			   					   , trg.[max_used_memory_kb]			   						  )
	,trg.[query_cost]					   =coalesce(src.[query_cost]					   					   , trg.[query_cost]					   						  )
	,trg.[timeout_sec]					   =coalesce(src.[timeout_sec]					   					   , trg.[timeout_sec]					   						  )
	,trg.[resource_semaphore_id]		   =coalesce(src.[resource_semaphore_id]		   					   , trg.[resource_semaphore_id]		   						  )
	,trg.[queue_id]						   =coalesce(src.[queue_id]						   					   , trg.[queue_id]						   						  )
	,trg.[wait_order]					   =coalesce(src.[wait_order]					   					   , trg.[wait_order]					   						  )
	,trg.[is_next_candidate]			   =coalesce(src.[is_next_candidate]			   					   , trg.[is_next_candidate]			   						  )
	,trg.[wait_time_ms]					   =coalesce(src.[wait_time_ms]					   					   , trg.[wait_time_ms]					   						  )
	,trg.[pool_id]						   =coalesce(src.[pool_id]						   					   , trg.[pool_id]						   						  )
	,trg.[is_small]						   =coalesce(src.[is_small]						   					   , trg.[is_small]						   						  )
	,trg.[ideal_memory_kb]				   =coalesce(src.[ideal_memory_kb]				   					   , trg.[ideal_memory_kb]				   						  )
	,trg.[reserved_worker_count]		   =coalesce(src.[reserved_worker_count]		   					   , trg.[reserved_worker_count]		   						  )
	,trg.[used_worker_count]			   =coalesce(src.[used_worker_count]			   					   , trg.[used_worker_count]			   						  )
	,trg.[max_used_worker_count]		   =coalesce(src.[max_used_worker_count]		   					   , trg.[max_used_worker_count]		   						  )
	,trg.[reserved_node_bitmap]			   =coalesce(src.[reserved_node_bitmap]			   					   , trg.[reserved_node_bitmap]			   						  )
	,trg.[bucketid]						   =coalesce(src.[bucketid]						   					   , trg.[bucketid]						   						  )
	,trg.[refcounts]					   =coalesce(src.[refcounts]					   					   , trg.[refcounts]					   						  )
	,trg.[usecounts]					   =coalesce(src.[usecounts]					   					   , trg.[usecounts]					   						  )
	,trg.[size_in_bytes]				   =coalesce(src.[size_in_bytes]				   					   , trg.[size_in_bytes]				   						  )
	,trg.[memory_object_address]		   =coalesce(src.[memory_object_address]		   					   , trg.[memory_object_address]		   						  )
	,trg.[cacheobjtype]					   =coalesce(src.[cacheobjtype]					   					   , trg.[cacheobjtype]					   						  )
	,trg.[objtype]						   =coalesce(src.[objtype]						   					   , trg.[objtype]						   						  )
	,trg.[parent_plan_handle]			   =coalesce(src.[parent_plan_handle]			   					   , trg.[parent_plan_handle]			   						  )
	,trg.[creation_time]				   =coalesce(src.[creation_time]				   					   , trg.[creation_time]				   						  )
	,trg.[execution_count]				   =coalesce(src.[execution_count]				   					   , trg.[execution_count]				   						  )
	,trg.[total_worker_time]			   =coalesce(src.[total_worker_time]			   					   , trg.[total_worker_time]			   						  )
	,trg.[min_last_worker_time]			   =coalesce(src.[min_last_worker_time]			   					   , trg.[min_last_worker_time]			   						  )
	,trg.[max_last_worker_time]			   =coalesce(src.[max_last_worker_time]			   					   , trg.[max_last_worker_time]			   						  )
	,trg.[min_worker_time]				   =coalesce(src.[min_worker_time]				   					   , trg.[min_worker_time]				   						  )
	,trg.[max_worker_time]				   =coalesce(src.[max_worker_time]				   					   , trg.[max_worker_time]				   						  )
	,trg.[total_physical_reads]			   =coalesce(src.[total_physical_reads]			   					   , trg.[total_physical_reads]			   						  )
	,trg.[min_last_physical_reads]		   =coalesce(src.[min_last_physical_reads]		   					   , trg.[min_last_physical_reads]		   						  )
	,trg.[max_last_physical_reads]		   =coalesce(src.[max_last_physical_reads]		   					   , trg.[max_last_physical_reads]		   						  )
	,trg.[min_physical_reads]			   =coalesce(src.[min_physical_reads]			   					   , trg.[min_physical_reads]			   						  )
	,trg.[max_physical_reads]			   =coalesce(src.[max_physical_reads]			   					   , trg.[max_physical_reads]			   						  )
	,trg.[total_logical_writes]			   =coalesce(src.[total_logical_writes]			   					   , trg.[total_logical_writes]			   						  )
	,trg.[min_last_logical_writes]		   =coalesce(src.[min_last_logical_writes]		   					   , trg.[min_last_logical_writes]		   						  )
	,trg.[max_last_logical_writes]		   =coalesce(src.[max_last_logical_writes]		   					   , trg.[max_last_logical_writes]		   						  )
	,trg.[min_logical_writes]			   =coalesce(src.[min_logical_writes]			   					   , trg.[min_logical_writes]			   						  )
	,trg.[max_logical_writes]			   =coalesce(src.[max_logical_writes]			   					   , trg.[max_logical_writes]			   						  )
	,trg.[total_logical_reads]			   =coalesce(src.[total_logical_reads]			   					   , trg.[total_logical_reads]			   						  )
	,trg.[min_last_logical_reads]		   =coalesce(src.[min_last_logical_reads]		   					   , trg.[min_last_logical_reads]		   						  )
	,trg.[max_last_logical_reads]		   =coalesce(src.[max_last_logical_reads]		   					   , trg.[max_last_logical_reads]		   						  )
	,trg.[min_logical_reads]			   =coalesce(src.[min_logical_reads]			   					   , trg.[min_logical_reads]			   						  )
	,trg.[max_logical_reads]			   =coalesce(src.[max_logical_reads]			   					   , trg.[max_logical_reads]			   						  )
	,trg.[total_clr_time]				   =coalesce(src.[total_clr_time]				   					   , trg.[total_clr_time]				   						  )
	,trg.[min_last_clr_time]			   =coalesce(src.[min_last_clr_time]			   					   , trg.[min_last_clr_time]			   						  )
	,trg.[max_last_clr_time]			   =coalesce(src.[max_last_clr_time]			   					   , trg.[max_last_clr_time]			   						  )
	,trg.[min_clr_time]					   =coalesce(src.[min_clr_time]					   					   , trg.[min_clr_time]					   						  )
	,trg.[max_clr_time]					   =coalesce(src.[max_clr_time]					   					   , trg.[max_clr_time]					   						  )
	,trg.[min_last_elapsed_time]		   =coalesce(src.[min_last_elapsed_time]		   					   , trg.[min_last_elapsed_time]		   						  )
	,trg.[max_last_elapsed_time]		   =coalesce(src.[max_last_elapsed_time]		   					   , trg.[max_last_elapsed_time]		   						  )
	,trg.[min_elapsed_time]				   =coalesce(src.[min_elapsed_time]				   					   , trg.[min_elapsed_time]				   						  )
	,trg.[max_elapsed_time]				   =coalesce(src.[max_elapsed_time]				   					   , trg.[max_elapsed_time]				   						  )
	,trg.[total_rows]					   =coalesce(src.[total_rows]					   					   , trg.[total_rows]					   						  )
	,trg.[min_last_rows]				   =coalesce(src.[min_last_rows]				   					   , trg.[min_last_rows]				   						  )
	,trg.[max_last_rows]				   =coalesce(src.[max_last_rows]				   					   , trg.[max_last_rows]				   						  )
	,trg.[min_rows]						   =coalesce(src.[min_rows]						   					   , trg.[min_rows]						   						  )
	,trg.[max_rows]						   =coalesce(src.[max_rows]						   					   , trg.[max_rows]						   						  )
	,trg.[total_dop]					   =coalesce(src.[total_dop]					   					   , trg.[total_dop]					   						  )
	,trg.[min_last_dop]					   =coalesce(src.[min_last_dop]					   					   , trg.[min_last_dop]					   						  )
	,trg.[max_last_dop]					   =coalesce(src.[max_last_dop]					   					   , trg.[max_last_dop]					   						  )
	,trg.[min_dop]						   =coalesce(src.[min_dop]						   					   , trg.[min_dop]						   						  )
	,trg.[max_dop]						   =coalesce(src.[max_dop]						   					   , trg.[max_dop]						   						  )
	,trg.[total_grant_kb]				   =coalesce(src.[total_grant_kb]				   					   , trg.[total_grant_kb]				   						  )
	,trg.[min_last_grant_kb]			   =coalesce(src.[min_last_grant_kb]			   					   , trg.[min_last_grant_kb]			   						  )
	,trg.[max_last_grant_kb]			   =coalesce(src.[max_last_grant_kb]			   					   , trg.[max_last_grant_kb]			   						  )
	,trg.[min_grant_kb]					   =coalesce(src.[min_grant_kb]					   					   , trg.[min_grant_kb]					   						  )
	,trg.[max_grant_kb]					   =coalesce(src.[max_grant_kb]					   					   , trg.[max_grant_kb]					   						  )
	,trg.[total_used_grant_kb]			   =coalesce(src.[total_used_grant_kb]			   					   , trg.[total_used_grant_kb]			   						  )
	,trg.[min_last_used_grant_kb]		   =coalesce(src.[min_last_used_grant_kb]		   					   , trg.[min_last_used_grant_kb]		   						  )
	,trg.[max_last_used_grant_kb]		   =coalesce(src.[max_last_used_grant_kb]		   					   , trg.[max_last_used_grant_kb]		   						  )
	,trg.[min_used_grant_kb]			   =coalesce(src.[min_used_grant_kb]			   					   , trg.[min_used_grant_kb]			   						  )
	,trg.[max_used_grant_kb]			   =coalesce(src.[max_used_grant_kb]			   					   , trg.[max_used_grant_kb]			   						  )
	,trg.[total_ideal_grant_kb]			   =coalesce(src.[total_ideal_grant_kb]			   					   , trg.[total_ideal_grant_kb]			   						  )
	,trg.[min_last_ideal_grant_kb]		   =coalesce(src.[min_last_ideal_grant_kb]		   					   , trg.[min_last_ideal_grant_kb]		   						  )
	,trg.[max_last_ideal_grant_kb]		   =coalesce(src.[max_last_ideal_grant_kb]		   					   , trg.[max_last_ideal_grant_kb]		   						  )
	,trg.[min_ideal_grant_kb]			   =coalesce(src.[min_ideal_grant_kb]			   					   , trg.[min_ideal_grant_kb]			   						  )
	,trg.[max_ideal_grant_kb]			   =coalesce(src.[max_ideal_grant_kb]			   					   , trg.[max_ideal_grant_kb]			   						  )
	,trg.[total_reserved_threads]		   =coalesce(src.[total_reserved_threads]		   					   , trg.[total_reserved_threads]		   						  )
	,trg.[min_last_reserved_threads]	   =coalesce(src.[min_last_reserved_threads]	   					   , trg.[min_last_reserved_threads]	   						  )
	,trg.[max_last_reserved_threads]	   =coalesce(src.[max_last_reserved_threads]	   					   , trg.[max_last_reserved_threads]	   						  )
	,trg.[min_reserved_threads]			   =coalesce(src.[min_reserved_threads]			   					   , trg.[min_reserved_threads]			   						  )
	,trg.[max_reserved_threads]			   =coalesce(src.[max_reserved_threads]			   					   , trg.[max_reserved_threads]			   						  )
	,trg.[total_used_threads]			   =coalesce(src.[total_used_threads]			   					   , trg.[total_used_threads]			   						  )
	,trg.[min_last_used_threads]		   =coalesce(src.[min_last_used_threads]		   					   , trg.[min_last_used_threads]		   						  )
	,trg.[max_last_used_threads]		   =coalesce(src.[max_last_used_threads]		   					   , trg.[max_last_used_threads]		   						  )
	,trg.[min_used_threads]				   =coalesce(src.[min_used_threads]				   					   , trg.[min_used_threads]				   						  )
	,trg.[max_used_threads]				   =coalesce(src.[max_used_threads]				   					   , trg.[max_used_threads]				   						  )
	from [srv].[RequestStatistics] as trg
	inner join @tbl2 as src on (trg.[session_id]=src.[session_id])
							and (trg.[request_id]=src.[request_id])
							and (trg.[database_id]=src.[database_id])
							and (trg.[user_id]=src.[user_id])
							and (trg.[start_time]=src.[start_time])
							and (trg.[command] collate DATABASE_DEFAULT=src.[command] collate DATABASE_DEFAULT)
							and ((trg.[sql_handle]=src.[sql_handle] and src.[sql_handle] IS NOT NULL) or (src.[sql_handle] IS NULL))
							and ((trg.[plan_handle]=src.[plan_handle] and src.[plan_handle] IS NOT NULL) or (src.[plan_handle] IS NULL))
							and (trg.[transaction_id]=src.[transaction_id])
							and ((trg.[connection_id]=src.[connection_id] and src.[connection_id] IS NOT NULL) or (src.[connection_id] IS NULL));
	UPDATE trg
	SET trg.[EndRegUTCDate]=GetUTCDate()
	from [srv].[RequestStatistics] as trg
	where not exists(
						select top(1) 1
						from @tbl2 as src
						where (trg.[session_id]=src.[session_id])
							and (trg.[request_id]=src.[request_id])
							and (trg.[database_id]=src.[database_id])
							and (trg.[user_id]=src.[user_id])
							and (trg.[start_time]=src.[start_time])
							and (trg.[command] collate DATABASE_DEFAULT=src.[command] collate DATABASE_DEFAULT)
							and ((trg.[sql_handle]=src.[sql_handle] and src.[sql_handle] IS NOT NULL) or (src.[sql_handle] IS NULL))
							and ((trg.[plan_handle]=src.[plan_handle] and src.[plan_handle] IS NOT NULL) or (src.[plan_handle] IS NULL))
							and (trg.[transaction_id]=src.[transaction_id])
							and ((trg.[connection_id]=src.[connection_id] and src.[connection_id] IS NOT NULL) or (src.[connection_id] IS NULL))
					 );

	INSERT into [srv].[RequestStatistics] ([session_id]
	           ,[request_id]
	           ,[start_time]
	           ,[status]
	           ,[command]
	           ,[sql_handle]
			   --,[TSQL]
	           ,[statement_start_offset]
	           ,[statement_end_offset]
	           ,[plan_handle]
			   --,[QueryPlan]
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
			   ,[is_blocking_other_session]
			   ,[dop]
			   ,[request_time]
			   ,[grant_time]
			   ,[requested_memory_kb]
			   ,[granted_memory_kb]
			   ,[required_memory_kb]
			   ,[used_memory_kb]
			   ,[max_used_memory_kb]
			   ,[query_cost]
			   ,[timeout_sec]
			   ,[resource_semaphore_id]
			   ,[queue_id]
			   ,[wait_order]
			   ,[is_next_candidate]
			   ,[wait_time_ms]
			   ,[pool_id]
			   ,[is_small]
			   ,[ideal_memory_kb]
			   ,[reserved_worker_count]
			   ,[used_worker_count]
			   ,[max_used_worker_count]
			   ,[reserved_node_bitmap]
			   ,[bucketid]
			   ,[refcounts]
			   ,[usecounts]
			   ,[size_in_bytes]
			   ,[memory_object_address]
			   ,[cacheobjtype]
			   ,[objtype]
			   ,[parent_plan_handle]
			   ,[creation_time]
			   ,[execution_count]
			   ,[total_worker_time]
			   ,[min_last_worker_time]
			   ,[max_last_worker_time]
			   ,[min_worker_time]
			   ,[max_worker_time]
			   ,[total_physical_reads]
			   ,[min_last_physical_reads]
			   ,[max_last_physical_reads]
			   ,[min_physical_reads]
			   ,[max_physical_reads]
			   ,[total_logical_writes]
			   ,[min_last_logical_writes]
			   ,[max_last_logical_writes]
			   ,[min_logical_writes]
			   ,[max_logical_writes]
			   ,[total_logical_reads]
			   ,[min_last_logical_reads]
			   ,[max_last_logical_reads]
			   ,[min_logical_reads]
			   ,[max_logical_reads]
			   ,[total_clr_time]
			   ,[min_last_clr_time]
			   ,[max_last_clr_time]
			   ,[min_clr_time]
			   ,[max_clr_time]
			   ,[min_last_elapsed_time]
			   ,[max_last_elapsed_time]
			   ,[min_elapsed_time]
			   ,[max_elapsed_time]
			   ,[total_rows]
			   ,[min_last_rows]
			   ,[max_last_rows]
			   ,[min_rows]
			   ,[max_rows]
			   ,[total_dop]
			   ,[min_last_dop]
			   ,[max_last_dop]
			   ,[min_dop]
			   ,[max_dop]
			   ,[total_grant_kb]
			   ,[min_last_grant_kb]
			   ,[max_last_grant_kb]
			   ,[min_grant_kb]
			   ,[max_grant_kb]
			   ,[total_used_grant_kb]
			   ,[min_last_used_grant_kb]
			   ,[max_last_used_grant_kb]
			   ,[min_used_grant_kb]
			   ,[max_used_grant_kb]
			   ,[total_ideal_grant_kb]
			   ,[min_last_ideal_grant_kb]
			   ,[max_last_ideal_grant_kb]
			   ,[min_ideal_grant_kb]
			   ,[max_ideal_grant_kb]
			   ,[total_reserved_threads]
			   ,[min_last_reserved_threads]
			   ,[max_last_reserved_threads]
			   ,[min_reserved_threads]
			   ,[max_reserved_threads]
			   ,[total_used_threads]
			   ,[min_last_used_threads]
			   ,[max_last_used_threads]
			   ,[min_used_threads]
			   ,[max_used_threads])
	select		src.[session_id]
	           ,src.[request_id]
	           ,src.[start_time]
	           ,src.[status]
	           ,src.[command]
	           ,src.[sql_handle]
			   --,src.[TSQL]
	           ,src.[statement_start_offset]
	           ,src.[statement_end_offset]
	           ,src.[plan_handle]
			   --,src.[QueryPlan]
	           ,src.[database_id]
	           ,src.[user_id]
	           ,src.[connection_id]
	           ,src.[blocking_session_id]
	           ,src.[wait_type]
	           ,src.[wait_time]
	           ,src.[last_wait_type]
	           ,src.[wait_resource]
	           ,src.[open_transaction_count]
	           ,src.[open_resultset_count]
	           ,src.[transaction_id]
	           ,src.[context_info]
	           ,src.[percent_complete]
	           ,src.[estimated_completion_time]
	           ,src.[cpu_time]
	           ,src.[total_elapsed_time]
	           ,src.[scheduler_id]
	           ,src.[task_address]
	           ,src.[reads]
	           ,src.[writes]
	           ,src.[logical_reads]
	           ,src.[text_size]
	           ,src.[language]
	           ,src.[date_format]
	           ,src.[date_first]
	           ,src.[quoted_identifier]
	           ,src.[arithabort]
	           ,src.[ansi_null_dflt_on]
	           ,src.[ansi_defaults]
	           ,src.[ansi_warnings]
	           ,src.[ansi_padding]
	           ,src.[ansi_nulls]
	           ,src.[concat_null_yields_null]
	           ,src.[transaction_isolation_level]
	           ,src.[lock_timeout]
	           ,src.[deadlock_priority]
	           ,src.[row_count]
	           ,src.[prev_error]
	           ,src.[nest_level]
	           ,src.[granted_query_memory]
	           ,src.[executing_managed_code]
	           ,src.[group_id]
	           ,src.[query_hash]
	           ,src.[query_plan_hash]
	           ,src.[most_recent_session_id]
	           ,src.[connect_time]
	           ,src.[net_transport]
	           ,src.[protocol_type]
	           ,src.[protocol_version]
	           ,src.[endpoint_id]
	           ,src.[encrypt_option]
	           ,src.[auth_scheme]
	           ,src.[node_affinity]
	           ,src.[num_reads]
	           ,src.[num_writes]
	           ,src.[last_read]
	           ,src.[last_write]
	           ,src.[net_packet_size]
	           ,src.[client_net_address]
	           ,src.[client_tcp_port]
	           ,src.[local_net_address]
	           ,src.[local_tcp_port]
	           ,src.[parent_connection_id]
	           ,src.[most_recent_sql_handle]
	           ,src.[login_time]
	           ,src.[host_name]
	           ,src.[program_name]
	           ,src.[host_process_id]
	           ,src.[client_version]
	           ,src.[client_interface_name]
	           ,src.[security_id]
	           ,src.[login_name]
	           ,src.[nt_domain]
	           ,src.[nt_user_name]
	           ,src.[memory_usage]
	           ,src.[total_scheduled_time]
	           ,src.[last_request_start_time]
	           ,src.[last_request_end_time]
	           ,src.[is_user_process]
	           ,src.[original_security_id]
	           ,src.[original_login_name]
	           ,src.[last_successful_logon]
	           ,src.[last_unsuccessful_logon]
	           ,src.[unsuccessful_logons]
	           ,src.[authenticating_database_id]
			   ,src.[is_blocking_other_session]
			   ,src.[dop]
			   ,src.[request_time]
			   ,src.[grant_time]
			   ,src.[requested_memory_kb]
			   ,src.[granted_memory_kb]
			   ,src.[required_memory_kb]
			   ,src.[used_memory_kb]
			   ,src.[max_used_memory_kb]
			   ,src.[query_cost]
			   ,src.[timeout_sec]
			   ,src.[resource_semaphore_id]
			   ,src.[queue_id]
			   ,src.[wait_order]
			   ,src.[is_next_candidate]
			   ,src.[wait_time_ms]
			   ,src.[pool_id]
			   ,src.[is_small]
			   ,src.[ideal_memory_kb]
			   ,src.[reserved_worker_count]
			   ,src.[used_worker_count]
			   ,src.[max_used_worker_count]
			   ,src.[reserved_node_bitmap]
			   ,src.[bucketid]
			   ,src.[refcounts]
			   ,src.[usecounts]
			   ,src.[size_in_bytes]
			   ,src.[memory_object_address]
			   ,src.[cacheobjtype]
			   ,src.[objtype]
			   ,src.[parent_plan_handle]
			   ,src.[creation_time]
			   ,src.[execution_count]
			   ,src.[total_worker_time]
			   ,src.[min_last_worker_time]
			   ,src.[max_last_worker_time]
			   ,src.[min_worker_time]
			   ,src.[max_worker_time]
			   ,src.[total_physical_reads]
			   ,src.[min_last_physical_reads]
			   ,src.[max_last_physical_reads]
			   ,src.[min_physical_reads]
			   ,src.[max_physical_reads]
			   ,src.[total_logical_writes]
			   ,src.[min_last_logical_writes]
			   ,src.[max_last_logical_writes]
			   ,src.[min_logical_writes]
			   ,src.[max_logical_writes]
			   ,src.[total_logical_reads]
			   ,src.[min_last_logical_reads]
			   ,src.[max_last_logical_reads]
			   ,src.[min_logical_reads]
			   ,src.[max_logical_reads]
			   ,src.[total_clr_time]
			   ,src.[min_last_clr_time]
			   ,src.[max_last_clr_time]
			   ,src.[min_clr_time]
			   ,src.[max_clr_time]
			   ,src.[min_last_elapsed_time]
			   ,src.[max_last_elapsed_time]
			   ,src.[min_elapsed_time]
			   ,src.[max_elapsed_time]
			   ,src.[total_rows]
			   ,src.[min_last_rows]
			   ,src.[max_last_rows]
			   ,src.[min_rows]
			   ,src.[max_rows]
			   ,src.[total_dop]
			   ,src.[min_last_dop]
			   ,src.[max_last_dop]
			   ,src.[min_dop]
			   ,src.[max_dop]
			   ,src.[total_grant_kb]
			   ,src.[min_last_grant_kb]
			   ,src.[max_last_grant_kb]
			   ,src.[min_grant_kb]
			   ,src.[max_grant_kb]
			   ,src.[total_used_grant_kb]
			   ,src.[min_last_used_grant_kb]
			   ,src.[max_last_used_grant_kb]
			   ,src.[min_used_grant_kb]
			   ,src.[max_used_grant_kb]
			   ,src.[total_ideal_grant_kb]
			   ,src.[min_last_ideal_grant_kb]
			   ,src.[max_last_ideal_grant_kb]
			   ,src.[min_ideal_grant_kb]
			   ,src.[max_ideal_grant_kb]
			   ,src.[total_reserved_threads]
			   ,src.[min_last_reserved_threads]
			   ,src.[max_last_reserved_threads]
			   ,src.[min_reserved_threads]
			   ,src.[max_reserved_threads]
			   ,src.[total_used_threads]
			   ,src.[min_last_used_threads]
			   ,src.[max_last_used_threads]
			   ,src.[min_used_threads]
			   ,src.[max_used_threads]
	from @tbl2 as src
	where not exists(
						select top(1) 1
						from [srv].[RequestStatistics] as trg
						where (trg.[session_id]=src.[session_id])
							and (trg.[request_id]=src.[request_id])
							and (trg.[database_id]=src.[database_id])
							and (trg.[user_id]=src.[user_id])
							and (trg.[start_time]=src.[start_time])
							and (trg.[command] collate DATABASE_DEFAULT=src.[command] collate DATABASE_DEFAULT)
							and ((trg.[sql_handle]=src.[sql_handle] and src.[sql_handle] IS NOT NULL) or (src.[sql_handle] IS NULL))
							and ((trg.[plan_handle]=src.[plan_handle] and src.[plan_handle] IS NOT NULL) or (src.[plan_handle] IS NULL))
							and (trg.[transaction_id]=src.[transaction_id])
							and ((trg.[connection_id]=src.[connection_id] and src.[connection_id] IS NOT NULL) or (src.[connection_id] IS NULL))
					 );

	UPDATE pq
	SET pq.[dop]						=coalesce(t.[dop]						, pq.[dop]							)
      ,pq.[request_time]				=coalesce(t.[request_time]				, pq.[request_time]					)
      ,pq.[grant_time]					=coalesce(t.[grant_time]				, pq.[grant_time]					)
      ,pq.[requested_memory_kb]			=coalesce(t.[requested_memory_kb]		, pq.[requested_memory_kb]			)
      ,pq.[granted_memory_kb]			=coalesce(t.[granted_memory_kb]			, pq.[granted_memory_kb]			)
      ,pq.[required_memory_kb]			=coalesce(t.[required_memory_kb]		, pq.[required_memory_kb]			)
      ,pq.[used_memory_kb]				=coalesce(t.[used_memory_kb]			, pq.[used_memory_kb]				)
      ,pq.[max_used_memory_kb]			=coalesce(t.[max_used_memory_kb]		, pq.[max_used_memory_kb]			)
      ,pq.[query_cost]					=coalesce(t.[query_cost]				, pq.[query_cost]					)
      ,pq.[timeout_sec]					=coalesce(t.[timeout_sec]				, pq.[timeout_sec]					)
      ,pq.[resource_semaphore_id]		=coalesce(t.[resource_semaphore_id]		, pq.[resource_semaphore_id]		)
      ,pq.[queue_id]					=coalesce(t.[queue_id]					, pq.[queue_id]						)
      ,pq.[wait_order]					=coalesce(t.[wait_order]				, pq.[wait_order]					)
      ,pq.[is_next_candidate]			=coalesce(t.[is_next_candidate]			, pq.[is_next_candidate]			)
      ,pq.[wait_time_ms]				=coalesce(t.[wait_time_ms]				, pq.[wait_time_ms]					)
      ,pq.[pool_id]						=coalesce(t.[pool_id]					, pq.[pool_id]						)
      ,pq.[is_small]					=coalesce(t.[is_small]					, pq.[is_small]						)
      ,pq.[ideal_memory_kb]				=coalesce(t.[ideal_memory_kb]			, pq.[ideal_memory_kb]				)
      ,pq.[reserved_worker_count]		=coalesce(t.[reserved_worker_count]		, pq.[reserved_worker_count]		)
      ,pq.[used_worker_count]			=coalesce(t.[used_worker_count]			, pq.[used_worker_count]			)
      ,pq.[max_used_worker_count]		=coalesce(t.[max_used_worker_count]		, pq.[max_used_worker_count]		)
      ,pq.[reserved_node_bitmap]		=coalesce(t.[reserved_node_bitmap]		, pq.[reserved_node_bitmap]			)
      ,pq.[bucketid]					=coalesce(t.[bucketid]					, pq.[bucketid]						)
      ,pq.[refcounts]					=coalesce(t.[refcounts]					, pq.[refcounts]					)
      ,pq.[usecounts]					=coalesce(t.[usecounts]					, pq.[usecounts]					)
      ,pq.[size_in_bytes]				=coalesce(t.[size_in_bytes]				, pq.[size_in_bytes]				)
      ,pq.[memory_object_address]		=coalesce(t.[memory_object_address]		, pq.[memory_object_address]		)
      ,pq.[cacheobjtype]				=coalesce(t.[cacheobjtype]				, pq.[cacheobjtype]					)
      ,pq.[objtype]						=coalesce(t.[objtype]					, pq.[objtype]						)
      ,pq.[parent_plan_handle]			=coalesce(t.[parent_plan_handle]		, pq.[parent_plan_handle]			)
      ,pq.[creation_time]				=coalesce(t.[creation_time]				, pq.[creation_time]				)
      ,pq.[execution_count]				=coalesce(t.[execution_count]			, pq.[execution_count]				)
      ,pq.[total_worker_time]			=coalesce(t.[total_worker_time]			, pq.[total_worker_time]			)
      ,pq.[min_last_worker_time]		=coalesce(t.[min_last_worker_time]		, pq.[min_last_worker_time]			)
      ,pq.[max_last_worker_time]		=coalesce(t.[max_last_worker_time]		, pq.[max_last_worker_time]			)
      ,pq.[min_worker_time]				=coalesce(t.[min_worker_time]			, pq.[min_worker_time]				)
      ,pq.[max_worker_time]				=coalesce(t.[max_worker_time]			, pq.[max_worker_time]				)
      ,pq.[total_physical_reads]		=coalesce(t.[total_physical_reads]		, pq.[total_physical_reads]			)
      ,pq.[min_last_physical_reads]		=coalesce(t.[min_last_physical_reads]	, pq.[min_last_physical_reads]		)
      ,pq.[max_last_physical_reads]		=coalesce(t.[max_last_physical_reads]	, pq.[max_last_physical_reads]		)
      ,pq.[min_physical_reads]			=coalesce(t.[min_physical_reads]		, pq.[min_physical_reads]			)
      ,pq.[max_physical_reads]			=coalesce(t.[max_physical_reads]		, pq.[max_physical_reads]			)
      ,pq.[total_logical_writes]		=coalesce(t.[total_logical_writes]		, pq.[total_logical_writes]			)
      ,pq.[min_last_logical_writes]		=coalesce(t.[min_last_logical_writes]	, pq.[min_last_logical_writes]		)
      ,pq.[max_last_logical_writes]		=coalesce(t.[max_last_logical_writes]	, pq.[max_last_logical_writes]		)
      ,pq.[min_logical_writes]			=coalesce(t.[min_logical_writes]		, pq.[min_logical_writes]			)
      ,pq.[max_logical_writes]			=coalesce(t.[max_logical_writes]		, pq.[max_logical_writes]			)
      ,pq.[total_logical_reads]			=coalesce(t.[total_logical_reads]		, pq.[total_logical_reads]			)
      ,pq.[min_last_logical_reads]		=coalesce(t.[min_last_logical_reads]	, pq.[min_last_logical_reads]		)
      ,pq.[max_last_logical_reads]		=coalesce(t.[max_last_logical_reads]	, pq.[max_last_logical_reads]		)
      ,pq.[min_logical_reads]			=coalesce(t.[min_logical_reads]			, pq.[min_logical_reads]			)
      ,pq.[max_logical_reads]			=coalesce(t.[max_logical_reads]			, pq.[max_logical_reads]			)
      ,pq.[total_clr_time]				=coalesce(t.[total_clr_time]			, pq.[total_clr_time]				)
      ,pq.[min_last_clr_time]			=coalesce(t.[min_last_clr_time]			, pq.[min_last_clr_time]			)
      ,pq.[max_last_clr_time]			=coalesce(t.[max_last_clr_time]			, pq.[max_last_clr_time]			)
      ,pq.[min_clr_time]				=coalesce(t.[min_clr_time]				, pq.[min_clr_time]					)
      ,pq.[max_clr_time]				=coalesce(t.[max_clr_time]				, pq.[max_clr_time]					)
      ,pq.[min_last_elapsed_time]		=coalesce(t.[min_last_elapsed_time]		, pq.[min_last_elapsed_time]		)
      ,pq.[max_last_elapsed_time]		=coalesce(t.[max_last_elapsed_time]		, pq.[max_last_elapsed_time]		)
      ,pq.[min_elapsed_time]			=coalesce(t.[min_elapsed_time]			, pq.[min_elapsed_time]				)
      ,pq.[max_elapsed_time]			=coalesce(t.[max_elapsed_time]			, pq.[max_elapsed_time]				)
      ,pq.[total_rows]					=coalesce(t.[total_rows]				, pq.[total_rows]					)
      ,pq.[min_last_rows]				=coalesce(t.[min_last_rows]				, pq.[min_last_rows]				)
      ,pq.[max_last_rows]				=coalesce(t.[max_last_rows]				, pq.[max_last_rows]				)
      ,pq.[min_rows]					=coalesce(t.[min_rows]					, pq.[min_rows]						)
      ,pq.[max_rows]					=coalesce(t.[max_rows]					, pq.[max_rows]						)
      ,pq.[total_dop]					=coalesce(t.[total_dop]					, pq.[total_dop]					)
      ,pq.[min_last_dop]				=coalesce(t.[min_last_dop]				, pq.[min_last_dop]					)
      ,pq.[max_last_dop]				=coalesce(t.[max_last_dop]				, pq.[max_last_dop]					)
      ,pq.[min_dop]						=coalesce(t.[min_dop]					, pq.[min_dop]						)
      ,pq.[max_dop]						=coalesce(t.[max_dop]					, pq.[max_dop]						)
      ,pq.[total_grant_kb]				=coalesce(t.[total_grant_kb]			, pq.[total_grant_kb]				)
      ,pq.[min_last_grant_kb]			=coalesce(t.[min_last_grant_kb]			, pq.[min_last_grant_kb]			)
      ,pq.[max_last_grant_kb]			=coalesce(t.[max_last_grant_kb]			, pq.[max_last_grant_kb]			)
      ,pq.[min_grant_kb]				=coalesce(t.[min_grant_kb]				, pq.[min_grant_kb]					)
      ,pq.[max_grant_kb]				=coalesce(t.[max_grant_kb]				, pq.[max_grant_kb]					)
      ,pq.[total_used_grant_kb]			=coalesce(t.[total_used_grant_kb]		, pq.[total_used_grant_kb]			)
      ,pq.[min_last_used_grant_kb]		=coalesce(t.[min_last_used_grant_kb]	, pq.[min_last_used_grant_kb]		)
      ,pq.[max_last_used_grant_kb]		=coalesce(t.[max_last_used_grant_kb]	, pq.[max_last_used_grant_kb]		)
      ,pq.[min_used_grant_kb]			=coalesce(t.[min_used_grant_kb]			, pq.[min_used_grant_kb]			)
      ,pq.[max_used_grant_kb]			=coalesce(t.[max_used_grant_kb]			, pq.[max_used_grant_kb]			)
      ,pq.[total_ideal_grant_kb]		=coalesce(t.[total_ideal_grant_kb]		, pq.[total_ideal_grant_kb]			)
      ,pq.[min_last_ideal_grant_kb]		=coalesce(t.[min_last_ideal_grant_kb]	, pq.[min_last_ideal_grant_kb]		)
      ,pq.[max_last_ideal_grant_kb]		=coalesce(t.[max_last_ideal_grant_kb]	, pq.[max_last_ideal_grant_kb]		)
      ,pq.[min_ideal_grant_kb]			=coalesce(t.[min_ideal_grant_kb]		, pq.[min_ideal_grant_kb]			)
      ,pq.[max_ideal_grant_kb]			=coalesce(t.[max_ideal_grant_kb]		, pq.[max_ideal_grant_kb]			)
      ,pq.[total_reserved_threads]		=coalesce(t.[total_reserved_threads]	, pq.[total_reserved_threads]		)
      ,pq.[min_last_reserved_threads]	=coalesce(t.[min_last_reserved_threads]	, pq.[min_last_reserved_threads]	)
      ,pq.[max_last_reserved_threads]	=coalesce(t.[max_last_reserved_threads]	, pq.[max_last_reserved_threads]	)
      ,pq.[min_reserved_threads]		=coalesce(t.[min_reserved_threads]		, pq.[min_reserved_threads]			)
      ,pq.[max_reserved_threads]		=coalesce(t.[max_reserved_threads]		, pq.[max_reserved_threads]			)
      ,pq.[total_used_threads]			=coalesce(t.[total_used_threads]		, pq.[total_used_threads]			)
      ,pq.[min_last_used_threads]		=coalesce(t.[min_last_used_threads]		, pq.[min_last_used_threads]		)
      ,pq.[max_last_used_threads]		=coalesce(t.[max_last_used_threads]		, pq.[max_last_used_threads]		)
      ,pq.[min_used_threads]			=coalesce(t.[min_used_threads]			, pq.[min_used_threads]				)
      ,pq.[max_used_threads]			=coalesce(t.[max_used_threads]			, pq.[max_used_threads]				)
	from @tbl2 as t
	inner join srv.PlanQuery as pq on t.[plan_handle]=pq.[PlanHandle] and t.[sql_handle]=pq.[SQLHandle];
	
	--drop table #ttt;
END


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сбор данных об активных запросах', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoStatisticsActiveRequests';

