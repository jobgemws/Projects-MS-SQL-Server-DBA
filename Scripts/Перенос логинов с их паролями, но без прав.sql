--sp - выполняется в контексте любой БД сервера
--В Messages вывыодится скрипт создания для всех логинов (без мапинга прав, только право connect)
exec [SRV].[dbo].[sp_help_revlogin]
 
--В Messages вывыодится скрипт создания для указанного логина (без мапинга прав, только право connect)
exec [SRV].[dbo].[sp_help_revlogin] @login_name='Login'