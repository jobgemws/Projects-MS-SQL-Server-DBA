

CREATE PROCEDURE [nav].[ZabbixGetCountRequestStatus]
	@Status nvarchar(255)=NULL,
	@IsBlockingSession bit=0
AS
BEGIN
	/*
		возвращает кол-во запросов с заданным статусом
	*/
	SET NOCOUNT ON;

	if(@IsBlockingSession=0)
	begin
		select count(*) as [Count]
		from sys.dm_exec_requests ER with(readuncommitted)
		where [status]=@Status
		and [command]  in (
							'UPDATE',
							'TRUNCATE TABLE',
							'SET OPTION ON',
							'SET COMMAND',
							'SELECT INTO',
							'SELECT',
							'NOP',
							'INSERT',
							'EXECUTE',
							'DELETE',
							'DECLARE',
							'CONDITIONAL',
							'BULK INSERT',
							'BEGIN TRY',
							'BEGIN CATCH',
							'AWAITING COMMAND',
							'ASSIGN',
							'ALTER TABLE'
						  )
		--свой фильтр
		--and [start_time]<=DateAdd(second,-1,GetDate());
	end
	else
	begin
		select count(*) as [Count]
		from sys.dm_exec_requests ER with(readuncommitted)
		where [blocking_session_id]>0
		and [command]  in (
							'UPDATE',
							'TRUNCATE TABLE',
							'SET OPTION ON',
							'SET COMMAND',
							'SELECT INTO',
							'SELECT',
							'NOP',
							'INSERT',
							'EXECUTE',
							'DELETE',
							'DECLARE',
							'CONDITIONAL',
							'BULK INSERT',
							'BEGIN TRY',
							'BEGIN CATCH',
							'AWAITING COMMAND',
							'ASSIGN',
							'ALTER TABLE'
						  )
		--свой фильтр
		--and [start_time]<=DateAdd(second,-1,GetDate());
	end
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает кол-во запросов с заданным статусом', @level0type = N'SCHEMA', @level0name = N'nav', @level1type = N'PROCEDURE', @level1name = N'ZabbixGetCountRequestStatus';

