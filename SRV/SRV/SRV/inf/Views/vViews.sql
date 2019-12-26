
CREATE   view [inf].[vViews] as
--представления
select cast(SERVERPROPERTY(N'MachineName') as nvarchar(255)) AS [Server],
       DB_NAME() AS DBName,
	   s.name as SchemaName,
	   t.name as TableName,
	   t.type as Type,
	   t.type_desc as TypeDesc,
	   t.create_date as CreateDate,
	   t.modify_date as ModifyDate
from sys.views as t
inner join sys.schemas as s on t.schema_id=s.schema_id

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Представления', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vViews';

