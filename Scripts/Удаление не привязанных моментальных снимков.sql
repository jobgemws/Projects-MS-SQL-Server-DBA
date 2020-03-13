--Удаление не привязанных моментальных снимков
 
use [master]
set xact_abort on;
set nocount on;
 
--Ищем путь для снэпшотов
declare @path varchar(2000)=''
set @path=(select top 1 left(physical_name,charindex('\',physical_name,4)) [path] from sys.master_files where is_sparse=1)
 
declare @table table(a varchar(4000),b int,c int)
 
insert into @table(a,b,c)
exec xp_dirtree @path,1,1
 
declare @SQL nvarchar(max)=''
 
select @SQL=@SQL+'
exec xp_cmdshell ''del '+@path+''+b.a+'''
'
from
(select b.physical_name physical_name
 from sys.databases a inner join sys.master_files b on(a.database_id=b.database_id )
where a.source_database_id is not null) a
full outer join @table b on(a.physical_name=@path+b.a )
where a.physical_name is null and right(b.a,3)='.ss'
 
print @SQL
 
if len(@SQL)>0
exec sp_executesql @SQL