
CREATE PROCEDURE [srv].[ExcelGetColumns]
as
begin
	/*
		возвращает информацию по столбцам
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	SELECT top(0) [Server]
      ,[DBName]
      ,[TableName]
      ,[SchemaName]
      ,[Ord]
      ,[Column_Name]
      ,[Data_Type]
      ,[Prec]
      ,[Scale]
      ,[LEN]
      ,[Is_Nullable]
      ,[Column_Default]
      ,[Table_Type]
	  into #ttt
  FROM [inf].[vColumns];

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
      ,[TableName]
      ,[SchemaName]
      ,[Ord]
      ,[Column_Name]
      ,[Data_Type]
      ,[Prec]
      ,[Scale]
      ,[LEN]
      ,[Is_Nullable]
      ,[Column_Default]
      ,[Table_Type])
	select [Server]
      ,[DBName]
      ,[TableName]
      ,[SchemaName]
      ,[Ord]
      ,[Column_Name]
      ,[Data_Type]
      ,[Prec]
      ,[Scale]
      ,[LEN]
      ,[Is_Nullable]
      ,[Column_Default]
      ,[Table_Type]
	from ['+@dbs+'].[inf].[vColumns];';

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
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает информацию по столбцам', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'ExcelGetColumns';

