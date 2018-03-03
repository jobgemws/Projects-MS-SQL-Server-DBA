
CREATE PROCEDURE [srv].[ExcelGetAllIndexFrag]
as
begin
	/*
		возвращает информацию по всем индексам, которые занимают не менее 20 страниц
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	SELECT top(0) @@SERVERNAME as [ServerName]
      ,[DBName]
      ,[Schema]
      ,[Name]
      ,[index_name]
      ,[avg_fragmentation_in_percent]
      ,[page_count]
      ,[avg_fragment_size_in_pages]
      ,[database_id]
      ,[object_id]
      ,[index_id]
      ,[partition_number]
      ,[index_type_desc]
      ,[alloc_unit_type_desc]
      ,[index_depth]
      ,[index_level]
      ,[fragment_count]
      ,[FullTable]
	  into #ttt
  FROM [inf].[AllIndexFrag];

  select [name]
  into #dbs
  from sys.databases;

  declare @dbs nvarchar(255);
  declare @sql nvarchar(max);

  while(exists(select top(1) 1 from #dbs))
  begin
	select top(1)
	@dbs=[name]
	from #dbs;

	set @sql=
	N'insert into #ttt([ServerName]
      ,[DBName]
      ,[Schema]
      ,[Name]
      ,[index_name]
      ,[avg_fragmentation_in_percent]
      ,[page_count]
      ,[avg_fragment_size_in_pages]
      ,[database_id]
      ,[object_id]
      ,[index_id]
      ,[partition_number]
      ,[index_type_desc]
      ,[alloc_unit_type_desc]
      ,[index_depth]
      ,[index_level]
      ,[fragment_count]
      ,[FullTable])
	select @@SERVERNAME as [ServerName]
      ,[DBName]
      ,[Schema]
      ,[Name]
      ,[index_name]
      ,[avg_fragmentation_in_percent]
      ,[page_count]
      ,[avg_fragment_size_in_pages]
      ,[database_id]
      ,[object_id]
      ,[index_id]
      ,[partition_number]
      ,[index_type_desc]
      ,[alloc_unit_type_desc]
      ,[index_depth]
      ,[index_level]
      ,[fragment_count]
      ,[FullTable]
	from ['+@dbs+'].[inf].[AllIndexFrag];';

	exec sp_executesql @sql;

	delete from #dbs
	where [name]=@dbs;
  end

  select *
  from #ttt
  where [page_count]>=20;

  drop table #ttt;
  drop table #dbs;
end

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает информацию по всем индексам, которые занимают не менее 20 страниц', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'ExcelGetAllIndexFrag';

