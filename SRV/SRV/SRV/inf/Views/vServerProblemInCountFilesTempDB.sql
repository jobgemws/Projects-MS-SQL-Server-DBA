create view [inf].[vServerProblemInCountFilesTempDB]
as
/*
	Можно узнать есть ли у проблемы с количеством файлов tempdb.
	Этим запросом пытаемся найти latch на системные страницы PFS, GAM, SGAM в базе данных tempdb.
	Если запрос ничего не возвращает или возвращает строки только с «Is Not PFS, GAM, or SGAM page», то скорее всего текущая нагрузка не требует увеличения файлов tempdb
*/
Select session_id,
wait_type,
wait_duration_ms,
blocking_session_id,
resource_description,
		ResourceType = Case
When Cast(Right(resource_description, Len(resource_description) - Charindex(':', resource_description, 3)) As Int) - 1 % 8088 = 0 Then 'Is PFS Page'
			When Cast(Right(resource_description, Len(resource_description) - Charindex(':', resource_description, 3)) As Int) - 2 % 511232 = 0 Then 'Is GAM Page'
			When Cast(Right(resource_description, Len(resource_description) - Charindex(':', resource_description, 3)) As Int) - 3 % 511232 = 0 Then 'Is SGAM Page'
			Else 'Is Not PFS, GAM, or SGAM page'
			End
From sys.dm_os_waiting_tasks
Where wait_type Like 'PAGE%LATCH_%'
And resource_description Like '2:%' 

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация о проблемах с количеством файлов БД tempdb экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vServerProblemInCountFilesTempDB';

