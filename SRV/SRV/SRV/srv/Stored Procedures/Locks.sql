
  
CREATE   PROCEDURE [srv].[Locks]
(
   @Mode int = 4
)
/*
  @Mode - 0 вывод активных запросов без кода T-SQL и sql plan 1 окно
  @Mode - 1 блокируемый запрос и заблокированный 1 окно
  @Mode - 2 запрос инициирующий блокировку в том числе каскадную и окно @Mode - 1 (блокируемый и заблокированный запрос)
  @Mode - 3 три окна, сочетаниие @Mode 2 и 0, но в третьем окне дополнительно выводится полный текст запроса и sql plan
*/
AS
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	/*Мониториг sql процессов выполняемых в данный момент на сервере, блокировок процессов*/
	BEGIN
	SET XACT_ABORT ON;
	IF @Mode = 0
	BEGIN;
		SELECT DISTINCT
	    r.session_id             AS spid,
	    r.percent_complete       AS [percent],
	    r.open_transaction_count AS open_trans,
	    r.[status],
	    r.reads,
	    r.logical_reads,
	    r.writes,
	    s.cpu,
	    DB_NAME(r.database_id)   AS [db_name],
	    s.[hostname],
		dmec.client_net_address,
	    s.[program_name],
	    s.loginame,
	    r.start_time,
	    r.wait_time,
	    r.last_wait_type,
	    r.blocking_session_id    AS blocking,
	    r.command
	  FROM sys.dm_exec_requests r
	  inner join sys.dm_exec_connections dmec ON r.session_id = dmec.session_id
	    INNER JOIN sys.sysprocesses s ON s.spid = r.session_id
	  WHERE (r.[status]<>'background' and r.command<>'TASK MANAGER') AND r.session_id <> @@spid
	  ORDER BY r.session_id;
	END;
	
	IF @Mode = 1
	BEGIN;
	  SELECT
	      t.blocking_session_id           AS blocking,
	      t.session_id                    AS blocked,
	      p2.[program_name]               AS program_blocking,
	      p1.[program_name]               AS program_blocked,
	      DB_NAME(l.resource_database_id) AS [database],
	      p2.[hostname]                   AS host_blocking,
	      p1.[hostname]                   AS host_blocked,
	      t.wait_duration_ms,
	      l.request_mode,
	      l.resource_type,
	      t.wait_type,
	      (SELECT SUBSTRING(st.text, (r.statement_start_offset/2) + 1, 
	              ((CASE r.statement_end_offset 
	                  WHEN -1 THEN DATALENGTH(st.text) 
	                  ELSE r.statement_end_offset END
	                - r.statement_start_offset) /2 ) + 1)
	        FROM sys.dm_exec_requests AS r 
	          CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS st 
	        WHERE r.session_id = l.request_session_id) AS statement_blocked,
	      CASE WHEN t.blocking_session_id > 0 THEN 
	        (SELECT st.text 
	          FROM sys.sysprocesses AS p 
	            CROSS APPLY sys.dm_exec_sql_text(p.sql_handle) AS st
	          WHERE p.spid = t.blocking_session_id)
	      ELSE NULL END AS statement_blocking
	    FROM sys.dm_os_waiting_tasks AS t
	      INNER JOIN sys.dm_tran_locks AS l 
	        ON t.resource_address = l.lock_owner_address
	      INNER JOIN sys.sysprocesses p1 ON p1.spid = t.session_id
	      INNER JOIN sys.sysprocesses p2 ON p2.spid = t.blocking_session_id
	    WHERE (p1.[status]<>'background' and p1.cmd<>'TASK MANAGER') and t.session_id<>@@SPID 
	END;
	
	IF @Mode = 2
	BEGIN;
	SELECT 
	    spid,
	    [status],
	    CONVERT(CHAR(3), s.blocked) AS blocked,
	    loginame,
	    SUBSTRING([program_name], 1, 25)   AS program,
	    SUBSTRING(DB_NAME(s.dbid), 1, 10)  AS [database],
	    SUBSTRING(hostname, 1, 12)         AS host,
	    cmd,
	    waittype,
	    t.[text]
	  FROM (select * from sys.sysprocesses where blocked = 0) s 
	  INNER JOIN (SELECT distinct blocked FROM sys.sysprocesses WHERE blocked <> 0) p on(s.spid=p.blocked)
	  CROSS APPLY sys.dm_exec_sql_text (s.sql_handle) t
	
	SELECT
	    t.blocking_session_id            AS blocking,
	    t.session_id                     AS blocked,
	    p2.[program_name]                AS program_blocking,
	    p1.[program_name]                AS program_blocked,
	    DB_NAME(l.resource_database_id)  AS [database],
	    p2.[hostname]                    AS host_blocking,
	    p1.[hostname]                    AS host_blocked,
	    t.wait_duration_ms,
	    l.request_mode,
	    l.resource_type,
	    t.wait_type,
	    (SELECT SUBSTRING(st.text, (r.statement_start_offset / 2) + 1, 
	              ((CASE r.statement_end_offset 
	                  WHEN -1 THEN DATALENGTH(st.text)
	                  ELSE r.statement_end_offset END
	                - r.statement_start_offset) / 2) + 1
	            )
	      FROM sys.dm_exec_requests AS r
	        CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS st 
	      WHERE r.session_id = l.request_session_id) AS statement_blocked,
	    CASE WHEN t.blocking_session_id > 0 THEN 
	          (SELECT st.text 
	            FROM sys.sysprocesses AS p  
	              CROSS APPLY sys.dm_exec_sql_text(p.sql_handle) AS st 
	            WHERE p.spid = t.blocking_session_id) ELSE NULL 
	         END AS statement_blocking
	  FROM sys.dm_os_waiting_tasks AS t
	    INNER JOIN sys.dm_tran_locks AS l
	      ON t.resource_address = l.lock_owner_address
	    INNER JOIN sys.sysprocesses p1   ON p1.spid = t.session_id
	    INNER JOIN sys.sysprocesses p2   ON p2.spid = t.blocking_session_id
	  WHERE (p1.[status]<>'background' and p1.cmd<>'TASK MANAGER')  AND t.session_id<>@@spid
	  ORDER BY t.blocking_session_id  DESC;
	END;
	
	IF @Mode = 3
	BEGIN;
	SELECT 
	    DISTINCT spid,
	    [status],
	    CONVERT(CHAR(3), s.blocked) AS blocked,
	    loginame,
	    SUBSTRING([program_name], 1, 255)   AS program,
	    SUBSTRING(DB_NAME(s.dbid), 1, 255)  AS [database],
	    SUBSTRING(hostname, 1, 255)         AS host,
	    cmd,
	    waittype,
	    t.[text]
	  FROM (select * from sys.sysprocesses where blocked = 0) s 
	  INNER JOIN (SELECT distinct blocked FROM sys.sysprocesses WHERE blocked <> 0) p on(s.spid=p.blocked)
	  CROSS APPLY sys.dm_exec_sql_text (s.sql_handle) t
	  
	  
	SELECT
	    DISTINCT t.blocking_session_id                AS blocking,
	    t.session_id                        AS blocked,
	    SUBSTRING(p2.[program_name], 1, 255)  AS program_blocking,
	    SUBSTRING(p1.[program_name], 1, 255)  AS program_blocked,
	    DB_NAME(l.resource_database_id)      AS [database],
	    p2.[hostname]                        AS host_blocking,
	    p1.[hostname]                        AS host_blocked,
	    t.wait_duration_ms,
	    l.request_mode,
	    l.resource_type,
	    t.wait_type,
	    (SELECT SUBSTRING(st.text, (r.statement_start_offset/2) + 1, 
	            ((CASE r.statement_end_offset WHEN -1 THEN DATALENGTH(st.text)
	              ELSE r.statement_end_offset 
	              END - r.statement_start_offset) / 2) + 1) 
	      FROM sys.dm_exec_requests AS r 
	        CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS st 
	      WHERE r.session_id = l.request_session_id) AS statement_blocked,
	    CASE WHEN t.blocking_session_id > 0 THEN 
	           (SELECT st.text 
	              FROM sys.sysprocesses AS p  
	                CROSS APPLY sys.dm_exec_sql_text(p.sql_handle) AS st 
	              WHERE p.spid = t.blocking_session_id) ELSE NULL 
	         END AS statement_blocking
	  FROM sys.dm_os_waiting_tasks AS t
	    INNER JOIN sys.dm_tran_locks AS l 
	      ON t.resource_address = l.lock_owner_address
	    INNER JOIN sys.sysprocesses p1   ON p1.spid = t.session_id
	    INNER JOIN sys.sysprocesses p2   ON p2.spid = t.blocking_session_id
	  WHERE (p1.[status]<>'background' and p1.cmd<>'TASK MANAGER') AND t.session_id<>@@spid
	  ORDER BY wait_duration_ms desc,t.blocking_session_id  DESC;
	
	WITH A AS(SELECT DISTINCT
	    r.session_id             AS spid,
	    r.percent_complete       AS [percent],
	    r.open_transaction_count AS open_trans,
	    r.[status],
	    r.reads,
	    r.logical_reads,
	    r.writes,
	    s.cpu,
	    DB_NAME(r.database_id)   AS [db_name],
	    s.[hostname],
		dmec.client_net_address,
	    s.[program_name],
	    s.loginame,
	    r.start_time,
	    r.wait_time,
	    r.last_wait_type,
	    r.blocking_session_id    AS blocking,
	    r.command,
	    (SELECT SUBSTRING(text, statement_start_offset / 2 + 1,
	            (CASE WHEN statement_end_offset = -1 THEN
	                    LEN(CONVERT(NVARCHAR(MAX),text)) * 2 
	                  ELSE statement_end_offset 
	                  END - statement_start_offset) / 2)
	      FROM sys.dm_exec_sql_text(r.sql_handle)) AS [statement],
	    t.[text],r.plan_handle,r.scheduler_id 
	  FROM sys.dm_exec_requests r
	  LEFT JOIN sys.dm_exec_connections dmec ON r.session_id = dmec.session_id
	    LEFT JOIN sys.sysprocesses s ON s.spid = r.session_id
	    OUTER APPLY sys.dm_exec_sql_text (r.sql_handle) t
	  WHERE (r.[status]<>'background' and r.command<>'TASK MANAGER') AND r.session_id <> @@spid and hostname<>'')
	
	SELECT A.spid,s.cpu_id,threads.threads,s.current_tasks_count current_tasks,s.runnable_tasks_count runnable_tasks,[percent],open_trans,A.[status],reads,logical_reads,writes,cpu,[db_name],[hostname],client_net_address
	,[program_name],loginame,start_time,wait_time,last_wait_type,blocking,command,[statement],[text],query_plan 
	FROM A A OUTER APPLY sys.dm_exec_query_plan (plan_handle) 
	LEFT JOIN sys.dm_os_schedulers s on(A.scheduler_id=s.scheduler_id) --выбираем данные по доступу к ЦП
	LEFT JOIN (SELECT  cpu_id,count(SThreads.os_thread_id) threads
	FROM sys.dm_os_threads AS SThreads  
	INNER JOIN sys.dm_os_schedulers s on(SThreads.scheduler_address=s.scheduler_address)
	GROUP BY cpu_id) threads ON(s.cpu_id=threads.cpu_id)
	ORDER BY spid ,wait_time DESC
	END;
	IF @Mode = 4
	BEGIN
	SELECT DISTINCT
	    r.session_id             AS spid,sh.cpu_id,threads.threads,sh.current_tasks_count current_tasks,sh.runnable_tasks_count runnable_tasks,
	    r.percent_complete       AS [percent],
	    r.open_transaction_count AS open_trans,
	    r.[status],
	    r.reads,
	    r.logical_reads,
	    r.writes,
	    s.cpu,
	    DB_NAME(r.database_id)   AS [db_name],
	    s.[hostname],
		dmec.client_net_address,
	    s.[program_name],
	    s.loginame,
	    r.start_time,
	    r.wait_time,
	    r.last_wait_type,
	    r.blocking_session_id    AS blocking,
	    r.command,
	   (SELECT SUBSTRING(text, statement_start_offset / 2 + 1,
	            (CASE WHEN statement_end_offset = -1 THEN
	                    LEN(CONVERT(NVARCHAR(MAX),text)) * 2 
	                  ELSE statement_end_offset 
	                  END - statement_start_offset) / 2)
	      FROM sys.dm_exec_sql_text(r.sql_handle)) AS [statement],
	    t.[text]
	  FROM sys.dm_exec_requests r
	  left join sys.dm_exec_connections dmec ON r.session_id = dmec.session_id
	    left JOIN sys.sysprocesses s ON s.spid = r.session_id
	    outer APPLY sys.dm_exec_sql_text (r.sql_handle) t
		LEFT JOIN sys.dm_os_schedulers sh on(r.scheduler_id=sh.scheduler_id) --выбираем данные по доступу к ЦП
	  LEFT JOIN (SELECT  cpu_id,count(SThreads.os_thread_id) threads
	FROM sys.dm_os_threads AS SThreads  
	INNER JOIN sys.dm_os_schedulers s on(SThreads.scheduler_address=s.scheduler_address)
	GROUP BY cpu_id) threads ON(sh.cpu_id=threads.cpu_id)
	  WHERE (r.[status]<>'background' and r.command<>'TASK MANAGER') AND r.session_id <> @@spid and hostname<>''
	  ORDER BY r.session_id ,r.wait_time DESC;
	END
END


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Мониториг sql процессов выполняемых в данный момент на сервере, блокировок процессов', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'Locks';

