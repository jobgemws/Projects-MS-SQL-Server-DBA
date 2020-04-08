USE [master]
 
DECLARE @Login varchar(255)='login'
DECLARE @Default_DB varchar(255)='master' --БД по умолчанию
DECLARE @SQL nvarchar(max)=N'' --sql контейнер
DECLARE @processadmin tinyint=1 --даем права processadmin на сервере
DECLARE @IS_VIEW_ANY_DEFINITION tinyint=1 --просмотр любого определения объектов в рамках сервера
DECLARE @IS_ALTER_ANY_DEFINITION tinyint=0 --изменения любого определения объектов в рамках сервера ALTER DDL в рамках сервера
DECLARE @All_User_DBs tinyint=1 --для всех пользовательских БД
 
DECLARE @ListDatabases TABLE([DB] varchar(255))
DECLARE @ListDBRoles TABLE([Role] varchar(255))
 
--Список ролей
insert into @ListDBRoles
select distinct [name]
from
(select distinct [name]
from sys.database_principals where [type_desc]='DATABASE_ROLE'
and name in('db_datareader')) roles --список ролей которые необходимо
 
--Заполнения списка необходимых БД
INSERT INTO @ListDatabases
select [name]
from sys.databases where database_id>4 and name not in('SRV','Admin')
and (name in('') or @All_User_DBs=1) --Здесь через запятую дать список БД
 
SET @SQL='CREATE LOGIN ['+@Login+'] FROM WINDOWS WITH DEFAULT_DATABASE=['+@Default_DB+']'
 
begin try
    print @SQL
    exec sp_executesql @SQL
end try
begin catch
    if @@error<>0
    select 'Логин ['+@Login+'] уже существует на сервере!' msg
end catch
 
--Очистка SQL контэйнера
set @SQL=''
 
if @processadmin=1
set @SQL='ALTER SERVER ROLE [processadmin] ADD MEMBER ['+@Login+']'
 
begin try
    print @SQL
    exec sp_executesql @SQL
end try
begin catch
    select ERROR_MESSAGE() err_msg, @SQL
end catch
 
set @SQL=''
 
--Создание юзера для default database
set @SQL='USE ['+@Default_DB+']
CREATE USER ['+@Login+'] FOR LOGIN ['+@Login+']'
 
begin try
    print @SQL
    exec sp_executesql @SQL
end try
begin catch
    select ERROR_MESSAGE() err_msg, @SQL script
end catch
 
set @SQL=''
 
IF @IS_VIEW_ANY_DEFINITION=1
set @SQL='GRANT VIEW ANY DEFINITION TO ['+@Login+']'
 
begin try
    print @SQL
    exec sp_executesql @SQL
end try
begin catch
    select ERROR_MESSAGE() err_msg, @SQL script
end catch
 
set @SQL=''
 
--DDL admin в рамках сервера
IF @IS_ALTER_ANY_DEFINITION=1
set @SQL='GRANT ALTER ANY DEFINITION TO ['+@Login+']'
 
begin try
    print @SQL
    exec sp_executesql @SQL
end try
begin catch
    select ERROR_MESSAGE() err_msg, @SQL script
end catch
 
set @SQL=''
set @SQL=''
 
IF (select count(1) from @ListDatabases)>0
begin
begin
    select @SQL=@SQL+'
    USE ['+DB+']
    begin try CREATE USER ['+@Login+'] FOR LOGIN ['+@Login+'] end try
    begin catch end catch'
    from @ListDatabases
end
 
begin try
    print @SQL
    exec sp_executesql @SQL
end try
begin catch
    select ERROR_MESSAGE() err_msg, @SQL script
end catch
 
set @SQL=''
 
select @SQL=@SQL+'
USE ['+DB+']
begin try ALTER ROLE  ['+R.Role+'] ADD MEMBER ['+@Login+'] end try
begin catch end catch'
from @ListDatabases DBS INNER JOIN @ListDBRoles R ON(1=1)
 
begin try
    print @SQL
    exec sp_executesql @SQL
end try
begin catch
    select ERROR_MESSAGE() err_msg, @SQL script
end catch
end