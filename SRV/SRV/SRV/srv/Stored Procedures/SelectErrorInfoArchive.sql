
CREATE PROCEDURE [srv].[SelectErrorInfoArchive]
@StartDate datetime=NULL,
@FinishDate datetime=NULL,
@IsRealTime bit=NULL
/*
	Процедура выборки архива по отправленным почтовым сообщениям
*/
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	set @StartDate =DATETIMEFROMPARTS(YEAR(@StartDate), MONTH(@StartDate), DAY(@StartDate), 0, 0, 0, 0);
	set @FinishDate=DATETIMEFROMPARTS(YEAR(@FinishDate), MONTH(@FinishDate), DAY(@FinishDate), 23, 59, 59, 999);

	SELECT [ErrorInfo_GUID]
      ,[ERROR_TITLE]
      ,[ERROR_PRED_MESSAGE]
      ,[ERROR_NUMBER]
      ,[ERROR_MESSAGE]
      ,[ERROR_LINE]
      ,[ERROR_PROCEDURE]
      ,[ERROR_POST_MESSAGE]
      ,[RECIPIENTS]
      ,[InsertDate]
      ,[StartDate]
      ,[FinishDate]
      ,[Count]
      ,[UpdateDate]
      ,[IsRealTime]
      ,[InsertUTCDate]
  FROM [srv].[ErrorInfoArchive]
  where (InsertDate>=@StartDate or @StartDate is null)
  and (InsertDate<=@FinishDate or @FinishDate is null)
  and (IsRealTime=@IsRealTime or @IsRealTime is null);
END



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Процедура выборки архива по отправленным почтовым сообщениям', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'SelectErrorInfoArchive';

