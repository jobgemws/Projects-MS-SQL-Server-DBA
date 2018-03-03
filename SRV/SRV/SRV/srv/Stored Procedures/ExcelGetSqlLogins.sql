CREATE PROCEDURE [srv].[ExcelGetSqlLogins]
as
begin
	/*
		возвращает все скульные логины для входа на сервер MS SQL SERVER
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
	
	SELECT @@SERVERNAME as [ServerName]
	  ,[Name] as [Login]
      ,[CreateDate]
      ,[ModifyDate]
      ,[DefaultDatabaseName]
      ,[IsPolicyChecked]
      ,[IsExpirationChecked]
      ,[IsDisabled]
	FROM [inf].[SqlLogins];
end

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает все скульные логины для входа на сервер MS SQL SERVER', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'ExcelGetSqlLogins';

