/*В другом окне вызываем ALTER DATABASE [<Имя БД>] set multi_user with no_wait
 
здесь запускаем завершение блокирующего процесса
Повторить возможно пару раз пок не получится завершить блокирующий процесс и вернуть БД в multi_user
*/
 
declare @SQL nvarchar(max)=''
 
--Обработка begin try .. end catch для принудительного завершения всех блокирующих процессов с обработкой ошибок
select @SQL=@SQL+'begin try
kill '+cast(spid as varchar(5)) +'
end try
begin catch end catch
'
from
(SELECT
    DISTINCT t.blocking_session_id spid
  FROM sys.dm_os_waiting_tasks AS t
    INNER JOIN sys.dm_tran_locks AS l
      ON t.resource_address = l.lock_owner_address
    INNER JOIN sys.sysprocesses p1   ON p1.spid = t.session_id
    INNER JOIN sys.sysprocesses p2   ON p2.spid = t.blocking_session_id
  WHERE t.session_id<>@@spid /*кроме собственного процесса*/) a 
 
exec sp_executesql @SQL