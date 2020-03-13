set xact_abort on;
set nocount on;
set dateformat dmy;
 
declare @inf table(inf nvarchar(4000));
 
insert into @inf
exec xp_cmdshell 'dir E:\DBTemplatesFull\*.bak';
 
;with tbl0 as (
    select replace(replace(inf,',',''),'.bak','') as inf
    from @inf
    where right(inf,4)='.bak'
)
, tbl1 as (
    select cast(left(inf,20) as datetime) as [DateModify],
    replace(rtrim(ltrim(substring(inf,21,len(inf)))),' ',',') as inf
    from tbl0
)
, tbl2 as (
    select [DateModify],
    left(inf,charindex(N',',inf)-1) as inf,
    replace(inf,left(inf,charindex(',',inf)),'') as FileBak
    from tbl1
)
, tbl_res as (
    select [DateModify],
    replace(inf, char(160), N'') as inf,
    FileBak
    from tbl2
)
select [DateModify],
cast(replace(inf, N' ', N'') as bigint)/1024.0/1024.0 as [size(Mb)],
FileBak
from tbl_res;