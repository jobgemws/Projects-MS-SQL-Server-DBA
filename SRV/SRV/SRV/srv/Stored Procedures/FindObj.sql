


CREATE   procedure [srv].[FindObj]
	@find nvarchar(255)=N'StateOfResource'
as
begin
	set nocount on;
	set xact_abort on;
	
	if (object_id(N'tempdb..##TBL', N'U') is not null) drop table ##TBL;
	
	create table ##TBL (DB nvarchar(255), [obj] nvarchar(255), [type_desc] nvarchar(255));
	
	insert into ##TBL (DB, [obj], [type_desc])
	exec sp_MSforeachdb N'USE [?] select DB_NAME() as DB, [name] as [obj], [type_desc] from sys.objects';
	
	--объекты
	select DB, [obj], [type_desc]
	from ##TBL
	where [obj]=@find;
	
	--зависимости
	declare @SQL nvarchar(max)=N'';
	
	set @SQL=N'USE [?]  
	select DB_NAME() DB,b.[name] def_obj,b.type_desc,referenced_entity_name,c.[type_desc] COLLATE Cyrillic_General_CI_AS ref_type_desc 
	,isnull(referenced_database_name,DB_NAME()) referenced_database_name, referenced_server_name 
	from sys.sql_expression_dependencies a
	left join sys.objects b on(a.referencing_id=b.[object_id])
	left join ##TBL c on(a.referenced_entity_name=c.[obj] and (isnull(referenced_database_name,DB_NAME())=c.DB))
	where b.[name]='''+@find+N''' or referenced_entity_name='''+@find+N'''
	union
	select DB_NAME() DB,tr.[name],o.type_desc,o.[name],o.[type_desc],DB_NAME() DB, '''' referenced_server_name 
	from sys.triggers tr LEFT JOIN sys.objects o on(tr.parent_id=o.object_id)
	where tr.name='''+@find+N''' or o.[name]='''+@find+N'''';
	
	declare @RES table (DB nvarchar(255), def_obj nvarchar(255), [type_desc] nvarchar(255),referenced_entity_name nvarchar(255)
	,ref_type_desc nvarchar(255), referenced_database_name nvarchar(255), referenced_server_name nvarchar(255));
	
	insert into @RES (DB, def_obj, [type_desc], referenced_entity_name, ref_type_desc, referenced_database_name, referenced_server_name)
	exec sp_MSforeachdb @SQL;
	
	select DB, def_obj, [type_desc], referenced_entity_name, ref_type_desc, referenced_database_name, referenced_server_name
	from @RES;
	
	if (object_id(N'tempdb..##TBL', N'U') is not null)	drop table ##TBL;
end

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Поиск объекта sql в рамках одного SQL сервера. Нахождение всех использований указанного объекта в определении других sql объектов.', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'FindObj';

