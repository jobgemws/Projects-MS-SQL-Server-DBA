-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[GetPlansObject]
(	
	@ObjectID int,
	@DBID int
)
RETURNS TABLE 
AS
/*
	09.08.2017 ГЕМ: возвращает все планы заданного объекта
*/
RETURN 
(
	select 
	creation_time,
	last_execution_time,
	execution_count,
	total_worker_time/1000 as CPU,
	convert(money, (total_worker_time))/(execution_count*1000)as [AvgCPUTime],
	qs.total_elapsed_time/1000 as TotDuration,
	convert(money, (qs.total_elapsed_time))/(execution_count*1000)as [AvgDur],
	total_logical_reads as [Reads],
	total_logical_writes as [Writes],
	total_logical_reads+total_logical_writes as [AggIO],
	convert(money, (total_logical_reads+total_logical_writes)/(execution_count + 0.0))as [AvgIO],
	case 
		when sql_handle IS NULL then ' '
		else(substring(st.text,(qs.statement_start_offset+2)/2,(
			case
				when qs.statement_end_offset =-1 then len(convert(nvarchar(MAX),st.text))*2      
				else qs.statement_end_offset    
			end - qs.statement_start_offset)/2  ))
	end as query_text,
	db_name(st.dbid)as database_name,
	object_schema_name(st.objectid, st.dbid)+'.'+object_name(st.objectid, st.dbid) as object_name,
	qp.query_plan
	from sys.dm_exec_query_stats  qs
	cross apply sys.dm_exec_sql_text(sql_handle) st
	cross apply sys.dm_exec_query_plan(qs.plan_handle) qp
	where st.objectid=@ObjectID and st.dbid=@DBID
)

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает все планы заданного объекта', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'FUNCTION', @level1name = N'GetPlansObject';

