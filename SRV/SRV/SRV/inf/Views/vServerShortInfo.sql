


CREATE view [inf].[vServerShortInfo] as
--основная информация
-- Имена сервера и экземпляра 
Select @@SERVERNAME as [Server\Instance]
-- версия SQL Server 
,@@VERSION as SQLServerVersion
-- экземпляр SQL Server 
,@@ServiceName AS ServiceInstance
 -- Текущая БД (БД, в контексте которой выполняется запрос)
,DB_NAME() AS CurrentDB_Name
,system_user as CurrentLogin--логин
,USER_NAME() as CurrentUser--пользователь
,SERVERPROPERTY(N'BuildClrVersion')					as BuildClrVersion
,SERVERPROPERTY(N'Collation')						as Collation
,SERVERPROPERTY(N'CollationID')						as CollationID
,SERVERPROPERTY(N'ComparisonStyle')					as ComparisonStyle
,SERVERPROPERTY(N'ComputerNamePhysicalNetBIOS')		as ComputerNamePhysicalNetBIOS
,SERVERPROPERTY(N'Edition')							as Edition
,SERVERPROPERTY(N'EditionID')						as EditionID
,SERVERPROPERTY(N'EngineEdition')					as EngineEdition
,SERVERPROPERTY(N'HadrManagerStatus')				as HadrManagerStatus
,SERVERPROPERTY(N'InstanceName')					as InstanceName
,SERVERPROPERTY(N'IsClustered')						as IsClustered
,SERVERPROPERTY(N'IsFullTextInstalled')				as IsFullTextInstalled
,SERVERPROPERTY(N'IsHadrEnabled')					as IsHadrEnabled
,SERVERPROPERTY(N'IsIntegratedSecurityOnly')		as IsIntegratedSecurityOnly
,SERVERPROPERTY(N'IsLocalDB')						as IsLocalDB
,SERVERPROPERTY(N'IsSingleUser')					as IsSingleUser
,SERVERPROPERTY(N'IsXTPSupported')					as IsXTPSupported
,SERVERPROPERTY(N'LCID')							as LCID
,SERVERPROPERTY(N'LicenseType')						as LicenseType
,SERVERPROPERTY(N'MachineName')						as MachineName
,SERVERPROPERTY(N'NumLicenses')						as NumLicenses
,SERVERPROPERTY(N'ProcessID')						as ProcessID
,SERVERPROPERTY(N'ProductVersion')					as ProductVersion
,SERVERPROPERTY(N'ProductLevel')					as ProductLevel
,SERVERPROPERTY(N'ResourceLastUpdateDateTime')		as ResourceLastUpdateDateTime
,SERVERPROPERTY(N'ResourceVersion')					as ResourceVersion
,SERVERPROPERTY(N'ServerName')						as ServerName
,SERVERPROPERTY(N'SqlCharSet')						as SqlCharSet
,SERVERPROPERTY(N'SqlCharSetName')					as SqlCharSetName
,SERVERPROPERTY(N'SqlSortOrder')					as SqlSortOrder
,SERVERPROPERTY(N'SqlSortOrderName')				as SqlSortOrderName
,SERVERPROPERTY(N'FilestreamShareName')				as FilestreamShareName
,SERVERPROPERTY(N'FilestreamConfiguredLevel')		as FilestreamConfiguredLevel
,SERVERPROPERTY(N'FilestreamEffectiveLevel')		as FilestreamEffectiveLevel

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Основная информация экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vServerShortInfo';

