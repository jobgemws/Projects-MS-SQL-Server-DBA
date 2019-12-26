


  --Назначение: Производительность MS SQL.Вывод мониторинга. Масштабируемые данные по времени
  --Автор: Прилепа Б.А. - АБД
  --Создано: 12.01.2017. Изменено 28.05.2019
  --exec srv.GetScalling_monitor_db @t=1						--RAM - HDD (СТАТИСТИКА DESC)

  --exec srv.GetScalling_monitor_db @t=2						--(БД) Размеры баз данных, mdf и ldf файла
  --exec srv.GetScalling_monitor_db @t=22						--(БД) Свободное место в файлах mdf, ldf
  --exec srv.GetScalling_monitor_db @t=3						--(БД) RAM под БД
  --exec srv.GetScalling_monitor_db @t=5						--(БД) Затраты процессорного времени по базам данных (CPUtime)
  --exec srv.GetScalling_monitor_db @t=6,@DATABASE='Trucks',@status_session='running'			--(БД) Сессии на БД (можно и по имени хоста) --status: 'running','sleeping'
  --exec srv.GetScalling_monitor_db @t=7						--(БД) Текущие запросы выполняемые на сервере (sp_Locks)
  --exec srv.GetScalling_monitor_db @t=8			--(БД) Мониторинг блокировок и повисающих запросов, job-ов (sp_Locks 3)
  --exec srv.GetScalling_monitor_db @t=19                       --(БД) Кто активен и потребление ресурсов ([dbo].[sp_WhoIsActive_Admin])
  --exec srv.GetScalling_monitor_db @t=20,@DATABASE='',@tbl='transportmodel1cs'	--(БД) Статистика по запросам
  --exec srv.GetScalling_monitor_db @t=18,@DATABASE='MonopolySunTemp',@type_desc_object='FN',@Unloading=0 ,@TABLE='CustomCheckOrderSave'  --(БД) Статистика по запросам БД (хранимки)
  --exec srv.GetScalling_monitor_db @t=9,@DATABASE='MonopolySun',@DATE1='2019-05-28'			--(БЭКАПЫ PRD-SQL-SRV01-02) Мониторинг бэкапов (запросом)

  --exec srv.GetScalling_monitor_db @t=4,@DATABASE='MonopolySun',@ON_ALL_DATABASE=0,@TABLE='msTruckInOrder_OnOff_ToAgreement'	--(TABLES) Размеры таблиц (+ обращения), данные в них и индексы (Если БД нет, то ничего не выведет)
  --exec srv.GetScalling_monitor_db @t=21,@TABLE='msTruckInOrder_OnOff_ToAgreement',@like=1 --(иногда возвращает пусто или не полный набор, особенности отображения в sys) --ПОИСК ИСПОЛЬЗОВАНИЯ ОБЪЕКТА ПО ВСЕМ БАЗАМ
  --exec srv.GetScalling_monitor_db @t=21,@TABLE='Order',@DATABASE='Trucks',@like=0 --(иногда возвращает пусто или не полный набор, особенности отображения в sys) --ПОИСК ИСПОЛЬЗОВАНИЯ ОБЪЕКТА ПО ВСЕМ БАЗАМ
  --exec srv.GetScalling_monitor_db @t=21,@DATABASE='MonopolySun',@like=0 --использование БД в хранимых объектах
  --exec srv.GetScalling_monitor_db @t=21,@DATABASE='MonopolySun',@job=1 --И джобы рассматриваем
  --exec srv.GetScalling_monitor_db @t=10,@DATABASE='WialonBuffer',@TABLE='booking_histories' 		--(TABLES) Суммарная cтатистика чтений и записей по таблицам
  --exec srv.GetScalling_monitor_db @t=17,@DATABASE='SRV'				--(БД) индексы! Последние чтения из таблиц, по всем таблицам БД
  --exec srv.GetScalling_monitor_db @t=17,@DATABASE='MonopolySun',@TABLE='msOrder_ToAgreement'			--(БД) индексы! Последние чтения из таблиц, без указания таблицы выводится по всем таблицам

  --exec srv.GetScalling_monitor_db @t=10						--(БД) Суммарная cтатистика по базам данных чтение/запись (индексы)
  --exec srv.GetScalling_monitor_db @t=16						--(БД) Суммарная cтатистика по базам данных чтение/запись (системные счетчики)

  --exec srv.GetScalling_monitor_db @t=11		--(JOBS) Данные по выполнению заданий на сервере (job-ов) msdb.dbo.GetStatisticJobs
  --exec srv.GetScalling_monitor_db @t=12		--(WAITS) Мониторинг статистики по ожиданиям /*Очистить статистику DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR);*/

  --exec srv.GetScalling_monitor_db @t=13,@DATABASE='MonopolyDataMigration',@TABLE='Order'		--(INDEXES) Используемость индексов в БД, какие индексы можно убрать
  --exec srv.GetScalling_monitor_db @t=14,@DATABASE='MonopolySunTemp',@TABLE='transfer_Order'		--(INDEXES) Фрагментированность индексов
  --exec srv.GetScalling_monitor_db @t=14,@DATABASE='MonopolySunTemp',@TABLE='Order',@Index_Is_Detailed=1		--(INDEXES) Фрагментированность индексов
  --exec srv.GetScalling_monitor_db @t=15,@DATABASE='Trucks'			--(INDEXES) Перечень всех индексов

  CREATE   procedure [srv].[GetScalling_monitor_db] 
   @t					int			  = 0 /* См. выше* режимы просмотра*/
  ,@DATABASE			nvarchar(255) = N''
  ,@DATABASE_Unloading	nvarchar(255) = N''
  ,@DATE1				datetime	  = null
  ,@DATE2				datetime	  = N''
  ,@SERVER				nvarchar(255) = N''
  ,@TABLE				nvarchar(255) = N''
  ,@ON_ALL_DATABASE		int			  = 0
  ,@status_session		nvarchar(50)  = N''
  ,@type_desc_object	nvarchar(50)  = N''
  ,@Unloading			bit			  = 0 --выгрузка
  ,@Index_Is_Detailed	bit			  = 0 --'Detailed данные по уровням индексов', =1 просмотр нижних уровней может привести к высокой нагрузке на диск по чтениям
  ,@job					int			  = 0
  ,@like				int			  = 0 --Поиск в тексте stored objects по шаблону
  as
  begin
  set xact_abort on;
  set nocount on;
  --Общая процедура мониторинга SQL Server

  declare @servername nvarchar(255)=cast(SERVERPROPERTY(N'MachineName') as nvarchar(255));

  if @SERVER=0
  SELECT  @SERVER=@servername 

  /*@t=1 Чтения запись по БД - раз в 2 секунды, RAM - раз в минуту, HDD - раз в полчаса*/
  if @DATE1>@DATE2
  begin
	declare @DATE3 datetime
	set @DATE3=@DATE2
	set @DATE2=@DATE1
	set @DATE1=@DATE3
  end

  if @t=1 --Анализ свободного места на дисках и используемости RAM
  exec srv.Disk_RAM--проверка на текущий момент

  if @t=2 --Размеры баз данных
  SELECT  db,[file_name],[Size(Mb)],[SizeDB(Mb)], [All DBs Size(Mb)]=(case when id=1 then [All DBs Size(Mb)] else null end)
  ,[SizeData(Mb)]=(case when id=1 then [SizeData(Mb)] else null end)
  ,[SizeLog(Mb)]=(case when id=1 then [SizeLog(Mb)] else null end)
  from
  (SELECT  db,[file_name],[Size(Mb)],[SizeDB(Mb)],[All DBs Size(Mb)],sum(case when [type]=1 then [Size(Mb)] else 0 end) over (partition by 1) [SizeLog(Mb)],
  sum(case when [type]=0 then [Size(Mb)] else 0 end) over (partition by 1) [SizeData(Mb)],row_number() over (order by [SizeDB(Mb)] desc) id
  from
  (SELECT  b.name db,c.name [file_name],cast(sum(BytesOnDisk)/1024.0/1024.0 as numeric(12,3)) [Size(Mb)],cast(sum(BytesOnDisk/1024.0/1024.0) over (partition by b.name) as numeric(12,3)) [SizeDB(Mb)],
  cast(sum(BytesOnDisk/1024.0/1024.0) over (partition by 1) as numeric(12,3)) [All DBs Size(Mb)],c.[type]
  from ::fn_virtualfilestats(NULL, NULL) a inner join (SELECT  * from sys.databases where database_id>4) b on(a.DbId=b.database_id)
  inner join  master.sys.master_files c on(a.DbId=c.database_id and  a.FileId=c.[file_id])
  where b.name=@DATABASE or @DATABASE=''
  group by b.name,c.name,BytesOnDisk,c.[type]) a) a
  order by 4 desc

  --Объем RAM выделенного под разные базы данных
  if @t=3
  begin
	if object_id('tempdb..#SUMMA','U') is not null
	drop table #SUMMA

	SELECT  count(*)AS cached_pages_count, count(*)/128  [Size (Mb)]
		,CASE database_id
			WHEN 32767 THEN 'ResourceDb'
			ELSE db_name(database_id)
			END AS Database_name
			into #SUMMA
	FROM sys.dm_os_buffer_descriptors
	GROUP BY db_name(database_id) ,database_id

	SELECT  Database_name,[Size (Mb)],cast(round(([Size (Mb)]/cast(sum([Size (Mb)]) over (partition by 1) as float))*100,2) as numeric(12,2)) [RAM (%)]
	from #SUMMA
	ORDER BY [Size (Mb)] DESC
	if object_id('tempdb..#SUMMA','U') is not null
	drop table #SUMMA
  end

  if @t=4 and DB_ID(@DATABASE) is not null --Размеры таблиц, данные в них и индексы
  begin
  declare @SS varchar(max)
  
  if @ON_ALL_DATABASE=1
  set @SS='USE ['+@DATABASE+']
  declare @id	int,@pages	bigint,@reservedpages  bigint,@usedpages  bigint
	SELECT  @reservedpages = sum(a.total_pages),
		@usedpages = sum(a.used_pages),
		@pages = sum(CASE
					When it.internal_type IN (202,204,207,211,212,213,214,215,216,221,222,236) Then 0
					When a.type <> 1 and p.index_id < 2 Then a.used_pages
					When p.index_id < 2 Then a.data_pages
					Else 0 END)
	from sys.partitions p join sys.allocation_units a on p.partition_id = a.container_id
		left join sys.internal_tables it on p.object_id = it.object_id
SELECT  @reservedpages = @reservedpages + sum(isnull(reserved_page_count,0)),@usedpages = @usedpages + sum(isnull(used_page_count,0))
		FROM sys.dm_db_partition_stats p, sys.internal_tables it
		WHERE p.object_id = it.object_id;
	select [reserved(Mb)] = cast((@reservedpages * 8192) / (1024.0*1024.0) as numeric(12,2)),[data(Mb)] = cast((@pages * 8192) / (1024.0*1024.0) as numeric(12,2)),[index_size(Mb)] = cast(((@usedpages - @pages) * 8192) / (1024.0*1024.0) as numeric(12,2)),[unused(Mb)] = cast(((@reservedpages - @usedpages) * 8192) / (1024.0*1024.0) as numeric(12,2))'

  begin try	
		print @SS
		exec (@SS)	
  end try
  begin catch
		select ERROR_MESSAGE() ERR_MSG
  end catch

  declare @sql varchar(max)=''

  set @sql='
		USE ['+@DATABASE+']
		declare @table table(
		name nvarchar(255),
		[rows] bigint,
		reserved nvarchar(255),
		data nvarchar(255),
		index_size nvarchar(255),
		unused nvarchar(255),id int identity)
		DECLARE @name nvarchar(255)
		DECLARE SysCur CURSOR LOCAL FOR SELECT  ''[''+b.name+''].[''+a.name+'']'' as name 
		FROM sys.objects a inner join sys.schemas b on(a.schema_id=b.schema_id)
		WHERE type=''U'' and (a.name='''+@TABLE+''' or '''+@TABLE+'''='''')
		OPEN SysCur
		FETCH NEXT FROM SysCur INTO @name
		WHILE @@FETCH_STATUS=0 
		BEGIN
			insert into @table(name,[rows],reserved,data,index_size,unused)
			exec sp_spaceused @name 
			update @table
			set name=@name
			where id=(select top 1 id from @table order by id desc)
		FETCH NEXT FROM SysCur INTO @name
		END
		CLOSE SysCur
		DEALLOCATE SysCur
		declare @clean_table table(
		name nvarchar(255),
		[rows] int,
		[reserved(Kb)] int,
		[data(Kb)] int,
		[index_size(Kb)] int,
		[unused(Kb)] int)
		insert into @clean_table([name],[rows],[reserved(Kb)],[data(Kb)],[index_size(Kb)],[unused(Kb)])
		SELECT  cast(name as nvarchar(255)),cast([rows] as bigint),cast(replace(reserved,'' KB'','''') as bigint),cast(replace(data,'' KB'','''') as bigint),
		cast(replace(index_size,'' KB'','''') as bigint),cast(replace(unused,'' KB'','''') as bigint) from @table
		declare @TB table(srv nvarchar(255),DBName nvarchar(255),tbl nvarchar(255),Reads bigint,Writes bigint, [Reads@Writes] bigint,SampleDays numeric(20,5),SampleSecons bigint)
		insert into @TB(srv,DBName,tbl,Reads,Writes,[Reads@Writes],SampleDays,SampleSecons)
			SELECT   cast(SERVERPROPERTY(N''MachineName'') as nvarchar(255)) AS ServerName,
				DB_NAME() AS DBName,
				''[''+s.name+''].[''+ob.name+'']'' AS TableName ,
				SUM(ddius.user_seeks + ddius.user_scans+ddius.user_lookups) AS Reads ,
				SUM(ddius.user_updates) AS Writes,
				SUM(ddius.user_seeks + ddius.user_scans+ddius.user_lookups
					+ ddius.user_updates) AS [Reads&Writes],(SELECT DATEDIFF(s,create_date,GETDATE())/86400.0
				  FROM master.sys.databases WHERE name = ''tempdb'') AS SampleDays,( SELECT DATEDIFF(s, create_date, GETDATE()) AS SecoundsRunnig FROM master.sys.databases WHERE name = ''tempdb'') AS SampleSeconds
		FROM    sys.dm_db_index_usage_stats ddius
				INNER JOIN sys.indexes i ON ddius.object_id=i.object_id AND i.index_id=ddius.index_id
				INNER JOIN sys.objects ob ON(ddius.object_id=ob.object_id) 
				INNER JOIN sys.schemas s ON(ob.schema_id=s.schema_id) 
		WHERE    OBJECTPROPERTY(ddius.object_id,''IsUserTable'') = 1 AND ddius.database_id = DB_ID() AND (''''='''' or OBJECT_NAME(ddius.object_id)='''')
		GROUP BY ''[''+s.name+''].[''+ob.name+'']''		
		SELECT  ca.name tbl, max([rows]) [rows],max([reserved(Kb)]) [reserved(Kb)],max([data(Kb)]) [data(Kb)],max([index_size(Kb)]) [index_size(Kb)]
		,max([unused(Kb)]) [unused(Kb)],max(cast([reserved(Kb)]/1024.0 as numeric(12,3))) as [data(Mb)],max(isnull(Reads,0)) Reads,max(isnull(Writes,0)) Writes
		,max(isnull([Reads@Writes],0)) [Reads@Writes],max(last_user_update) last_user_update,max(last_user_seek) last_user_seek,max(last_user_scan) last_user_scan,max(last_user_lookup) last_user_lookup,
		max(SampleDays) SampleDays,(SELECT  max(create_date) as start_statistic from sys.databases where name=''tempdb'') start_statistic
		from @clean_table ca LEFT OUTER JOIN @TB cb ON(ca.name=cb.tbl) LEFT OUTER JOIN (SELECT ''[''+sc.name+''].[''+b.name+'']'' tbl,last_user_update,last_user_seek,
		last_user_scan,last_user_lookup from sys.dm_db_index_usage_stats a inner join ['+@DATABASE+'].sys.objects b on(a.object_id=b.object_id and db_NAME(a.database_id)='''+@DATABASE+''')
		inner join ['+@DATABASE+'].sys.schemas sc on(b.schema_id=sc.schema_id) left outer join ['+@DATABASE+'].sys.indexes ind on(a.index_id=ind.index_id and a.object_id=ind.object_id)
	    where db_NAME(a.database_id)='''+@DATABASE+''') c ON(ca.name=c.tbl) group by ca.name order by 8,9'
		
		begin try	
				print @sql
				exec (@sql)
		end try
		begin catch
				select ERROR_MESSAGE() ERR_MSG
		end catch
  end
  if @t=5 --Затраты процессорного времени по базам данных
	WITH DB_CPU_Stats
	AS
	(SELECT  DatabaseID, DB_Name(DatabaseID) AS [DatabaseName], SUM(total_worker_time) AS [CPU_Time_Ms]
	FROM sys.dm_exec_query_stats AS qs
	CROSS APPLY (SELECT  CONVERT(int, value) AS [DatabaseID]
				 FROM sys.dm_exec_plan_attributes(qs.plan_handle)
				 WHERE attribute = N'dbid') AS F_DB
	GROUP BY DatabaseID)
	SELECT  ROW_NUMBER() OVER(ORDER BY [CPU_Time_Ms] DESC) AS [row_num],
		  DatabaseName, [CPU_Time_Ms],
		  CAST([CPU_Time_Ms] * 1.0 / SUM([CPU_Time_Ms]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPUPercent]
	FROM DB_CPU_Stats
	WHERE DatabaseID not in(1,3,4) -- system databases
	AND DatabaseID <> 32767 -- ResourceDB
	and DatabaseName<>'master'
	ORDER BY row_num OPTION (RECOMPILE);

	if @t=6 --Сессии на БД
	SELECT   distinct a.session_id,[host_name],p.cpu,p.waittime,p.lastwaittype,client_net_address,local_net_address,a.[program_name],
	login_name,a.[status],last_request_start_time,
	last_request_end_time,--[lock_timeout],
	original_login_name,--db_name(database_id) DB,
	cpu_time,total_scheduled_time,total_elapsed_time
	FROM    sys.dm_exec_sessions a left outer join sys.dm_exec_connections b on(a.session_id=b.session_id)
	left outer join sys.sysprocesses p on(a.session_id=p.spid)
	WHERE   database_id > 0
	AND ((DB_NAME(dbid)=@DATABASE or @DATABASE='' or cast(p.spid as nvarchar(5))=@DATABASE) or (ltrim(rtrim([host_name]))=@DATABASE or @DATABASE=''))
	and (@status_session='' or a.[status]=@status_session)
	order by [host_name],a.session_id,p.waittime desc,cpu desc

	if @t=7 --Текущие запросы
	exec srv.Locks 4;

	if @t=8 --Мониторинг блокировок
	exec srv.Locks 3;

	if @t=9 --ИНФА по бэкапам
	begin
		set @DATE1=case when @DATE1='' then NULL else @DATE1 end
		exec srv.Backups_info @DATE=@DATE1,@DATABASE=@DATABASE
	end

	if @t=10 --Статистика чтений и записей по таблицам
	begin
	if @DATABASE<>''
	begin
	declare @sql2 nvarchar(max)=''	

	set @sql2='
	USE ['+@DATABASE+']
	SELECT   cast(SERVERPROPERTY(N''MachineName'') as nvarchar(255)) AS ServerName ,
				DB_NAME() AS DBName ,
				s.name+''.''+ob.name AS TableName ,
				SUM(ddius.user_seeks + ddius.user_scans + ddius.user_lookups)
																	   AS  Reads ,
				SUM(ddius.user_updates) AS Writes ,
				SUM(ddius.user_seeks + ddius.user_scans + ddius.user_lookups
					+ ddius.user_updates) AS [Reads&Writes],
				( SELECT     DATEDIFF(s, create_date, GETDATE()) / 86400.0
				  FROM      master.sys.databases
				  WHERE     name = ''tempdb''
				) AS SampleDays ,
				( SELECT     DATEDIFF(s, create_date, GETDATE()) AS SecoundsRunnig
				  FROM      master.sys.databases
				  WHERE     name = ''tempdb''
				) AS SampleSeconds
		FROM    sys.dm_db_index_usage_stats ddius
				INNER JOIN sys.indexes i ON ddius.object_id = i.object_id
											 AND i.index_id = ddius.index_id
				INNER JOIN sys.objects ob ON(ddius.object_id=ob.object_id) 
				INNER JOIN sys.schemas s ON(ob.schema_id=s.schema_id) 
		WHERE    OBJECTPROPERTY(ddius.object_id, ''IsUserTable'') = 1
				AND ddius.database_id = DB_ID()
				AND ('''+@TABLE+'''='''' or OBJECT_NAME(ddius.object_id)='''+@TABLE+''')
		GROUP BY s.name+''.''+ob.name
		ORDER BY Reads,Writes'
		begin try	
				print @sql2
				exec sp_executesql @sql2	
		end try
		begin catch
				print @sql
				select ERROR_MESSAGE() ERR_MSG
		end catch

	end
	if @DATABASE=''
	begin
		DECLARE @TBL TABLE([server] nvarchar(255),db nvarchar(255),Reads bigint,Writes bigint,[Reads&Writes] bigint,SampleDays numeric(12,3),SampleSeconds int)
		DECLARE @name nvarchar(255)=''
		declare @sql_10 nvarchar(max)=''
		DECLARE SysCur CURSOR LOCAL FOR SELECT  name FROM sys.databases
		OPEN SysCur
		FETCH NEXT FROM SysCur INTO @name
		WHILE @@FETCH_STATUS=0 BEGIN
		set @sql_10='
			USE ['+@name+']
			SELECT   cast(SERVERPROPERTY(N''MachineName'') as nvarchar(255)) AS ServerName ,
					DB_NAME() AS DBName ,
					SUM(ddius.user_seeks + ddius.user_scans + ddius.user_lookups)
																		   AS  Reads ,
					SUM(ddius.user_updates) AS Writes ,
					SUM(ddius.user_seeks + ddius.user_scans + ddius.user_lookups
						+ ddius.user_updates) AS [Reads&Writes] ,
					( SELECT     DATEDIFF(s, create_date, GETDATE()) / 86400.0
					  FROM      master.sys.databases
					  WHERE     name = ''tempdb''
					) AS SampleDays ,
					( SELECT     DATEDIFF(s, create_date, GETDATE()) AS SecoundsRunnig
					  FROM      master.sys.databases
					  WHERE     name = ''tempdb''
					) AS SampleSeconds
			FROM    sys.dm_db_index_usage_stats ddius
					INNER JOIN sys.indexes i ON ddius.object_id = i.object_id
												 AND i.index_id = ddius.index_id
			WHERE    OBJECTPROPERTY(ddius.object_id, ''IsUserTable'') = 1
					AND ddius.database_id = DB_ID()'
		insert into @TBL([server],db,Reads,Writes,[Reads&Writes],SampleDays,SampleSeconds)
		exec sp_executesql @sql_10
		FETCH NEXT FROM SysCur INTO @name
		END
		CLOSE SysCur
		DEALLOCATE SysCur

		--Вывод данных Reads/Writes по индексам
		SELECT  [server],db,Reads,Writes,[Reads&Writes]
		,cast((Reads/cast(sum(Reads) over (partition by 1) as float)*100) as numeric(12,3)) [Reads(%)]
		,cast((Writes/cast(sum(Writes) over (partition by 1) as float)*100) as numeric(12,3)) [Writes(%)]
		,cast(([Reads&Writes]/cast(sum([Reads&Writes]) over (partition by 1) as float)*100) as numeric(12,3)) [Reads&Writes(%)]
		,SampleDays,SampleSeconds 
		FROM @TBL order by [Reads&Writes] desc,Writes desc,Reads desc

	end
	end
	
	if @t=11
	--Данные по выполнению заданий на сервере (job-ов)
	exec srv.GetStatisticJobs

	if @t=12
	--Мониторинг статистики по sql ожиданиям
	exec srv.Get_Statistic_Waits

	if @t=13 --используемость индексов в БД, какие индексы можно убрать
	begin
	declare @INDEX nvarchar(max)
	set @INDEX='
	USE ['+@DATABASE+']
	SELECT  DB_NAME() БД,
	 o.name AS ObjectName
	 , i.name AS IndexName
	 , i.index_id AS IndexID
	 , dm_ius.user_seeks AS UserSeek
	 , dm_ius.user_scans AS UserScans
	 , dm_ius.user_lookups AS UserLookups
	 , dm_ius.user_updates AS UserUpdates
	 ,last_user_seek
	 ,last_user_scan
	 ,last_user_lookup
	 ,last_user_update
	 , p.TableRows
	 , ''DROP INDEX '' + QUOTENAME(i.name)
	 + '' ON '' + QUOTENAME(s.name) + ''.'' + QUOTENAME(OBJECT_NAME(dm_ius.OBJECT_ID)) AS ''drop statement''
	 FROM sys.dm_db_index_usage_stats dm_ius
	 INNER JOIN sys.indexes i ON i.index_id = dm_ius.index_id AND dm_ius.OBJECT_ID = i.OBJECT_ID
	 INNER JOIN sys.objects o ON dm_ius.OBJECT_ID = o.OBJECT_ID
	 INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
	 INNER JOIN (SELECT  SUM(p.rows) TableRows, p.index_id, p.OBJECT_ID
	 FROM sys.partitions p GROUP BY p.index_id, p.OBJECT_ID) p
	 ON p.index_id = dm_ius.index_id AND dm_ius.OBJECT_ID = p.OBJECT_ID
	 WHERE OBJECTPROPERTY(dm_ius.OBJECT_ID,''IsUserTable'') = 1
	 AND dm_ius.database_id = DB_ID()
	 AND i.type_desc in(''clustered'', ''nonclustered'')
	 AND i.is_unique_constraint = 0
	 AND (o.name='''+@TABLE+''' or '''+@TABLE+'''='''')
	 ORDER BY (dm_ius.user_seeks + dm_ius.user_scans + dm_ius.user_lookups) ASC'

		begin try	
				exec sp_executesql @INDEX	
		end try
		begin catch
				print @INDEX
				select ERROR_MESSAGE() ERR_MSG
		end catch
	 end

	 if @t=14 --Фрагментированность индексов для БД
	 begin
	 --Контэйнер сбора фрагментированности по индексу
	 DECLARE @FRAG nvarchar(max)

		set @FRAG='
		USE ['+@DATABASE+']

	    SELECT  TOP  10000000000 DB_NAME() БД,b.object_id,c.name+''.''+b.name Таблица,
		s.[index],index_type_desc Тип_индекса,
		alloc_unit_type_desc Расположение,
		round(avg_fragmentation_in_percent,2) [Фрагментированность(%)],
		fragment_count Фрагментов,
		page_count Страниц_данных,
		avg_fragment_size_in_pages [Фрагменты/страницы]
		FROM sys.dm_db_index_physical_stats(DB_ID(), '+case when len(@TABLE)>0 then 'cast(object_id('''+@TABLE+''',''U'') as varchar(50))' else 'NULL' end+', NULL, NULL, '+case when @Index_Is_Detailed=0 then 'NULL' else '''DETAILED''' end+') a inner join
		sys.objects b on(a.object_id=b.object_id)
		inner join sys.schemas c on(b.schema_id=c.schema_id)
		left join 
		(SELECT  index_id id,name [index],[object_id] from sys.indexes) s on(b.object_id=s.[object_id] and a.[index_id]=s.id)
		WHERE alloc_unit_type_desc=''IN_ROW_DATA'' and ('''+@TABLE+'''='''' or b.name='''+@TABLE+''')
		order by c.name+''.''+b.name'

		begin try
				print @FRAG
				exec sp_executesql @FRAG
		end try
		begin catch
				select ERROR_MESSAGE () err_msg
		end catch
     end

	 if @t=15 --Все индексы в БД
	 begin
	 declare @IND nvarchar(4000)=''
	 set @IND=   
	 'USE ['+@DATABASE+']
	  declare @indexes table(ServerName nvarchar(255),[DB_Name] nvarchar(255),TableName nvarchar(255),IndexName nvarchar(255),type_desc nvarchar(255),[Индексов] int)
		insert into @indexes
		SELECT   cast(SERVERPROPERTY(N''MachineName'') as nvarchar(255)) AS ServerName ,
				DB_NAME() AS [DB_Name] ,
				o.Name AS TableName ,
				i.Name AS IndexName, i.type_desc,COUNT(*) OVER (PARTITION BY o.Name ) [Индексов]
		FROM    sys.objects o
				LEFT JOIN sys.indexes i ON o.object_id = i.object_id
		WHERE   o.Type = ''U'' 
				AND LEFT(i.Name, 1) <> ''_'' 

		SELECT  a.*,(case when b.TableName is not null then 1 else 0 end) [ExistsClustered] FROM @indexes a left join (SELECT  TableName from @indexes where type_desc=''CLUSTERED'') b 
		on(a.TableName=b.TableName)
		ORDER BY a.[Индексов] DESC,a.TableName '

		begin try
				print @IND
				exec sp_executesql @IND
		end try
		begin catch
				select ERROR_MESSAGE () err_msg
		end catch
	end
	if @t=16
	--Статистика чтений, записей по файлам
	  SELECT  db,NumberReads,NumberWrites
	  ,cast(NumberReads/(cast(sum(NumberReads) over (partition by 1) as float))*100 as numeric(12,3)) [NumberReads(%)]
	  ,cast(NumberWrites/(cast(sum(NumberWrites) over (partition by 1) as float))*100 as numeric(12,3)) [NumberWrites(%)]
	  ,(cast(sum(NumberReads) over (partition by 1)/cast(sum(NumberWrites+NumberReads) over (partition by 1) as float) as numeric(12,4)))*100 [% reads]
	  ,(cast(sum(NumberWrites) over (partition by 1)/cast(sum(NumberWrites+NumberReads) over (partition by 1) as float) as numeric(12,4)))*100 [% writes]
	  from
	  (SELECT  b.name db,sum(NumberReads) NumberReads,sum(NumberWrites) NumberWrites
	  from ::fn_virtualfilestats(NULL, NULL) a inner join sys.databases b on(a.DbId=b.database_id)
	  inner join  master.sys.master_files c on(a.DbId=c.database_id and  a.FileId=c.[file_id])
	  where b.name=@DATABASE or @DATABASE=''
	  group by b.name) a
	  order by 4 desc,5 desc

	  if @t=17
	  begin
	  declare @sql_17 nvarchar(4000)=''

	  set @sql_17='
	  use ['+@DATABASE+']
	  SELECT  db_NAME(a.database_id) db,b.name tbl,/*a.object_id,ind.name [index],*/sum(user_seeks) user_seeks,sum(user_scans) user_scans,sum(user_lookups) user_lookups,sum(user_updates) user_updates,max(last_user_update) last_user_update,max(last_user_seek) last_user_seek,max(last_user_scan) last_user_scan,max(last_user_lookup)  last_user_lookup
	  from sys.dm_db_index_usage_stats a inner join sys.objects b on(a.object_id=b.object_id)
	  left outer join sys.indexes ind on(a.index_id=ind.index_id and a.object_id=ind.object_id)
	  where db_NAME(a.database_id)='''+@DATABASE+''' and ('''+@TABLE+'''='''' or b.name='''+@TABLE+''')
	  group by db_NAME(a.database_id),b.name
	  order by 3,4,5,6'

	  	begin try
				print @sql_17
				exec sp_executesql @sql_17
		end try
		begin catch
				select ERROR_MESSAGE () err_msg
		end catch
	  end

	  if @t=18
	  begin
	  declare @V nvarchar(max)

	  declare @ON_ALL_DATABASE_sql nvarchar(2000)=''
	  set @ON_ALL_DATABASE_sql=case when @Unloading=0 then '' when @Unloading=1 then 'into ['+@DATABASE_Unloading+'].[dbo].['+@DATABASE+'_'+@type_desc_object+'_'+replace(cast(cast(getdate() as date) as nvarchar(50)),'-','')+']' end
	  declare @ON_ALL_DATABASE_sql2 nvarchar(2000)=''
	  set @ON_ALL_DATABASE_sql2=case when @Unloading=1 
	  then 'if object_id(''master.dbo.['+@DATABASE+'_'+@type_desc_object+'_'+replace(cast(cast(getdate() as date) as nvarchar(50)),'-','')+']'',''U'') is not null
	  drop table ['+@DATABASE+'_'+@type_desc_object+'_'+replace(cast(cast(getdate() as date) as nvarchar(50)),'-','')+']
	  ' else '
	  ' end

	  set @V=@ON_ALL_DATABASE_sql2+'
		WITH P AS (		SELECT  sum(qs.execution_count) execution_count,max(qs.last_execution_time) last_execution_time,
		cast(sum(qs.total_worker_time)/1000.0 as int) total_worker_time,sum(qs.total_rows) total_rows,sum(qs.total_physical_reads)+sum(qs.total_logical_reads) total_reads
		,obj.name obj,obj.type_desc,isnull(db.name,'''+@DATABASE+''') DB
		,cast(datediff(ss,(SELECT  create_date from sys.databases where name=''tempdb''),getdate())/(60.0*60.0*24.0) as numeric(11,2))  [Days]
		'+@ON_ALL_DATABASE_sql+'		
		FROM sys.dm_exec_query_stats qs
		CROSS APPLY sys.dm_exec_sql_text (qs.sql_handle) t 
		INNER JOIN sys.databases db  (nolock) on(t.dbid=db.database_id and db.name=N'''+@DATABASE+''')
		INNER JOIN ['+@DATABASE+'].sys.objects obj  (nolock) on(t.objectid=obj.object_id)
		
		where ('''+@type_desc_object+'''='''' or obj.type_desc='''+@type_desc_object+''' or obj.type='''+@type_desc_object+''') and ('''+@TABLE+'''='''' or obj.name='''+@TABLE+''')
		and ('''+@TABLE+'''='''' or obj.name='''+@TABLE+''' or obj.name='''+@TABLE+''') and left(obj.name,7)<>''Obsolet''
		group by t.[text],db.name,obj.name,obj.type_desc)

		SELECT execution_count,last_execution_time,total_worker_time,total_rows,total_reads,
		obj,[type_desc],DB,[Days]
		FROM P
		UNION
		SELECT NULL,NULL,NULL,NULL,NULL,[name] COLLATE Cyrillic_General_CI_AS,obj2.type_desc COLLATE Cyrillic_General_CI_AS,null,null 
		from ['+@DATABASE+'].sys.objects obj2 where 
			('''+@type_desc_object+'''='''' or obj2.type_desc='''+@type_desc_object+''' or obj2.type='''+@type_desc_object+''') and ('''+@TABLE+'''='''' or obj2.name='''+@TABLE+''')
		and ('''+@TABLE+'''='''' or obj2.name='''+@TABLE+''' or obj2.name='''+@TABLE+''') and left(obj2.name,7)<>''Obsolet''
		order by 1 desc'

		begin try
				exec sp_executesql @V
		end try
		begin catch
				select ERROR_MESSAGE() ERR_MSG
		end catch

	  end
	  if @t=19 --Кто активен и потребление ресурсов
	  begin
	  exec [srv].[Used_resouces_by_sessions]

	  exec [dbo].[sp_WhoIsActive_Admin]
	  end
	  if @t=20
	  begin
	  IF OBJECT_ID('tempdb..#temp_stat','U') IS NOT NULL
	  drop table #temp_stat

		SELECT  distinct TOP  50 --top 2000
		 db.name db,SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1,
		((CASE qs.statement_end_offset
		WHEN -1 THEN DATALENGTH(qt.TEXT)
		ELSE qs.statement_end_offset
		END - qs.statement_start_offset)/2)+1) as script, 
		qs.execution_count,plan_handle,total_worker_time
		into #temp_stat
		FROM sys.dm_exec_query_stats qs
		CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
		LEFT JOIN sys.databases db on(qt.dbid =db.database_id)
		ORDER BY total_worker_time DESC, execution_count DESC

		SELECT  TOP  100 db,script,execution_count,total_worker_time,query_plan from #temp_stat qs
		CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
		where left(script,40) not in('SELECT  distinct referenced_database_name')
		and left(script,19) not in('SELECT  DB_NAME() DB')
		and (db=@DATABASE or @DATABASE='') and (script like ''+'%'+@TABLE+'%'+'' or @TABLE='')
		order by execution_count desc

	  IF OBJECT_ID('tempdb..#temp_stat','U') IS NOT NULL
	  drop table #temp_stat
	  end
	  if @t=21 and @like=1
	  begin
			if len(@t)>0 and @DATABASE=''
			exec srv.FindObject @name=@TABLE,@like=@like
			if len(@DATABASE)>0
			exec srv.All_Find_Ref_Other_DB @DBB=@DATABASE
	  end
	  if @t=21 and @like=0 and @DATABASE=''
	  begin
			exec [srv].[FindObj] @find=@TABLE
	  end
	  if @t=21 and @like=0 and 1=(SELECT  count(1) from sys.databases where name=@DATABASE)
	  begin
			exec [srv].[Depend_objects] @DB=@DATABASE,@obj=@TABLE,@job=@job
	  end
	  if @t=22
	  exec [srv].[DB_USE_DATASPACE] @DATABASE
  end

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Общая процедура мониторинга SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'GetScalling_monitor_db';

