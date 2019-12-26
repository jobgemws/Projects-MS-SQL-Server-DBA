

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [srv].[AutoShortInfoRunJobs]
	@second int=60,
	@body nvarchar(max)=NULL OUTPUT
AS
BEGIN
	/*
		Returns a message about completed tasks 
		for later sending to the mail
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @servername nvarchar(255)=cast(SERVERPROPERTY(N'MachineName') as nvarchar(255));

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
          ,@servername
      FROM [inf].[vJobRunShortInfo]
      where [Enabled]=1
      and ([LastRunOutcome]=0
      or [LastRunDurationInt]>=@second)
      and LastDateTime>=DateAdd(day,-2,getdate());

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
           ,@servername as [Server]
		   ,[TargetServer]
	  FROM [inf].[vJobRunShortInfo];
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Returns a message about completed tasks for later sending to the mail', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoShortInfoRunJobs';

