CREATE VIEW [inf].[vInnerTableSize] as
--размеры встроенных таблиц
select object_name(p.[object_id]) as [Name]
	 , SUM(a.[total_pages]) as TotalPages
	 , SUM(p.[rows]) as CountRows
	 , cast(SUM(a.[total_pages]) * 8192/1024. as decimal(18, 2)) as TotalSizeKB
from sys.partitions as p
inner join sys.allocation_units as a on p.[partition_id]=a.[container_id]
left outer join sys.internal_tables as it on p.[object_id]=it.[object_id]
where OBJECTPROPERTY(p.[object_id], N'IsUserTable')=0
group by object_name(p.[object_id])
--order by p.[rows] desc;

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Размер встроенных таблиц', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vInnerTableSize';

