CREATE view [inf].[vProcedures] as
-- Дополнительная информация о ХП 

SELECT  @@Servername AS ServerName ,
        DB_NAME() AS DB_Name ,
		s.name as SchemaName,
        o.name AS 'ViewName' ,
        o.[type] ,
        o.Create_date ,
        sm.[definition] AS 'Stored Procedure script'
FROM    sys.objects o
		inner join sys.schemas s on o.schema_id=s.schema_id
        INNER JOIN sys.sql_modules sm ON o.object_id = sm.object_id
WHERE   o.[type] in ('P', 'PC') -- Stored Procedures 
        -- AND sm.[definition] LIKE '%insert%'
        -- AND sm.[definition] LIKE '%update%'
        -- AND sm.[definition] LIKE '%delete%'
        -- AND sm.[definition] LIKE '%tablename%'
--ORDER BY o.name;



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Хранимые процедуры с их определениями', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vProcedures';

