---
DECLARE @kb_in_page numeric(11,2)=8+(96/1024.0)
DECLARE @available_physical_memory_Mb int
DECLARE @available_RAM_Percent numeric(4,1)
 
select @available_physical_memory_Mb=ceiling(available_physical_memory_kb/1024.0)
from sys.dm_os_sys_memory;
 
with os_schedulers as (select cpu_id,active_workers_count,load_factor
from sys.dm_os_schedulers
where [status]='VISIBLE ONLINE'),
Offline_cpu(offline_cpu) as (select count(1) offline_cpu
from sys.dm_os_schedulers
where [status]='VISIBLE OFFLINE' and cpu_id<=15 /*считаем пока условно что максимум 16 ядер*/)
 
select
    (select count(distinct session_id) 
        from sys.dm_exec_requests r
        where connection_id is not null) Active_queries,
    --Число пользовательских подключений (проверяем на периодах как меняется их число, идет ли сброс или накопление)
    (select count(distinct p.spid)
        from sys.sysprocesses p
        where  p.[program_name]<>''
        and p.lastwaittype NOT IN('XE_LIVE_TARGET_TVF','TRACEWRITE')) user_connections,
 
    (select count(distinct cpu_id)
        from os_schedulers
        where (active_workers_count in(0,1,2) and load_factor<7) /*повышенная нагрузка на ядро*/
        or (active_workers_count in(3,4,5) and load_factor in(0,1,2,3))
 
        /*повышенный фактор нагрузки*/) [easy_loaded_cores],
--Процент загруженных ядер доступных инстансу MS SQL (>50% загрузки)
 
    (select count(distinct cpu_id)
        from os_schedulers
        where (active_workers_count in(3,4,5,6,7,8) /*повышенная нагрузка на ядро*/ and load_factor in(4,5,6,7,8,9))
        or (active_workers_count>8 and load_factor<=2)
        /*повышенный фактор нагрузки*/) [middle_loaded_cores],
    (select count(distinct cpu_id)
        from os_schedulers
        where ((active_workers_count>8 and load_factor>3) /*повышенная нагрузка на ядро*/ or (active_workers_count<=8 and load_factor>9)  /*повышенный фактор нагрузки*/)) [highly_loaded_cores],
        CASE WHEN (select Offline_cpu from Offline_cpu)>0 then (select Offline_cpu from Offline_cpu) else 0 end Offline_cpu,
    (select datediff(SS,MIN(start_time),getdate()) SS
        from sys.dm_exec_requests
        where [connection_id] is not null
        and last_wait_type not in('XE_LIVE_TARGET_TVF','TRACEWRITE','PREEMPTIVE_OS_ENCRYPTMESSAGE')
        and command<>'UPDATE STATISTICS') [max_waiting_query_sec],
 
    @available_physical_memory_Mb Avail_RAM_Memory_Mb,
 
    (select CAST(SUM(granted_query_memory*@kb_in_page)/1024.0 AS INT) 
        from sys.dm_exec_requests
        where connection_id is not null) RAM_Queries_Mb,
    (select cast(sum(memory_usage*@kb_in_page) as int)
        from sys.dm_exec_sessions) RAM_Sessions_Mb,
    (select count(distinct blocking_session_id)
        from sys.dm_os_waiting_tasks
        where blocking_session_id is not null) [blocking_queries],
    isnull((select 1
                from sys.sysprocesses
                where lastwaittype='TRACEWRITE'),0) tracing