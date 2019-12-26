
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [srv].[GetHTMLTableShortInfoRunJobsServers]
	@Path nvarchar(255),
	@Filename nvarchar(255),
	@second int=60
AS
BEGIN
	/*
		формирует HTML-код для таблицы выполненных заданий
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @servername nvarchar(255)=cast(SERVERPROPERTY(N'MachineName') as nvarchar(255));

	DECLARE  @objFileSystem int
        ,@objTextStream int,
		@objErrorObject int,
		@strErrorMessage nvarchar(1000),
	    @Command nvarchar(1000),
	    @hr int,
		@fileAndPath varchar(80);

	select @strErrorMessage='opening the File System Object'
	EXECUTE @hr = sp_OACreate  'Scripting.FileSystemObject' , @objFileSystem OUT
	
	Select @FileAndPath=@path+'\'+@filename
	if @HR=0 Select @objErrorObject=@objFileSystem , @strErrorMessage='Creating file "'+@FileAndPath+'"'
	if @HR=0 execute @hr = sp_OAMethod   @objFileSystem   , 'CreateTextFile'
	, @objTextStream OUT, @FileAndPath,2,True

	if @HR=0 Select @objErrorObject=@objTextStream, 
	@strErrorMessage='writing to the file "'+@FileAndPath+'"'

	declare @body nvarchar(max);

	declare @tbl table (
						Job_GUID				uniqueidentifier
						,Job_Name				nvarchar(255)
						,LastFinishRunState		nvarchar(255)
						,LastDateTime			datetime
						,LastRunDurationString	nvarchar(255)
						,LastOutcomeMessage		nvarchar(max)
						,[Server]				nvarchar(255)
						,ID						int identity(1,1)
					   );

	declare
	@Job_GUID				uniqueidentifier
	,@Job_Name				nvarchar(255)
	,@LastFinishRunState	nvarchar(255)
	,@LastDateTime			datetime
	,@LastRunDurationString	nvarchar(255)
	,@LastOutcomeMessage	nvarchar(max)
	,@Server				nvarchar(255)
	,@ID					int;

	insert into @tbl(
						Job_GUID
						,Job_Name
						,LastFinishRunState
						,LastDateTime
						,LastRunDurationString
						,LastOutcomeMessage
						,[Server]
					)
			select		Job_GUID
						,Job_Name
						,LastFinishRunState
						,LastDateTime
						,LastRunDurationString
						,LastOutcomeMessage
						,[Server]
			from	srv.ShortInfoRunJobsServers
			where [InsertUTCDate]>=DateAdd(day,-1,GetUTCDate())
			order by [Server] asc, LastRunDurationInt desc;

	if(exists(select top(1) 1 from @tbl))
	begin
		set @body='В ходе анализа последних выполнений заданий, были выявлены следующие задания, которые либо с ошибочным завершением, '
				 +'либо выполнились по времени более '+cast(@second as nvarchar(255))+' секунд:<br><br>'+'<TABLE BORDER=5>';

		set @body=@body+'<TR>';

		set @body=@body+'<TD>';
		set @body=@body+'№ п/п';
		set @body=@body+'</TD>';
	
		set @body=@body+'<TD>';
		set @body=@body+'СЕРВЕР';
		set @body=@body+'</TD>';

		set @body=@body+'<TD>';
		set @body=@body+'ЗАДАНИЕ';
		set @body=@body+'</TD>';
	
		set @body=@body+'<TD>';
		set @body=@body+'СТАТУС';
		set @body=@body+'</TD>';

		set @body=@body+'<TD>';
		set @body=@body+'ДАТА И ВРЕМЯ';
		set @body=@body+'</TD>';

		set @body=@body+'<TD>';
		set @body=@body+'ДЛИТЕЛЬНОСТЬ';
		set @body=@body+'</TD>';

		set @body=@body+'<TD>';
		set @body=@body+'СООБЩЕНИЕ';
		set @body=@body+'</TD>';

		set @body=@body+'</TR>';

		if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Write', Null, @body;

		set @body='';

		DECLARE sql_cursor CURSOR LOCAL FOR
		select Job_GUID
			  ,Job_Name
			  ,LastFinishRunState
			  ,LastDateTime
			  ,LastRunDurationString
			  ,LastOutcomeMessage
			  ,[Server]
		from @tbl;
		
		OPEN sql_cursor;
		  
		FETCH NEXT FROM sql_cursor   
		INTO @Job_GUID
			  ,@Job_Name
			  ,@LastFinishRunState
			  ,@LastDateTime
			  ,@LastRunDurationString
			  ,@LastOutcomeMessage
			  ,@Server;

		set @ID=0;

		while (@@FETCH_STATUS = 0 )
		begin
			set @ID=@ID+1;
			
			set @body=@body+'<TR>';

			--select top (1)
			--@ID						=	[ID]
			--,@Job_GUID				=	Job_GUID
			--,@Job_Name				=	Job_Name				
			--,@LastFinishRunState	=	LastFinishRunState		
			--,@LastDateTime			=	LastDateTime			
			--,@LastRunDurationString	=	LastRunDurationString	
			--,@LastOutcomeMessage	=	LastOutcomeMessage		
			--,@Server				=	[Server]				
			--from @tbl;

			set @body=@body+'<TD>';
			set @body=@body+cast(@ID as nvarchar(max));
			set @body=@body+'</TD>';
		
			set @body=@body+'<TD>';
			set @body=@body+coalesce(@Server, '');
			set @body=@body+'</TD>';
		
			set @body=@body+'<TD>';
			set @body=@body+coalesce(@Job_Name,'');
			set @body=@body+'</TD>';
		
			set @body=@body+'<TD>';
			set @body=@body+coalesce(@LastFinishRunState,'');
			set @body=@body+'</TD>';

			set @body=@body+'<TD>';
			set @body=@body+coalesce(rep.GetDateFormat(@LastDateTime, default)+' '+rep.GetTimeFormat(@LastDateTime, default), '');--cast(@InsertDate as nvarchar(max));
			set @body=@body+'</TD>';

			set @body=@body+'<TD>';
			set @body=@body+coalesce(@LastRunDurationString,'');
			set @body=@body+'</TD>';

			set @body=@body+'<TD>';
			set @body=@body+coalesce(@LastOutcomeMessage, '');
			set @body=@body+'</TD>';

			--delete from @tbl
			--where ID=@ID;

			set @body=@body+'</TR>';

			if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Write', Null, @body;

			set @body='';

			FETCH NEXT FROM sql_cursor   
			INTO @Job_GUID
			  ,@Job_Name
			  ,@LastFinishRunState
			  ,@LastDateTime
			  ,@LastRunDurationString
			  ,@LastOutcomeMessage
			  ,@Server;
		end

		CLOSE sql_cursor;
		DEALLOCATE sql_cursor;

		set @body=@body+'</TABLE>';
	end
	else
	begin
		set @body='В ходе анализа последних выполнений заданий, задания с ошибочным завершением, а также те, что выполнились по времени более '
				 +cast(@second as nvarchar(255))
				 +' секунд, не выявлены на сервере '+@servername;
	end
	
	set @body=@body+'<br><br>Для более детальной информации обратитесь к таблице SRV.srv.ShortInfoRunJobs';

	if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Write', Null, @body;

	if @HR=0 Select @objErrorObject=@objTextStream, @strErrorMessage='closing the file "'+@FileAndPath+'"'
	if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Close'
	
	if @hr<>0
		begin
		Declare 
			@Source varchar(255),
			@Description Varchar(255),
			@Helpfile Varchar(255),
			@HelpID int
		
		EXECUTE sp_OAGetErrorInfo  @objErrorObject, 
			@source output,@Description output,@Helpfile output,@HelpID output
		Select @strErrorMessage='Error whilst '
				+coalesce(@strErrorMessage,'doing something')
				+', '+coalesce(@Description,'')
		raiserror (@strErrorMessage,16,1)
		end
	EXECUTE  sp_OADestroy @objTextStream
	EXECUTE sp_OADestroy @objFileSystem
END


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает HTML-код для таблицы выполненных заданий', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'GetHTMLTableShortInfoRunJobsServers';

