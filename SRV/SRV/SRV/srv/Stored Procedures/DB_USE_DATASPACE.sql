

--Цель: анализ свободного места в БД
--Автор: Прилепа Б.А. - АБД
--Дата создания: 10.08.2015

CREATE   procedure [srv].[DB_USE_DATASPACE]
	@DATABASE nvarchar(255)=N''
as
begin
	set nocount on;
	set xact_abort on;

	begin try
		--Цель: анализ свободного места в БД
		DECLARE @SQL nvarchar(max)=N'';
		
		IF (OBJECT_ID(N'tempdb..##DB_FILES', N'U') IS NOT NULL)	DROP TABLE tempdb..##DB_FILES;
		
		create table ##DB_FILES([Name] nvarchar(255), [FileName] nvarchar(2000),[Size(Mb)] numeric(11,2), [UsedSpace(Mb)] numeric(11,2), ID int);
		
		DECLARE @name nvarchar(255)=N'';
		
		DECLARE SysCur CURSOR LOCAL FOR 
		SELECT [name]
		FROM sys.databases
		WHERE @DATABASE=N''
		   OR [name]=@DATABASE;

		OPEN SysCur;

		FETCH NEXT FROM SysCur INTO @name;

		WHILE (@@FETCH_STATUS=0)
		BEGIN
			set @SQL=N'USE ['+@name+N']
			create table #tmpspc (Fileid int, FileGroup int, TotalExtents int, UsedExtents int, Name sysname, FileName nchar(520))
						insert #tmpspc EXEC (''dbcc showfilestats'')
			
			insert into ##DB_FILES([Name],[FileName],[Size(Mb)], [UsedSpace(Mb)],ID)
			SELECT
			cast(s.name as varchar(255)) AS [Name],
			cast(s.physical_name as varchar(2000)) AS [FileName],
			cast(round((s.size * CONVERT(float,8)/1024.0),2) AS numeric(11,2)) AS [Size(Mb)],
			cast(round((CAST(CASE s.type WHEN 2 THEN 0 ELSE tspc.UsedExtents*convert(float,64) END AS float)/1024.0),2) AS numeric(11,2)) AS [UsedSpace(Mb)],
			cast(s.file_id as INT) AS [ID]
			FROM
			sys.filegroups AS g
			INNER JOIN sys.master_files AS s ON ((s.type = 2 or s.type = 0) and s.database_id = db_id() and (s.drop_lsn IS NULL)) AND (s.data_space_id=g.data_space_id)
			LEFT OUTER JOIN #tmpspc tspc ON tspc.Fileid = s.file_id
			WHERE
			(CAST(cast(g.name as varbinary(256)) AS sysname)=N''PRIMARY'')
			UNION ALL
			SELECT
			s.name AS [Name],
			s.physical_name AS [FileName],
			round((s.size * CONVERT(float,8)/1024.0),2) AS [Size],
			round((CAST(FILEPROPERTY(s.name, ''SpaceUsed'') AS float)* CONVERT(float,8)/1024.0),2) AS [UsedSpace],
			s.file_id AS [ID]
			FROM
			sys.master_files AS s
			WHERE
			(s.type = 1 and s.database_id = db_id())
			ORDER BY
			[ID] ASC
			drop table #tmpspc';
		
			exec sp_executesql @SQL;

			FETCH NEXT FROM SysCur INTO @name;
		END

		CLOSE SysCur;
		DEALLOCATE SysCur;
		
		SELECT [Name],[FileName],[Size(Mb)], [UsedSpace(Mb)],[Size(Mb)]-[UsedSpace(Mb)] [Available(Mb)],cast((1-([UsedSpace(Mb)]/[Size(Mb)]))*100 as numeric(5,2)) [AvailbaleSpace(%)]
		FROM ##DB_FILES
		ORDER BY (1-([UsedSpace(Mb)]/[Size(Mb)]))*100 ASC;
		
		IF (OBJECT_ID('tempdb..##DB_FILES','U') IS NOT NULL) DROP TABLE tempdb..##DB_FILES;
	end try
	begin catch
		if (@@ERROR<>0)	SELECT ERROR_LINE() AS ERROR_LINE, ERROR_MESSAGE() AS ERROR_MESSAGE;
	end catch
end

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Анализ свободного места в БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'DB_USE_DATASPACE';

