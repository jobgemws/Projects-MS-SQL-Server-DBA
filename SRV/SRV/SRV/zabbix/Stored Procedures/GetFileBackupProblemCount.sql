




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [zabbix].[GetFileBackupProblemCount]
	@path    nvarchar(255) = N'E:\DBTemplates\' --путь к резервным копиям
AS
BEGIN
	/*
		Количество проблемных резервных копий по указанному пути (нехватка или дата создания свыше 24 часов)
	*/

	--SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET XACT_ABORT ON;

	declare @servername nvarchar(255)=cast(SERVERPROPERTY(N'MachineName') as nvarchar(255));

	--set dateformat dmy;

	declare @srv nvarchar(2);
	declare @SourceFolder nvarchar(500);
	declare @inf table(inf nvarchar(4000));
	declare @tbl table([FileBak] nvarchar(255));
	declare @cmd nvarchar(4000);
	declare @ind int=6;
	declare @str_date nvarchar(32);
	declare @style_date tinyint;

	declare @server_name nvarchar(255)=cast(SERVERPROPERTY(N'ComputerNamePhysicalNetBIOS') as nvarchar(255));
	
	if(left(@server_name, 3) in (N'HLT', N'STG'))
	begin
		set @srv = right(@servername, 2);
		set @SourceFolder = N'\\backup-srv01\SQL_Backups\DB\PRD-SQL-SRV'+@srv;
		set @cmd=N'dir /b '+@SourceFolder+N'\*.bak';
	
		insert into @tbl([FileBak])
		exec xp_cmdshell @cmd;
	end
	else
	begin
		while(@ind>0)
		begin
			set @srv = cast(@ind as nvarchar(2));
			if(len(@srv)=1) set @srv=N'0'+@srv;
			set @SourceFolder = N'\\backup-srv01\SQL_Backups\DB\PRD-SQL-SRV'+@srv;
			set @cmd=N'dir /b '+@SourceFolder+N'\*.bak';
	
			insert into @tbl([FileBak])
			exec xp_cmdshell @cmd;
	
			set @ind=@ind-1;
		end
	end
	
	delete from @tbl
	where [FileBak]=N'File Not Found'
	   or [FileBak] is null;
	
	set @cmd=N'dir '+@path+N'\*.bak';
	
	insert into @inf
	exec xp_cmdshell @cmd;

	set @str_date=(
		select top(1) substring([inf], 1, 32) 
		from @inf
		where [inf] like '[0-9][0-9]%'
	);

	if(@str_date like '%/%') set @style_date=0;
	else if(@str_date like '%.%') set @style_date=104;
	
	;with tbl0 as (
		select replace(replace(inf,',',''),'.bak','') as inf
		from @inf
		where right(inf,4)='.bak'
	)
	, tbl1 as (
		select convert(datetime, left(inf,20), @style_date) as [DateModify],
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
		select t.[DateModify],
		replace(t.inf, char(160), N'') as inf,
		t.FileBak,
		tt.FileBak as SourceFileBak
		from @tbl as tt
		left outer join tbl2 as t on t.[FileBak]=substring(tt.[FileBak],1, len(tt.[FileBak])-len(N'.bak'))
	)
	select count(*) as [count]
	--select [DateModify],
	--cast(replace(inf, N' ', N'') as bigint)/1024.0/1024.0 as [size(Mb)],
	--FileBak,
	--SourceFileBak
	from tbl_res
	where [DateModify] is null
	or [DateModify]<=DateAdd(hour,-36,GetDate());
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает количество проблемных резервных копий по указанному пути (нехватка или дата создания свыше 24 часов)', @level0type = N'SCHEMA', @level0name = N'zabbix', @level1type = N'PROCEDURE', @level1name = N'GetFileBackupProblemCount';

