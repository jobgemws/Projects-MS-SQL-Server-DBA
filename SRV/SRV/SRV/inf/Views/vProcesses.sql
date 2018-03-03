

CREATE view [inf].[vProcesses] as
select
db_name(dbid) as DB_Name,
login_time,
last_batch,
(select top(1) [text] from sys.dm_exec_sql_text(sql_handle)) as SQLText,
status,
blocked,
physical_io,
open_tran,
hostname,
program_name,
hostprocess,
cmd,
nt_domain,
nt_username,
net_address,
net_library,
loginame,
spid,
kpid,
waittype,
waittime,
lastwaittype,
waitresource,
dbid,
uid,
cpu,
memusage,
ecid,
sid,
context_info,
stmt_start,
stmt_end,
request_id
from sysprocesses




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Процессы экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vProcesses';

