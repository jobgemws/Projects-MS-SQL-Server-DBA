--Очистка сервера от всех пользовательских БД
declare @SQL nvarchar(max)='' --SQL контэйнер
DECLARE @name nvarchar(255)=''
 
DECLARE SysCur CURSOR LOCAL FOR SELECT name FROM sys.databases where database_id>4 and [name]<>'SRV'
OPEN SysCur
FETCH NEXT FROM SysCur INTO @name
WHILE @@FETCH_STATUS=0 BEGIN
    SET @SQL=''
 
    --Уничтожаем все процессы, которые могут помешать переводу БД в SINGLE_USER
    SELECT @sql=@sql+'begin try kill '+cast(s.spid as varchar(5))+' end try
    begin catch end catch'  FROM sys.sysprocesses s
    left JOIN sys.dm_exec_requests r ON s.spid = r.session_id
    outer APPLY sys.dm_exec_sql_text (s.sql_handle) t
    WHERE ((r.[status]<>'background' and r.command<>'TASK MANAGER' and s.dbid=db_id(@name))
    or (charindex('ALTER DATABASE ['+@name+'] SET SINGLE_USER',t.text,0)>0) --ищем блокирующий процесс
    or (charindex('ALTER DATABASE '+@name+' SET SINGLE_USER',t.text,0)>0))
    and s.hostname<>'' and s.spid<>@@spid
 
    begin try
        exec sp_executesql @SQL
    end try
    begin catch
        select @name DB,ERROR_MESSAGE() ERR_MSG
    end catch
 
    set @SQL='ALTER DATABASE ['+@name+'] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE ['+@name+']'
     
    begin try
        exec sp_executesql @SQL
    end try
    begin catch
        select @name DB,ERROR_MESSAGE() ERR_MSG
    end catch
FETCH NEXT FROM SysCur INTO @name
END
CLOSE SysCur
DEALLOCATE SysCur
 
SELECT [name] DB FROM sys.databases where database_id>4