

--Принудительная чистка кэшей

CREATE   procedure [srv].[CleanCashes]
as
begin
	set nocount on;
	set xact_abort on;

	DBCC FREESESSIONCACHE  WITH NO_INFOMSGS; --кэши сессий распредленных запросов

	DBCC FREESYSTEMCACHE ('ALL')  WITH MARK_IN_USE_FOR_REMOVAL, NO_INFOMSGS;

	DBCC DROPCLEANBUFFERS;

	DECLARE @database_id int;

	DECLARE SysCur CURSOR LOCAL FOR SELECT database_id FROM sys.databases;

	OPEN SysCur;

	FETCH NEXT FROM SysCur INTO @database_id;

	WHILE (@@FETCH_STATUS=0)
	BEGIN
		DBCC FLUSHPROCINDB(@database_id) WITH NO_INFOMSGS; --чистка процедурных кэшей

		FETCH NEXT FROM SysCur INTO @database_id;
	END

	CLOSE SysCur;
	DEALLOCATE SysCur;
end


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Принудительная чистка кэшей', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'CleanCashes';

