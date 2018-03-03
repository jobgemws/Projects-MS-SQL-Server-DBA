create view [inf].[SysLogins]
as
/*
	все логи (скульные и виндовые) на вход
*/
select [name] as [Name],
createdate as CreateDate,
updatedate as UpdateDate,
dbname as DBName, --БД по умолчанию
denylogin as DenyLogin, --отказано в доступе
hasaccess as HasAccess, --разрешен вход на сервер
isntname as IsntName, --имя входа (винда-1, скуль-0)
isntgroup as IsntGroup, --группа винды
isntuser as IsntUser,--пользователь винды
sysadmin as SysAdmin,
securityadmin as SecurityAdmin,
serveradmin as ServerAdmin,
setupadmin as SetupAdmin,
processadmin as ProcessAdmin,
diskadmin as DiskAdmin,
dbcreator as DBCreator,
bulkadmin as BulkAdmin
from sys.syslogins

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Все логи (скульные и виндовые) на вход экземпляра MS SQL Server (sys.syslogins)', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'SysLogins';

