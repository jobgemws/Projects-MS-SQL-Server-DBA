create view [inf].[SqlLogins]
as
/*
	логи скульные на вход
*/
select [name] as [Name], 
create_date as CreateDate, 
modify_date as ModifyDate, 
default_database_name as DefaultDatabaseName, 
is_policy_checked as IsPolicyChecked, --политика паролей
is_expiration_checked as IsExpirationChecked, --истечение срока действия паролей
is_disabled as IsDisabled
from sys.sql_logins

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Логи скульные на вход экземпляра MS SQL Server (sys.sql_logins)', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'SqlLogins';

