
CREATE PROCEDURE [srv].[ExcelGetDefaultsConstraints]
as
begin
	/*
		возвращает информацию по значениям по умолчанию
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	SELECT top(0) [ServerName]
      ,[DB_Name]
      ,[SchemaName]
      ,[TableName]
      ,[Column_NBR]
      ,[Column_Name]
      ,[DefaultName]
      ,[Defaults]
      ,[type]
      ,[type_desc]
      ,[create_date]
	  into #ttt
  FROM [inf].[vDefaultsConstraints];

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
      ,[DB_Name]
      ,[SchemaName]
      ,[TableName]
      ,[Column_NBR]
      ,[Column_Name]
      ,[DefaultName]
      ,[Defaults]
      ,[type]
      ,[type_desc]
      ,[create_date])
	select [ServerName]
      ,[DB_Name]
      ,[SchemaName]
      ,[TableName]
      ,[Column_NBR]
      ,[Column_Name]
      ,[DefaultName]
      ,[Defaults]
      ,[type]
      ,[type_desc]
      ,[create_date]
	from ['+@dbs+'].[inf].[vDefaultsConstraints];';

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
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает информацию по ограничениям значений по умолчанию', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'ExcelGetDefaultsConstraints';

