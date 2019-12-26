

CREATE   procedure [srv].[Depend_objects]
	@DB nvarchar(255)=N'',
	@type nvarchar(50)=N'',
	@type2 nvarchar(50)=N'',
	@ref_DB nvarchar(255)=N'',
	@obj nvarchar(255)=N'',
	@ref_obj nvarchar(255)=N'',
	@stat int=0, 
	@srv int=0,
	@job int=0
as
begin
	set xact_abort on;
	set nocount on;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	/*Построение зависимостей в хранимых объектов MS SQL (на основе sys.sql_expression_dependencies)*/
	
	IF (OBJECT_ID(N'tempdb..##TBL', N'U') IS NOT NULL) DROP TABLE tempdb..##TBL;
	
	IF (LEN(@DB)<1)
	begin
		RAISERROR(N'Вы не указали БД!', 10, 2);

		return 0;
	end
	
	IF ((@job=1) and (len(@obj)>0))
	begin
		--Использование объекта в SQL JOBS
		select a.name job,N'в теле' place,b.command,a.enabled
		from msdb..sysjobs a inner join msdb..sysjobsteps b on(a.job_id=b.job_id)
		where (command like N'%'+@obj+N'%' or command like N'%'+@obj+N'%' or a.name=@obj) AND (@DB=N'' OR (command like N'%'+@DB+N'%' or [database_name]=@DB));
	end
	
	IF ((@job=1) and (len(@obj)=0))
	begin
		--ИСпользование объекта в SQL JOBS
		select a.name job,N'в теле' place,b.command,a.enabled
		from msdb..sysjobs a inner join msdb..sysjobsteps b on(a.job_id=b.job_id)
		where command like N'%'+@DB+N'%' or [database_name]=@DB;
	end
	
	IF ((@type not in (N'U', N'V', N'P', N'FN', N'IF', N'TR', N'TF', N'')) or (@type2 not in(N'U', N'V', N'P', N'FN', N'IF', N'TR', N'TF', N'')))
	begin
		RAISERROR(N'Вы указали не валидный тип поиска! Валидные типы:
		SQL_INLINE_TABLE_VALUED_FUNCTION	IF
		SQL_SCALAR_FUNCTION	FN
		SQL_STORED_PROCEDURE	P 
		SQL_TABLE_VALUED_FUNCTION	TF
		SQL_TRIGGER	TR
		USER_TABLE	U 
		VIEW	V ', 10, 2);

		return 0;
	end
	
	create table ##TBL(DB nvarchar(255), [obj] nvarchar(255), COL nvarchar(255), [type_desc] nvarchar(255), [type] nvarchar(5));
	
	declare @S varchar(max)=N'USE [?] select DB_NAME() DB,[name] [obj],'''' COL,[type_desc],[type] from sys.objects 
	where [type] in(''P'',
	''V'',
	''U'',
	''IF'',
	''FN'',
	''TF'',
	''TR'')
	UNION
	select TOP 1 DB_NAME() DB,TABLE_NAME,COLUMN_NAME COL,''USER_TABLE'' [type_desc],''U'' [type] 
	FROM INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME='''+@obj+N'''';
	
	insert into ##TBL(DB, [obj], COL, [type_desc], [type])
	exec sp_MSforeachdb @S;
	
	if ((@obj<>N'') and (@type=N''))
	begin
		select *
		from ##TBL
		where DB not in (N'master', N'tempdb', N'model', N'msdb')
		 and ([obj]=@obj or COL=@obj);
	end
	
	declare @DBR sysname=@DB;

	DECLARE @dbContext nvarchar(256)=@DBR+N'.dbo.'+N'sp_executeSQL';
	
	declare @SQL nvarchar(max)=N'';
	
	--Не рассматриваем триггеры
	IF (((@type not in (N'TR')) and (@type2<>N'TR')) and (@stat=0))
	begin
		set @SQL=N'
		select DB_NAME() DB,b.[name] parent_obj,b.type,b.type_desc,referenced_entity_name,case when referenced_server_name is null then isnull(c.[type],'''')
		else '''' end ref_type,
		case when referenced_server_name is null then isnull(c.[type_desc],''Не существует!'')
		else '''' end ref_type_desc
		,isnull(referenced_database_name,DB_NAME()) referenced_database_name, isnull(referenced_server_name ,'''') referenced_server_name
		from sys.sql_expression_dependencies a
		left join sys.objects b on(a.referencing_id=b.[object_id])
		left join ##TBL c on(a.referenced_entity_name=c.[obj] and (isnull(referenced_database_name,DB_NAME())=c.DB))
		where  left(b.[name],7)<>''Obsolet''
		and right(b.[name], 4) not in(''Test'',''COPY'')
		and right(b.[name], 2) not in(''BP'')
		and right(b.[name], 3) not in(''OLD'')
		and left(b.[name], 6) not in(''DELETE'') and left(b.[name], 3) not in(''sp_'')
		and b.[name] not like ''%[0-9][0-9][0-9][0-9]''
		and (b.[type]='''+@type+N''' or '''+@type+N'''='''') and (c.[type]='''+@type2+N''' or '''+@type2+N'''='''') and (b.[name]='''+@obj+N''' or '''+@obj+N'''='''' or a.referenced_entity_name='''+@obj+N''')
		and (referenced_entity_name='''+@ref_obj+N''' or '''+@ref_obj+N'''='''')
		and (a.[referenced_database_name]='''+@ref_DB+N''' or '''+@ref_DB+N'''='''') and ('+case when @srv=0 then N'''''=''''' when @srv=1 then N'a.[referenced_server_name]<>''''' end+N')
		GROUP BY b.[name],b.type_desc,b.type,referenced_entity_name,c.[type],c.[type_desc],isnull(referenced_database_name,DB_NAME()), referenced_server_name';
		
		print @SQL;
		
		--Блок обработки ошибок
		BEGIN TRY
			EXEC @dbContext @SQL;
		END TRY
		BEGIN CATCH
			SELECT ERROR_MESSAGE() as ERR_MSG, ERROR_LINE() as ERR_LINE;
		END CATCH
	end
	
	IF ((@type not in (N'TR')) and (@type2<>N'TR') and (@stat=1))
	begin
		set @SQL=N'
		select DB_NAME() DB,o.name [obj],o.type_desc,isnull(referenced_entity_name,'''') referenced_entity_name,isnull(ref_type_desc,'''') ref_type_desc
		,isnull(referenced_database_name,'''') referenced_database_name
		from sys.objects o LEFT OUTER JOIN
		(select b.[name] parent_obj,b.type_desc,referenced_entity_name,c.[type_desc] ref_type_desc
		,isnull(referenced_database_name,DB_NAME()) referenced_database_name
		from sys.sql_expression_dependencies a
		left join sys.objects b on(a.referencing_id=b.[object_id])
		left join ##TBL c on(a.referenced_entity_name=c.[obj] and (isnull(referenced_database_name,DB_NAME())=c.DB))
		where  left(b.[name],7)<>''Obsolet''
		and right(b.[name], 4) not in(''Test'',''COPY'')
		and right(b.[name], 2) not in(''BP'')
		and right(b.[name], 3) not in(''OLD'')
		and left(b.[name], 6) not in(''DELETE'') and left(b.[name], 3) not in(''sp_'')
		and b.[name] not like ''%[0-9][0-9][0-9][0-9]''
		and (b.[type]='''+@type+N''' or '''+@type+N'''='''') and (c.[type]='''+@type2+N''' or '''+@type2+N'''='''')
		GROUP BY b.[name],b.type_desc,referenced_entity_name,c.[type_desc],isnull(referenced_database_name,DB_NAME()) ) tbl 
		ON(o.name=tbl.parent_obj and o.type_desc=tbl.type_desc and (o.[type]='''+@type+N''' or '''+@type+N'''=''''))
		where (o.[type]='''+@type+N''' or '''+@type+N'''='''')
		and  left(o.[name],7)<>''Obsolet''
		and right(o.[name], 4) not in(''Test'',''COPY'')
		and right(o.[name], 2) not in(''BP'')
		and right(o.[name], 3) not in(''OLD'')
		and left(o.[name], 6) not in(''DELETE'') and left(o.[name], 3) not in(''sp_'')
		and o.[name] not like ''%[0-9][0-9][0-9][0-9]''';
		
		--Блок обработки ошибок
		BEGIN TRY
			EXEC @dbContext @SQL;
		END TRY
		BEGIN CATCH
			SELECT ERROR_MESSAGE() as ERR_MSG, ERROR_LINE() as ERR_LINE;
		END CATCH
	end
	
	--Отдельно рассматриваем триггеры
	IF ((@type=N'TR') or (@type2=N'TR'))
	begin
		IF (LEN(@SQL)>0)
		begin
			RAISERROR(N'Ошибка формирования скрипта SQL!', 10, 2);

			print @SQL;

			return 0;
		end
		
		set @SQL=N'select distinct b.name [trigger],isnull(a.referenced_database_name,DB_NAME()) referenced_database_name,a.referenced_entity_name,isnull(ob.type_desc,''Нет объекта'') ref_type_desc,o.name parent_name,o.type_desc 
		from sys.sql_expression_dependencies a inner join sys.objects b on(a.referencing_id=b.object_id)
		inner join sys.triggers tr on(a.referencing_id=tr.object_id and ('''+@type+N'''=''TR'' or 0=1))
		inner join sys.objects o on(tr.parent_id=o.object_id )
		left join ##TBL ob on(a.referenced_entity_name=ob.[obj] and (referenced_database_name is null or referenced_database_name=ob.DB))
		where (ob.[type]='''+@type2+N''' or '''+@type2+N'''='''')
		and (referenced_entity_name='''+@ref_obj+N''' or '''+@ref_obj+N'''='''')
		and (a.[referenced_database_name]='''+@ref_DB+N''' or '''+@ref_DB+N'''='''')
		order by 1';
		
		--Блок обработки ошибок
		BEGIN TRY
			EXEC @dbContext @SQL;
		END TRY
		BEGIN CATCH
			SELECT ERROR_MESSAGE() as ERR_MSG, ERROR_LINE() as ERR_LINE;
		END CATCH
	end
	
	IF (OBJECT_ID(N'tempdb..##TBL', N'U') IS NOT NULL)	DROP TABLE tempdb..##TBL;
	
	
end

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Построение зависимостей в хранимых объектов MS SQL (на основе sys.sql_expression_dependencies)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'Depend_objects';

