declare @sql nvarchar(max)='';
 
select @sql=@sql+';ALTER DATABASE ['+[name]+'] SET RECOVERY SIMPLE WITH NO_WAIT'
from sys.databases
where recovery_model<>3
and [state]=0
 
exec sp_executesql @sql;