



CREATE   PROCEDURE [srv].[MergeDBFileInfo]
AS
BEGIN
	/*
		обновляет таблицу файлов БД
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @servername nvarchar(255)=cast(SERVERPROPERTY(N'MachineName') as nvarchar(255));

	;merge [srv].[DBFile] as f
	using [inf].[ServerDBFileInfo] as ff
	on f.File_ID=ff.File_ID and f.DB_ID=ff.[database_id] and f.[Server]=ff.[Server]
	when matched then
		update set UpdateUTCDate	= getUTCDate()
				 ,[Name]			= ff.[FileName]			
				 ,[Drive]			= ff.[Drive]			
				 ,[Physical_Name]	= ff.[Physical_Name]	
				 ,[Ext]				= ff.[Ext]				
				 ,[Growth]			= ff.[Growth]			
				 ,[IsPercentGrowth]	= ff.[is_percent_growth]	
				 ,[SizeMb]			= ff.[SizeMb]			
				 ,[DiffSizeMb]		= round(ff.[SizeMb]-f.[SizeMb],3)	
	when not matched by target then
		insert (
				[Server]
				,[Name]
				,[Drive]
				,[Physical_Name]
				,[Ext]
				,[Growth]
				,[IsPercentGrowth]
				,[DB_ID]
				,[DB_Name]
				,[SizeMb]
				,[File_ID]
				,[DiffSizeMb]
			   )
		values (
				ff.[Server]
				,ff.[FileName]
				,ff.[Drive]
				,ff.[Physical_Name]
				,ff.[Ext]
				,ff.[Growth]
				,ff.[is_percent_growth]
				,ff.[database_id]
				,ff.[DB_Name]
				,ff.[SizeMb]
				,ff.[File_id]
				,0
			   )
	when not matched by source and f.[Server]=@servername then delete;
END



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Обновляет таблицу по файлам БД', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'MergeDBFileInfo';

