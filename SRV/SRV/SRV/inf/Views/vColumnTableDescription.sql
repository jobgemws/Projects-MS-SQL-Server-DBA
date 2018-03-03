
CREATE VIEW [inf].[vColumnTableDescription] as
select 
SCHEMA_NAME(t.schema_id) as SchemaName
,QUOTENAME(object_schema_name(t.[object_id]))+'.'+quotename(t.[name]) as TableName
,c.[name] as ColumnName
,ep.[value] as ColumnDescription
from sys.tables as t
inner join sys.columns as c on c.[object_id]=t.[object_id]
left outer join sys.extended_properties as ep on t.[object_id]=ep.[major_id]
											 and ep.[minor_id]=c.[column_id]
											 and ep.[name]='MS_Description'
where t.[is_ms_shipped]=0;

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Описание столбцов таблиц', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vColumnTableDescription';

