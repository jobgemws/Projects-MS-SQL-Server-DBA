--Процессы инициирующие блокировки, в том числе каскадные
SELECT
    DISTINCT spid, --Id процесса
    [status],
    /*
    running  - процесс запущен и выполняется в данный момент
    runnable - задача в сессии в очереди на запуск, с целью получить доступ на запуск, более полный список
    suspended  - сессия приостановлена, в ожидании другого события (смотреть ожидания)
    https://docs.microsoft.com/ru-ru/sql/relational-databases/system-compatibility-views/sys-sysprocesses-transact-sql?view=sql-server-2017
    */
    CONVERT(CHAR(3), s.blocked) AS blocked, --заблокированный процесс
    loginame, --логин выполнения
    SUBSTRING([program_name], 1, 255)   AS program, --имя программы
    SUBSTRING(DB_NAME(s.dbid), 1, 255)  AS [database], -- Имя БД на которой выполняется запрос
    SUBSTRING(hostname, 1, 255)         AS host, --Имя хоста инициировавшего запрос
    cmd, --Тип команды выполнения (к примеру SELECT, INSERT, DBCC и пр.)
    waittype, --Тип ожидания запроса
    t.[text]
  FROM
  (select * from sys.sysprocesses where blocked = 0 /*берем не блокированные сессии*/) s
  INNER JOIN (SELECT distinct blocked FROM sys.sysprocesses WHERE blocked <> 0 /*берем заблокированные сессии*/) p on(s.spid=p.blocked)
  CROSS APPLY /*соединяем только тез у кого есть sql_handle и тд. sql запрос*/ 
  sys.dm_exec_sql_text (s.sql_handle) t --текст запроса инициировавший блокировку
 
 
--Широкая картина блокирующий процесс - заблокированный
SELECT
    DISTINCT t.blocking_session_id                AS blocking, --Id блокирующей сессии
    t.session_id                        AS blocked,            --Id заблокированной сессии
    SUBSTRING(p2.[program_name], 1, 255)  AS program_blocking, --программа блокирующая
    SUBSTRING(p1.[program_name], 1, 255)  AS program_blocked,  --программа заблокированная
    DB_NAME(l.resource_database_id)      AS [database],        --Имя БД на которой выполняется запрос
    p2.[hostname]                        AS host_blocking,     --хост блокирующего процесса
    p1.[hostname]                        AS host_blocked,      --хост заблокированного процесса
    t.wait_duration_ms,                                        --ожидание последнего ожидания по данному запросу, часто отличается от общего времени выполнения
    l.request_mode,                                            --тип запроса, S - SELECT  
    l.resource_type,                                           --по сути уровень блокировки (при блокировке ресурсов обычно PAGE, KEY и тд. блокировк на уровне страницы или ключа)
    --(DATABASE, FILE, OBJECT, PAGE, KEY, EXTENT, RID, APPLICATION, METADATA, HOBT, or ALLOCATION_UNIT)
    t.wait_type,                                  --ожидания, одно из select wait_type from sys.dm_os_wait_stats                  
    (SELECT SUBSTRING(st.text, (r.statement_start_offset/2) + 1,
            ((CASE r.statement_end_offset WHEN -1 THEN DATALENGTH(st.text)
              ELSE r.statement_end_offset
              END - r.statement_start_offset) / 2) + 1)
      FROM sys.dm_exec_requests AS r
        CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
      WHERE r.session_id = l.request_session_id) AS statement_blocked, /*выбираем из dm_exec_sql_text кусок sql скрипта, который оказался блокируемым*/
    CASE WHEN t.blocking_session_id > 0 THEN
           (SELECT st.text
              FROM sys.sysprocesses AS p 
                CROSS APPLY sys.dm_exec_sql_text(p.sql_handle) AS st
              WHERE p.spid = t.blocking_session_id) ELSE NULL
         END AS statement_blocking                                      /*выбираем из dm_exec_sql_text кусок sql скрипта, который оказался блокирующим*/
  FROM sys.dm_os_waiting_tasks AS t   --здесь хранятся ожидающие задачи
    INNER JOIN sys.dm_tran_locks AS l --здесь хранятся активные данные по блокировкам в менеджере ресурсов MS SQL
      ON t.resource_address /*адрес сессий из dm_os_waiting_tasks*/ = l.lock_owner_address --адресс блокированной сессии в dm_tran_locks
    INNER JOIN sys.sysprocesses p1   ON p1.spid = t.session_id --соединяем для извлечения [program_name],[hostname] заблокированного процесса
    INNER JOIN sys.sysprocesses p2   ON p2.spid = t.blocking_session_id--соединяем для извлечения [program_name],[hostname] блокирующего процесса
  WHERE (p1.[status]<>'background' and p1.cmd<>'TASK MANAGER') /*нам интересны сессии явного SQL скрипта*/  AND t.session_id<>@@spid /*не берем наш собственный процесс*/
  ORDER BY wait_duration_ms desc,t.blocking_session_id  DESC;
 
 
--Все выполняемые сессии с активными или отложенными выполнениями SQL скриптов, расширенных процедур OLE
WITH A AS(SELECT DISTINCT
    r.session_id             AS spid, --Id процесса
    r.percent_complete       AS [percent], --Для отдельных операций вроде ALTER INDEX, BACKUP, ROLLBACK мы можем видеть условный процент выполнения задачи
    r.open_transaction_count AS open_trans, --Число открытых транзакций, связанных с данной сессией
    r.[status],                             --статус (running, suspended и пр. описанные выше)
    r.reads,                                --число операция чтений связанных с запросом
    r.logical_reads,                        --логических чтений
    r.writes,                               --записей 
    s.cpu,                                  --тактов cpu для выполнения запроса
    DB_NAME(r.database_id)   AS [db_name],  --Имя БД
    s.[hostname],                           --Имя ПК инициирующего запрос
    dmec.client_net_address,                --IP adress клиента
    s.[program_name],                       --имя программы
    s.loginame,                             --логин
    r.start_time,                           --время запуска запроса
    r.wait_time,                            --ожидание, виды ожиданий https://docs.microsoft.com/ru-ru/sql/relational-databases/system-dynamic-management-views/sys-dm-os-wait-stats-transact-sql?view=sql-server-2017
    r.last_wait_type,                       --последнее ожидание (задача может находится в различных состояниях выполнения) 
    r.blocking_session_id    AS blocking,   --блокирующий процесс (0 - нет блокирующего)
    r.command,                              --command (общий вид запросов SQL - SELECT, DBCC и пр.) 
    (SELECT SUBSTRING(text, statement_start_offset / 2 + 1,
            (CASE WHEN statement_end_offset = -1 THEN
                    LEN(CONVERT(NVARCHAR(MAX),text)) * 2
                  ELSE statement_end_offset
                  END - statement_start_offset) / 2)
      FROM sys.dm_exec_sql_text(r.sql_handle)) AS [statement], /*фрагмент sql кода активный для выполнения на данный момент, актуально для больших sql скриптов из мно-ва фрагментов*/
    t.[text] /*весь текст запроса*/,r.plan_handle --binary план запроса, необходим, чтобы потом достать xml plan из sys.dm_exec_query_plan
  ,r.scheduler_id --scheduler_id  планировщика SQL Server, привязка к core
  FROM sys.dm_exec_requests r
  LEFT JOIN sys.dm_exec_connections dmec ON r.session_id = dmec.session_id
    LEFT JOIN sys.sysprocesses s ON s.spid = r.session_id
    OUTER APPLY sys.dm_exec_sql_text (r.sql_handle) t --отображать и те процесс, которые не имеют sql кода выполняемого
  WHERE (r.[status]<>'background' and r.command<>'TASK MANAGER') AND r.session_id <> @@spid and hostname<>'')
 
SELECT A.spid,s.cpu_id,s.current_tasks_count current_tasks,s.runnable_tasks_count runnable_tasks,[percent],open_trans,A.[status],reads,logical_reads,writes,cpu,[db_name],[hostname],client_net_address
,[program_name],loginame,start_time,wait_time,last_wait_type,blocking,command,[statement],[text],query_plan
FROM A A OUTER APPLY sys.dm_exec_query_plan (plan_handle) --соединяем xml plan выполнения запроса
LEFT JOIN sys.dm_os_schedulers s on(A.scheduler_id=s.scheduler_id) --выбираем данные по доступу к ЦП
ORDER BY spid ,wait_time DESC