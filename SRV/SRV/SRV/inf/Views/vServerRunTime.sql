
CREATE   view [inf].[vServerRunTime] as
--время работы сервера
SELECT  cast(SERVERPROPERTY(N'MachineName') as nvarchar(255)) AS ServerName ,
        create_date AS  ServerStarted ,
        DATEDIFF(s, create_date, GETDATE()) / 86400.0 AS DaysRunning ,
        DATEDIFF(s, create_date, GETDATE()) AS SecondsRunnig
FROM    sys.databases
WHERE   name = 'tempdb'; 



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация о времени работы экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vServerRunTime';

