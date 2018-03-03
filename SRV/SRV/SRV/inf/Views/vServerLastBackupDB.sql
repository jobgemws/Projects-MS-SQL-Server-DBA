

CREATE VIEW [inf].[vServerLastBackupDB] as
with backup_cte as
(
    select
        bs.[database_name],
        backup_type =
            case bs.[type]
                when 'D' then 'database'
                when 'L' then 'log'
                when 'I' then 'differential'
                else 'other'
            end,
        bs.[first_lsn],
		bs.[last_lsn],
		bs.[backup_start_date],
		bs.[backup_finish_date],
		cast(bs.[backup_size] as decimal(18,3))/1024/1024 as BackupSizeMb,
        rownum = 
            row_number() over
            (
                partition by bs.[database_name], type 
                order by bs.[backup_finish_date] desc
            ),
		LogicalDeviceName = bmf.[logical_device_name],
		PhysicalDeviceName = bmf.[physical_device_name],
		bs.[server_name],
		bs.[user_name]
    FROM msdb.dbo.backupset bs
    INNER JOIN msdb.dbo.backupmediafamily bmf 
        ON [bs].[media_set_id] = [bmf].[media_set_id]
)
select
    [server_name] as [ServerName],
	[database_name] as [DBName],
	[user_name] as [USerName],
    [backup_type] as [BackupType],
	[backup_start_date] as [BackupStartDate],
    [backup_finish_date] as [BackupFinishDate],
	[BackupSizeMb], --размер без сжатия
	[LogicalDeviceName],
	[PhysicalDeviceName],
	[first_lsn] as [FirstLSN],
	[last_lsn] as [LastLSN]
from backup_cte
where rownum = 1;


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сведения о последних резервных копиях БД экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vServerLastBackupDB';

