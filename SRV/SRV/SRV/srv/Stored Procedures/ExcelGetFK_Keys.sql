
CREATE PROCEDURE [srv].[ExcelGetFK_Keys]
as
begin
	/*
		возвращает информацию по FK-ключам
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	SELECT top(0) @@SERVERNAME as [ServerName]
      ,[ForeignKey]
      ,[SchemaName]
      ,[TableName]
      ,[ColumnName]
      ,[ReferenceSchemaName]
      ,[ReferenceTableName]
      ,[ReferenceColumnName]
      ,[create_date]
	  into #ttt
  FROM [inf].[vFK_Keys];

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
      ,[ForeignKey]
      ,[SchemaName]
      ,[TableName]
      ,[ColumnName]
      ,[ReferenceSchemaName]
      ,[ReferenceTableName]
      ,[ReferenceColumnName]
      ,[create_date])
	select @@SERVERNAME as [ServerName]
      ,[ForeignKey]
      ,[SchemaName]
      ,[TableName]
      ,[ColumnName]
      ,[ReferenceSchemaName]
      ,[ReferenceTableName]
      ,[ReferenceColumnName]
      ,[create_date]
	from ['+@dbs+'].[inf].[vFK_Keys];';

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
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает информацию по FK-ключам', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'ExcelGetFK_Keys';

