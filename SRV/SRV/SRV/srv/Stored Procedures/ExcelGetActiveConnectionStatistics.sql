
CREATE PROCEDURE [srv].[ExcelGetActiveConnectionStatistics]
as
begin
	/*
		возвращает статистику по активным подключениям MS SQL SERVER
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	;with conn as (
		SELECT [ServerName]
			  ,[DBName]
			  ,[ProgramName]
			  ,[LoginName]
			  ,[Status]
			  ,cast([LoginTime] as DATE) as [LoginDate]
			  ,count(*) as [Count]
			  ,MIN(InsertUTCDate) as StartInsertUTCDate
			  ,MAX(InsertUTCDate) as FinishInsertUTCDate
		FROM [srv].[ActiveConnectionStatistics]
		group by [ServerName]
			  ,[DBName]
		    ,[ProgramName]
		    ,[LoginName]
		    ,[Status]
			,cast([LoginTime] as DATE)
	) 
	SELECT [ServerName]
	  ,[DBName]
      ,[ProgramName]
      ,[LoginName]
      ,[Status]
      ,MIN([Count]) as MinCountRows
	  ,MAX([Count]) as MaxCountRows
	  ,AVG([Count]) as AvgCountRows
	  ,MAX([Count])-MIN([Count]) as AbsDiffCountRows
	  ,count(*) as CountRowsStatistic
	  ,MIN(StartInsertUTCDate) as StartInsertUTCDate
	  ,MAX(FinishInsertUTCDate) as FinishInsertUTCDate
  FROM conn
  group by [ServerName]
	  ,[DBName]
      ,[ProgramName]
      ,[LoginName]
      ,[Status];
end

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает статистику по активным подключениям MS SQL SERVER', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'ExcelGetActiveConnectionStatistics';

