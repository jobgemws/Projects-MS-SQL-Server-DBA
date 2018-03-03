
create view [inf].[vJOBS] as
select
	job_id,
	originating_server,
	name,
	enabled,
	description,
	start_step_id,
	category_id,
	owner_sid,
	notify_level_eventlog,
	notify_level_email,
	notify_level_netsend,
	notify_level_page,
	notify_email_operator_id,
	notify_netsend_operator_id,
	notify_page_operator_id,
	delete_level,
	date_created,
	date_modified,
	version_number,
	originating_server_id,
	master_server
from msdb.dbo.sysjobs_view


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Задания Агента экземпляра MS SQL Server по представлению msdb.dbo.sysjobs_view', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vJOBS';

