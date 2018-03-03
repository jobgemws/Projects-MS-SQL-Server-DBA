
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[XPDeleteFile]
	@FileType int=0 --0-backup/1-report
	,@FolderPath nvarchar(255)--полный путь откуда удалять
	,@FileExtension nvarchar(255)=N'*'--расширение файла
	,@OldDays int --старость в днях от текущей даты
	,@SubFolder int=0 --0-игнорирования вложенных папок/1-вложенные папки
AS
BEGIN
	/*
		удаление файлов
	*/
	SET NOCOUNT ON;

	declare @dt datetime=DateAdd(day, -@OldDays, GetDate());
	set @dt=DATETIMEFROMPARTS(year(@dt), month(@dt), day(@dt), 0, 0, 0, 0);

    EXECUTE master.dbo.xp_delete_file @FileType,
									  @FolderPath,
									  @FileExtension,
									  @dt,
									  @SubFolder;
END


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Удаление файлов', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'XPDeleteFile';

