with s as (
	select  top(100)
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
			convert(money, (total_logical_reads+total_logical_writes)/(execution_count + 0.0)) as [AvgIO],
			[sql_handle],
			plan_handle,
			statement_start_offset,
			statement_end_offset,
			plan_generation_num,
			total_physical_reads,
			convert(money, total_physical_reads/(execution_count + 0.0)) as [AvgIOPhysicalReads],
			convert(money, total_logical_reads/(execution_count + 0.0)) as [AvgIOLogicalReads],
			convert(money, total_logical_writes/(execution_count + 0.0)) as [AvgIOLogicalWrites],
			query_hash,
			query_plan_hash,
			total_rows,
			convert(money, total_rows/(execution_count + 0.0)) as [AvgRows],
			total_dop,
			convert(money, total_dop/(execution_count + 0.0)) as [AvgDop],
			total_grant_kb,
			convert(money, total_grant_kb/(execution_count + 0.0)) as [AvgGrantKb],
			total_used_grant_kb,
			convert(money, total_used_grant_kb/(execution_count + 0.0)) as [AvgUsedGrantKb],
			total_ideal_grant_kb,
			convert(money, total_ideal_grant_kb/(execution_count + 0.0)) as [AvgIdealGrantKb],
			total_reserved_threads,
			convert(money, total_reserved_threads/(execution_count + 0.0)) as [AvgReservedThreads],
			total_used_threads,
			convert(money, total_used_threads/(execution_count + 0.0)) as [AvgUsedThreads]
	from sys.dm_exec_query_stats as qs with(readuncommitted)
	order by [AvgIdealGrantKb] DESC--convert(money, (qs.total_elapsed_time))/(execution_count*1000) desc-->=100 --выполнялся запрос не менее 100 мс
)
select
	s.creation_time,
	s.last_execution_time,
	s.execution_count,
	s.CPU,
	s.[AvgCPUTime],
	s.TotDuration,
	s.[AvgDur],
	s.[AvgIOLogicalReads],
	s.[AvgIOLogicalWrites],
	s.[AggIO],
	s.[AvgIO],
	s.[AvgIOPhysicalReads],
	s.plan_generation_num,
	s.[AvgRows],
	s.[AvgDop],
	s.[AvgGrantKb],
	s.[AvgUsedGrantKb],
	s.[AvgIdealGrantKb],
	s.[AvgReservedThreads],
	s.[AvgUsedThreads],
	--st.text as query_text,
	case 
		when sql_handle IS NULL then ' '
		else(substring(st.text,(s.statement_start_offset+2)/2,(
			case
				when s.statement_end_offset =-1 then len(convert(nvarchar(MAX),st.text))*2      
				else s.statement_end_offset    
			end - s.statement_start_offset)/2  ))
	end as query_text,
	db_name(st.dbid) as database_name,
	object_schema_name(st.objectid, st.dbid)+'.'+object_name(st.objectid, st.dbid) as [object_name],
	sp.[query_plan],
	s.[sql_handle],
	s.plan_handle,
	s.query_hash,
	s.query_plan_hash
from s
cross apply sys.dm_exec_sql_text(s.[sql_handle]) as st
cross apply sys.dm_exec_query_plan(s.[plan_handle]) as sp
ORDER BY s.[AvgIdealGrantKb] DESC