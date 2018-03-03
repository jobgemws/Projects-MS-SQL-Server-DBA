
CREATE PROCEDURE [srv].[ExcelGetWaits]
as
begin
	/*
		возвращает задержки по статистическим данным MS SQL Server
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
	
	SELECT @@SERVERNAME as [ServerName]
	  ,[WaitType]
      ,[Wait_S]
      ,[Resource_S]
      ,[Signal_S]
      ,[WaitCount]
      ,[Percentage]
      ,[AvgWait_S]
      ,[AvgRes_S]
      ,[AvgSig_S]
	FROM [inf].[vWaits];
end

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает задержки по статистическим данным MS SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'ExcelGetWaits';

