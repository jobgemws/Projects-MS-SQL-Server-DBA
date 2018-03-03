-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [srv].[InsertTableStatistics]
AS
BEGIN
	/*
		собирает кол-во строк в каждой таблице по кластерным индексам (примерное кол-во)+размеры таблиц
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @dt date=CAST(GetUTCDate() as date);
    declare @dbs nvarchar(255);
	declare @sql nvarchar(max);

	select [name]
	into #dbs3
	from [master].sys.databases;

	while(exists(select top(1) 1 from #dbs3))
	begin
		select top(1)
		@dbs=[name]
		from #dbs3;

		set @sql=
		N'USE ['+@dbs+']; '
		+N'IF(object_id('+N''''+N'[inf].[vCountRows]'+N''''+N') is not null) BEGIN '
		+N'insert into [SRV].[srv].[TableIndexStatistics]
	         ([ServerName]
				   ,[DBName]
		           ,[SchemaName]
		           ,[TableName]
		           ,[IndexUsedForCounts]
		           ,[CountRows])
		SELECT [ServerName]
			  ,[DBName]
		      ,[SchemaName]
		      ,[TableName]
		      ,[IndexUsedForCounts]
		      ,[Rows]
		  FROM [inf].[vCountRows]
		  where [Type_Desc]='+''''+'CLUSTERED'+''''+'; END';

		exec sp_executesql @sql;

		delete from #dbs3
		where [name]=@dbs;
	end

	select [name]
	into #dbs
	from sys.databases;

	while(exists(select top(1) 1 from #dbs))
	begin
		select top(1)
		@dbs=[name]
		from #dbs;

		set @sql=
		N'USE ['+@dbs+']; '
		+N'IF(object_id('+N''''+N'[inf].[vTableSize]'+N''''+N') is not null) BEGIN '
		+N'INSERT INTO [SRV].[srv].[TableStatistics]
	         ([ServerName]
			   ,[DBName]
	         ,[SchemaName]
	         ,[TableName]
	         ,[CountRows]
	         ,[DataKB]
	         ,[IndexSizeKB]
	         ,[UnusedKB]
	         ,[ReservedKB]
			 ,[TotalPageSizeKB]
			 ,[UsedPageSizeKB]
			 ,[DataPageSizeKB])
	   SELECT [Server]
		  ,[DBName]
	         ,[SchemaName]
	         ,[TableName]
	         ,[CountRows]
	         ,[DataKB]
	         ,[IndexSizeKB]
	         ,[UnusedKB]
	         ,[ReservedKB]
			 ,[TotalPageSizeKB]
			 ,[UsedPageSizeKB]
			 ,[DataPageSizeKB]
		FROM ['+@dbs+'].[inf].[vTableSize]; END';

		exec sp_executesql @sql;

		delete from #dbs
		where [name]=@dbs;
	end

	drop table #dbs;
	drop table #dbs3;

	declare @dt_back date=CAST(DateAdd(day,-1,@dt) as date);

	;with tbl1 as (
		select [Date], 
			   [CountRows],
			   [DataKB],
			   [IndexSizeKB],
			   [UnusedKB],
			   [ReservedKB],
			   [ServerName], 
			   [DBName], 
			   [SchemaName], 
			   [TableName],
			   [TotalPageSizeKB],
			   [UsedPageSizeKB],
			   [DataPageSizeKB]
		from [srv].[TableStatistics]
		where [Date]=@dt_back
	)
	, tbl2 as (
		select [Date], 
			   [CountRows], 
			   [CountRowsBack],
			   [DataKBBack],
			   [IndexSizeKBBack],
			   [UnusedKBBack],
			   [ReservedKBBack],
			   [ServerName], 
			   [DBName], 
			   [SchemaName], 
			   [TableName],
			   [TotalPageSizeKBBack],
			   [UsedPageSizeKBBack],
			   [DataPageSizeKBBack]
		from [srv].[TableStatistics]
		where [Date]=@dt
	)
	update t2
	set t2.[CountRowsBack]		=t1.[CountRows],
		t2.[DataKBBack]			=t1.[DataKB],
		t2.[IndexSizeKBBack]	=t1.[IndexSizeKB],
		t2.[UnusedKBBack]		=t1.[UnusedKB],
		t2.[ReservedKBBack]		=t1.[ReservedKB],
		t2.[TotalPageSizeKBBack]=t1.[TotalPageSizeKB],
		t2.[UsedPageSizeKBBack]	=t1.[UsedPageSizeKB],
		t2.[DataPageSizeKBBack]	=t1.[DataPageSizeKB]
	from tbl1 as t1
	inner join tbl2 as t2 on t1.[Date]=DateAdd(day,-1,t2.[Date])
	and t1.[ServerName]=t2.[ServerName]
	and t1.[DBName]=t2.[DBName]
	and t1.[SchemaName]=t2.[SchemaName]
	and t1.[TableName]=t2.[TableName];

	;with tbl1 as (
		select [Date], 
			   [CountRows], 
			   [CountRowsNext],
			   [DataKBNext],
			   [IndexSizeKBNext],
			   [UnusedKBNext],
			   [ReservedKBNext],
			   [ServerName], 
			   [DBName], 
			   [SchemaName], 
			   [TableName],
			   [TotalPageSizeKBNext],
			   [UsedPageSizeKBNext],
			   [DataPageSizeKBNext]
		from [srv].[TableStatistics]
		where [Date]=@dt_back
	)
	, tbl2 as (
		select [Date], 
			   [CountRows],
			   [DataKB],
			   [IndexSizeKB],
			   [UnusedKB],
			   [ReservedKB],
			   [ServerName], 
			   [DBName], 
			   [SchemaName], 
			   [TableName],
			   [TotalPageSizeKB],
			   [UsedPageSizeKB],
			   [DataPageSizeKB]
		from [srv].[TableStatistics]
		where [Date]=@dt
	)
	update t1
	set t1.[CountRowsNext]		=t2.[CountRows],
		t1.[DataKBNext]			=t2.[DataKB],
		t1.[IndexSizeKBNext]	=t2.[IndexSizeKB],
		t1.[UnusedKBNext]		=t2.[UnusedKB],
		t1.[ReservedKBNext]		=t2.[ReservedKB],
		t1.[TotalPageSizeKBNext]=t2.[TotalPageSizeKB],
		t1.[UsedPageSizeKBNext]	=t2.[UsedPageSizeKB],
		t1.[DataPageSizeKBNext]	=t2.[DataPageSizeKB]
	from tbl1 as t1
	inner join tbl2 as t2 on t1.[Date]=DateAdd(day,-1,t2.[Date])
	and t1.[ServerName]=t2.[ServerName]
	and t1.[DBName]=t2.[DBName]
	and t1.[SchemaName]=t2.[SchemaName]
	and t1.[TableName]=t2.[TableName];
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Собирает кол-во строк в каждой таблице по кластерным индексам (примерное кол-во)+размеры таблиц', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'InsertTableStatistics';

