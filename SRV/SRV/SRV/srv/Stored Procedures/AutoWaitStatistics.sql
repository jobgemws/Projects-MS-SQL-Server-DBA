CREATE   PROCEDURE [srv].[AutoWaitStatistics]
AS
BEGIN
	/*
		Сбор данных по ожиданиям MS SQL Server
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @servername nvarchar(255)=cast(SERVERPROPERTY(N'MachineName') as nvarchar(255));

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
	 SELECT @servername AS [Server]
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

