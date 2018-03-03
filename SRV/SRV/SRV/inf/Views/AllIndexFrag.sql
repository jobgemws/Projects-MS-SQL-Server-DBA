





CREATE view [inf].[AllIndexFrag] as
SELECT t2.TABLE_CATALOG as [DBName]
	 ,t2.TABLE_SCHEMA as [Schema]
	 ,t2.TABLE_NAME as [Name]
	 ,(select top(1) idx.[name] from [sys].[indexes] as idx where t1.[object_id] = idx.[object_id] and idx.[index_id] = a.[index_id]) as index_name
	 ,a.avg_fragmentation_in_percent
	 ,a.page_count
	 ,a.avg_fragment_size_in_pages
	 ,a.[database_id]
	 ,a.[object_id]
	 ,a.index_id
	 ,a.partition_number
	 ,a.index_type_desc
	 ,a.alloc_unit_type_desc
	 ,a.index_depth
	 ,a.index_level
	 ,a.fragment_count
	 ,'['+t2.table_catalog+'].['+t2.table_schema+'].['+t2.table_name+']' as FullTable
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL,
     NULL, NULL, NULL) AS a
    --JOIN sys.indexes AS b ON a.object_id = b.object_id AND a.index_id = b.index_id
	JOIN sys.tables as t1 on a.object_id=t1.object_id
	inner join INFORMATION_SCHEMA.TABLES as t2 on t1.name=t2.table_name
	--where t1.type_desc = 'USER_TABLE'
	--and t2.table_catalog='VTSDB2'
	--and a.avg_fragmentation_in_percent>30
	--order by a.avg_fragmentation_in_percent desc;






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Все индексы с информацией о степени фрагментации (sys.dm_db_index_physical_stats)', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'AllIndexFrag';

