








CREATE TRIGGER [SchemaLog] 
ON DATABASE --ALL SERVER 
FOR DDL_DATABASE_LEVEL_EVENTS 
AS
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	DECLARE @data XML
	begin try
	if(CURRENT_USER<>'NT AUTHORITY\NETWORK SERVICE' and SYSTEM_USER<>'NT AUTHORITY\NETWORK SERVICE')
	begin
		SET @data = EVENTDATA();
		INSERT srv.ddl_log(
					PostTime,
					DB_Login,
					DB_User,
					Event,
					TSQL
				  ) 
		select 
					GETUTCDATE(),
					CONVERT(nvarchar(255), SYSTEM_USER),
					CONVERT(nvarchar(255), CURRENT_USER), 
					@data.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(255)'), 
					@data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(max)')
		where		@data.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(255)') not in('UPDATE_STATISTICS', 'ALTER_INDEX')
				and	@data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(max)') not like '%Msmerge%';
	end
	end try
	begin catch
	end catch











GO
DISABLE TRIGGER [SchemaLog]
    ON DATABASE;


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Запись изменений БД (DDL)', @level0type = N'TRIGGER', @level0name = N'SchemaLog';

