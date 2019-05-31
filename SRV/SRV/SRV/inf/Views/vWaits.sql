﻿








CREATE view [inf].[vWaits] as
/*
	2014-08-22 ГЕМ:
		SQL Server отслеживает время, которое проходит между выходом потока из состояния «выполняется» и его возвращением в это состояние, 
		определяя его как «время ожидания» (wait time) и время, потраченное в состоянии «готов к выполнению», 
		определяя его как «время ожидания сигнала» (signal wait time), 
		т.е. сколько времени требуется потоку после получения сигнала о доступности ресурсов для того, 
		чтобы получить доступ к процессору. 
		Мы должны понять, сколько времени тратит поток в состоянии «приостановлен», 
		называемом «временем ожидания ресурсов» (resource wait time), вычитая время ожидания сигнала из общего времени ожидания.

		http://habrahabr.ru/post/216309/

		505: CXPACKET 
			Означает параллелизм, но не обязательно в нем проблема. 
			Поток-координатор в параллельном запросе всегда накапливает эти ожидания. 
			Если параллельные потоки не заняты работой или один из потоков заблокирован, то ожидающие потоки также накапливают ожидание CXPACKET, 
			что приводит к более быстрому накоплению статистики по этому типу — в этом и проблема. 
			Один поток может иметь больше работы, чем остальные, и по этой причине весь запрос блокируется, пока долгий поток не закончит свою работу. 
			Если этот тип ожидания совмещен с большими цифрами ожидания PAGEIOLATCH_XX, то это может быть сканирование больших таблиц 
			по причине некорректных некластерных индексов или из-за плохого плана выполнения запроса. 
			Если это не является причиной, вы можете попробовать применение опции MAXDOP со значениями 4, 2, или 1 для проблемных запросов 
			или для всего экземпляра сервера (устанавливается на сервере параметром «max degree of parallelism»). 
			Если ваша система основана на схеме NUMA, попробуйте установить MAXDOP в значение, равное количеству процессоров в одном узле NUMA для того, 
			чтобы определить, не в этом ли проблема. Вам также нужно определить эффект от установки MAXDOP на системах со смешанной нагрузкой. 
			Если честно, я бы поиграл с параметром «cost threshold for parallelism» (поднял его до 25 для начала), прежде чем снижать значение MAXDOP для всего экземпляра. 
			И не забывайте про регулятор ресурсов (Resource Governor) в Enterprise версии SQL Server 2008, который позволяет установить количество процессоров 
			для конкретной группы соединений с сервером.

		304: PAGEIOLATCH_XX
			Вот тут SQL Server ждет чтения страницы данных с диска в память. 
			Этот тип ожидания может указывать на проблему в системе ввода/вывода (что является первой реакцией на этот тип ожидания), 
			но почему система ввода/вывода должна обслуживать такое количество чтений? 
			Возможно, давление оказывает буферный пул/память (недостаточно памяти для типичной нагрузки), внезапное изменение в планах выполнения, 
			приводящее к большим параллельным сканированиям вместо поиска, раздувание кэша планов или некоторые другие причины. 
			Не стоит считать, что основная проблема в системе ввода/вывода.

		275: ASYNC_NETWORK_IO
			Здесь SQL Server ждет, пока клиент закончит получать данные. 
			Причина может быть в том, что клиент запросил слишком большое количество данных или просто получает их ооочень медленно из-за плохого кода — я почти никогда не не видел, 
			чтобы проблема заключалась в сети. 
			Клиенты часто читают по одной строке за раз — так называемый RBAR или «строка за агонизирующей строкой»(Row-By-Agonizing-Row) — вместо того, 
			чтобы закешировать данные на клиенте и уведомить SQL Server об окончании чтения немедленно.

		112: WRITELOG
			Подсистема управления логом ожидает записи лога на диск. 
			Как правило, означает, что система ввода/ввода не может обеспечить своевременную запись всего объема лога, 
			но на высоконагруженных системах это может быть вызвано общими ограничениями записи лога, что может означать, 
			что вам следует разделить нагрузку между несколькими базами, или даже сделать ваши транзакции чуть более долгими, 
			чтобы уменьшить количество записей лога на диск. Для того, чтобы убедиться, что причина в системе ввода/вывода, 
			используйте DMV sys.dm_io_virtual_file_stats для того, чтобы изучить задержку ввода/вывода для файла лога и увидеть, 
			совпадает ли она с временем задержки WRITELOG. Если WRITELOG длится дольше, вы получили внутреннюю конкуренцию за запись на диск и должны разделить нагрузку. 
			Если нет, выясняйте, почему вы создаете такой большой лог транзакций. 
			Здесь (https://sqlperformance.com/2012/12/io-subsystem/trimming-t-log-fat) 
			и здесь (https://sqlperformance.com/2013/01/io-subsystem/trimming-more-transaction-log-fat) можно почерпнуть некоторые идеи.
			(прим переводчика: следующий запрос позволяет в простом и удобном виде получить статистику задержек ввода/вывода для каждого файла каждой базы данных на сервере:
				-- Плохо: Ср.задержка одной операции > 20 мсек
				USE master
				GO
				SELECT cast(db_name(a.database_id) AS VARCHAR) AS Database_Name
					 , b.physical_name
					 --, a.io_stall
					 , a.size_on_disk_bytes
					 , a.io_stall_read_ms / a.num_of_reads 'Ср.задержка одной операции чтения'
					 , a.io_stall_write_ms / a.num_of_writes 'Ср.задержка одной операции записи'
					 --, *
				FROM
					sys.dm_io_virtual_file_stats(NULL, NULL) a
					INNER JOIN sys.master_files b
						ON a.database_id = b.database_id AND a.file_id = b.file_id
				where num_of_writes > 0 and num_of_reads > 0
				ORDER BY
					Database_Name
				  , a.io_stall DESC

		109: BROKER_RECEIVE_WAITFOR
			Здесь Service Broker ждет новые сообщения. 
			Я бы рекомендовал добавить это ожидание в список исключаемых и заново выполнить запрос со статистикой ожидания.

		086: MSQL_XP
			Здесь SQL Server ждет выполнения расширенных хранимых процедур. 
			Это может означать наличие проблем в коде ваших расширенных хранимых процедур.

		074: OLEDB
			Как и предполагается из названия, это ожидание взаимодействия с использованием OLEDB — например, со связанным сервером. 
			Однако, OLEDB также используется в DMV и командой DBCC CHECKDB, так что не думайте, 
			что проблема обязательно в связанных серверах — это может быть внешняя система мониторинга, чрезмерно использующая вызовы DMV. 
			Если это и в самом деле связанный сервер — тогда проведите анализ ожиданий на связанном сервере и определите, в чем проблема с производительностью на нем.

		054: BACKUPIO
			Показывает, когда вы делаете бэкап напрямую на ленту, что ооочень медленно. 
			Я бы предпочел отфильтровать это ожидание. 
			(прим. переводчика: я встречался с этим типом ожиданий при записи бэкапа на диск, при этом бэкап небольшой базы выполнялся очень долго, 
			не успевая выполниться в технологический перерыв и вызывая проблемы с производительностью у пользователей. 
			Если это ваш случай, возможно дело в системе ввода/вывода, используемой для бэкапирования, 
			необходимо рассмотреть возможность увеличения ее производительности либо пересмотреть план обслуживания 
			(не выполнять полные бэкапы в короткие технологические перерывы, заменив их дифференциальными))

		041: LCK_M_XX
			Здесь поток просто ждет доступа для наложения блокировки на объект и означает проблемы с блокировками. 
			Это может быть вызвано нежелательной эскалацией блокировок или плохим кодом, но также может быть вызвано тем, 
			что операции ввода/вывода занимают слишком долгое время и держат блокировки дольше, чем обычно. 
			Посмотрите на ресурсы, связанные с блокировками, используя DMV sys.dm_os_waiting_tasks. 
			Не стоит считать, что основная проблема в блокировках.

		032: ONDEMAND_TASK_QUEUE
			Это нормально и является частью системы фоновых задач (таких как отложенный сброс, очистка в фоне). 
			Я бы добавил это ожидание в список исключаемых и заново выполнил запрос со статистикой ожидания.

		031: BACKUPBUFFER
			Показывает, когда вы делаете бэкап напрямую на ленту, что ооочень медленно. 
			Я бы предпочел отфильтровать это ожидание.

		027: IO_COMPLETION
			SQL Server ждет завершения ввода/вывода и этот тип ожидания может быть индикатором проблемы с системой ввода/вывода.

		024: SOS_SCHEDULER_YIELD
			Чаще всего это код, который не попадает в другие типы ожидания, но иногда это может быть конкуренция в циклической блокировке.

		022: DBMIRROR_EVENTS_QUEUE
		022: DBMIRRORING_CMD
			Эти два типа показывают, что система управления зеркальным отображением (database mirroring) сидит и ждет, чем бы ей заняться. 
			Я бы добавил эти ожидания в список исключаемых и заново выполнил запрос со статистикой ожидания.

		018: PAGELATCH_XX
			Это конкуренция за доступ к копиям страниц в памяти. 
			Наиболее известные случаи — это конкуренция PFS, SGAM, и GAM, возникающие в базе tempdb 
			при определенных типах нагрузок (https://www.sqlskills.com/blogs/paul/a-sql-server-dba-myth-a-day-1230-tempdb-should-always-have-one-data-file-per-processor-core/). 
			Для того, чтобы выяснить, за какие страницы идет конкуренция, вам нужно использовать DMV sys.dm_os_waiting_tasks для того, 
			чтобы выяснить, из-за каких страниц возникают блокировки. 
			По проблемам с базой tempdb Роберт Дэвис (его блог http://www.sqlservercentral.com/blogs/robert_davis/) написал хорошую статью, показывающую, 
			как их решать (http://www.sqlservercentral.com/blogs/robert_davis/2010/03/05/Breaking-Down-TempDB-Contention/).
			Другая частая причина, которую я видел — часто обновляемый индекс с конкурирующими вставками в индекс, использующий последовательный ключ (IDENTITY).

		016: LATCH_XX
			Это конкуренция за какие либо не страничные структуры в SQL Server'е — так что это не связано с вводом/выводом и данными вообще. 
			Причину такого типа задержки может быть достаточно сложно понять и вам необходимо использовать DMV sys.dm_os_latch_stats.

		013: PREEMPTIVE_OS_PIPEOPS
			Здесь SQL Server переключается в режим упреждающего планирования для того, чтобы запросить о чем-то Windows. 
			Этот тип ожидания был добавлен в 2008 версии и еще не был документирован. 
			Самый простой способ выяснить, что он означает — это убрать начальные PREEMPTIVE_OS_ и поискать то, что осталось, в MSDN — это будет название API Windows.

		013: THREADPOOL
			Такой тип говорит, что недостаточно рабочих потоков в системе для того, чтобы удовлетворить запрос. 
			Обычно причина в большом количестве сильно параллелизованных запросов, пытающихся выполниться. 
			(прим. переводчика: также это может быть намеренно урезанное значение параметра сервера «max worker threads»)

		009: BROKER_TRANSMITTER
			Здесь Service Broker ждет новых сообщений для отправки. 
			Я бы рекомендовал добавить это ожидание в список исключаемых и заново выполнить запрос со статистикой ожидания.

		006: SQLTRACE_WAIT_ENTRIES
			Часть слушателя (trace) SQL Server'а. 
			Я бы рекомендовал добавить это ожидание в список исключаемых и заново выполнить запрос со статистикой ожидания.

		005: DBMIRROR_DBM_MUTEX
			Это один из недокументированных типов и в нем конкуренция возникает за отправку буфера, который делится между сессиями зеркального отображения (database mirroring). 
			Может означать, что у вас слишком много сессий зеркального отображения.

		005: RESOURCE_SEMAPHORE
			Здесь запрос ждет память для исполнения (память, используемая для обработки операторов запроса — таких, как сортировка). 
			Это может быть недостаток памяти при конкурентной нагрузке.

		003: PREEMPTIVE_OS_AUTHENTICATIONOPS
		003: PREEMPTIVE_OS_GENERICOPS
			Здесь SQL Server переключается в режим упреждающего планирования для того, чтобы запросить о чем-то Windows. 
			Этот тип ожидания был добавлен в 2008 версии и еще не был документирован. 
			Самый простой способ выяснить, что он означает — это убрать начальные PREEMPTIVE_OS_ и поискать то, что осталось, в MSDN — это будет название API Windows.

		003: SLEEP_BPOOL_FLUSH
			Это ожидание можно часто увидеть и оно означает, что контрольная точка ограничивает себя для того, чтобы избежать перегрузки системы ввода/вывода. 
			Я бы рекомендовал добавить это ожидание в список исключаемых и заново выполнить запрос со статистикой ожидания.

		002: MSQL_DQ
			Здесь SQL Server ожидает, пока выполнится распределенный запрос. 
			Это может означать проблемы с распределенными запросами или может быть просто нормой.

		002: RESOURCE_SEMAPHORE_QUERY_COMPILE
			Когда в системе происходит слишком много конкурирующих перекомпиляций запросов, SQL Server ограничивает их выполнение. 
			Я не помню уровня ограничения, но это ожидание может означать излишнюю перекомпиляцию или, возможно, слишком частое использование одноразовых планов.

		001: DAC_INIT
			Я никогда раньше этого не видел и BOL говорит, что причина в инициализации административного подключения. 
			Я не могу представить, как это может быть преимущественным ожиданием на чьей либо системе...

		001: MSSEARCH
			Этот тип является нормальным при полнотекстовых операциях. 
			Если это преимущественное ожидание, это может означать, что ваша система тратит больше всего времени на выполнение полнотекстовых запросов. 
			Вы можете рассмотреть возможность добавить этот тип ожидания в список исключаемых.

		001: PREEMPTIVE_OS_FILEOPS
		001: PREEMPTIVE_OS_LIBRARYOPS
		001: PREEMPTIVE_OS_LOOKUPACCOUNTSID
		001: PREEMPTIVE_OS_QUERYREGISTRY
			Здесь SQL Server переключается в режим упреждающего планирования для того, чтобы запросить о чем-то Windows. 
			Этот тип ожидания был добавлен в 2008 версии и еще не был документирован. 
			Самый простой способ выяснить, что он означает — это убрать начальные PREEMPTIVE_OS_ и поискать то, что осталось, в MSDN — это будет название API Windows.

		001: SQLTRACE_LOCK
			Часть слушателя (trace) SQL Server'а. 
			Я бы рекомендовал добавить это ожидание в список исключаемых и заново выполнить запрос со статистикой ожидания.

		LCK_M_XXX
		http://sqlcom.ru/waitstats-and-waittypes/lck_m_xxx/
		Это механизм ядра SQL Server, позволяющий организовать одновременную работу с данными в одно и то же время. 
		Другими словами этот механизм поддерживает целостность данных, защищая доступ к объекту базы данных.
		
		ИЗ Book On-Line:
		LCK_M_BU
		Имеет место, когда задача ожидает получения блокировки для массового обновления (BU). 
		Матрицу совместимости блокировок см. в представлении sys.dm_tran_locks
		
		LCK_M_IS
		Имеет место, когда задача ожидает получения блокировки с намерением коллективного доступа (IS). 
		Матрицу совместимости блокировок см. в представлении sys.dm_tran_locks
		
		LCK_M_IU
		Имеет место, когда задача ожидает получения блокировки с намерением обновления (IU). 
		Матрицу совместимости блокировок см. в представлении sys.dm_tran_locks 
		
		LCK_M_IX
		Имеет место, когда задача ожидает получения блокировки с намерением монопольного доступа (IX). 
		Матрицу совместимости блокировок см. в представлении sys.dm_tran_locks
		
		LCK_M_S
		Имеет место, когда задача ожидает получения совмещаемой блокировки. 
		Матрицу совместимости блокировок см. в представлении sys.dm_tran_locks
		
		LCK_M_SCH_M
		Имеет место, когда задача ожидает получения блокировки на изменение схемы. 
		Матрицу совместимости блокировок см. в представлении sys.dm_tran_locks
		
		LCK_M_SCH_S
		Имеет место, когда задача ожидает получения совмещаемой блокировки схемы. 
		Матрицу совместимости блокировок см. в представлении sys.dm_tran_locks
		
		LCK_M_SIU
		Имеет место, когда задача ожидает получения совмещаемой блокировки с намерением обновления. 
		Матрицу совместимости блокировок см. в представлении sys.dm_tran_locks
		
		LCK_M_SIX
		Имеет место, когда задача ожидает получения совмещаемой блокировки с намерением монопольного доступа. 
		Матрицу совместимости блокировок см. в представлении sys.dm_tran_locks 
		
		LCK_M_U
		Имеет место, когда задача ожидает получения блокировки на обновление. 
		Матрицу совместимости блокировок см. в представлении sys.dm_tran_locks
		
		LCK_M_UIX
		Имеет место, когда задача ожидает получения блокировки на обновление с намерением монопольного доступа. 
		Матрицу совместимости блокировок см. в представлении sys.dm_tran_locks 
		
		LCK_M_X
		Имеет место, когда задача ожидает получения блокировки на монопольный доступ. 
		Матрицу совместимости блокировок см. в представлении sys.dm_tran_locks
		
		Объяснение:
		
		Я считаю, что объяснение этого вида ожиданий очень лёгкое. 
		Когда любое задание ожидает наложения блокировки на любой ресурс, происходит этот вид ожиданий. 
		Основная причина сложности наложения блокировки состоит в том, что на необходимый ресурс уже наложена блокировка и другая операция производится с этими данными. 
		Это вид ожиданий сообщает, что ресурсы не доступны или заняты в данный момент.

		Вы можете использовать следующие методы, чтобы обнаружить блокировки

		EXEC sp_who2
		Быстрый способ найти заблокированные запросы-[srv].[vBlockingQuery]
		DMV – sys.dm_tran_locks
		DMV – sys.dm_os_waiting_tasks
		Устранение LCK_M_XXX:
		
		Проверьте долгие транзакции, постарайтесь разбить их на более мелкие
		Уровень изоляции Serialization может создавать этот вид ожиданий. 
		Изначальный уровень изоляции SQL Server — ‘Read Committed’
		Один из моих клиентов решил этот вопрос с помощью уровня изоляции ‘Read Uncommitted’. 
		Я настоятельно не рекомендую такое решение, так как будет очень много грязного чтения в базе данных
		Найдите заблокированные запросы, изучите почему так происходит и исправьте их
		Секционирование может быть источником проблемы
		Проверьте нет ли проблем с памятью и IO операциями
		Проверить память можно с помощью следующих счётчиков производительности (Perfomance Monitor):
		
		SQLServer: Memory Manager\Memory Grants Pending (Постоянное значение более чем 0-2 свидетельствует о проблеме)
		SQLServer: Memory Manager\Memory Grants Outstanding
		SQLServer: Buffer Manager\Buffer Hit Cache Ratio (Чем больше, тем лучше. Обычно значение долго превышать 90%)
		SQLServer: Buffer Manager\Page Life Expectancy (плохо, когда ниже 300)
		Memory: Available Mbytes
		Memory: Page Faults/sec
		Memory: Pages/sec
		Проверить диск можно с помощью:
		
		Average Disk sec/Read (Постоянное значение более чем 4-8 мс свидетельствует о проблеме)
		Average Disk sec/Write (Постоянное значение более чем 4-8 мс свидетельствует о проблеме)
		Average Disk Read/Write Queue Length
		Заметка: Представленная тут информация является только моим опытом. 
		Я настраиваю, чтобы вы читали Books On-Line. 
		Все мои обсуждения ожиданий здесь носят общий характер и изменяются от системы к системе. 
		Я рекомендую сначала тестировать всё на сервере разработки, прежде чем применять это на рабочем сервере.

		ASYNC_IO_COMPLETION
		http://sqlcom.ru/waitstats-and-waittypes/async_io_completion/

		Для любой хорошей системы есть 3 важные вещи: Процессор, Диск, Память. 
		Из этих трёх, Диск является наиболее критичным для SQL Server. 
		Смотря на случаи из реального мира, я не вижу людей, которые улучшают Процессоры или Память часто, однако Диски меняются достаточно часть 
		(увеличение дискового пространства, пропускной способности). 
		Сегодня мы рассмотрим ещё одно ожидание, которое относится к Диску.

		Из Book On-Line:
		Имеет место, когда для своего завершения задача ожидает ввода-вывода.
		
		Объяснение:
		Любые задания ожидают завершения I/O. 
		Если SQL Server очень медленно обрабатывает данные и клиенты ожидают их, то счётчик ASYNC_IO_COMPLETION будет увеличиваться. 
		Так же это ожидание провоцируется Backup, созданием и редактированием баз данных.
		
		Уменьшение ASYNC_IO_COMPLETION ожиданий:
		
		1. Посмотрите на код и найдите там не оптимальные участки, по возможности перепишите их
		2. Надлежащим образом, на разных дисках, разместите файлы журналов (LDF) и файлы данных (MDF), 
			Tempdb на другом отдельном диске, часто используемые таблицы в разных файловых группах и на разных дисках.
		3. Проверьте статистику использования файлов баз данных, обратите внимание на IO Read Stall и IO Write Stall (fn_virtualfilestats)
		4. Проверьте файл логов на наличие ошибок Диска
		5. Если вы используете SAN (сетевое хранилище данных), то необходимо правильно настроить параметр HBA Queue Depth, почитать о котором можно в интернете
		6. Проверьте наличие нужных индексов
		7. Проверьте показания следующих счётчиков Perfomance Monitor
		SQLServer: Memory Manager\Memory Grants Pending (Постоянное значение более чем 0-2 свидетельствует о проблеме)
		SQLServer: Memory Manager\Memory Grants Outstanding
		SQLServer: Buffer Manager\Buffer Hit Cache Ratio (Чем больше, тем лучше. Обычно значение долго превышать 90%)
		SQLServer: Buffer Manager\Page Life Expectancy (плохо, когда ниже 300)
		Memory: Available Mbytes
		Memory: Page Faults/sec
		Memory: Pages/sec
		Average Disk sec/Read (Постоянное значение более чем 4-8 мс свидетельствует о проблеме)
		Average Disk sec/Write (Постоянное значение более чем 4-8 мс свидетельствует о проблеме)
		Average Disk Read/Write Queue Length
*/
WITH [Waits] AS
    (SELECT
        [wait_type], --имя типа ожидания
        [wait_time_ms] / 1000.0 AS [WaitS],--Общее время ожидания данного типа в миллисекундах. Это время включает signal_wait_time_ms
        ([wait_time_ms] - [signal_wait_time_ms]) / 1000.0 AS [ResourceS],--Общее время ожидания данного типа в миллисекундах без signal_wait_time_ms
        [signal_wait_time_ms] / 1000.0 AS [SignalS],--Разница между временем сигнализации ожидающего потока и временем начала его выполнения
        [waiting_tasks_count] AS [WaitCount],--Число ожиданий данного типа. Этот счетчик наращивается каждый раз при начале ожидания
        100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
        ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]
    FROM sys.dm_os_wait_stats
    WHERE [waiting_tasks_count]>0
		and [wait_type] NOT IN (
        N'BROKER_EVENTHANDLER',         N'BROKER_RECEIVE_WAITFOR',
        N'BROKER_TASK_STOP',            N'BROKER_TO_FLUSH',
        N'BROKER_TRANSMITTER',          N'CHECKPOINT_QUEUE',
        N'CHKPT',                       N'CLR_AUTO_EVENT',
        N'CLR_MANUAL_EVENT',            N'CLR_SEMAPHORE',
        N'DBMIRROR_DBM_EVENT',          N'DBMIRROR_EVENTS_QUEUE',
        N'DBMIRROR_WORKER_QUEUE',       N'DBMIRRORING_CMD',
        N'DIRTY_PAGE_POLL',             N'DISPATCHER_QUEUE_SEMAPHORE',
        N'EXECSYNC',                    N'FSAGENT',
        N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
        N'HADR_CLUSAPI_CALL',           N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
        N'HADR_LOGCAPTURE_WAIT',        N'HADR_NOTIFICATION_DEQUEUE',
        N'HADR_TIMER_TASK',             N'HADR_WORK_QUEUE',
        N'KSOURCE_WAKEUP',              N'LAZYWRITER_SLEEP',
        N'LOGMGR_QUEUE',                N'ONDEMAND_TASK_QUEUE',
        N'PWAIT_ALL_COMPONENTS_INITIALIZED',
        N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
        N'REQUEST_FOR_DEADLOCK_SEARCH', N'RESOURCE_QUEUE',
        N'SERVER_IDLE_CHECK',           N'SLEEP_BPOOL_FLUSH',
        N'SLEEP_DBSTARTUP',             N'SLEEP_DCOMSTARTUP',
        N'SLEEP_MASTERDBREADY',         N'SLEEP_MASTERMDREADY',
        N'SLEEP_MASTERUPGRADED',        N'SLEEP_MSDBSTARTUP',
        N'SLEEP_SYSTEMTASK',            N'SLEEP_TASK',
        N'SLEEP_TEMPDBSTARTUP',         N'SNI_HTTP_ACCEPT',
        N'SP_SERVER_DIAGNOSTICS_SLEEP', N'SQLTRACE_BUFFER_FLUSH',
        N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
        N'SQLTRACE_WAIT_ENTRIES',       N'WAIT_FOR_RESULTS',
        N'WAITFOR',                     N'WAITFOR_TASKSHUTDOWN',
        N'WAIT_XTP_HOST_WAIT',          N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
        N'WAIT_XTP_CKPT_CLOSE',         N'XE_DISPATCHER_JOIN',
        N'XE_DISPATCHER_WAIT',          N'XE_TIMER_EVENT',
		N'XE_LIVE_TARGET_TVF',
		N'PREEMPTIVE_XE_DISPATCHER',
		N'PREEMPTIVE_OS_ENCRYPTMESSAGE',
		N'PREEMPTIVE_OS_AUTHENTICATIONOPS',
		N'PREEMPTIVE_OS_CRYPTOPS',
		N'PREEMPTIVE_OS_DECRYPTMESSAGE',
		N'PREEMPTIVE_OS_CRYPTACQUIRECONTEXT',
		N'PREEMPTIVE_OS_CRYPTIMPORTKEY',
		N'PREEMPTIVE_OS_DELETESECURITYCONTEXT',
		N'PREEMPTIVE_OS_DEVICEOPS',
		N'PREEMPTIVE_OS_AUTHORIZATIONOPS',
		N'PREEMPTIVE_OS_CLOSEHANDLE',
		N'PREEMPTIVE_OS_COMOPS',
		N'PREEMPTIVE_OS_CREATEFILE',
		N'PREEMPTIVE_CLOSEBACKUPVDIDEVICE',
		N'PREEMPTIVE_COM_COCREATEINSTANCE',
		N'PREEMPTIVE_COM_QUERYINTERFACE',
		N'PREEMPTIVE_FILESIZEGET',
		N'PREEMPTIVE_OLEDBOPS',
		N'PREEMPTIVE_OS_DISCONNECTNAMEDPIPE',
		N'PREEMPTIVE_OS_DOMAINSERVICESOPS',
		N'PREEMPTIVE_OS_DELETEFILE',
		N'PREEMPTIVE_OS_FILEOPS',
		N'PREEMPTIVE_OS_FLUSHFILEBUFFERS',
		N'PREEMPTIVE_OS_GENERICOPS',
		N'PREEMPTIVE_OS_GETDISKFREESPACE',
		N'PREEMPTIVE_OS_GETFILEATTRIBUTES',
		N'PREEMPTIVE_OS_GETPROCADDRESS',
		N'PREEMPTIVE_OS_GETVOLUMEPATHNAME',
		N'PREEMPTIVE_OS_LIBRARYOPS',
		N'PREEMPTIVE_OS_LOADLIBRARY',
		N'PREEMPTIVE_OS_LOOKUPACCOUNTSID',
		N'PREEMPTIVE_OS_NETVALIDATEPASSWORDPOLICY',
		N'PREEMPTIVE_OS_PIPEOPS',
		N'PREEMPTIVE_OS_QUERYCONTEXTATTRIBUTES',
		N'PREEMPTIVE_OS_QUERYREGISTRY',
		N'PREEMPTIVE_OS_REPORTEVENT',
		N'PREEMPTIVE_OS_REVERTTOSELF',
		N'PREEMPTIVE_OS_SECURITYOPS',
		N'PREEMPTIVE_OS_SQMLAUNCH',
		N'PREEMPTIVE_OS_WAITFORSINGLEOBJECT',
		N'PREEMPTIVE_OS_WRITEFILE',
		N'PREEMPTIVE_OS_WRITEFILEGATHER',
		N'PREEMPTIVE_XE_CALLBACKEXECUTE',
		N'PREEMPTIVE_XE_SESSIONCOMMIT',
		N'PREEMPTIVE_XE_TARGETFINALIZE',
		N'PREEMPTIVE_XE_TARGETINIT',
		N'PREEMPTIVE_OS_AUTHZINITIALIZECONTEXTFROMSID',
		N'PREEMPTIVE_OS_GETVOLUMENAMEFORVOLUMEMOUNTPOINT',
		N'PREEMPTIVE_OS_MOVEFILE',
		N'PREEMPTIVE_OS_NETVALIDATEPASSWORDPOLICYFREE',
		N'PREEMPTIVE_OS_SETFILEVALIDDATA',
		N'PREEMPTIVE_TRANSIMPORT',
		N'PREEMPTIVE_XE_GETTARGETSTATE',
		N'PREEMPTIVE_OS_GETCOMPRESSEDFILESIZE',
		N'PREEMPTIVE_OS_DEVICEIOCONTROL',
		N'PREEMPTIVE_OS_VERIFYTRUST',
		N'PREEMPTIVE_OS_SETNAMEDSECURITYINFO',
		N'PREEMPTIVE_OLE_UNINIT',
		N'PREEMPTIVE_DTC_BEGINTRANSACTION',
		N'PREEMPTIVE_DTC_ENLIST',
		N'PREEMPTIVE_OLE_UNINIT',
		N'PREEMPTIVE_OS_DTCOPS',
		N'PREEMPTIVE_SB_STOPENDPOINT',
		N'PREEMPTIVE_DTC_COMMITREQUESTDONE',
		N'PREEMPTIVE_DTC_PREPAREREQUESTDONE',
		N'PREEMPTIVE_OS_AUTHZINITIALIZERESOURCEMANAGER',
		N'PREEMPTIVE_OS_AUTHZGETINFORMATIONFROMCONTEXT',
		N'PREEMPTIVE_CREATEPARAM',
		N'PREEMPTIVE_OS_WSASETLASTERROR',
		N'PREEMPTIVE_OS_SQLCLROPS',
		N'PREEMPTIVE_OS_INITIALIZESECURITYCONTEXT',
		N'PREEMPTIVE_OS_GETADDRINFO',
		N'PREEMPTIVE_COM_CREATEACCESSOR',
		N'PREEMPTIVE_COM_SETPARAMETERINFO',
		N'PREEMPTIVE_COM_SETPARAMETERPROPERTIES',
		N'PREEMPTIVE_OS_ACCEPTSECURITYCONTEXT',
		N'PREEMPTIVE_OS_ACQUIRECREDENTIALSHANDLE',
		N'PREEMPTIVE_COM_GETDATA'
		)
    )
, ress as (
	SELECT
	    [W1].[wait_type] AS [WaitType],
	    CAST ([W1].[WaitS] AS DECIMAL (16, 2)) AS [Wait_S],--Общее время ожидания данного типа в миллисекундах. Это время включает signal_wait_time_ms
	    CAST ([W1].[ResourceS] AS DECIMAL (16, 2)) AS [Resource_S],--Общее время ожидания данного типа в миллисекундах без signal_wait_time_ms
	    CAST ([W1].[SignalS] AS DECIMAL (16, 2)) AS [Signal_S],--Разница между временем сигнализации ожидающего потока и временем начала его выполнения
	    [W1].[WaitCount] AS [WaitCount],--Число ожиданий данного типа. Этот счетчик наращивается каждый раз при начале ожидания
	    CAST ([W1].[Percentage] AS DECIMAL (5, 2)) AS [Percentage],
	    CAST (([W1].[WaitS] / [W1].[WaitCount]) AS DECIMAL (16, 4)) AS [AvgWait_S],
	    CAST (([W1].[ResourceS] / [W1].[WaitCount]) AS DECIMAL (16, 4)) AS [AvgRes_S],
	    CAST (([W1].[SignalS] / [W1].[WaitCount]) AS DECIMAL (16, 4)) AS [AvgSig_S]
	FROM [Waits] AS [W1]
	INNER JOIN [Waits] AS [W2]
	    ON [W2].[RowNum] <= [W1].[RowNum]
	GROUP BY [W1].[RowNum], [W1].[wait_type], [W1].[WaitS],
	    [W1].[ResourceS], [W1].[SignalS], [W1].[WaitCount], [W1].[Percentage]
	HAVING SUM ([W2].[Percentage]) - [W1].[Percentage] < 95 -- percentage threshold
)
SELECT [WaitType]
      ,MAX([Wait_S]) as [Wait_S]
      ,MAX([Resource_S]) as [Resource_S]
      ,MAX([Signal_S]) as [Signal_S]
      ,MAX([WaitCount]) as [WaitCount]
      ,MAX([Percentage]) as [Percentage]
      ,MAX([AvgWait_S]) as [AvgWait_S]
      ,MAX([AvgRes_S]) as [AvgRes_S]
      ,MAX([AvgSig_S]) as [AvgSig_S]
  FROM ress
  group by [WaitType]






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Информация по ожиданиям (по статистикам) экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vWaits';

