

CREATE   PROCEDURE [srv].[AutoDeleteSnapshotNotDB]
	@path nvarchar(2000)='E:\DB\'
AS
BEGIN
	/*
		удаление моментальных снимков, которые не привязаны к текущим БД
	*/

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	set xact_abort on;
	 
	declare @table table(a nvarchar(4000), b int, c int);
	 
	insert into @table(a,b,c)
	exec xp_dirtree @path, 1, 1;
	 
	declare @SQL nvarchar(max)=N'';
	 
	select @SQL=@SQL+N'
	exec xp_cmdshell ''del '+@path+N''+b.a+N'''
	'
	from
	(select b.physical_name as physical_name
	 from sys.databases a inner join sys.master_files as b on (a.database_id=b.database_id )
	where a.source_database_id is not null) as a
	full outer join @table as b on (a.physical_name=@path+b.a )
	where a.physical_name is null
	and b.a like N'%.ss';
	 
	--заменить print на exec
	--print @SQL;
	
	if(len(@SQL)>1)	exec sp_executesql @SQL;
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Выполняет удаление моментальных снимков, которые не привязаны к текущим БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoDeleteSnapshotNotDB';

