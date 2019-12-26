--Быстрый мониторинг основных параметров производительности
--Автор: Прилепа Б.А. - АБД
--09.07.2019

CREATE   PROCEDURE [zabbix].[GetServerPerformance_Info] @HighLoadCPU INT = 60,
	@SuperHighLoadCPU INT = 80,
	--@MinLimitRAM INT = 1024,
	@CountBlocks INT = 1,
	@HighCountBlocks INT = 5,
	@MaxWaitQuery INT = 15,
	@LockMaxWaitQuery_ms INT = 300
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON; 

	--Высчитываем число доступных ноде процессоров
	declare @cpu_count int
	set @cpu_count=(select top 1 cpu_count from sys.dm_os_nodes where node_state_desc='ONLINE')-1 --Так как отсчет cpu_id идет с нуля

	;WITH os_schedulers
	AS
	(SELECT
			cpu_id
		   ,active_workers_count
		   ,load_factor
		FROM sys.dm_os_schedulers
		WHERE cpu_id <= @cpu_count 
		      AND [status] = 'VISIBLE ONLINE'),
	Offline_cpu (Offline_cpu)
	AS
	--https://docs.microsoft.com/ru-ru/sql/relational-databases/system-dynamic-management-views/sys-dm-os-schedulers-transact-sql?view=sql-server-ver15
	(SELECT
			COUNT([status]) offline_cpu
		FROM sys.dm_os_schedulers
		WHERE cpu_id <= @cpu_count 
		      AND [status] = 'VISIBLE OFFLINE'
	)

	SELECT
		RES = (CASE
			WHEN [highly_loaded_cores_%] >= @SuperHighLoadCPU 
			OR ([blocking_queries] > @CountBlocks AND [highly_loaded_cores_%] >= @HighLoadCPU)
			THEN 8 --Сильная перегрузка CPU для доступных ядер (повторение такой картины говорит о крайне критической проблеме с нагрузкой ЦП)
			WHEN [highly_loaded_cores_%] >= @HighLoadCPU
			AND ([blocking_queries] = 0 AND ([max_waiting_query_sec] >= @MaxWaitQuery OR [maintenance_max_waiting_query_sec] >= @MaxWaitQuery)) THEN 7 --Высокое значение загруженности CPU (без блокировок, есть запросы свыше @MaxWaitQuery)
			WHEN [highly_loaded_cores_%] >= @HighLoadCPU
			AND ([blocking_queries] = 0 AND ([max_waiting_query_sec] < @MaxWaitQuery AND [maintenance_max_waiting_query_sec] < @MaxWaitQuery)) THEN 6 --Высокое значение загруженности CPU (без блокировок, а также слишком длинный запросов)			
			WHEN [blocking_queries] >= @HighCountBlocks OR
				([blocking_queries] >= @CountBlocks AND
				[max_lock_waiting_ms] >= @LockMaxWaitQuery_ms * 10) THEN 5 --Критическая проблема с блокировками 
			WHEN [blocking_queries] > @CountBlocks AND
				[blocking_queries] < @HighCountBlocks AND
				[max_lock_waiting_ms] >= @LockMaxWaitQuery_ms THEN 4 --Несколько долгих блокировок
			--Частое повторение говорит о значимой критичности плохой производительности одного или нескольких запросов
			WHEN [blocking_queries] = @CountBlocks AND
				[max_lock_waiting_ms] >= @LockMaxWaitQuery_ms THEN 3 --Одиночная долгая блокировка
			--Частое повторение говорит о системной проблеме с одним запросом
			WHEN [blocking_queries] = 0 AND
				[max_waiting_query_sec] >= @MaxWaitQuery THEN 2 --Долгие SQL запросы, кроме обслуживания и профилирования
            WHEN [blocking_queries] = 0 AND
				[maintenance_max_waiting_query_sec] >= @MaxWaitQuery THEN 1 --MS SQL процессы обслуживания, задача
			WHEN (SELECT
						Offline_cpu
					FROM Offline_cpu)
				> 0 THEN 9 --Есть ядра, которых не видит MS SQL, но они доступны (требуется рестарт сервиса)
			ELSE 0
		END)
	FROM (SELECT
			[highly_loaded_cores_%],
			[Offline_cpu],
			[max_waiting_query_sec],
			[blocking_queries],
			[maintenance_max_waiting_query_sec],
			[max_lock_waiting_ms]
		FROM (SELECT  (SELECT
						CAST(CAST(ROUND(COUNT(DISTINCT cpu_id) / (SELECT
								COUNT(DISTINCT cpu_id) / 1.0
							FROM os_schedulers)
						, 2) AS NUMERIC(4, 2)) * 100 AS INT)
					FROM os_schedulers
					WHERE ((active_workers_count > 8
					AND load_factor > 3) /*повышенная нагрузка на ядро*/ OR (active_workers_count <= 8
					AND load_factor > 9)  /*повышенный фактор нагрузки*/))
				[highly_loaded_cores_%]
			   ,CASE
					WHEN (SELECT
								Offline_cpu
							FROM Offline_cpu)
						> 0 THEN (SELECT
								Offline_cpu
							FROM Offline_cpu)
					ELSE 0
				END Offline_cpu
			   --Запросы JOB-ов, сервисов, пользовательские запросы
			   ,(SELECT
					DATEDIFF(SS, MIN(start_time), GETDATE()) SS
					FROM sys.dm_exec_requests
					WHERE [connection_id] IS NOT NULL
					AND last_wait_type NOT IN ('XE_LIVE_TARGET_TVF' /*Сборщик XE Events*/, --АБД сам следит за провилированием
											   'TRACEWRITE' /*Профайлер*/,
											    'PREEMPTIVE_OS_ENCRYPTMESSAGE'/*упреждающее сообщение шифрования ОС*/,'BROKER_RECEIVE_WAITFOR' /*Таймер диалога*/)
					AND (command NOT IN ('UPDATE STATISTICS','BACKUP DATABASE','BACKUP LOG','RESTORE DATABASE','RESTORE LOG','DBCC')
					--Обновление стастик, DBCC, операции создание и восстановления резервных копий
					))
				[max_waiting_query_sec]
				,(SELECT
					DATEDIFF(SS, MIN(start_time), GETDATE()) SS
					FROM sys.dm_exec_requests
					WHERE [connection_id] IS NOT NULL
					AND last_wait_type NOT IN ('XE_LIVE_TARGET_TVF' /*Сборщик XE Events*/, --АБД сам следит за провилированием
											   'TRACEWRITE' /*Профайлер*/,
											    'PREEMPTIVE_OS_ENCRYPTMESSAGE'/*упреждающее сообщение шифрования ОС*/,'BROKER_RECEIVE_WAITFOR' /*Таймер диалога*/)
					AND (command IN ('UPDATE STATISTICS','BACKUP DATABASE','BACKUP LOG','RESTORE DATABASE','RESTORE LOG','DBCC')
					--Обновление стастик, DBCC, операции создание и восстановления резервных копий
					))
				[maintenance_max_waiting_query_sec]
			   ,(SELECT
						COUNT(distinct blocking_session_id)
					FROM sys.dm_os_waiting_tasks
					WHERE blocking_session_id IS NOT NULL)
				[blocking_queries]
				,(SELECT
						max(wait_duration_ms)
					FROM sys.dm_os_waiting_tasks
					WHERE blocking_session_id IS NOT NULL)
				[max_lock_waiting_ms]
				) a) TBL


END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Хранимая процедура для быстрого анализа основных проблем на сервере MS SQL с 

1 - нет блокировок, но время max время выполнения запроса >=30 сек.
2 - имеется одна блокировка в соотношении с max долгим запросом >=30 сек.
3 - имеется 1-4 блокировки в соотношении с max долгим запросом >=30 сек.
4 - имеется 5 и более блокировок  или (от 1 и более блокировки с max долгим запросом от 90 сек.
5 - низкое значение доступной RAM для ОС ([Avail_RAM_Memory_Mb] <= @MinLimitRAM)
<=1024 Mb
6 - крайне низкое значение доступной RAM для ОС ([Avail_RAM_Memory_Mb] <= @MinLimitRAM)
<=206 Mb или доступная для MS SQL RAM меньше 100 Мб
7 - бол-во ядер с высокой нагрузкой на ЦП   ( [highly_loaded_cores_%] >= @HighLoadCPU)
>60-80% всех ядер доступных MS SQL сильно нагружены
8 - бол-во ядер со сверхвысокой нагрузкой на ЦП   ( [highly_loaded_cores_%] >= @SuperHighLoadCPU)
>80% всех ядер доступных MS SQL сильно нагружены
9 - есть доступные ядра, но они помечены OFFLINE для MS SQL', @level0type = N'SCHEMA', @level0name = N'zabbix', @level1type = N'PROCEDURE', @level1name = N'GetServerPerformance_Info';

