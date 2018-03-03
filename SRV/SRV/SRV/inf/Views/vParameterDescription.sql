CREATE view [inf].[vParameterDescription] as
select
SCHEMA_NAME(obj.[schema_id]) as SchemaName
,QUOTENAME(object_schema_name(obj.[object_id]))+'.'+quotename(object_name(obj.[object_id])) as ParentObjectName
,p.[name] as ParameterName
,obj.[type] as [Type]
,obj.[type_desc] as [TypeDesc]
,ep.[value] as ParameterDescription
from sys.parameters as p
inner join sys.objects as obj on p.[object_id]=obj.[object_id]
left outer join sys.extended_properties as ep on obj.[object_id]=ep.[major_id]
											 and ep.[minor_id]=p.[parameter_id]
											 and ep.[name]='MS_Description'
where obj.[is_ms_shipped]=0

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Описание для параметров', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vParameterDescription';

