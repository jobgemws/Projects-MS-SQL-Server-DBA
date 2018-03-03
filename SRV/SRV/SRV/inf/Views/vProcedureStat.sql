

CREATE view [inf].[vProcedureStat] as 
select DB_Name(coalesce(QS.[database_id], ST.[dbid], PT.[dbid])) as [DB_Name]
	  ,OBJECT_SCHEMA_NAME(coalesce(QS.[object_id], ST.[objectid], PT.[objectid]), coalesce(QS.[database_id], ST.[dbid], PT.[dbid])) as [Schema_Name]
	  ,object_name(coalesce(QS.[object_id], ST.[objectid], PT.[objectid]), coalesce(QS.[database_id], ST.[dbid], PT.[dbid])) as [Object_Name]
	  ,coalesce(QS.[database_id], ST.[dbid], PT.[dbid]) as [database_id]
	  ,SCHEMA_ID(OBJECT_SCHEMA_NAME(coalesce(QS.[object_id], ST.[objectid], PT.[objectid]), coalesce(QS.[database_id], ST.[dbid], PT.[dbid]))) as [schema_id]
      ,coalesce(QS.[object_id], ST.[objectid], PT.[objectid]) as [object_id]
      ,QS.[type]
      ,QS.[type_desc]
      ,QS.[sql_handle]
      ,QS.[plan_handle]
      ,QS.[cached_time]
      ,QS.[last_execution_time]
      ,QS.[execution_count]
      ,QS.[total_worker_time]
      ,QS.[last_worker_time]
      ,QS.[min_worker_time]
      ,QS.[max_worker_time]
      ,QS.[total_physical_reads]
      ,QS.[last_physical_reads]
      ,QS.[min_physical_reads]
      ,QS.[max_physical_reads]
      ,QS.[total_logical_writes]
      ,QS.[last_logical_writes]
      ,QS.[min_logical_writes]
      ,QS.[max_logical_writes]
      ,QS.[total_logical_reads]
      ,QS.[last_logical_reads]
      ,QS.[min_logical_reads]
      ,QS.[max_logical_reads]
      ,QS.[total_elapsed_time]
      ,QS.[last_elapsed_time]
      ,QS.[min_elapsed_time]
      ,QS.[max_elapsed_time]
	  ,ST.[encrypted]
	  ,ST.[text] as [TSQL]
	  ,PT.[query_plan]
FROM sys.dm_exec_procedure_stats AS QS
     CROSS APPLY sys.dm_exec_sql_text(QS.[sql_handle]) as ST
	 CROSS APPLY sys.dm_exec_query_plan(QS.[plan_handle]) as PT

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Статистика по хранимым поцедурам', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vProcedureStat';

