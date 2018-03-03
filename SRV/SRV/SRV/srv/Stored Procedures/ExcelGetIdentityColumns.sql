
CREATE PROCEDURE [srv].[ExcelGetIdentityColumns]
as
begin
	/*
		возвращает информацию по Identity-столбцам
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	SELECT top(0) [ServerName]
      ,[DBName]
      ,[SchemaName]
      ,[TableName]
      ,[Column_id]
      ,[IdentityColumn]
      ,[Seed_Value]
      ,[Last_Value]
	  into #ttt
  FROM [inf].[vIdentityColumns];

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
      ,[SchemaName]
      ,[TableName]
      ,[Column_id]
      ,[IdentityColumn]
      ,[Seed_Value]
      ,[Last_Value])
	select [ServerName]
      ,[DBName]
      ,[SchemaName]
      ,[TableName]
      ,[Column_id]
      ,[IdentityColumn]
      ,[Seed_Value]
      ,[Last_Value]
	from ['+@dbs+'].[inf].[vIdentityColumns];';

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
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает информацию по Identity-столбцам', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'ExcelGetIdentityColumns';

