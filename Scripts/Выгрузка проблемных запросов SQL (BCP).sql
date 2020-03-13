declare @path varchar(4000)='...' --каталог для выгрузки
 
select [text],sum(Duration/1000.0) Duration_sec,count(*) k
into #scripts
from [master].[dbo].[Hard_Queries]
group by [text]
 
--Оставляем только пользовательские запросы SELECT
delete from #scripts where [text] not like '%SELECT %' or [text] is null or [text] like  '%sys[.]%'
 
select top 50 [text]
into #upload
from #scripts order by Duration_sec desc,k desc
 
alter table #upload add id int identity primary key clustered
 
--Выгрузка в файлы
declare @SQL varchar(4000)
declare @i int=1
create table ##scripts(query_text nvarchar(max))
declare @S nvarchar(max)
 
while @i<=(select max(id) from #upload)
begin
    insert into ##scripts
    select [text]
    from #upload
    where id=@i
 
    set @S=(select query_text from ##scripts)
 
    --Для выгрузки Мы не используем постоянную таблицу, а глобальгую временную ##
    set @SQL='bcp ##scripts out '+@path+'Query_'+cast(@i as varchar(5))+'.sql -t, -c -T'
 
    exec xp_cmdshell @SQL
 
    truncate table ##scripts
 
    set @SQL=''
    set @i=@i+1
end
 
if object_id('tempdb..#scripts','U') is not null
drop table #scripts
if object_id('tempdb..#upload','U') is not null
drop table #upload
if object_id('tempdb..##scripts','U') is not null
drop table ##scripts
 
--если нужно просто выгрузить конкретные:
/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [creation_time]
      ,[last_execution_time]
      ,[execution_count]
      ,[CPU]
      ,[AvgCPUTime]
      ,[TotDuration]
      ,[AvgDur]
      ,[AvgIOLogicalReads]
      ,[AvgIOLogicalWrites]
      ,[AggIO]
      ,[AvgIO]
      ,[AvgIOPhysicalReads]
      ,[plan_generation_num]
      ,[AvgRows]
      ,[AvgDop]
      ,[AvgGrantKb]
      ,[AvgUsedGrantKb]
      ,[AvgIdealGrantKb]
      ,[AvgReservedThreads]
      ,[AvgUsedThreads]
      ,[query_text]
      ,[database_name]
      ,[object_name]
      ,[query_plan]
      ,[sql_handle]
      ,[plan_handle]
      ,[query_hash]
      ,[query_plan_hash]
  FROM [SRV].[inf].[vBigQuery]
  --where [query_hash] not in (0x1AADE5DC56150A93, 0xA1DCDCD0FEE2A76E, 0xBA79760FB10D45B4, 0x406F781B0EA47C27, 0x43AC465293F789F1, 0x4DA6385A6D029A6E, 0xE92FFE03031AA15E, 0xED05E739A651F2D8
                            --,0x9C0252414788B575, 0x9A8DDCC88EF11240, 0xC75C5BF0A41CAE99, 0xBC44CBE8E4CDEC2D)
  where [query_hash] in (0xC75C5BF0A41CAE99, 0xBC44CBE8E4CDEC2D)
  order by [AvgCPUTime] desc
 
  select *
  from #tbl
 
  --запулить один раз
  --alter table #tbl add id int identity primary key clustered
 
  --Выгрузка в файлы
declare @SQL varchar(4000);
declare @i int=1;
create table ##scripts(query_text nvarchar(max));
declare @S nvarchar(max);
 
declare @path varchar(4000)='...' --каталог для выгрузки
  
while @i<=(select max(id) from #tbl)
begin
    insert into ##scripts
    select [query_text]
    from #tbl
    where id=@i
  
    set @S=(select query_text from ##scripts)
  
    --Для выгрузки Мы не используем постоянную таблицу, а глобальгую временную ##
    set @SQL='bcp ##scripts out '+@path+'Query_'+cast(@i as varchar(5))+'.sql -t, -c -T'
  
    exec xp_cmdshell @SQL
  
    truncate table ##scripts
  
    set @SQL=''
    set @i=@i+1
end