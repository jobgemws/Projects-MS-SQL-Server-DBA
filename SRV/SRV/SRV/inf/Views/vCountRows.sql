CREATE view [inf].[vCountRows] as
	-- Метод получения количества записей с использованием DMV dm_db_partition_stats 
	SELECT  @@ServerName AS ServerName ,
	        DB_NAME() AS DBName ,
	        OBJECT_SCHEMA_NAME(ddps.object_id) AS SchemaName ,
	        OBJECT_NAME(ddps.object_id) AS TableName ,
	        i.Type_Desc ,
	        i.Name AS IndexUsedForCounts ,
	        SUM(ddps.row_count) AS Rows
	FROM    sys.dm_db_partition_stats ddps
	        JOIN sys.indexes i ON i.object_id = ddps.object_id
	                              AND i.index_id = ddps.index_id
	WHERE   i.type_desc IN ( 'CLUSTERED', 'HEAP' )
	                              -- This is key (1 index per table) 
	        AND OBJECT_SCHEMA_NAME(ddps.object_id) <> 'sys'
	GROUP BY ddps.object_id ,
	        i.type_desc ,
	        i.Name
	--ORDER BY SchemaName ,
	--        TableName;

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Метод получения количества записей с использованием DMV dm_db_partition_stats', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vCountRows';

