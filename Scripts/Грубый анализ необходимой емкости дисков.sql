;with tbl0 as (
SELECT [Drive], [Type_desc], sum(SizeGb) as SizeGb, count(*) as cnt
  FROM [inf].[vDBFilesOperationsStat]
  group by [Drive], [Type_desc]
)
, tbl as (
    select case when ([Type_desc]='LOG') then
                case when (SizeGb>cnt*16) then SizeGb else cnt*16 end
                else SizeGb
            end as SizeGb
          ,[Drive]
          ,cnt
    from tbl0
)
, tbl_res as (
    select [Drive], sum(cnt) as cnt, sum(SizeGb) as SizeGb
    from tbl
    group by [Drive]
)
select t.[Drive], t.cnt, (d.Disk_Space_Mb/1024)-t.SizeGb as Diff, (d.Disk_Space_Mb/1024) as Disk_Free_Space_Gb, d.[State], d.[Available_Mb]/1024 as [Available_Gb], d.[Available_Percent]
from tbl_res as t
inner join inf.vDisk as d on t.Drive=substring(d.[Disk],1,1)
where (d.Disk_Space_Mb/1024)<t.SizeGb+8