
CREATE PROCEDURE [srv].[ExcelGetViews]
as
begin
	/*
		возвращает информацию по представлениям
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	SELECT top(0) [Server]
      ,[DBName]
      ,[SchemaName]
      ,[TableName]
      ,[Type]
      ,[TypeDesc]
      ,[CreateDate]
      ,[ModifyDate]
	  into #ttt
  FROM [inf].[vViews];

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
	    ,[Type]
	    ,[TypeDesc]
	    ,[CreateDate]
	    ,[ModifyDate])
	select [Server]
	    ,[DBName]
	    ,[SchemaName]
	    ,[TableName]
	    ,[Type]
	    ,[TypeDesc]
	    ,[CreateDate]
	    ,[ModifyDate]
	from ['+@dbs+'].[inf].[vViews];';

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
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает информацию по представлениям', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'ExcelGetViews';

