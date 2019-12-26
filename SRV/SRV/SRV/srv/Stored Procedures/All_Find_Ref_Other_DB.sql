


CREATE   proc [srv].[All_Find_Ref_Other_DB]
	@DBB sysname=null,
	@srv int=0--'MonopolySun'
as
begin
	set nocount on;
	set xact_abort on;
	
	DECLARE @dbContext nvarchar(256)=@DBB+N'.dbo.'+N'sp_executeSQL';
	DECLARE @DB sysname=N'';
	
	DECLARE ExecCurS CURSOR FOR
	select [name]
	from sys.databases
	where database_id>4; --and (@DB is null or [name]=@DB)

	OPEN ExecCurS;

	FETCH NEXT FROM ExecCurS INTO @DB;

	WHILE (@@FETCH_STATUS=0)
	BEGIN
		SET @dbContext=@DB+N'.dbo.'+N'sp_executeSQL';
	
		EXEC @dbContext N'srv.Find_Ref_Other_DB @DB=@param1,@srv=@param2',N'@param1 varchar(255),@param2 int',@param1=@DBB,@param2=@srv
	
		FETCH NEXT FROM ExecCurS INTO @DB;
	END

	CLOSE ExecCurS;
	DEALLOCATE ExecCurS;
end

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Формирование картинки зависимостей sql stored objects для всего SQL Server-а.
В оснвое используется перебор всех пользовательских БД с вызовом ХП Find_Ref_Other_DB.', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'All_Find_Ref_Other_DB';

