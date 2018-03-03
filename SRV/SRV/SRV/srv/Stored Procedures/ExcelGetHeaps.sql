
CREATE PROCEDURE [srv].[ExcelGetHeaps]
as
begin
	/*
		возвращает информацию по всем кучам
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	SELECT [Server]
      ,[DBName]
      ,[SchemaName]
      ,[TableName]
      ,[Type_Desc]
      ,[Rows]
	  into #ttt
  FROM [inf].[vHeaps];

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
	N'insert into #ttt([Server]
      ,[DBName]
      ,[SchemaName]
      ,[TableName]
      ,[Type_Desc]
      ,[Rows])
	select [Server]
      ,[DBName]
      ,[SchemaName]
      ,[TableName]
      ,[Type_Desc]
      ,[Rows]
	from ['+@dbs+'].[inf].[vHeaps];';

	exec sp_executesql @sql;

	delete from #dbs
	where [name]=@dbs;
  end

  select *
  from #ttt;

  drop table #ttt;
  drop table #dbs;
end

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает информацию по всем кучам', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'ExcelGetHeaps';

