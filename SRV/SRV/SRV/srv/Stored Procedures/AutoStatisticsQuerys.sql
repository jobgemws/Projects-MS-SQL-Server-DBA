-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[AutoStatisticsQuerys]
AS
BEGIN
	/*
		Сбор данных о запросах по статистикам MS SQL Server
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	select [ID]
	into #tbl
	from [srv].[QueryStatistics]
	where [InsertUTCDate]<=DateAdd(day,-180,GetUTCDate());

	delete from qs
	from #tbl as t
	inner join [srv].[QueryStatistics] as qs on t.[ID]=qs.[ID];

	declare @tbl0 table (
						[SQLHandle] [varbinary](64) NOT NULL,
						[TSQL] [nvarchar](max) NULL
					   );

	declare @tbl1 table (
						[PlanHandle] [varbinary](64) NOT NULL,
						[SQLHandle] [varbinary](64) NOT NULL,
						[QueryPlan] [xml] NULL
					   );

	declare @tbl2 table (
							[creation_time] [datetime] NOT NULL,
							[last_execution_time] [datetime] NOT NULL,
							[execution_count] [bigint] NOT NULL,
							[CPU] [bigint] NULL,
							[AvgCPUTime] [money] NULL,
							[TotDuration] [bigint] NULL,
							[AvgDur] [money] NULL,
							[Reads] [bigint] NOT NULL,
							[Writes] [bigint] NOT NULL,
							[AggIO] [bigint] NULL,
							[AvgIO] [money] NULL,
							[sql_handle] [varbinary](64) NOT NULL,
							[plan_handle] [varbinary](64) NOT NULL,
							[statement_start_offset] [int] NOT NULL,
							[statement_end_offset] [int] NOT NULL,
							[query_text] [nvarchar](max) NULL,
							[database_name] [nvarchar](128) NULL,
							[object_name] [nvarchar](257) NULL,
							[query_plan] [xml] NULL
						);

	INSERT INTO @tbl2
           ([creation_time]
           ,[last_execution_time]
           ,[execution_count]
           ,[CPU]
           ,[AvgCPUTime]
           ,[TotDuration]
           ,[AvgDur]
           ,[Reads]
           ,[Writes]
           ,[AggIO]
           ,[AvgIO]
           ,[sql_handle]
           ,[plan_handle]
           ,[statement_start_offset]
           ,[statement_end_offset]
           ,[query_text]
           ,[database_name]
           ,[object_name]
           ,[query_plan])
	select  qs.creation_time,
			qs.last_execution_time,
			qs.execution_count,
			qs.total_worker_time/1000 as CPU,
			convert(money, (qs.total_worker_time))/(qs.execution_count*1000)as [AvgCPUTime],
			qs.total_elapsed_time/1000 as TotDuration,
			convert(money, (qs.total_elapsed_time))/(qs.execution_count*1000)as [AvgDur],
			total_logical_reads as [Reads],
			total_logical_writes as [Writes],
			total_logical_reads+total_logical_writes as [AggIO],
			convert(money, (qs.total_logical_reads+qs.total_logical_writes)/(qs.execution_count + 0.0))as [AvgIO],
			qs.[sql_handle],
			qs.plan_handle,
			qs.statement_start_offset,
			qs.statement_end_offset,
			case 
				when sql_handle IS NULL then ' '
				else(substring(st.text,(qs.statement_start_offset+2)/2,(
					case
						when qs.statement_end_offset =-1 then len(convert(nvarchar(MAX),st.text))*2      
						else qs.statement_end_offset    
					end - qs.statement_start_offset)/2  ))
			end as query_text,
			db_name(st.dbid) as database_name,
			object_schema_name(st.objectid, st.dbid)+'.'+object_name(st.objectid, st.dbid) as [object_name],
			sp.[query_plan]
	from sys.dm_exec_query_stats as qs with(readuncommitted)
	cross apply sys.dm_exec_sql_text(qs.[sql_handle]) as st
	cross apply sys.dm_exec_query_plan(qs.[plan_handle]) as sp;

	insert into @tbl1 (
						[PlanHandle],
						[SQLHandle],
						[QueryPlan]
					  )
	select				[plan_handle],
						[sql_handle],
						(select top(1) [query_plan] from sys.dm_exec_query_plan([plan_handle])) as [QueryPlan]--cast(cast([query_plan] as nvarchar(max)) as XML),
	from @tbl2
	group by [plan_handle],
			 [sql_handle];--,
			 --cast([query_plan] as nvarchar(max)),
			 --[query_text];

	insert into @tbl0 (
						[SQLHandle],
						[TSQL]
					  )
	select				[sql_handle],
						(select top(1) text from sys.dm_exec_sql_text([sql_handle])) as [TSQL]--[query_text]
	from @tbl2
	group by [sql_handle];--,
			 --cast([query_plan] as nvarchar(max)),
			 --[query_text];

	;merge [srv].[SQLQuery] as trg
	using @tbl0 as src on trg.[SQLHandle]=src.[SQLHandle]
	WHEN NOT MATCHED BY TARGET THEN
	INSERT (
		 	[SQLHandle],
		 	[TSQL]
		   )
	VALUES (
		 	src.[SQLHandle],
		 	src.[TSQL]
		   );
	
	;merge [srv].[PlanQuery] as trg
	using @tbl1 as src on trg.[SQLHandle]=src.[SQLHandle] and trg.[PlanHandle]=src.[PlanHandle]
	WHEN NOT MATCHED BY TARGET THEN
	INSERT (
		 	[PlanHandle],
		 	[SQLHandle],
		 	[QueryPlan]
		   )
	VALUES (
			src.[PlanHandle],
		 	src.[SQLHandle],
		 	src.[QueryPlan]
		   );

    INSERT INTO [srv].[QueryStatistics]
           ([creation_time]
           ,[last_execution_time]
           ,[execution_count]
           ,[CPU]
           ,[AvgCPUTime]
           ,[TotDuration]
           ,[AvgDur]
           ,[Reads]
           ,[Writes]
           ,[AggIO]
           ,[AvgIO]
           ,[sql_handle]
           ,[plan_handle]
           ,[statement_start_offset]
           ,[statement_end_offset]
           --,[query_text]
           ,[database_name]
           ,[object_name]
           --,[query_plan]
		   )
	select  [creation_time]
           ,[last_execution_time]
           ,[execution_count]
           ,[CPU]
           ,[AvgCPUTime]
           ,[TotDuration]
           ,[AvgDur]
           ,[Reads]
           ,[Writes]
           ,[AggIO]
           ,[AvgIO]
           ,[sql_handle]
           ,[plan_handle]
           ,[statement_start_offset]
           ,[statement_end_offset]
           --,[query_text]
           ,[database_name]
           ,[object_name]
           --,[query_plan]
	from @tbl2;
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сбор данных о запросах по статистикам MS SQL Server', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoStatisticsQuerys';

