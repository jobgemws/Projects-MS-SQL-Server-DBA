SELECT
*
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.[sql_handle]) AS t
INNER JOIN sys.databases AS db (READUNCOMMITTED)
ON (t.dbid = db.database_id)
INNER JOIN sys.objects AS obj (READUNCOMMITTED)
ON (t.objectid = obj.object_id)