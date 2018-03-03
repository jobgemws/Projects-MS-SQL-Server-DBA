

CREATE view [inf].[vTriggers] as
select t.name as TriggerName,
	   t.parent_class_desc,
	   t.type as TrigerType,
	   t.create_date as TriggerCreateDate,
	   t.modify_date as TriggerModifyDate,
	   t.is_disabled as TriggerIsDisabled,
	   t.is_instead_of_trigger as TriggerInsteadOfTrigger,
	   t.is_ms_shipped as TriggerIsMSShipped,
	   t.is_not_for_replication,
	   s.name as SchenaName,
	   ob.name as ObjectName,
	   ob.type_desc as ObjectTypeDesc,
	   ob.type as ObjectType,
	   sm.[DEFINITION] AS 'Trigger script'
from sys.triggers as t --sys.server_triggers
left outer join sys.objects as ob on t.parent_id=ob.object_id
left outer join sys.schemas as s on ob.schema_id=s.schema_id
left outer join sys.sql_modules sm ON t.object_id = sm.OBJECT_ID;



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Триггеры', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vTriggers';

