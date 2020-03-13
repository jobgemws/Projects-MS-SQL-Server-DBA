set xact_abort on;
set nocount on;
 
declare @path varchar(4000)='E:\sql_data\' --каталог mdf файлов
declare @path2 varchar(4000)='F:\sql_log\' --каталог ldf файлов
 
declare @tbl table(a varchar(4000),b int,c int, d int) --собираем содержимое файлов
 
insert into @tbl(a,b,c) --mdf файлы собираем
exec xp_dirtree @path,1,1
 
update @tbl --метка для пути @path
set d=1
 
insert into @tbl(a,b,c) --ldf файлы собираем
exec xp_dirtree @path2,1,1
 
--в для @path2 получит значение null
 
declare @SQL nvarchar(max)=''--контейнер sql скрипта
 
select @SQL=@SQL+'
exec xp_cmdshell ''del '+case when d=1 then @path+p.a else @path2+p.a end+''''
from
(select db.name DB, mf.physical_name
from sys.databases db
INNER JOIN sys.master_files mf on(db.database_id=mf.database_id)
where db.database_id>4 /*не системные, не смотрим онлайн БД и пр. это не важно*/) db
right outer join @tbl p ON(db.physical_name=case when d=1 then @path+p.a else @path2+p.a end)
where db.DB is null
and (p.a like '%.mdf' or p.a like '%.ldf');
 
begin try
    exec sp_executesql @SQL --выполняем удаление файлов (поскольку они не связанны, то должны удаляться на ура)
    print @SQL--печатаем скрипт
end try
begin catch --Обработчик ошибок
    IF @@ERROR<>0
    begin
        print @SQL
        select ERROR_MESSAGE() err_msg --обработка ошибок
    end
end catch