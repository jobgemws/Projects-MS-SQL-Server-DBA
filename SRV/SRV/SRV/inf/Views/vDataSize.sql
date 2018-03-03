
CREATE view [inf].[vDataSize] as
with tbl as (
	select sum(ReservedKB) as [ReservedUserTablesKB],
	sum(DataKB) as [DataUserTablesKB],
	sum(IndexSizeKB) as [IndexSizeUserTablesKB],
	sum(UnusedKB) as [UnusedUserTablesKB],
	sum([TotalPageSizeKB]) as [TotalPageSizeKB],
	sum([UsedPageSizeKB]) as [UsedPageSizeKB],
	sum([DataPageSizeKB]) as [DataPageSizeKB]
	from inf.vTableSize
)
select
(
	select cast(sum([total_pages]) * 8192 / 1024. as decimal(18,2))
	from sys.partitions p join sys.allocation_units a on p.partition_id = a.container_id
	left join sys.internal_tables it on p.object_id = it.object_id
	WHERE OBJECTPROPERTY(p.[object_id], N'IsUserTable') = 0
) as [TotalPagesSystemTablesKB],
	[TotalPageSizeKB],
	[UsedPageSizeKB],
	[DataPageSizeKB],
	[DataUserTablesKB],
	[IndexSizeUserTablesKB],
	[UnusedUserTablesKB]
from tbl;

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Размеры БД', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vDataSize';

