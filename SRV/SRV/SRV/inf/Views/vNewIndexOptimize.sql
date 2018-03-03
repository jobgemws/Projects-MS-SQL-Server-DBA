CREATE view [inf].[vNewIndexOptimize] as
/*
	ГЕМ: степень полезности новых индексов
	index_advantage: >50 000 - очень выгодно создать индекс
					 >10 000 - можно создать индекс, однако нужно анализировать и его поддержку
					 <=10000 - индекс можно не создавать
*/
SELECT @@ServerName AS ServerName,
       DB_Name(ddmid.[database_id]) as [DBName],
	   OBJECT_SCHEMA_NAME(ddmid.[object_id], ddmid.[database_id]) as [Schema],
	   OBJECT_NAME(ddmid.[object_id], ddmid.[database_id]) as [Name],
	   ddmigs.user_seeks * ddmigs.avg_total_user_cost * (ddmigs.avg_user_impact * 0.01) AS index_advantage,
	   ddmigs.group_handle,
	   ddmigs.unique_compiles,
	   ddmigs.last_user_seek,
	   ddmigs.last_user_scan,
	   ddmigs.avg_total_user_cost,
	   ddmigs.avg_user_impact,
	   ddmigs.system_seeks,
	   ddmigs.last_system_scan,
	   ddmigs.last_system_seek,
	   ddmigs.avg_total_system_cost,
	   ddmigs.avg_system_impact,
	   ddmig.index_group_handle,
	   ddmig.index_handle,
	   ddmid.database_id,
	   ddmid.[object_id],
	   ddmid.equality_columns,	  -- =
	   ddmid.inequality_columns,
	   ddmid.[statement],
       ( LEN(ISNULL(ddmid.equality_columns, N'')
             + CASE WHEN ddmid.equality_columns IS NOT NULL
                         AND ddmid.inequality_columns IS NOT NULL THEN ','
                    ELSE ''
               END) - LEN(REPLACE(ISNULL(ddmid.equality_columns, N'')
                                  + CASE WHEN ddmid.equality_columns
                                                            IS NOT NULL
                                              AND ddmid.inequality_columns
                                                            IS NOT NULL
                                         THEN ','
                                         ELSE ''
                                    END, ',', '')) ) + 1 AS K ,
       COALESCE(ddmid.equality_columns, '')
       + CASE WHEN ddmid.equality_columns IS NOT NULL
                   AND ddmid.inequality_columns IS NOT NULL THEN ','
              ELSE ''
         END + COALESCE(ddmid.inequality_columns, '') AS Keys ,
       ddmid.included_columns AS [include] ,
       'Create NonClustered Index [IX_' + OBJECT_NAME(ddmid.[object_id], ddmid.[database_id]) + '_missing_'
       + CAST(ddmid.index_handle AS VARCHAR(20)) 
       + '] On ' + ddmid.[statement] COLLATE database_default
       + ' (' + ISNULL(ddmid.equality_columns, '')
       + CASE WHEN ddmid.equality_columns IS NOT NULL
                   AND ddmid.inequality_columns IS NOT NULL THEN ','
              ELSE ''
         END + ISNULL(ddmid.inequality_columns, '') + ')'
       + ISNULL(' Include (' + ddmid.included_columns + ');', ';')
                                                 AS sql_statement ,
       ddmigs.user_seeks ,
       ddmigs.user_scans ,
       CAST(( ddmigs.user_seeks + ddmigs.user_scans )
       * ddmigs.avg_user_impact AS BIGINT) AS 'est_impact' ,
       ( SELECT    DATEDIFF(Second, create_date, GETDATE()) Seconds
         FROM      sys.databases
         WHERE     name = 'tempdb'
       ) SecondsUptime 
FROM
sys.dm_db_missing_index_group_stats ddmigs
INNER JOIN sys.dm_db_missing_index_groups AS ddmig
ON ddmigs.group_handle = ddmig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details AS ddmid
ON ddmig.index_handle = ddmid.index_handle
--WHERE   mid.database_id = DB_ID()
--ORDER BY migs_adv.index_advantage



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сведения о возможных новых индексах и их степени полезности экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vNewIndexOptimize';

