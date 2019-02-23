
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[AutoWaitStatistics]
AS
BEGIN
	/*
		Сбор данных по ожиданиям MS SQL Server
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	INSERT INTO [srv].[WaitsStatistics]
           ([Server]
           ,[WaitType]
           ,[Wait_S]
           ,[Resource_S]
           ,[Signal_S]
           ,[WaitCount]
           ,[Percentage]
           ,[AvgWait_S]
           ,[AvgRes_S]
           ,[AvgSig_S])
	 SELECT @@SERVERNAME AS [Server]
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
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сбор данных по ожиданиям MS SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoWaitStatistics';

