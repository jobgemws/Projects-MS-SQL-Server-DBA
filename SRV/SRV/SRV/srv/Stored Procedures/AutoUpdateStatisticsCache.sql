-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[AutoUpdateStatisticsCache]
	@DB_Name nvarchar(255)=null,
	@IsUpdateStatistics bit=0
AS
BEGIN
	/*
		очистка кеша с последующим обновлением статистики по всем несистемным БД
	*/
	SET NOCOUNT ON;

    declare @tbl table (Name nvarchar(255), [DB_ID] int);
	declare @db_id int;
	declare @name nvarchar(255);
	declare @str nvarchar(255);
	
	--получаем все БД, которые не помечены как только для чтения
	insert into @tbl(Name, [DB_ID])
	select name, database_id
	from sys.databases
	where name not in ('master', 'tempdb', 'model', 'msdb', 'distribution')
	and is_read_only=0	--write
	and state=0			--online
	and user_access=0	--MULTI_USER
	and is_auto_close_on=0
	and (name=@DB_Name or @DB_Name is null);
	
	while(exists(select top(1) 1 from @tbl))
	begin
		--получаем идентификатор нужной БД
		select top(1)
			@db_id=[DB_ID]
		  , @name=Name
		from @tbl;
	
		--очищаем кэш по id БД
		DBCC FLUSHPROCINDB(@db_id);
	
		if(@IsUpdateStatistics=1)
		begin
			--обновляем статистику
			set @str='USE'+' ['+@name+']; exec sp_updatestats;'
			exec(@str);
		end
	
		delete from @tbl
		where [DB_ID]=@db_id;
	end
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Очистка кеша с последующим обновлением статистики по всем несистемным БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoUpdateStatisticsCache';

