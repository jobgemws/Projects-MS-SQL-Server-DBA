
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [srv].[AutoStatisticsActiveConnections]
AS
BEGIN
	/*
		Автосбор данных об активных подключениях
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @servername nvarchar(255)=cast(SERVERPROPERTY(N'MachineName') as nvarchar(255));

	;with conn as (
		select @servername as [ServerName]
		   ,[SessionID]
           ,[LoginName]
		   ,[DBName]           
		   ,[ProgramName]
           ,[Status]
		   ,[LoginTime]
		from [SRV].[inf].[vActiveConnect] with(readuncommitted)
	)
	merge [srv].[ActiveConnectionStatistics] as trg
	using conn as src on (
								trg.[ServerName] collate DATABASE_DEFAULT=src.[ServerName] collate DATABASE_DEFAULT
							and trg.[SessionID]=src.[SessionID]
							and trg.[LoginName] collate DATABASE_DEFAULT=src.[LoginName] collate DATABASE_DEFAULT
							and ((trg.[DBName] collate DATABASE_DEFAULT=src.[DBName] collate DATABASE_DEFAULT) or (src.[DBName] IS NULL))
							and trg.[LoginTime]=src.[LoginTime]
						 )
	WHEN NOT MATCHED BY TARGET THEN
	INSERT (
			[ServerName]
			,[SessionID]
			,[LoginName]
			,[DBName]
			,[ProgramName]
			,[Status]
			,[LoginTime]
		   )
	VALUES (
			src.[ServerName]
			,src.[SessionID]
			,src.[LoginName]
			,src.[DBName]
			,src.[ProgramName]
			,src.[Status]
			,src.[LoginTime]
		   )
	WHEN MATCHED THEN
	UPDATE SET
	trg.[ProgramName]=coalesce(src.[ProgramName] collate DATABASE_DEFAULT, trg.[ProgramName] collate DATABASE_DEFAULT) 
	,trg.[Status]=coalesce(src.[Status] collate DATABASE_DEFAULT, trg.[Status] collate DATABASE_DEFAULT)
	WHEN NOT MATCHED BY SOURCE AND (trg.[EndRegUTCDate] IS NULL) THEN
	UPDATE SET trg.[EndRegUTCDate]=GetUTCDate();
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Автосбор данных об активных подключениях', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoStatisticsActiveConnections';

