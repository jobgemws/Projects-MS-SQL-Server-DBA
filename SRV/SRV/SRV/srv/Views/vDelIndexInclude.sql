CREATE view [srv].[vDelIndexInclude] as
	/*
	  Погорелов А.А.
	  Поиск перекрывающихся(лишних) индексов.
	  Если поля индекса перекрываются более широким индексом в том же порядке следования полей начиная с первого поля, то 
	  этот индекс считается лишним, так как запросы могут использовать более широкий индекс.
	
	  http://www.sql.ru/blogs/andraptor/1218
	*/
	WITH cte_index_info AS (
	SELECT
	tSS.[name] AS [SchemaName]
	,tSO.[name] AS [ObjectName]
	,tSO.[type_desc] AS [ObjectType]
	,tSO.[create_date] AS [ObjectCreateDate]
	,tSI.[name] AS [IndexName]
	,tSI.[is_primary_key] AS [IndexIsPrimaryKey]
	,d.[index_type_desc] AS [IndexType]
	,d.[avg_fragmentation_in_percent] AS [IndexFragmentation]
	,d.[fragment_count] AS [IndexFragmentCount]
	,d.[avg_fragment_size_in_pages] AS [IndexAvgFragmentSizeInPages]
	,d.[page_count] AS [IndexPages]
	,c.key_columns AS [IndexKeyColumns]
	,COALESCE(ic.included_columns, '') AS [IndexIncludedColumns]
	,tSI.is_unique_constraint
	FROM
	(
	SELECT
	tSDDIPS.[object_id] AS [object_id]
	,tSDDIPS.[index_id] AS [index_id]
	,tSDDIPS.[index_type_desc] AS [index_type_desc]
	,MAX(tSDDIPS.[avg_fragmentation_in_percent]) AS [avg_fragmentation_in_percent]
	,MAX(tSDDIPS.[fragment_count]) AS [fragment_count]
	,MAX(tSDDIPS.[avg_fragment_size_in_pages]) AS [avg_fragment_size_in_pages]
	,MAX(tSDDIPS.[page_count]) AS [page_count]
	FROM
	[sys].[dm_db_index_physical_stats] (DB_ID(), NULL, NULL , NULL, N'LIMITED') tSDDIPS
	GROUP BY
	tSDDIPS.[object_id]
	,tSDDIPS.[index_id]
	,tSDDIPS.[index_type_desc]
	) d
	INNER JOIN [sys].[indexes] tSI ON
	tSI.[object_id] = d.[object_id]
	AND tSI.[index_id] = d.[index_id]
	INNER JOIN [sys].[objects] tSO ON
	tSO.[object_id] = d.[object_id]
	INNER JOIN [sys].[schemas] tSS ON
	tSS.[schema_id] = tSO.[schema_id]
	CROSS APPLY (
	SELECT
	STUFF((
	SELECT
	', ' + c.[name] +
	CASE ic.[is_descending_key]
	WHEN 1 THEN
	'(-)'
	ELSE
	''
	END
	FROM
	[sys].[index_columns] ic
	INNER JOIN [sys].[columns] c ON
	c.[object_id] = ic.[object_id]
	and c.[column_id] = ic.[column_id]
	WHERE
	ic.[index_id] = tSI.[index_id]
	AND ic.[object_id] = tSI.[object_id]
	AND ic.[is_included_column] = 0
	ORDER BY
	ic.[key_ordinal]
	FOR XML
	PATH('')
	)
	,1, 2, ''
	) AS [key_columns]
	) c
	CROSS APPLY (
	SELECT
	STUFF((
	SELECT
	', ' + c.[name]
	FROM
	[sys].[index_columns] ic
	INNER JOIN [sys].[columns] c ON
	c.[object_id] = ic.[object_id]
	AND c.[column_id] = ic.[column_id]
	WHERE
	ic.[index_id] = tSI.[index_id]
	AND ic.[object_id] = tSI.[object_id]
	AND ic.[is_included_column] = 1
	FOR XML
	PATH('')
	)
	,1, 2, ''
	) AS [included_columns]
	) ic
	WHERE
	tSO.[type_desc] IN (
	N'USER_TABLE'
	)
	AND OBJECTPROPERTY(tSO.[object_id], N'IsMSShipped') = 0
	AND d.[index_type_desc] NOT IN (
	'HEAP'
	)
	)
	SELECT
	t1.[SchemaName]
	,t1.[ObjectName]
	,t1.[ObjectType]
	,t1.[ObjectCreateDate]
	,t1.[IndexName] as [DelIndexName]
	,t1.[IndexIsPrimaryKey]
	,t1.[IndexType]
	,t1.[IndexFragmentation]
	,t1.[IndexFragmentCount]
	,t1.[IndexAvgFragmentSizeInPages]
	,t1.[IndexPages]
	,t1.[IndexKeyColumns]
	,t1.[IndexIncludedColumns]
	,t2.[IndexName] as [ActualIndexName]
	FROM
	cte_index_info t1
	INNER JOIN cte_index_info t2 ON
	t2.[SchemaName] = t1.[SchemaName]
	AND t2.[ObjectName] = t1.[ObjectName]
	AND t2.[IndexName] <> t1.[IndexName]
	AND PATINDEX(REPLACE(t1.[IndexKeyColumns], '_', '[_]') + ',%', t2.[IndexKeyColumns] + ',') > 0
	WHERE
	t1.[IndexIncludedColumns] = '' -- don't check indexes with INCLUDE columns
	AND t1.[IndexIsPrimaryKey] = 0 -- don't check primary keys
	AND t1.is_unique_constraint=0  -- don't check unique constraint
	AND t1.[IndexType] NOT IN (
	N'CLUSTERED INDEX'
	,N'UNIQUE CLUSTERED INDEX'
	) -- don't check clustered indexes
	
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Поиск перекрывающихся(лишних) индексов', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'VIEW', @level1name = N'vDelIndexInclude';

