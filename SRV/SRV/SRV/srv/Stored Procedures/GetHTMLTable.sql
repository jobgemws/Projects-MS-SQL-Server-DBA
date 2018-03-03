-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[GetHTMLTable]
	@recipients nvarchar(max)
	,@dt		datetime -- по какое число читать
AS
BEGIN
	/*
			формирует HTML-код для таблицы
	*/
	SET NOCOUNT ON;

    declare @body nvarchar(max);
	declare @tbl table(ID int identity(1,1)
					  ,[ERROR_TITLE]		nvarchar(max)
					  ,[ERROR_PRED_MESSAGE] nvarchar(max)
					  ,[ERROR_NUMBER]		nvarchar(max)
					  ,[ERROR_MESSAGE]		nvarchar(max)
					  ,[ERROR_LINE]			nvarchar(max)
					  ,[ERROR_PROCEDURE]	nvarchar(max)
					  ,[ERROR_POST_MESSAGE]	nvarchar(max)
					  ,[InsertDate]			datetime
					  ,[StartDate]			datetime
					  ,[FinishDate]			datetime
					  ,[Count]				int
					  );
	declare
	@ID						int
	,@ERROR_TITLE			nvarchar(max)
	,@ERROR_PRED_MESSAGE	nvarchar(max)
	,@ERROR_NUMBER			nvarchar(max)
	,@ERROR_MESSAGE			nvarchar(max)
	,@ERROR_LINE			nvarchar(max)
	,@ERROR_PROCEDURE		nvarchar(max)
	,@ERROR_POST_MESSAGE	nvarchar(max)
	,@InsertDate			datetime
	,@StartDate				datetime
	,@FinishDate			datetime
	,@Count					int

	insert into @tbl(
				[ERROR_TITLE]		
				,[ERROR_PRED_MESSAGE] 
				,[ERROR_NUMBER]		
				,[ERROR_MESSAGE]		
				,[ERROR_LINE]			
				,[ERROR_PROCEDURE]	
				,[ERROR_POST_MESSAGE]	
				,[InsertDate]
				,[StartDate]
				,[FinishDate]
				,[Count]
	)
	select top 100
				[ERROR_TITLE]		
				,[ERROR_PRED_MESSAGE] 
				,[ERROR_NUMBER]		
				,[ERROR_MESSAGE]		
				,[ERROR_LINE]			
				,[ERROR_PROCEDURE]	
				,[ERROR_POST_MESSAGE]	
				,[InsertDate]
				,[StartDate]
				,[FinishDate]
				,[Count]
	from [srv].[ErrorInfo]
	where ([RECIPIENTS]=@recipients) or (@recipients IS NULL)
	and InsertDate<=@dt
	order by InsertDate asc;

	set @body='<TABLE BORDER=5>';

	set @body=@body+'<TR>';

	set @body=@body+'<TD>';
	set @body=@body+'№ п/п';
	set @body=@body+'</TD>';
	
	set @body=@body+'<TD>';
	set @body=@body+'ДАТА';
	set @body=@body+'</TD>';

	set @body=@body+'<TD>';
	set @body=@body+'ОШИБКА';
	set @body=@body+'</TD>';
	
	set @body=@body+'<TD>';
	set @body=@body+'ОПИСАНИЕ';
	set @body=@body+'</TD>';

	set @body=@body+'<TD>';
	set @body=@body+'КОД ОШИБКИ';
	set @body=@body+'</TD>';

	set @body=@body+'<TD>';
	set @body=@body+'СООБЩЕНИЕ';
	set @body=@body+'</TD>';

	set @body=@body+'<TD>';
	set @body=@body+'НАЧАЛО';
	set @body=@body+'</TD>';

	set @body=@body+'<TD>';
	set @body=@body+'ОКОНЧАНИЕ';
	set @body=@body+'</TD>';

	set @body=@body+'<TD>';
	set @body=@body+'КОЛИЧЕСТВО';
	set @body=@body+'</TD>';

	set @body=@body+'<TD>';
	set @body=@body+'НОМЕР СТРОКИ';
	set @body=@body+'</TD>';

	set @body=@body+'<TD>';
	set @body=@body+'ПРОЦЕДУРА';
	set @body=@body+'</TD>';

	set @body=@body+'<TD>';
	set @body=@body+'ПРИМЕЧАНИЕ';
	set @body=@body+'</TD>';

	set @body=@body+'</TR>';

	while((select top 1 1 from @tbl)>0)
	begin
		set @body=@body+'<TR>';

		select top 1
		@ID					=[ID]
		,@ERROR_TITLE		=[ERROR_TITLE]		
		,@ERROR_PRED_MESSAGE=[ERROR_PRED_MESSAGE]
		,@ERROR_NUMBER		=[ERROR_NUMBER]		
		,@ERROR_MESSAGE		=[ERROR_MESSAGE]	
		,@ERROR_LINE		=[ERROR_LINE]		
		,@ERROR_PROCEDURE	=[ERROR_PROCEDURE]	
		,@ERROR_POST_MESSAGE=[ERROR_POST_MESSAGE]
		,@InsertDate		=[InsertDate]
		,@StartDate			=[StartDate]
		,@FinishDate		=[FinishDate]
		,@Count				=[Count]
		from @tbl;

		set @body=@body+'<TD>';
		set @body=@body+cast(@ID as nvarchar(max));
		set @body=@body+'</TD>';
		
		set @body=@body+'<TD>';
		set @body=@body+rep.GetDateFormat(@InsertDate, default)+' '+rep.GetTimeFormat(@InsertDate, default);--cast(@InsertDate as nvarchar(max));
		set @body=@body+'</TD>';

		set @body=@body+'<TD>';
		set @body=@body+coalesce(@ERROR_TITLE,'');
		set @body=@body+'</TD>';
		
		set @body=@body+'<TD>';
		set @body=@body+coalesce(@ERROR_PRED_MESSAGE,'');
		set @body=@body+'</TD>';

		set @body=@body+'<TD>';
		set @body=@body+coalesce(@ERROR_NUMBER,'');
		set @body=@body+'</TD>';

		set @body=@body+'<TD>';
		set @body=@body+coalesce(@ERROR_MESSAGE,'');
		set @body=@body+'</TD>';

		set @body=@body+'<TD>';
		set @body=@body+rep.GetDateFormat(@StartDate, default)+' '+rep.GetTimeFormat(@StartDate, default);--cast(@StartDate as nvarchar(max));
		set @body=@body+'</TD>';

		set @body=@body+'<TD>';
		set @body=@body+rep.GetDateFormat(@FinishDate, default)+' '+rep.GetTimeFormat(@FinishDate, default);--cast(@FinishDate as nvarchar(max));
		set @body=@body+'</TD>';

		set @body=@body+'<TD>';
		set @body=@body+cast(@Count as nvarchar(max));
		set @body=@body+'</TD>';

		set @body=@body+'<TD>';
		set @body=@body+coalesce(@ERROR_LINE,'');
		set @body=@body+'</TD>';

		set @body=@body+'<TD>';
		set @body=@body+coalesce(@ERROR_PROCEDURE,'');
		set @body=@body+'</TD>';

		set @body=@body+'<TD>';
		set @body=@body+coalesce(@ERROR_POST_MESSAGE,'');
		set @body=@body+'</TD>';

		delete from @tbl
		where ID=@ID;

		set @body=@body+'</TR>';
	end

	set @body=@body+'</TABLE>';

	select @body;
END


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Формирует и возвращает HTML-код для таблицы', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'GetHTMLTable';

