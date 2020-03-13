----
set xact_abort on;
set nocount on;
  
if object_id('tempdb..#srv','U') is not null
drop table #srv
if object_id('tempdb..#User','U') is not null
drop table #User
  
SELECT  member.name AS MemberName
    ,s.permission_name permission
    into #srv
FROM sys.server_role_members
JOIN sys.server_principals AS member
    ON sys.server_role_members.member_principal_id = member.principal_id
LEFT JOIN sys.server_permissions s ON member.principal_id=s.grantee_principal_id
WHERE s.permission_name  not in('CONNECT SQL') and is_disabled=0 --не отключенные
GROUP BY member.name, s.permission_name
UNION
select l.name COLLATE Cyrillic_General_CI_AS,p.name COLLATE Cyrillic_General_CI_AS
from sys.syslogins l inner join sys.server_principals s on(l.name=s.name and s.type_desc='SQL_LOGIN')
inner join sys.server_role_members ss on(s.principal_id=ss.member_principal_id )
inner join sys.server_principals p on(ss.role_principal_id=p.principal_id );
 
WITH perm as (SELECT schem.name+'.'+sp.name COLLATE Cyrillic_General_CI_AS as [object_name] ,
sp.[type] as type_object,sp.type_desc as [type_object_desc],
grantee_principal.name as [Owner_name],grantee_principal.type_desc as [Owner_desc],
prmssn.[type] [Type_of_previlegion],prmssn.permission_name,
grantor_principal.name AS [Grantor]
FROM
sys.all_objects AS sp
INNER JOIN sys.database_permissions AS prmssn ON prmssn.major_id=sp.object_id AND prmssn.minor_id=0 AND prmssn.class=1
INNER JOIN sys.database_principals AS grantor_principal ON grantor_principal.principal_id = prmssn.grantor_principal_id
INNER JOIN sys.database_principals AS grantee_principal ON grantee_principal.principal_id = prmssn.grantee_principal_id
INNER JOIN sys.schemas AS schem on(sp.schema_id=schem.schema_id)
where schem.name<>'sys' and grantee_principal.name not in('public','guest') and left(sp.name,7)<>'Obsolet')
  
select isnull(a.[object_name],'') [object_name],isnull(a.[type_object_desc],'') [type_object_desc],tbl.[User]
,permission=MAX(isnull(permission,'')),db_datareader,db_datawriter,db_ddl_admin,db_backupoperator,db_owner,sysadmin=case when IS_SRVROLEMEMBER('sysadmin',tbl.[User]) in(1) then 'X' else '' end,MAX(isnull(ss.srv_permission,'')) srv_permission
into #USER
from
(select [object_name],type_object,[type_object_desc],permission=stuff((
    select ',' + CAST( [permission_name]  AS VARCHAR)
    from perm b
    where a.[Owner_name]=b.[Owner_name] and a.[object_name]=b.[object_name]
    for XML path('')
    ),1,1,''),[Owner_name],[Owner_desc],[Type_of_previlegion],[Grantor]
from perm a
group by [object_name],type_object,[type_object_desc],[Owner_name],[Owner_desc],[Type_of_previlegion],[Grantor]
UNION ALL
SELECT s.name as [object_name],'Sch' as type_object,'SCHEMA' as [type_object_desc],prmssn.permission_name,
grantee_principal.name as [Owner_name],grantee_principal.type_desc as [Owner_desc],
prmssn.[type] [Type_of_previlegion],
grantor_principal.name AS [Grantor]
FROM
sys.schemas AS s
INNER JOIN sys.database_permissions AS prmssn ON prmssn.major_id=s.schema_id AND prmssn.minor_id=0 AND prmssn.class=3
INNER JOIN sys.database_principals AS grantor_principal ON grantor_principal.principal_id = prmssn.grantor_principal_id
INNER JOIN sys.database_principals AS grantee_principal ON grantee_principal.principal_id = prmssn.grantee_principal_id
where s.name<>'sys' and grantee_principal.name not in('public','guest')) a
full outer join
(select c.name [User]
,db_datareader=MAX(case when b.name='db_datareader'  then 'X' else '' end)
,db_datawriter=MAX(case when b.name='db_datawriter'  then 'X' else '' end)
,db_backupoperator=MAX(case when b.name='db_backupoperator'  then 'X' else '' end)
,db_owner=MAX(case when b.name='db_owner'  then 'X' else '' end)
,db_ddl_admin=MAX(case when b.name='db_ddl_admin'  then 'X' else '' end)
from sys.database_role_members a
inner join sys.database_principals b on(a.role_principal_id=b.principal_id and b.type='R')
inner join sys.database_principals c on(a.member_principal_id=c.principal_id)
GROUP BY c.name) tbl ON(a.Owner_name=tbl.[User])
left outer join (SELECT MemberName,MAX(lst) srv_permission
FROM
(SELECT  MemberName AS MemberName
    ,stuff((
    select ',' + CAST( ss.permission  AS VARCHAR)
    from #srv ss
    where s.MemberName=ss.MemberName
    for XML path('')
    ),1,1,'') lst 
FROM #srv s
GROUP BY MemberName) ss
GROUP BY MemberName) ss ON(tbl.[User]=ss.MemberName COLLATE Cyrillic_General_CI_AS)
where [User] is not null and [User]<>'dbo'
group by a.[object_name],a.[type_object_desc],tbl.[User],db_datareader,db_datawriter,db_ddl_admin,db_backupoperator,db_owner
order by [User],db_datareader desc,db_datawriter desc,db_ddl_admin desc,db_owner desc
  
select distinct a.[User] COLLATE Cyrillic_General_CI_AS [User]
from #User a INNER JOIN sys.server_principals b ON(a.[User]=b.name COLLATE Cyrillic_General_CI_AS and b.is_disabled=0);
  
WITH DB AS (select b.name [Role], c.name [User]
from sys.database_role_members a
inner join sys.database_principals b on(a.role_principal_id=b.principal_id and b.type='R')
inner join sys.database_principals c on(a.member_principal_id=c.principal_id)
GROUP BY b.name,c.name)
  
select distinct a.[User], db_datareader,db_datawriter,db_owner,db_backupoperator,db_ddl_admin,lst db_roles,srv_permission
from #User a INNER JOIN sys.server_principals b ON(a.[User]=b.name COLLATE Cyrillic_General_CI_AS and b.is_disabled=0)
INNER JOIN (SELECT [User],stuff((
    select ',' + CAST( ss.[Role]  AS VARCHAR)
    from DB ss
    where s.[User]=ss.[User]
    for XML path('')
    ),1,1,'') lst 
FROM DB s) c ON(a.[User]=c.[User])
where a.object_name=''
order by [User];
  
select a.[User], object_name,type_object_desc,permission
from #User a INNER JOIN sys.server_principals b ON(a.[User]=b.name COLLATE Cyrillic_General_CI_AS and b.is_disabled=0)
where a.object_name<>''
order by [User], object_name
  
if object_id('tempdb..#srv','U') is not null
drop table #srv
if object_id('tempdb..#User','U') is not null
drop table #User
 
--select * from sys.syslogins