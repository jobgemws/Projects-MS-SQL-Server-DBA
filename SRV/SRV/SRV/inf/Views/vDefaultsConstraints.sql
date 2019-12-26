

CREATE   view [inf].[vDefaultsConstraints] as
-- Column Defaults 

SELECT  cast(SERVERPROPERTY(N'MachineName') as nvarchar(255)) AS ServerName ,
        DB_NAME() AS DB_Name ,
        OBJECT_SCHEMA_NAME(t.object_id) AS SchemaName ,
        t.Name AS TableName ,
        c.Column_ID AS Column_NBR ,
        c.Name AS Column_Name ,
        OBJECT_NAME(default_object_id) AS DefaultName ,
        OBJECT_DEFINITION(default_object_id) AS Defaults,
        dc.[type] ,
        dc.type_desc ,
        dc.create_date
FROM    sys.tables t
        INNER JOIN sys.columns c ON t.object_id = c.object_id
		inner join sys.default_constraints as dc on dc.object_id=c.default_object_id
WHERE    default_object_id <> 0
--ORDER BY TableName ,
--        SchemaName ,
--        c.Column_ID 



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ограничения значения по умолчанию для столбцов (с определением этих ограничений)', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vDefaultsConstraints';

