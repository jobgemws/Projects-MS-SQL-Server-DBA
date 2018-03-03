
CREATE PROCEDURE [srv].[ErrorInfoIncUpd]
	@ERROR_TITLE			nvarchar(max),
	@ERROR_PRED_MESSAGE		nvarchar(max),
	@ERROR_NUMBER			nvarchar(max),
	@ERROR_MESSAGE			nvarchar(max),
	@ERROR_LINE				nvarchar(max),
	@ERROR_PROCEDURE		nvarchar(max),
	@ERROR_POST_MESSAGE		nvarchar(max),
	@RECIPIENTS				nvarchar(max),
	@StartDate				datetime=null,
	@FinishDate				datetime=null,
	@IsRealTime				bit = 0
AS
BEGIN
	/*
		регистрация ошибки в таблицу ошибок на отправление по почте
		если уже в таблице есть запись с одинаковым заголовком, содержанием и отправителем
		, то изменится конечная дата ошибки, дата обновления записи, а также количество ошибок
	*/
	SET NOCOUNT ON;

	declare @ErrorInfo_GUID uniqueidentifier;

	select top 1
	@ErrorInfo_GUID=ErrorInfo_GUID
	from srv.ErrorInfo
	where (ERROR_TITLE=@ERROR_TITLE or @ERROR_TITLE is null)
	and RECIPIENTS=@RECIPIENTS
	and (ERROR_MESSAGE=@ERROR_MESSAGE or @ERROR_MESSAGE is null)
	and (ERROR_PRED_MESSAGE=@ERROR_PRED_MESSAGE or @ERROR_PRED_MESSAGE is null)
	and (ERROR_POST_MESSAGE=@ERROR_POST_MESSAGE or @ERROR_POST_MESSAGE is null)
	and (IsRealTime=@IsRealTime or @IsRealTime is null);

	if(@ErrorInfo_GUID is null)
	begin
		insert into srv.ErrorInfo
					(
						ERROR_TITLE		
						,ERROR_PRED_MESSAGE	
						,ERROR_NUMBER		
						,ERROR_MESSAGE		
						,ERROR_LINE			
						,ERROR_PROCEDURE	
						,ERROR_POST_MESSAGE	
						,RECIPIENTS
						,IsRealTime
						,StartDate
						,FinishDate			
					)
		select
					@ERROR_TITLE		
					,@ERROR_PRED_MESSAGE	
					,@ERROR_NUMBER		
					,@ERROR_MESSAGE		
					,@ERROR_LINE			
					,@ERROR_PROCEDURE	
					,@ERROR_POST_MESSAGE	
					,@RECIPIENTS
					,@IsRealTime
					,isnull(@StartDate, getdate())
					,isnull(@FinishDate,getdate())		
	end
	else
	begin
		update srv.ErrorInfo
		set FinishDate=getdate(),
		[Count]=[Count]+1,
		UpdateDate=getdate()
		where ErrorInfo_GUID=@ErrorInfo_GUID;
	end
END


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Регистрация ошибки в таблицу ошибок на отправление по почте', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'ErrorInfoIncUpd';

