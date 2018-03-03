-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[DeleteArchiveInProductDB]
AS
BEGIN
	/*
		что чистить в продуктовых БД
	*/

	SET NOCOUNT ON;
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Удаление данных в продуктовых БД (реализуется индивидуально)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'DeleteArchiveInProductDB';

