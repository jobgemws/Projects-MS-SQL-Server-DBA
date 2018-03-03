CREATE procedure [srv].[RunRequestGroupStatistics]
as
begin
	--сбор статистики по запросам
	truncate table [srv].[QueryRequestGroupStatistics];
	
	;with tbl as (
		select count(*) as [Count]
		  ,min([cpu_timeSec]) as [mincpu_timeSec]
		  ,max([cpu_timeSec]) as [maxcpu_timeSec]
		  ,min([wait_timeSec]) as [minwait_timeSec]
		  ,max([wait_timeSec]) as [maxwait_timeSec]
		  ,max([row_count]) as [row_count]
		  ,count([row_count]) as [SumCountRows]
		  ,min([reads]) as [min_reads]
		  ,max([reads]) as [max_reads]
		  ,min([writes]) as [min_writes]
		  ,max([writes]) as [max_writes]
		  ,min([logical_reads]) as [min_logical_reads]
		  ,max([logical_reads]) as [max_logical_reads]
		  ,min([open_transaction_count]) as [min_open_transaction_count]
		  ,max([open_transaction_count]) as [max_open_transaction_count]
		  ,min([transaction_isolation_level]) as [min_transaction_isolation_level]
		  ,max([transaction_isolation_level]) as [max_transaction_isolation_level]
		  ,min(total_elapsed_timeSec) as [mintotal_elapsed_timeSec]
		  ,max(total_elapsed_timeSec) as [maxtotal_elapsed_timeSec]
		  ,[sql_handle]
		from [srv].[vRequestStatistics] as tt with(readuncommitted)
		where [TSQL] is not null
		group by [sql_handle]
	)
	insert into [srv].[QueryRequestGroupStatistics](
					[TSQL],
					[Count],
					[mincpu_timeSec],
					[maxcpu_timeSec],
					[minwait_timeSec],
					[maxwait_timeSec],
					[row_count],
					[SumCountRows],
					[min_reads],
					[max_reads],
					[min_writes],
					[max_writes],
					[min_logical_reads],
					[max_logical_reads],
					[min_open_transaction_count],
					[max_open_transaction_count],
					[min_transaction_isolation_level],
					[max_transaction_isolation_level],
					[mintotal_elapsed_timeSec],
					[maxtotal_elapsed_timeSec],
					[DBName],
					[Unique_nt_user_name],
					[Unique_nt_domain],
					[Unique_login_name],
					[Unique_program_name],
					[Unique_host_name],
					[Unique_client_tcp_port],
					[Unique_client_net_address],
					[Unique_client_interface_name],
					[sql_handle]
				)
	select			(select top(1) [TSQL] from srv.SQLQuery as t where t.[SQLHandle]=tbl.[sql_handle]) as [TSQL],
					sum([Count]) as [Count],
					min([mincpu_timeSec]) as [mincpu_timeSec],
				    max([maxcpu_timeSec]) as [maxcpu_timeSec],
				    min([minwait_timeSec]) as [minwait_timeSec],
				    max([maxwait_timeSec]) as [maxwait_timeSec],
				    max([row_count]) as [row_count],
				    sum([SumCountRows]) as [SumCountRows],
				    min([min_reads]) as [min_reads],
				    max([max_reads]) as [max_reads],
				    min([min_writes]) as [min_writes],
				    max([max_writes]) as [max_writes],
				    min([min_logical_reads]) as [min_logical_reads],
				    max([max_logical_reads]) as [max_logical_reads],
				    min([min_open_transaction_count]) as [min_open_transaction_count],
				    max([max_open_transaction_count]) as [max_open_transaction_count],
				    min([min_transaction_isolation_level]) as [min_transaction_isolation_level],
				    max([max_transaction_isolation_level]) as [max_transaction_isolation_level],
				    min([mintotal_elapsed_timeSec]) as [mintotal_elapsed_timeSec],
				    max([maxtotal_elapsed_timeSec]) as [maxtotal_elapsed_timeSec],
					N'' as [DBName],
					N'' as [Unique_nt_user_name],
					N'' as [Unique_nt_domain],
					N'' as [Unique_login_name],
					N'' as [Unique_program_name],
					N'' as [Unique_host_name],
					N'' as [Unique_client_tcp_port],
					N'' as [Unique_client_net_address],
					N'' as [Unique_client_interface_name],
					[sql_handle]
	from tbl
	group by [sql_handle];

	declare @str nvarchar(max);
	declare @sql_handle varbinary(64);
	declare @tbl_temp table([sql_handle] varbinary(64));
	declare @tbl table ([sql_handle] varbinary(64), [TValue] nvarchar(max));

	insert into @tbl_temp([sql_handle])
	select [sql_handle]
	from [srv].[QueryRequestGroupStatistics]
	group by [sql_handle];

	delete from @tbl;

	while(exists(select top(1) 1 from @tbl_temp))
	begin
		set @str=N'';

		select top(1)
		@sql_handle=[sql_handle]
		from @tbl_temp;

		select @str=@str+N', '+[DBName]+N':'+cast(count(*) as nvarchar(255))
		from (
			select [DBName]
			from [srv].[vRequestStatistics] with(readuncommitted)
			where [sql_handle]=@sql_handle
			group by [DBName]
		) as t
		group by [DBName];

		insert into @tbl ([sql_handle], [TValue])
		select @sql_handle, @str;

		delete from @tbl_temp
		where [sql_handle]=@sql_handle;
	end

	update t
	set t.[DBName]=substring(tt.[TValue],3,len(tt.[TValue]))
	from [srv].[QueryRequestGroupStatistics] as t
	inner join @tbl as tt on t.[sql_handle]=tt.[sql_handle];

	insert into @tbl_temp([sql_handle])
	select [sql_handle]
	from [srv].[QueryRequestGroupStatistics]
	group by [sql_handle];

	delete from @tbl;

	while(exists(select top(1) 1 from @tbl_temp))
	begin
		set @str=N'';

		select top(1)
		@sql_handle=[sql_handle]
		from @tbl_temp;

		select @str=@str+N', '+[nt_user_name]+N':'+cast(count(*) as nvarchar(255))
		from (
			select [nt_user_name]
			from [srv].[vRequestStatistics] with(readuncommitted)
			where [sql_handle]=@sql_handle
			group by [nt_user_name]
		) as t
		group by [nt_user_name];

		insert into @tbl ([sql_handle], [TValue])
		select @sql_handle, @str;

		delete from @tbl_temp
		where [sql_handle]=@sql_handle;
	end

	update t
	set t.[Unique_nt_user_name]=substring(tt.[TValue],3,len(tt.[TValue]))
	from [srv].[QueryRequestGroupStatistics] as t
	inner join @tbl as tt on t.[sql_handle]=tt.[sql_handle];

	insert into @tbl_temp([sql_handle])
	select [sql_handle]
	from [srv].[QueryRequestGroupStatistics]
	group by [sql_handle];

	delete from @tbl;

	while(exists(select top(1) 1 from @tbl_temp))
	begin
		set @str=N'';

		select top(1)
		@sql_handle=[sql_handle]
		from @tbl_temp;

		select @str=@str+N', '+[nt_domain]+N':'+cast(count(*) as nvarchar(255))
		from (
			select [nt_domain]
			from [srv].[vRequestStatistics] with(readuncommitted)
			where [sql_handle]=@sql_handle
			group by [nt_domain]
		) as t
		group by [nt_domain];

		insert into @tbl ([sql_handle], [TValue])
		select @sql_handle, @str;

		delete from @tbl_temp
		where [sql_handle]=@sql_handle;
	end

	update t
	set t.[Unique_nt_domain]=substring(tt.[TValue],3,len(tt.[TValue]))
	from [srv].[QueryRequestGroupStatistics] as t
	inner join @tbl as tt on t.[sql_handle]=tt.[sql_handle];

	insert into @tbl_temp([sql_handle])
	select [sql_handle]
	from [srv].[QueryRequestGroupStatistics]
	group by [sql_handle];

	delete from @tbl;

	while(exists(select top(1) 1 from @tbl_temp))
	begin
		set @str=N'';

		select top(1)
		@sql_handle=[sql_handle]
		from @tbl_temp;

		select @str=@str+N', '+[login_name]+N':'+cast(count(*) as nvarchar(255))
		from (
			select [login_name]
			from [srv].[vRequestStatistics] with(readuncommitted)
			where [sql_handle]=@sql_handle
			group by [login_name]
		) as t
		group by [login_name];

		insert into @tbl ([sql_handle], [TValue])
		select @sql_handle, @str;

		delete from @tbl_temp
		where [sql_handle]=@sql_handle;
	end

	update t
	set t.[Unique_login_name]=substring(tt.[TValue],3,len(tt.[TValue]))
	from [srv].[QueryRequestGroupStatistics] as t
	inner join @tbl as tt on t.[sql_handle]=tt.[sql_handle];

	insert into @tbl_temp([sql_handle])
	select [sql_handle]
	from [srv].[QueryRequestGroupStatistics]
	group by [sql_handle];

	delete from @tbl;

	while(exists(select top(1) 1 from @tbl_temp))
	begin
		set @str=N'';

		select top(1)
		@sql_handle=[sql_handle]
		from @tbl_temp;

		select @str=@str+N', '+[program_name]+N':'+cast(count(*) as nvarchar(255))
		from (
			select [program_name]
			from [srv].[vRequestStatistics] with(readuncommitted)
			where [sql_handle]=@sql_handle
			group by [program_name]
		) as t
		group by [program_name];

		insert into @tbl ([sql_handle], [TValue])
		select @sql_handle, @str;

		delete from @tbl_temp
		where [sql_handle]=@sql_handle;
	end

	update t
	set t.[Unique_program_name]=substring(tt.[TValue],3,len(tt.[TValue]))
	from [srv].[QueryRequestGroupStatistics] as t
	inner join @tbl as tt on t.[sql_handle]=tt.[sql_handle];

	insert into @tbl_temp([sql_handle])
	select [sql_handle]
	from [srv].[QueryRequestGroupStatistics]
	group by [sql_handle];

	delete from @tbl;

	while(exists(select top(1) 1 from @tbl_temp))
	begin
		set @str=N'';

		select top(1)
		@sql_handle=[sql_handle]
		from @tbl_temp;

		select @str=@str+N', '+[host_name]+N':'+cast(count(*) as nvarchar(255))
		from (
			select [host_name]
			from [srv].[vRequestStatistics] with(readuncommitted)
			where [sql_handle]=@sql_handle
			group by [host_name]
		) as t
		group by [host_name];

		insert into @tbl ([sql_handle], [TValue])
		select @sql_handle, @str;

		delete from @tbl_temp
		where [sql_handle]=@sql_handle;
	end

	update t
	set t.[Unique_host_name]=substring(tt.[TValue],3,len(tt.[TValue]))
	from [srv].[QueryRequestGroupStatistics] as t
	inner join @tbl as tt on t.[sql_handle]=tt.[sql_handle];

	insert into @tbl_temp([sql_handle])
	select [sql_handle]
	from [srv].[QueryRequestGroupStatistics]
	group by [sql_handle];

	delete from @tbl;

	while(exists(select top(1) 1 from @tbl_temp))
	begin
		set @str=N'';

		select top(1)
		@sql_handle=[sql_handle]
		from @tbl_temp;

		select @str=@str+N', '+cast([client_tcp_port] as nvarchar(255))+N':'+cast(count(*) as nvarchar(255))
		from (
			select [client_tcp_port]
			from [srv].[vRequestStatistics] with(readuncommitted)
			where [sql_handle]=@sql_handle
			group by [client_tcp_port]
		) as t
		group by [client_tcp_port];

		insert into @tbl ([sql_handle], [TValue])
		select @sql_handle, @str;

		delete from @tbl_temp
		where [sql_handle]=@sql_handle;
	end

	update t
	set t.[Unique_client_tcp_port]=substring(tt.[TValue],3,len(tt.[TValue]))
	from [srv].[QueryRequestGroupStatistics] as t
	inner join @tbl as tt on t.[sql_handle]=tt.[sql_handle];

	insert into @tbl_temp([sql_handle])
	select [sql_handle]
	from [srv].[QueryRequestGroupStatistics]
	group by [sql_handle];

	delete from @tbl;

	while(exists(select top(1) 1 from @tbl_temp))
	begin
		set @str=N'';

		select top(1)
		@sql_handle=[sql_handle]
		from @tbl_temp;

		select @str=@str+N', '+[client_net_address]+N':'+cast(count(*) as nvarchar(255))
		from (
			select [client_net_address]
			from [srv].[vRequestStatistics] with(readuncommitted)
			where [sql_handle]=@sql_handle
			group by [client_net_address]
		) as t
		group by [client_net_address];

		insert into @tbl ([sql_handle], [TValue])
		select @sql_handle, @str;

		delete from @tbl_temp
		where [sql_handle]=@sql_handle;
	end

	update t
	set t.[Unique_client_net_address]=substring(tt.[TValue],3,len(tt.[TValue]))
	from [srv].[QueryRequestGroupStatistics] as t
	inner join @tbl as tt on t.[sql_handle]=tt.[sql_handle];

	insert into @tbl_temp([sql_handle])
	select [sql_handle]
	from [srv].[QueryRequestGroupStatistics]
	group by [sql_handle];

	delete from @tbl;

	while(exists(select top(1) 1 from @tbl_temp))
	begin
		set @str=N'';

		select top(1)
		@sql_handle=[sql_handle]
		from @tbl_temp;

		select @str=@str+N', '+[client_interface_name]+N':'+cast(count(*) as nvarchar(255))
		from (
			select [client_interface_name]
			from [srv].[vRequestStatistics] with(readuncommitted)
			where [sql_handle]=@sql_handle
			group by [client_interface_name]
		) as t
		group by [client_interface_name];

		insert into @tbl ([sql_handle], [TValue])
		select @sql_handle, @str;

		delete from @tbl_temp
		where [sql_handle]=@sql_handle;
	end

	update t
	set t.[Unique_client_interface_name]=substring(tt.[TValue],3,len(tt.[TValue]))
	from [srv].[QueryRequestGroupStatistics] as t
	inner join @tbl as tt on t.[sql_handle]=tt.[sql_handle];
end

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сбор статистики по запросам', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'RunRequestGroupStatistics';

