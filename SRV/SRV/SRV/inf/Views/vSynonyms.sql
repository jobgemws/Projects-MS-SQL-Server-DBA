create view [inf].[vSynonyms] as
-- дополнительная информация о синонимах

SELECT  @@Servername AS ServerName ,
        DB_NAME() AS DBName ,
		sch.name as SchemaName,
        s.name AS [Synonyms] ,
        s.create_date as CreateDate,
        s.base_object_name as BaseObjectName
FROM    sys.synonyms s
inner join sys.schemas as sch on sch.schema_id=s.schema_id
--ORDER BY s.name;



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Синонимы', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vSynonyms';

