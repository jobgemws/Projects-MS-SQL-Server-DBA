--к БД SRV
USE [SRV];
go
 
select coalesce(dp.[name], lg.[name]) as [LoginName],
       coalesce(dp.[create_date], [createdate]) as [CreateDate],
       coalesce(dp.[modify_date], [updatedate]) as [UpdateDate],
       case when ((dp.[type]='U') or (lg.[isntuser]=1)) then 1 else 0 end as [IsUserWindows],
       case when ((dp.[type]='G') or (lg.[isntgroup]=1)) then 1 else 0 end as [IsGroupWindows]
from sys.database_principals as dp
full outer join sys.syslogins as lg on dp.[name]=lg.[name]
where ((lg.[dbname] = 'SRV') or (lg.[dbname] is null) or ((lg.[dbname]='master') and (lg.[sysadmin]=1))) and ((lg.[hasaccess]=1) or (lg.[hasaccess] is null))
order by dp.[name] asc