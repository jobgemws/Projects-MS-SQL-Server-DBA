select db,[file_name],[Size(Mb)],[SizeDB(Mb)], [All DBs Size(Mb)]=(case when id=1 then [All DBs Size(Mb)] else null end)
,[SizeData(Mb)]=(case when id=1 then [SizeData(Mb)] else null end)
,[SizeLog(Mb)]=(case when id=1 then [SizeLog(Mb)] else null end)
from
(select db,[file_name],[Size(Mb)],[SizeDB(Mb)],[All DBs Size(Mb)],sum(case when [type]=1 then [Size(Mb)] else 0 end) over (partition by 1) [SizeLog(Mb)],
sum(case when [type]=0 then [Size(Mb)] else 0 end) over (partition by 1) [SizeData(Mb)],row_number() over (order by [SizeDB(Mb)] desc) id
from
(select b.name db,c.name [file_name],cast(sum(BytesOnDisk)/1024.0/1024.0 as numeric(12,3)) [Size(Mb)],cast(sum(BytesOnDisk/1024.0/1024.0) over (partition by b.name) as numeric(12,3)) [SizeDB(Mb)],
cast(sum(BytesOnDisk/1024.0/1024.0) over (partition by 1) as numeric(12,3)) [All DBs Size(Mb)],c.[type]
from ::fn_virtualfilestats(NULL, NULL) a inner join (select * from sys.databases where database_id>4) b on(a.DbId=b.database_id)
inner join  master.sys.master_files c on(a.DbId=c.database_id and  a.FileId=c.[file_id])
group by b.name,c.name,BytesOnDisk,c.[type]) a) a
order by 4 desc