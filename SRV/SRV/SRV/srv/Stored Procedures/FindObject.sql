

--exec [dbo].[sp_FindObject] @name='ms_Mail_Prepare&Send_CheckMove'
--exec [dbo].[sp_FindObject] @name='Operation',@like=1
CREATE   proc [srv].[FindObject]
	@name nvarchar(255)=N'sp_tc_search_code' --exec master.dbo.sp_FindObject @name='agreement_requests'
	/*,@name2 varchar(255)=''
	,@name3 varchar(255)='esbsrv02'
	,@name4 varchar(255)='esbsrv03'
	,@name5 varchar(255)='esbsrv04'*/
	,@mult int=0
	,@like int=1
as
begin
	set nocount on;
	set xact_abort on;
	--Хранимая процедура глобального поиска объекта, в том числе его использорвания в SQL JOB

	if (object_id(N'tempdb..#t', N'U') is not null)	drop table #t;

	declare @sql nvarchar(4000)=N'';
	declare @sql2 nvarchar(4000)=N'';

	if @like=0
	begin
		declare @P nvarchar(max)=N'';

		declare @table table (
							   referenced_database_name nvarchar(255),
							   DB nvarchar(255),
							   referenced_entity_name nvarchar(255),
							   type_desc_obj nvarchar(255),
							   ref_obj nvarchar(255),
							   [type_desc] nvarchar(255)
							 );

		set @P=N'use [?]
		select distinct referenced_database_name referenced_database_name,db_name() DB,referenced_entity_name,b.type_desc type_desc_obj,c.name ref_obj,c.type_desc
		from sys.sql_expression_dependencies a 
		LEFT JOIN sys.objects b on(a.referenced_id=b.object_id)
		LEFT JOIN sys.objects c on(a.referencing_id=c.object_id)
		where (referenced_entity_name='''+@name+N''' or c.name='''+@name+N''')';

		insert into @table (referenced_database_name, DB, referenced_entity_name, type_desc_obj, ref_obj, [type_desc])
		exec master..sp_msforeachdb @P;

		select referenced_database_name, referenced_entity_name, type_desc_obj, DB, ref_obj, [type_desc]
		from @table
		order by 1,2,3;
	end

	declare @tbl table (DB nvarchar(255), [type] nvarchar(50), [name] nvarchar(255), [type_desc] nvarchar(255));

	/*if @mult=1
	set @sql='USE [?]
	select DB_NAME() DB,''В тексте'',a.name name,a.type_desc from sys.objects a (nolock) inner join sys.sql_modules b (nolock) on(a.object_id=b.object_id) where b.[definition] like ''%'+@name+'%''
	or b.[definition] like ''%'+@name2+'%'' or b.[definition] like ''%'+@name3+'%'' or b.[definition] like ''%'+@name4+'%'' or b.[definition] like ''%'+@name5+'%'''*/

	if ((@mult=0) and (@like=1))
	begin
		set @sql=N'USE [?]
		select DB_NAME() DB,''В тексте'',a.name name,a.type_desc from sys.objects a (nolock) inner join sys.sql_modules b (nolock) on(a.object_id=b.object_id) 
		where a.[type] in(''P'',
		''V'',
		''U'',
		''IF'',
		''FN'',
		''TF'',
		''TR'') and b.[definition] like '''+'%'+@name+N'%'+'''
		union
		select DB_NAME() DB,''Столбец'',TABLE_NAME COLLATE Cyrillic_General_CI_AS,''Таблица'' type_desc from INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME='''+@name+N'''';
	end

	if ((@mult=0) and (@like=0))
	begin
		set @sql=N'USE [?]
		select DB_NAME() DB,''Столбец'',TABLE_NAME COLLATE Cyrillic_General_CI_AS,''Таблица'' type_desc from INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME='''+@name+N'''';
	end

	if @like=1
		insert into @tbl (DB, [type], [name], [type_desc])
		exec sp_Msforeachdb @sql;

	if @like=0
	begin
		set @sql2=N'USE [?]
		select DB_NAME() DB,''Название'',name name,type_desc from sys.objects where [name]='''+@name+N'''';

		insert into @tbl (DB, [type], [name], [type_desc])
		exec sp_Msforeachdb @sql2;
	end

		select distinct * 
		into #t
		from @tbl
		where DB not in (N'', N'master', N'msdb', N'monitor_performance', N'tempdb') 
		and [name] not like N'%_New'
		and [name] not like N'%_p'
		and [name] not like N'%_Test'
		and [name] not like N'%copy'
		and [name] not like N'%Old'
		and [name] not like N'%[0-9][0-9][0-9][0-9]%' 
		and [name] not like N'Obsolet%'
		and [name] not like N'DELETE%';


		select DB, [type], [name], [type_desc], job, command, [enabled]--,convert(date,last_run_date,104) last_run_date,left(last_run_time,2)+':'+right(left(last_run_time,4),2)+':'+right(last_run_time,2) last_run_time 
		from #t as a
		LEFT OUTER JOIN (
						 select a.[name] as job, b.command ,a.[enabled]--,cast(b.last_run_date as varchar(50)) last_run_date,cast(last_run_time as varchar(50)) last_run_time 
						 from msdb..sysjobs as a
						 inner join msdb..sysjobsteps as b on (a.job_id=b.job_id)
						) as b on (b.command like N''+N'%'+a.[name]+N'%'+N'');

		if (object_id('tempdb..#t','U') is not null) drop table #t;
	
end

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Хранимая процедура глобального поиска объекта, в том числе его использорвания в SQL JOB', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'FindObject';

