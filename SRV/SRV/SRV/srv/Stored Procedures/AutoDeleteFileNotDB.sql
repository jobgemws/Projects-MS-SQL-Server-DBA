

CREATE   PROCEDURE [srv].[AutoDeleteFileNotDB]
	@path_data nvarchar(4000)=N'E:\sql_data\' --каталог mdf файлов
   ,@path_log nvarchar(4000)=N'F:\sql_log\' --каталог ldf файлов
AS
BEGIN
	/*
		удаление не привязанных к серверу MS SQL mdf, ldf файлов
	*/

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	set xact_abort on;
	 
	declare @tbl table(a nvarchar(4000), b int, c int, d int); --собираем содержимое файлов
 
	insert into @tbl(a,b,c) --mdf файлы собираем
	exec xp_dirtree @path_data,1,1;
	 
	update @tbl --метка для пути @path
	set d=1;
	 
	insert into @tbl(a,b,c) --ldf файлы собираем
	exec xp_dirtree @path_log,1,1
	 
	--в для @path2 получит значение null
	 
	declare @SQL nvarchar(max)=N''--контейнер sql скрипта
	 
	select @SQL=@SQL+N'
	exec xp_cmdshell ''del '+case when d=1 then @path_data+p.a else @path_log+p.a end+N''''
	from
	(select db.name DB, mf.physical_name
	from sys.databases db
	INNER JOIN sys.master_files mf on(db.database_id=mf.database_id)
	where db.database_id>4 /*не системные, не смотрим онлайн БД и пр. это не важно*/) db
	right outer join @tbl p ON(db.physical_name=case when d=1 then @path_data+p.a else @path_log+p.a end)
	where db.DB is null
	and (p.a like N'%.mdf' or p.a like N'%.ldf');
	 
	begin try
	    exec sp_executesql @SQL; --выполняем удаление файлов (поскольку они не связанны, то должны удаляться на ура)
	    print @SQL;--печатаем скрипт
	end try
	begin catch --Обработчик ошибок
	    IF @@ERROR<>0
	    begin
	        print @SQL;
	        select ERROR_MESSAGE() err_msg; --обработка ошибок
	    end
	end catch
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Выполняет удаление не привязанных к серверу MS SQL mdf, ldf файлов', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoDeleteFileNotDB';

