



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [zabbix].[GetOldBackupsCount]
	@hours_full int=25 -- старость в часах для полной резервной копии
	,@hours_log int=1 -- старость в часах для резервной копии журнала транзакций
AS
BEGIN
	/*
		Количество тех БД, для которых давно не делались резервные копии
	*/

	--SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET XACT_ABORT ON;

	declare @server_name nvarchar(255)=cast(SERVERPROPERTY(N'ComputerNamePhysicalNetBIOS') as nvarchar(255));

	if((left(@server_name,3) in (N'PRD')) or (@server_name like 'SQL_SERVICES%') or (@server_name in ('com-dba-01')))
	begin
		select sum([count]) as [count]
		from(
			select count(*) as [count]
			from sys.databases as db
			left outer join [inf].[vServerLastBackupDB] as bak on db.[name]=bak.[DBName] and bak.[BackupType]=N'database'
			where db.[name] not in (N'tempdb', N'NewVeeamBackupDB')
			and (bak.BackupStartDate<DateAdd(hour,-@hours_full,GetDate()) or bak.BackupStartDate is null)
			and db.[create_date]<DateAdd(hour,-@hours_full,GetDate())
			union all
			select count(*) as [count]
			from sys.databases as db
			left outer join [inf].[vServerLastBackupDB] as bak on db.[name]=bak.[DBName] and bak.[BackupType]=N'log'
			where db.[name] not in (N'tempdb', N'NewVeeamBackupDB', N'NewVeeamBackupReporting', N'SRV', N'VeeamOne', N'FortisAdmin', N'SpotlightPlaybackDatabase', N'SpotlightStatisticsRepository')
			and db.[database_id]>4
			and (bak.BackupStartDate<DateAdd(hour,-@hours_log,GetDate()) or bak.BackupStartDate is null)
			and db.[create_date]<DateAdd(hour,-@hours_full,GetDate())
		) as t;
	end
	else select 0 as [count];
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает количество тех БД, для которых давно не делались резервные копии', @level0type = N'SCHEMA', @level0name = N'zabbix', @level1type = N'PROCEDURE', @level1name = N'GetOldBackupsCount';

