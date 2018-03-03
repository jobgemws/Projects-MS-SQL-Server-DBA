
CREATE PROCEDURE [srv].[RunErrorInfoProc]
	@IsRealTime bit =0	-- режим отправки
AS
BEGIN
	/*
		выполнить отправку уведомлений об ошибках с указанным режимом
	*/
	SET NOCOUNT ON;
	declare @dt datetime=getdate();

	declare @tbl table(Recipients nvarchar(max));
	declare @recipients nvarchar(max);
	declare @recipient nvarchar(255);
	declare @result nvarchar(max)='';
	declare @recp nvarchar(max);
	declare @ind int;
	declare @recipients_key nvarchar(max);

	 insert into @tbl(Recipients)
	 select [RECIPIENTS]
	 from srv.ErrorInfo
	 where InsertDate<=@dt and IsRealTime=@IsRealTime
	 group by [RECIPIENTS];

	 declare @rec_body table(Body nvarchar(max));
	 declare @body nvarchar(max);

	 declare @query nvarchar(max);

	 while((select top 1 1 from @tbl)>0)
	 begin
		select top 1
		@recipients=Recipients
		from @tbl;

		set @recipients_key=@recipients;
		set @result='';

		while(len(@recipients)>0)
		begin
			set @ind=CHARINDEX(';', @recipients);
			if(@ind>0)
			begin
				set @recipient=substring(@recipients,1, @ind-1);
				set @recipients=substring(@recipients,@ind+1,len(@recipients)-@ind);
			end
			else
			begin
				set @recipient=@recipients;
				set @recipients='';
			end;

			--select @recipients,@recipient

			--select @recipients, len(@recipients)

			exec [srv].[GetRecipients]
			@Recipient_Code=@recipient,
			@Recipients=@recp out;

			if(len(@recp)=0)
			begin
				exec [srv].[GetRecipients]
				@Recipient_Name=@recipient,
				@Recipients=@recp out;

				if(len(@recp)=0) set @recp=@recipient;
			end

			--select @recp,1

			set @result=@result+@recp+';';
		end

		set @result=substring(@result,1,len(@result)-1);
		set @recipients=@result;

		insert into @rec_body(Body)
		exec srv.GetHTMLTable @recipients=@recipients_key, @dt=@dt;

		select top 1
		@body=Body
		from @rec_body;

		--select @Recipients;

		 EXEC msdb.dbo.sp_send_dbmail
		-- Созданный нами профиль администратора почтовых рассылок
			@profile_name = 'profile_name',
		-- Адрес получателя
			@recipients = @recipients,--'Gribkov@mkis.su',
		-- Текст письма
			@body = @body,
		-- Тема
			@subject = N'ИНФОРМАЦИЯ ПО ОШИБКАМ ВЫПОЛНЕНИЯ',
			@body_format='HTML'--,
		-- Для примера добавим к письму результаты произвольного SQL-запроса
			--@query = @query--'SELECT TOP 10 name FROM sys.objects';

		delete from @tbl
		where Recipients=@recipients_key;

		delete from @rec_body;
	 end

	INSERT INTO [srv].[ErrorInfoArchive]
           ([ErrorInfo_GUID]
           ,[ERROR_TITLE]
           ,[ERROR_PRED_MESSAGE]
           ,[ERROR_NUMBER]
           ,[ERROR_MESSAGE]
           ,[ERROR_LINE]
           ,[ERROR_PROCEDURE]
           ,[ERROR_POST_MESSAGE]
           ,[RECIPIENTS]
		   ,[StartDate]
		   ,[FinishDate]
		   ,[Count]
	,IsRealTime
		   )
     SELECT
           [ErrorInfo_GUID]
           ,[ERROR_TITLE]
           ,[ERROR_PRED_MESSAGE]
           ,[ERROR_NUMBER]
           ,[ERROR_MESSAGE]
           ,[ERROR_LINE]
           ,[ERROR_PROCEDURE]
           ,[ERROR_POST_MESSAGE]
           ,[RECIPIENTS]
		   ,[StartDate]
		   ,[FinishDate]
		   ,[Count]
	,IsRealTime
	 FROM [srv].[ErrorInfo]
	 where IsRealTime=@IsRealTime
	 and InsertDate<=@dt
	 order by InsertDate;

	delete from [srv].[ErrorInfo]
	where IsRealTime=@IsRealTime
	and InsertDate<=@dt;
END


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Выполнить отправку уведомлений об ошибках с указанным режимом', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'RunErrorInfoProc';

