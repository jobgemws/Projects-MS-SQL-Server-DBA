
CREATE PROCEDURE [srv].[ExcelGetFuncs]
as
begin
	/*
		возвращает информацию по функциям
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	SELECT top(0) [ServerName]
      ,[DB_Name]
      ,[FunctionName]
      ,[type]
      ,[create_date]
      ,[Function script]
	  into #ttt
  FROM [inf].[vFuncs];

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
      ,[FunctionName]
      ,[type]
      ,[create_date]
      ,[Function script])
	select [ServerName]
      ,[DB_Name]
      ,[FunctionName]
      ,[type]
      ,[create_date]
      ,[Function script]
	from ['+@dbs+'].[inf].[vFuncs];';

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
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает информацию по функциям', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'ExcelGetFuncs';

