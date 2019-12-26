


CREATE   view [inf].[ServerDBFileInfo] as
SELECT  cast(SERVERPROPERTY(N'MachineName') as nvarchar(255)) AS [Server] ,
        File_id ,--Идентификатор файла в базе данных. Основное значение file_id всегда равно 1
        Type_desc ,--Описание типа файла
        Name as [FileName] ,--Логическое имя файла в базе данных
        LEFT(Physical_Name, 1) AS Drive ,--Метка тома, где располагается файл БД
        Physical_Name ,--Полное имя файла в операционной системе
        RIGHT(physical_name, 3) AS Ext ,--Расширение файла
        Size as CountPage, --Текущий размер файла в страницах по 8 КБ
		round((cast(Size*8 as float))/1024,3) as SizeMb, --Размер файла в МБ
		round((cast(Size*8 as float))/1024/1024,3) as SizeGb, --Размер файла в ГБ
        case when is_percent_growth=0 then Growth*8 else 0 end as Growth, --Прирост файла в страницах по 8 КБ
		case when is_percent_growth=0 then round((cast(Growth*8 as float))/1024,3) end as GrowthMb, --Прирост файла в МБ
		case when is_percent_growth=0 then round((cast(Growth*8 as float))/1024/1024,3) end as GrowthGb, --Прирост файла в ГБ
		case when is_percent_growth=1 then Growth else 0 end as GrowthPercent, --Прирост файла в целых процентах
		is_percent_growth, --Признак процентного приращения
		database_id,
		DB_Name(database_id) as [DB_Name],
		State,--состояние файла
		state_desc as StateDesc,--описание состояния файла
		is_media_read_only as IsMediaReadOnly,--файл находится на носителе только для чтения (0-и для записи)
		is_read_only as IsReadOnly,--файл помечен как файл только для чтения (0-и записи)
		is_sparse as IsSpace,--разреженный файл
		is_name_reserved as IsNameReserved,--1 - Имя удаленного файла, доступно для использования.
		--Необходимо получить резервную копию журнала, прежде чем удастся повторно использовать имя (аргументы name или physical_name) для нового имени файла
		--0 - Имя файла, недоступно для использовани
		create_lsn as CreateLsn,--Регистрационный номер транзакции в журнале (LSN), на котором создан файл
		drop_lsn as DropLsn,--Номер LSN, с которым файл удален
		read_only_lsn as ReadOnlyLsn,--Номер LSN, на котором файловая группа, содержащая файл, изменила тип с «для чтения и записи» на «только для чтения» (самое последнее изменение)
		read_write_lsn as ReadWriteLsn,--Номер LSN, на котором файловая группа, содержащая файл, изменила тип с «только для чтения» на «для чтения и записи» (самое последнее изменение)
		differential_base_lsn as DifferentialBaseLsn,--Основа для разностных резервных копий. Экстенты данных, измененных после того, как этот номер LSN будет включен в разностную резервную копию
		differential_base_guid as DifferentialBaseGuid,--Уникальный идентификатор базовой резервной копии, на которой будет основываться разностная резервная копия
		differential_base_time as DifferentialBaseTime,--Время, соответствующее differential_base_lsn
		redo_start_lsn as RedoStartLsn,--Номер LSN, с которого должен начаться следующий накат
		--Равно NULL, за исключением случаев, когда значение аргумента state = RESTORING или значение аргумента state = RECOVERY_PENDING
		redo_start_fork_guid as RedoStartForkGuid,--Уникальный идентификатор точки вилки восстановления.
		--Значение аргумента first_fork_guid следующей восстановленной резервной копии журнала должно соответствовать этому значению. Это отражает текущее состояние контейнера
		redo_target_lsn as RedoTargetLsn,--Номер LSN, на котором накат в режиме «в сети» по данному файлу может остановиться
		--Равно NULL, за исключением случаев, когда значение аргумента state = RESTORING или значение аргумента state = RECOVERY_PENDING
		redo_target_fork_guid as RedoTargetForkGuid,--Вилка восстановления, на которой может быть восстановлен контейнер. Используется в паре с redo_target_lsn
		backup_lsn as BackupLsn--Номер LSN самых новых данных или разностная резервная копия файла
FROM    sys.master_files--database_files


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация по файлам всех БД экземпляра MS SQL Server (sys.master_files)', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'ServerDBFileInfo';

