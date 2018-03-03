
CREATE PROCEDURE [srv].[SendDBMail]
	@recipients nvarchar(max),
	@srr_title nvarchar(255),
	@srr_mess nvarchar(255),
	@isHTML bit=0
AS
BEGIN
	/*
		отправка сообщения на почту
	*/
	SET NOCOUNT ON;
	declare @dt datetime=getdate();

	declare @recipient nvarchar(255);
	declare @result nvarchar(max)='';
	declare @recp nvarchar(max);
	declare @ind int;
	declare @recipients_key nvarchar(max);

	 declare @rec_body table(Body nvarchar(max));
	 declare @body nvarchar(max);

	 declare @query nvarchar(max);

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

		set @result=@result+@recp+';';
	end

	set @result=substring(@result,1,len(@result)-1);
	set @recipients=@result;

	declare @body_format nvarchar(32)=case when @isHTML=1 then 'HTML' else 'TEXT' end;

	 EXEC msdb.dbo.sp_send_dbmail
	-- Созданный нами профиль администратора почтовых рассылок
		@profile_name = 'profile_name',
	-- Адрес получателя
		@recipients = @recipients,--'Gribkov@ggg.ru',
	-- Текст письма
		@body = @srr_mess,
	-- Тема
		@subject = @srr_title,
		@body_format=@body_format--,
	-- Для примера добавим к письму результаты произвольного SQL-запроса
		--@query = @query--'SELECT TOP 10 name FROM sys.objects';
END


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Отправка сообщения на почту', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'SendDBMail';

