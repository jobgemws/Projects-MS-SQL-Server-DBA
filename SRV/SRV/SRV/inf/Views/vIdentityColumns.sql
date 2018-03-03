create view [inf].[vIdentityColumns] as
--Колонки identity
SELECT  @@Servername AS ServerName ,
        DB_NAME() AS DBName ,
        OBJECT_SCHEMA_NAME(object_id) AS SchemaName ,
        OBJECT_NAME(object_id) AS TableName ,
        Column_id ,
        Name AS  IdentityColumn ,
        Seed_Value ,
        Last_Value
FROM    sys.identity_columns
--ORDER BY SchemaName ,
--        TableName ,
--        Column_id; 



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Столбцы IDENTITY (т е с авто инкрементацией)', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vIdentityColumns';

