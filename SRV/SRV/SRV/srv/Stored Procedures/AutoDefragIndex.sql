CREATE PROCEDURE [srv].[AutoDefragIndex]
	@count int=null --кол-во одновременно обрабатываемых индексов
	,@isrebuild bit=0 --позволять ли перестраиваться индексам (фрагментация которых свыше 30%)
	,@isclear bit=1 --очистить обработанные индексы (т е заново оптимизировать индексы)
AS
BEGIN
	/*
		оптимизация индексов
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	if(@isclear=1)
	begin
		delete from [FortisAdmin].[srv].[ListDefragIndex]
		where [db_id]=DB_ID();
	end

	--определяем возможность перестраивать индекс в режиме ONLINE
	declare @isRebuildOnline bit=CASE WHEN (CAST (SERVERPROPERTY ('Edition') AS nvarchar (max)) LIKE '%Enterprise%' OR CAST (SERVERPROPERTY ('Edition') AS nvarchar (max)) LIKE '%Developer%' OR CAST (SERVERPROPERTY ('Edition') AS nvarchar (max)) LIKE '%Evaluation%') THEN 1 ELSE 0 END;

	declare @IndexName		nvarchar(255)
			,@db			nvarchar(255)
			,@db_id			int
			,@Shema			nvarchar(255)
			,@Table			nvarchar(255)
			,@SQL_Str		nvarchar (max)=N''
			,@frag			decimal(6,2)
			,@frag_after	decimal(6,2)
			,@frag_num		int
			,@page			int
			,@ts			datetime
			,@tsg			datetime
			,@tf			datetime
			,@object_id		int
			,@idx			int
			,@rec			int;

	--для обработки
	declare @tbl table (
						IndexName		nvarchar(255)
						,db				nvarchar(255)
						,[db_id]		int
						,Shema			nvarchar(255)
						,[Table]		nvarchar(255)
						,frag			decimal(6,2)
						,frag_num		int
						,[page]			int
						,[object_id]	int
						,idx			int
						,rec			int
					   );

	--для истории
	declare @tbl_copy table (
						IndexName		nvarchar(255)
						,db				nvarchar(255)
						,[db_id]		int
						,Shema			nvarchar(255)
						,[Table]		nvarchar(255)
						,frag			decimal(6,2)
						,frag_num		int
						,[page]			int
						,[object_id]	int
						,idx			int
						,rec			int
					   );

	set @ts = getdate()
	set @tsg = @ts;
	
	--выбираем индексы, которые фрагментированы не менее, чем на 10%
	--и которые еще не выбирались
	if(@count is null)
	begin
		insert into @tbl (
						IndexName	
						,db			
						,[db_id]	
						,Shema		
						,[Table]		
						,frag		
						,frag_num	
						,[page]				
						,[object_id]
						,idx		
						,rec		
					 )
		select				ind.index_name,
							ind.db,
							ind.database_id,
							ind.shema,
							ind.tb,
							ind.frag,
							ind.frag_num,
							ind.[page],
							ind.[object_id],
							ind.idx ,
							ind.rec
		from  [inf].[vIndexDefrag] as ind
		where not exists(
							select top(1) 1 from [FortisAdmin].[srv].[ListDefragIndex] as lind
							where lind.[db_id]=ind.database_id
							  and lind.[idx]=ind.idx
							  and lind.[object_id]=ind.[object_id]
						)
		--order by ind.[page] desc, ind.[frag] desc
	end
	else
	begin
		insert into @tbl (
						IndexName	
						,db			
						,[db_id]	
						,Shema		
						,[Table]		
						,frag		
						,frag_num	
						,[page]				
						,[object_id]
						,idx		
						,rec		
					 )
		select top (@count)
							ind.index_name,
							ind.db,
							ind.database_id,
							ind.shema,
							ind.tb,
							ind.frag,
							ind.frag_num,
							ind.[page],
							ind.[object_id],
							ind.idx ,
							ind.rec
		from  [inf].[vIndexDefrag] as ind
		where not exists(
							select top(1) 1 from [FortisAdmin].[srv].[ListDefragIndex] as lind
							where lind.[db_id]=ind.database_id
							  and lind.[idx]=ind.idx
							  and lind.[object_id]=ind.[object_id]
						)
		--order by ind.[page] desc, ind.[frag] desc
	end
	
	--если все индексы выбирались (т е выборка пуста)
	--то очищаем таблицу обработанных индексов
	--и начинаем заново
	if(not exists(select top(1) 1 from @tbl))
	begin
		delete from [FortisAdmin].[srv].[ListDefragIndex]
		where [db_id]=DB_ID();

		if(@count is null)
		begin
			insert into @tbl (
							IndexName	
							,db			
							,[db_id]	
							,Shema		
							,[Table]		
							,frag		
							,frag_num	
							,[page]				
							,[object_id]
							,idx		
							,rec		
						 )
			select				ind.index_name,
								ind.db,
								ind.database_id,
								ind.shema,
								ind.tb,
								ind.frag,
								ind.frag_num,
								ind.[page],
								ind.[object_id],
								ind.idx ,
								ind.rec
			from  [inf].[vIndexDefrag] as ind
			where not exists(
								select top(1) 1 from [FortisAdmin].[srv].[ListDefragIndex] as lind
								where lind.[db_id]=ind.database_id
								  and lind.[idx]=ind.idx
								  and lind.[object_id]=ind.[object_id]
							)
			--order by ind.[page] desc, ind.[frag] desc
		end
		else
		begin
			insert into @tbl (
							IndexName	
							,db			
							,[db_id]	
							,Shema		
							,[Table]		
							,frag		
							,frag_num	
							,[page]				
							,[object_id]
							,idx		
							,rec		
						 )
			select top (@count)
								ind.index_name,
								ind.db,
								ind.database_id,
								ind.shema,
								ind.tb,
								ind.frag,
								ind.frag_num,
								ind.[page],
								ind.[object_id],
								ind.idx ,
								ind.rec
			from  [inf].[vIndexDefrag] as ind
			where not exists(
								select top(1) 1 from [FortisAdmin].[srv].[ListDefragIndex] as lind
								where lind.[db_id]=ind.database_id
								  and lind.[idx]=ind.idx
								  and lind.[object_id]=ind.[object_id]
							)
			--order by ind.[page] desc, ind.[frag] desc
		end
	end

	--если выборка не пустая
	if(exists(select top(1) 1 from @tbl))
	begin
		--запоминаем выбранные индексы
		INSERT INTO [FortisAdmin].[srv].[ListDefragIndex]
		       (
				 [db]
				,[shema]
				,[table]
				,[IndexName]
				,[object_id]
				,[idx]
				,[db_id]
				,[frag]
			   )
		select	 [db]
				,[shema]
				,[table]
				,[IndexName]
				,[object_id]
				,[idx]
				,[db_id]
				,[frag]
		from @tbl;

		insert into @tbl_copy (
						IndexName	
						,db			
						,[db_id]	
						,Shema		
						,[Table]	
						,frag		
						,frag_num	
						,[page]			
						,[object_id]
						,idx		
						,rec		
					 )
		select			IndexName	
						,db			
						,[db_id]	
						,Shema		
						,[Table]	
						,frag			
						,frag_num	
						,[page]				
						,[object_id]
						,idx		
						,rec	
		from @tbl;
		
		DECLARE sql_cursor CURSOR LOCAL FOR
		select replace([IndexName], N']', N']]'),
			   replace([Shema], N']', N']]'),
			   replace([Table], N']', N']]')
		from @tbl;
		
		OPEN sql_cursor;
		  
		FETCH NEXT FROM sql_cursor   
		INTO @IndexName, @Shema, @Table;
		
		--формируем запрос на оптимизацию выбранных индексов (в случае реорганизации-с последующим обновлением статистики по ним)
		while (@@FETCH_STATUS = 0)
		begin
			if(@frag>=30 and @isrebuild=1 and @isRebuildOnline=1)
			begin
				set @SQL_Str = @SQL_Str+'begin try ALTER INDEX ['+@IndexName+'] on ['+@Shema+'].['+@Table+'] REBUILD WITH(ONLINE=ON); end try begin catch print 0; end catch '
			end
			else
			begin
				set @SQL_Str = @SQL_Str+'begin try ALTER INDEX ['+@IndexName+'] on ['+@Shema+'].['+@Table+'] REORGANIZE;'
									   +'UPDATE STATISTICS ['+@Shema+'].['+@Table+'] ['+@IndexName+']; end try begin catch print 0; end catch ';
			end

			FETCH NEXT FROM sql_cursor   
			INTO @IndexName, @Shema, @Table;
		end

		CLOSE sql_cursor;
		DEALLOCATE sql_cursor;

		--оптимизируем выбранные индексы
		execute sp_executesql  @SQL_Str;

		--записываем результат оптимизации индексов
		insert into [FortisAdmin].srv.Defrag(
									[db],
									[shema],
									[table],
									[IndexName],
									[frag_num],
									[frag],
									[page],
									ts,
									tf,
									frag_after,
									[object_id],
									idx,
									rec
								  )
						select
									[db],
									[shema],
									[table],
									[IndexName],
									[frag_num],
									[frag],
									[page],
									@ts,
									getdate(),
									(SELECT top(1) avg_fragmentation_in_percent
									FROM sys.dm_db_index_physical_stats
										(DB_ID([db]), [object_id], [idx], NULL ,
										N'LIMITED')
									where index_level = 0) as frag_after,
									[object_id],
									[idx],
									[rec]
						from	@tbl_copy;
	end
END



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Выполняет оптимизацию индексов (поверхностный обход узлов)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'AutoDefragIndex';

