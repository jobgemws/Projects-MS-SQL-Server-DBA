
CREATE view [inf].[vObjectInParentDescription] as
select
SCHEMA_NAME(obj.[schema_id]) as SchemaName
,QUOTENAME(object_schema_name(obj.[parent_object_id]))+'.'+quotename(object_name(obj.[parent_object_id])) as ParentObjectName
,QUOTENAME(object_schema_name(obj.[object_id]))+'.'+quotename(obj.[name]) as ObjectName
,obj.[type] as [Type]
,obj.[type_desc] as [TypeDesc]
,ep.[value] as ObjectDescription
from sys.all_objects as obj
left outer join sys.extended_properties as ep on obj.[parent_object_id]=ep.[major_id]
											 and ep.[minor_id]=obj.[object_id]
											 and ep.[name]='MS_Description'
where obj.[is_ms_shipped]=0
and obj.[parent_object_id]<>0

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Описание для объектов, у которых есть родители', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vObjectInParentDescription';

