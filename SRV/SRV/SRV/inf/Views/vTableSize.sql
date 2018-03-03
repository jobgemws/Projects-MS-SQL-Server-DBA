
CREATE view [inf].[vTableSize] as
with pagesizeKB as (
	SELECT low / 1024 as PageSizeKB
	FROM master.dbo.spt_values
	WHERE number = 1 AND type = 'E'
)
,f_size as (
	select p.[object_id], 
		   sum([total_pages]) as TotalPageSize,
		   sum([used_pages])  as UsedPageSize,
		   sum([data_pages])  as DataPageSize
	from sys.partitions p join sys.allocation_units a on p.partition_id = a.container_id
	left join sys.internal_tables it on p.object_id = it.object_id
	WHERE OBJECTPROPERTY(p.[object_id], N'IsUserTable') = 1
	group by p.[object_id]
)
,tbl as (
	SELECT
	  t.[schema_id],
	  t.[object_id],
	  i1.rowcnt as CountRows,
	  (COALESCE(SUM(i1.reserved), 0) + COALESCE(SUM(i2.reserved), 0)) * (select top(1) PageSizeKB from pagesizeKB) as ReservedKB,
	  (COALESCE(SUM(i1.dpages), 0) + COALESCE(SUM(i2.used), 0)) * (select top(1) PageSizeKB from pagesizeKB) as DataKB,
	  ((COALESCE(SUM(i1.used), 0) + COALESCE(SUM(i2.used), 0))
	    - (COALESCE(SUM(i1.dpages), 0) + COALESCE(SUM(i2.used), 0))) * (select top(1) PageSizeKB from pagesizeKB) as IndexSizeKB,
	  ((COALESCE(SUM(i1.reserved), 0) + COALESCE(SUM(i2.reserved), 0))
	    - (COALESCE(SUM(i1.used), 0) + COALESCE(SUM(i2.used), 0))) * (select top(1) PageSizeKB from pagesizeKB) as UnusedKB
	FROM sys.tables as t
	LEFT OUTER JOIN sysindexes as i1 ON i1.id = t.[object_id] AND i1.indid < 2
	LEFT OUTER JOIN sysindexes as i2 ON i2.id = t.[object_id] AND i2.indid = 255
	WHERE OBJECTPROPERTY(t.[object_id], N'IsUserTable') = 1
	OR (OBJECTPROPERTY(t.[object_id], N'IsView') = 1 AND OBJECTPROPERTY(t.[object_id], N'IsIndexed') = 1)
	GROUP BY t.[schema_id], t.[object_id], i1.rowcnt
)
SELECT
  @@Servername AS Server,
  DB_NAME() AS DBName,
  SCHEMA_NAME(t.[schema_id]) as SchemaName,
  OBJECT_NAME(t.[object_id]) as TableName,
  t.CountRows,
  t.ReservedKB,
  t.DataKB,
  t.IndexSizeKB,
  t.UnusedKB,
  f.TotalPageSize*(select top(1) PageSizeKB from pagesizeKB) as TotalPageSizeKB,
  f.UsedPageSize*(select top(1) PageSizeKB from pagesizeKB) as UsedPageSizeKB,
  f.DataPageSize*(select top(1) PageSizeKB from pagesizeKB) as DataPageSizeKB
FROM f_size as f
inner join tbl as t on t.[object_id]=f.[object_id]

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Размеры таблиц', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vTableSize';

