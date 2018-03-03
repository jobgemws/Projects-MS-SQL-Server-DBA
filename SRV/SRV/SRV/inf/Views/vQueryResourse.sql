




CREATE view [inf].[vQueryResourse] as
SELECT creation_time
	 , last_execution_time
	 ,round(cast((total_worker_time/execution_count) as float)/1000000,4) AS [Avg CPU Time SEC]
	 ,execution_count
    ,SUBSTRING(st.text, (qs.statement_start_offset/2)+1, 
        ((CASE qs.statement_end_offset
          WHEN -1 THEN DATALENGTH(st.text)
         ELSE qs.statement_end_offset
         END - qs.statement_start_offset)/2) + 1) AS statement_text
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация о запросах согласно статистике экземпляра MS SQL Server ', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vQueryResourse';

