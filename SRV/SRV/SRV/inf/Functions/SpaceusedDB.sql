CREATE FUNCTION [inf].[SpaceusedDB]
(
)
RETURNS 
@tbl TABLE 
(
	[DBName]			 nvarchar(255), 
	[DBSizeMB]			 decimal(18,3),
	[UnallocatedSpaceMB] decimal(18,3),
	[ReservedMB]		 decimal(18,3),
	[DataMB]			 decimal(18,3),
	[IndexSizeMB]		 decimal(18,3),
	[UnusedMB]			 decimal(18,3)

)
AS
BEGIN
	--SET QUERY_GOVERNOR_COST_LIMIT 0;
	--SET NOCOUNT ON;
	--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @id	int			-- The object id that takes up space
		,@type	character(2) -- The object type.
		,@pages	bigint			-- Working variable for size calc.
		,@dbname sysname
		,@dbsize bigint
		,@logsize bigint
		,@reservedpages  bigint
		,@usedpages  bigint
		,@rowCount bigint;
	
	select @dbsize = sum(convert(bigint,case when status & 64 = 0 then size else 0 end))
		, @logsize = sum(convert(bigint,case when status & 64 <> 0 then size else 0 end))
		from dbo.sysfiles;
	
	select @reservedpages = sum(a.total_pages),
		@usedpages = sum(a.used_pages),
		@pages = sum(
				CASE
					-- XML-Index and FT-Index and semantic index internal tables are not considered "data", but is part of "index_size"
					When it.internal_type IN (202,204,207,211,212,213,214,215,216,221,222,236) Then 0
					When a.type <> 1 and p.index_id < 2 Then a.used_pages
					When p.index_id < 2 Then a.data_pages
					Else 0
				END
			)
	from sys.partitions p join sys.allocation_units a on p.partition_id = a.container_id
		left join sys.internal_tables it on p.object_id = it.object_id;

		insert into @tbl ([DBName], [DBSizeMB], [UnallocatedSpaceMB], [ReservedMB], [DataMB], [IndexSizeMB], [UnusedMB])
		select
		database_name = db_name(),
		database_size = (convert (dec (15,2),@dbsize) + convert (dec (15,2),@logsize)) 
			* 8192 / 1048576,
		'unallocated space' = (case when @dbsize >= @reservedpages then
			(convert (dec (15,2),@dbsize) - convert (dec (15,2),@reservedpages)) 
			* 8192 / 1048576 else 0 end),
		reserved = @reservedpages * 8192 / 1048576.,
		data = @pages * 8192 / 1048576.,
		index_size = (@usedpages - @pages) * 8192 / 1048576.,
		unused = (@reservedpages - @usedpages) * 8192 / 1048576.;
	
	RETURN;
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Выводит информацию о распределении места в БД', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'FUNCTION', @level1name = N'SpaceusedDB';

