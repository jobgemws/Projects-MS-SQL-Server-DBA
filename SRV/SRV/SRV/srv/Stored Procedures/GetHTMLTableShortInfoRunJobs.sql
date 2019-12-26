
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [srv].[GetHTMLTableShortInfoRunJobs]
	@body nvarchar(max) OUTPUT,
	@second int=60
AS
BEGIN
	/*
		формирует HTML-код для таблицы выполненных заданий
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @servername nvarchar(255)=cast(SERVERPROPERTY(N'MachineName') as nvarchar(255));

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
			from	srv.ShortInfoRunJobs
			order by LastRunDurationInt desc;

	if(exists(select top(1) 1 from @tbl))
	begin
		set @body='В ходе анализа последних выполнений заданий, были выявлены следующие задания, которые либо с ошибочным завершением, '
				 +'либо выполнились по времени более '+cast(@second as nvarchar(255))+' секунд:<br><br>'+'<TABLE BORDER=5>';

		set @body=@body+'<TR>';

		set @body=@body+'<TD>';
		set @body=@body+'№ п/п';
		set @body=@body+'</TD>';
	
		set @body=@body+'<TD>';
		set @body=@body+'ГУИД';
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

		set @body=@body+'<TD>';
		set @body=@body+'СЕРВЕР';
		set @body=@body+'</TD>';

		set @body=@body+'</TR>';

		while((select top 1 1 from @tbl)>0)
		begin
			set @body=@body+'<TR>';

			select top 1
			@ID						=	[ID]
			,@Job_GUID				=	Job_GUID
			,@Job_Name				=	Job_Name				
			,@LastFinishRunState	=	LastFinishRunState		
			,@LastDateTime			=	LastDateTime			
			,@LastRunDurationString	=	LastRunDurationString	
			,@LastOutcomeMessage	=	LastOutcomeMessage		
			,@Server				=	[Server]				
			from @tbl;

			set @body=@body+'<TD>';
			set @body=@body+cast(@ID as nvarchar(max));
			set @body=@body+'</TD>';
		
			set @body=@body+'<TD>';
			set @body=@body+cast(@Job_GUID as nvarchar(255));
			set @body=@body+'</TD>';
		
			set @body=@body+'<TD>';
			set @body=@body+coalesce(@Job_Name,'');
			set @body=@body+'</TD>';
		
			set @body=@body+'<TD>';
			set @body=@body+coalesce(@LastFinishRunState,'');
			set @body=@body+'</TD>';

			set @body=@body+'<TD>';
			set @body=@body+rep.GetDateFormat(@LastDateTime, default)+' '+rep.GetTimeFormat(@LastDateTime, default);--cast(@InsertDate as nvarchar(max));
			set @body=@body+'</TD>';

			set @body=@body+'<TD>';
			set @body=@body+coalesce(@LastRunDurationString,'');
			set @body=@body+'</TD>';

			set @body=@body+'<TD>';
			set @body=@body+coalesce(@LastOutcomeMessage, '');
			set @body=@body+'</TD>';

			set @body=@body+'<TD>';
			set @body=@body+coalesce(@Server, '');
			set @body=@body+'</TD>';

			delete from @tbl
			where ID=@ID;

			set @body=@body+'</TR>';
		end

		set @body=@body+'</TABLE>';
	end
	else
	begin
		set @body='В ходе анализа последних выполнений заданий, задания с ошибочным завершением, а также те, что выполнились по времени более '
				 +cast(@second as nvarchar(255))
				 +' секунд, не выявлены на сервере '+@servername;
	end
	
	set @body=@body+'<br><br>Для более детальной информации обратитесь к таблице SRV.srv.ShortInfoRunJobs';
END


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Формирует и возвращает HTML-код для таблицы выполненных заданий', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'GetHTMLTableShortInfoRunJobs';

