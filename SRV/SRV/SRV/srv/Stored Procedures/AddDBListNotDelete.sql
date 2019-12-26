

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [srv].[AddDBListNotDelete]
	@DB_Name NVARCHAR(255),
	@IsAdd BIT=1 --Признак добавления (1-добавление, 0-удаление)
AS
BEGIN
	/*
		Добавляет БД в белый список или удаляет ее из этого списка
	*/

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	if(exists(select top(1) 1 from [srv].[DBListNotDelete]))
	BEGIN
		IF(@IsAdd=1)
		BEGIN
			INSERT INTO [srv].[DBListNotDelete]
			           ([Name]
			           ,[IsWhiteListAll])
			     select @DB_Name, 1;
		END
		ELSE IF(@IsAdd=0)
		BEGIN
			DELETE FROM [srv].[DBListNotDelete]
			WHERE [Name]=@DB_Name;
		END
	END
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Добавляет БД в белый список или удаляет ее из этого списка', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AddDBListNotDelete';

