CREATE view [inf].[vFuncs] as
-- Дополнительная информация о функциях

SELECT  @@Servername AS ServerName ,
        DB_NAME() AS DB_Name ,
        o.name AS 'FunctionName' ,
        o.[type] ,
        o.create_date ,
        sm.[DEFINITION] AS 'Function script'
FROM    sys.objects o
        INNER JOIN sys.sql_modules sm ON o.object_id = sm.OBJECT_ID
WHERE   o.[Type] in ('FN', 'AF', 'FS', 'FT', 'IF', 'TF') -- Function 
--ORDER BY o.NAME;




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Функции с их определениями', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vFuncs';

