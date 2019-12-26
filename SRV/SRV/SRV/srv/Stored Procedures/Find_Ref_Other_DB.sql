

CREATE   proc [srv].[Find_Ref_Other_DB]
	@DB nvarchar(255)=N'',
	@obj nvarchar(255)=null,
	@srv int=0
as
begin
	set nocount on;
	set xact_abort on;
	/*
	Хранимая процедура ищет использование хранимых объектов и таблиц в определении других хранимых обхектах SQL (в основе лежит sql_expression_dependencies)
	Выполняется только в контексте одной БД
	*/

	declare @sql nvarchar(max)=N'';
	
	set @sql=N'select DB_NAME() DB,b.name obj,b.type_desc,referenced_entity_name ,referenced_database_name, referenced_server_name 
	from sys.sql_expression_dependencies a INNER JOIN 
	sys.objects b on(a.referencing_id=b.object_id)
	left join sys.objects c on(a.referenced_entity_name=c.name)
	where lower(referenced_database_name) is not null and referenced_database_name not in(''master'')
	and left(b.name,7)<>''Obsolet''
	and right(b.name, 4) not in(''Test'',''COPY'')
	and right(b.name, 2) not in(''BP'')
	and left(b.name, 6) not in(''DELETE'')
	and b.name not like ''%[0-9][0-9][0-9][0-9]''
	and (referenced_database_name='''+@DB+N''' or '''+@DB+N''''+'='''')
	'+case when len(@obj)>0 then N'and (b.name='''+@obj+''' or referenced_entity_name='''+@obj+N''')' else N'' end +N'
	 '+case when @srv=1 then N'and exists(select 1 from sys.sql_expression_dependencies se where a.referencing_id=se.referencing_id and se.referenced_server_name is not null)' else N'' end +N'';
	
	declare @tbl table(DB nvarchar(255), obj nvarchar(255), [type_desc] nvarchar(255), referenced_entity_name nvarchar(255), referenced_database_name nvarchar(255), referenced_server_name nvarchar(255));
	
	--print @sql
	
	insert into @tbl
	exec sp_executesql @sql;
	
	if (exists(select top(1) 1 from @tbl)) select distinct DB, obj, [type_desc], referenced_entity_name, referenced_database_name, referenced_server_name from @tbl;
end

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Хранимая процедура ищет использование хранимых объектов и таблиц в определении других хранимых обхектах SQL (в основе лежит sql_expression_dependencies)
	Выполняется только в контексте одной БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'Find_Ref_Other_DB';

