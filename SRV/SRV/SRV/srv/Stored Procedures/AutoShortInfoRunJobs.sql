-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[AutoShortInfoRunJobs]
	@second int=60,
	@body nvarchar(max)=NULL OUTPUT
AS
BEGIN
	/*
		Возвращает сообщение о выполненных заданиях для последующей отправки на почту
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    truncate table [srv].[ShortInfoRunJobs];

	INSERT INTO [srv].[ShortInfoRunJobs]
           ([Job_GUID]
           ,[Job_Name]
           ,[LastFinishRunState]
           ,[LastDateTime]
           ,[LastRunDurationString]
           ,[LastRunDurationInt]
           ,[LastOutcomeMessage]
           ,[LastRunOutcome]
           ,[Server])
    SELECT [Job_GUID]
          ,[Job_Name]
          ,[LastFinishRunState]
          ,[LastDateTime]
          ,[LastRunDurationString]
          ,[LastRunDurationInt]
          ,[LastOutcomeMessage]
          ,LastRunOutcome
          ,@@SERVERNAME
      FROM [inf].[vJobRunShortInfo]
      where [Enabled]=1
      and ([LastRunOutcome]=0
      or [LastRunDurationInt]>=@second)
      and LastDateTime>=DateAdd(day,-2,getdate());

	  exec [srv].[GetHTMLTableShortInfoRunJobs] @body=@body OUTPUT;

	  INSERT INTO [srv].[ShortInfoRunJobsServers]
           ([Job_GUID]
           ,[Job_Name]
           ,[LastFinishRunState]
           ,[LastDateTime]
           ,[LastRunDurationString]
           ,[LastRunDurationInt]
           ,[LastOutcomeMessage]
           ,[LastRunOutcome]
           ,[Server]
		   ,[TargetServer])
	  SELECT [Job_GUID]
           ,[Job_Name]
           ,[LastFinishRunState]
           ,[LastDateTime]
           ,[LastRunDurationString]
           ,[LastRunDurationInt]
           ,[LastOutcomeMessage]
           ,[LastRunOutcome]
           ,@@SERVERNAME as [Server]
		   ,[TargetServer]
	  FROM [inf].[vJobRunShortInfo];
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает сообщение о выполненных заданиях для последующей отправки на почту', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoShortInfoRunJobs';

