






CREATE view [inf].[vActiveConnect] as
select
    db_name([database_id]) as DBName,
    [session_id] as SessionID,
    [login_name] as LoginName,
	[program_name] as ProgramName,
	[status] as [Status],
	[login_time] as [LoginTime]
from
    sys.dm_exec_sessions
where
    [database_id] > 0





GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Активные сессии экземпляра MS SQL Server (sys.dm_exec_sessions)', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vActiveConnect';

