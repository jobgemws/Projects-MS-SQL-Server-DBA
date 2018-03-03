


CREATE view [inf].[vPerformanceObject]
as
SELECT
object_name		as [Object],
counter_name	as [Counter],
instance_name	as [Instance],
cntr_value		as [Value_KB],
cntr_type		as [Type]
from master.dbo.sysperfinfo
--order by object_name, counter_name;




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Счетчики производительности экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vPerformanceObject';

