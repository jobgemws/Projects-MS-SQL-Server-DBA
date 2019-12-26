



/*
Автор - Прилепа Б.А. АБД
Мониторинг резервирования данных

exec [dbo].[sp_backups_info] --Вся история по всем базам
exec [dbo].[sp_backups_info] @db='Trucks' --Вя имеющаяся история по одной БД
exec [dbo].[sp_backups_info] @d='2019-01-28',@k=3 /*три дня в прошлое с 2019-01-28*/,@t='DD', @db='Trucks'
exec [dbo].[sp_backups_info] @d='2019-01-26',@k=8 /*8 часов в прошлое с 2019-01-26 00:00:00*/,@t='HH', @db='Trucks'
exec [dbo].[sp_backups_info] @d=null,@t='MI',@k=120 /*за 2 последних часа*/, @db='Trucks'
exec [dbo].[sp_backups_info] @db='Trucks',@d='2019-01-27 06:00:00',@d2='2019-01-25 10:00:00' --с 6 утра 27-го января дня и до 10 утра 25-го
exec [dbo].[sp_backups_info] @DATABASE='MonopolySun' --Получение результатов на удаленном сервера
*/

CREATE   procedure [srv].[Backups_info]
	@DATE		datetime	 = null,
	@DATE2		datetime	 = null,
	@DAYS		int			 = 7 /*период от даты*/,
	@INTERVAL	nvarchar(2)	 = N'DD'/*DD - дни*/ ,
	@DATABASE	nvarchar(255)= null
as
begin
	set nocount on;
	set xact_abort on;
	
	if (@DATE is null) set @DATE=getdate();
	
	declare @i int=0;
	
	if (@DATE2 is not null)
	begin
		set @i=1;
		set @DAYS=null;
	end
	
	if (@DATE2>@DATE)
	begin
		print N'Вторая дата @d2 - '''+convert(nvarchar(50),@DATE2,113)+N''' должна быть меньше пераой @d - '''+convert(nvarchar(50),@DATE,113)+N'''!';
		return 0;
	end
	
	if (@DATABASE is null)
		set @DATABASE=N''; --Поиск по всем БД
	
	declare @SQL nvarchar(max)=N'';
	
	declare @DAYS_BEFORE nvarchar(50)=@DAYS;
	
	declare @dop nvarchar(max)='';
	
	if (@i=0)
	begin
		set @dop=N'( '+@DAYS_BEFORE+N' is not null and backup_finish_date<='''+convert(nvarchar(50),@DATE,113)+N''' 
		and backup_finish_date>= dateadd('+@INTERVAL+N',-isnull('+@DAYS_BEFORE+N',999),'''+convert(nvarchar(50),@DATE,113)+N'''))';
	end
	
	if (@i=1)
	begin
		set @dop=N'(backup_finish_date<='''+convert(nvarchar(50), @DATE, 113)+N''' and backup_finish_date>='''+convert(nvarchar(50), @DATE2, 113)+N''')';
	end
	
	set @SQL=
	N'if len('''+@DATABASE+N''')>0 and (select count(1) from master.sys.databases where [name]='''+@DATABASE+N''')=0
	begin
	   print ''Указанная Вами БД ( '+@DATABASE+N' ) не найденна! Проверьте передаваемые параметры!''
	   return
	end
	
	select a.database_name,db.name db,[physical_name],a.recovery_model,
	case when a.type=''D'' then ''Полный'' 
	when a.type=''I'' then ''Дифференциальный''
	when a.type=''L'' then ''Транзакционный''
	when a.type=''F'' then ''File or filegroup''
	when a.type=''G'' then ''Differential file''
	when a.type=''P'' then ''Partial''
	when a.type=''Q'' then ''Differential partialend'' end [type]
	,is_damaged Поврежден
	,MAX(a.backup_finish_date) backup_finish_date
	,cast(c.backup_size/1024.0/1024.0 as numeric(12,3)) as backup_size
	,a.collation_name,
	[physical_device_name]=LAST_VALUE([physical_device_name]) over (partition by a.database_name order by backup_finish_date desc)
	,ROW_NUMBER() over (partition by a.database_name order by backup_finish_date desc) Rang
	,SUM(cast(c.backup_size/1024.0/1024.0 as numeric(12,3))) OVER (partition by 1) all_full_backup_size
	from master.sys.databases db left outer join (select * from [msdb].[dbo].[backupset] 
	where database_name='''+@DATABASE+N''' ) a on(a.database_name=db.name) 
	left join [msdb].[dbo].[backupmediafamily] b on(a.[media_set_id]=b.[media_set_id])
	left join [msdb].[dbo].[backupfile] c on(a.[backup_set_id]=c.[backup_set_id])
	where (db.name='''+@DATABASE+N''' or '''+@DATABASE+N'''='''')
	group by a.database_name,
	db.name
	,[physical_name],
	a.recovery_model,
	a.backup_finish_date,
	a.[compressed_backup_size],
	a.collation_name,
	[physical_device_name],
	c.backup_size,
	is_damaged,
	a.type
	order by a.backup_finish_date desc';
	
	begin try
		print @SQL;

		exec sp_executesql @SQL;
	end try
	begin catch
		print @SQL;

	    select ERROR_MESSAGE() as err_msg, ERROR_LINE() as err_line;
	end catch
end




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Мониторинг резервирования данных', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'Backups_info';

