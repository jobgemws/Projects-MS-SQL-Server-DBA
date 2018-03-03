
CREATE VIEW [inf].[vSchemaDescription] as
select
SCHEMA_NAME(t.schema_id) as SchemaName
--,QUOTENAME(object_schema_name(t.[object_id]))+'.'+quotename(t.[name]) as TableName
,ep.[value] as SchemaDescription
from sys.schemas as t
left outer join sys.extended_properties as ep on t.[schema_id]=ep.[major_id]
											 and ep.[minor_id]=0
											 and ep.[name]='MS_Description'

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Описание схем БД', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vSchemaDescription';

