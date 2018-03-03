CREATE PROCEDURE [srv].[ExcelGetSysLogins]
as
begin
	/*
		возвращает все логины для входа на сервер MS SQL SERVER
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
	
	SELECT @@SERVERNAME as [ServerName]
	  ,[Name] as [Login]
      ,[CreateDate]
      ,[UpdateDate]
      ,[DBName]
      ,[DenyLogin]
      ,[HasAccess]
	  ,case when([IsntName]=1) then N'MS SQL SERVER' else N'WINDOWS' end as [NameInput]
      ,[IsntGroup] as [GroupWindows]
      ,[IsntUser] as [UserWindows]
      ,[SysAdmin]
      ,[SecurityAdmin]
      ,[ServerAdmin]
      ,[SetupAdmin]
      ,[ProcessAdmin]
      ,[DiskAdmin]
      ,[DBCreator]
      ,[BulkAdmin]
	FROM [inf].[SysLogins];
end

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает все логины для входа на сервер MS SQL SERVER', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'ExcelGetSysLogins';

