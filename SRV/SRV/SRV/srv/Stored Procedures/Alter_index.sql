

--Анализ используемости, фрагментированности, важности индекса и его реорганизация/перестроение
--Прилепа Б.А. - АБД
--21.03.2019

CREATE   PROCEDURE [srv].[Alter_index]
	@DB nvarchar(255)=N'CompositeQuestions',
	@frag int=8,
	@danger int=2,
	@timeout int=5000,
	@op int=1,
	@TableRows int=1000,
	@MaxTableRows bigint=500000,
	@dop int=1000,
	@MI_U int=30,
	@MI_S int=10,
	@FillFactor tinyint=80
AS
BEGIN
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @tbl table([index] nvarchar(2000), [schema_name] varchar(255),[tbl] nvarchar(2000),index_id int,[object_id] int,[type] int,op int,k int identity not null)

	declare @SQL nvarchar(2000)--SQL контэйнер

	SET @SQL='SELECT i.name [index],o.name as [tbl],sh.name [schema_name],i.index_id,o.object_id,i.[type]
	,case when '+cast(@op as varchar(1))+'=1 or p.TableRows>='+cast(@MaxTableRows as varchar(50))+'
	 or (isnull(dm_ius.user_seeks,0)+ isnull(dm_ius.user_scans,0)+isnull(dm_ius.user_lookups,0))*'+cast(@danger as varchar(5))+'<=isnull(dm_ius.user_updates,0) then 1 else 0 end as op
	 FROM ['+@DB+'].sys.dm_db_index_usage_stats dm_ius
	 INNER JOIN ['+@DB+'].sys.indexes i ON i.index_id = dm_ius.index_id AND dm_ius.OBJECT_ID = i.OBJECT_ID
	 INNER JOIN ['+@DB+'].sys.objects o ON dm_ius.OBJECT_ID = o.OBJECT_ID
	 INNER JOIN ['+@DB+'].sys.schemas sh ON o.SCHEMA_ID =sh.SCHEMA_ID
	 INNER JOIN (SELECT SUM(p.rows) TableRows, p.index_id, p.OBJECT_ID
	 FROM ['+@DB+'].sys.partitions p GROUP BY p.index_id, p.OBJECT_ID) p
	 ON p.index_id = dm_ius.index_id AND dm_ius.OBJECT_ID = p.OBJECT_ID
	 WHERE i.type_desc in(''clustered'', ''nonclustered'') 	and (p.TableRows>='+cast(@TableRows as varchar(50))+' and p.TableRows<='+cast(@MaxTableRows*10 as varchar(50))+')
	 AND ((isnull(dm_ius.user_seeks,0)+ isnull(dm_ius.user_scans,0)+isnull(dm_ius.user_lookups,0)>'+cast(@dop as varchar(50))+'))
	 AND (last_user_seek>=cast(dateadd(MI,-'+cast(@MI_S as varchar(50))+',getdate()) as date)
	 OR last_user_scan>=cast(dateadd(MI,-'+cast(@MI_S as varchar(50))+',getdate()) as date)
	 OR last_user_lookup>=cast(dateadd(MI,-'+cast(@MI_S as varchar(50))+',getdate()) as date))
	 AND cast(last_user_update as date)>=cast(dateadd(MI,-'+cast(@MI_U as varchar(50))+',getdate()) as date)
	 order by (isnull(dm_ius.user_seeks,0)+ isnull(dm_ius.user_scans,0)+isnull(dm_ius.user_lookups,0)) desc, user_updates desc '

	insert into @tbl([index], [tbl],[schema_name],index_id, object_id, [type], [op])
	exec sp_executesql @SQL

	--print @SQL
	set @SQL=''

	--счетчик операций
	declare @k int=0

	DECLARE SSCur CURSOR LOCAL FOR SELECT k,'SET LOCK_TIMEOUT '+cast(@timeout as varchar(50))+';
	 ALTER INDEX ['+[index]+'] ON ['+@DB+'].['+[schema_name]+'].['+tbl+'] '+case when @op=1 or op=1 then 'REORGANIZE'
	 when @op=0 then 'REBUILD PARTITION = ALL WITH (SORT_IN_TEMPDB = ON,ALLOW_ROW_LOCKS = ON, FILLFACTOR = '+cast(@FillFactor as varchar(2))+')' end+'
	 UPDATE STATISTICS ['+@DB+'].['+[schema_name]+'].['+tbl+'] ['+[index]+']  WITH FULLSCAN' as script FROM (	SELECT [index],[tbl],[schema_name],op,k FROM @tbl a 
	CROSS APPLY (select top 1 avg_fragmentation_in_percent from sys.dm_db_index_physical_stats(DB_ID(@DB), a.object_id, a.index_id, NULL, NULL)) tbl
	where (tbl.avg_fragmentation_in_percent>@frag and a.[type]=1) OR (tbl.avg_fragmentation_in_percent>@frag*(@frag/2.0) and a.[type]=2)) t
	OPEN SSCur
	FETCH NEXT FROM SSCur INTO @k, @SQL
	WHILE @@FETCH_STATUS=0 BEGIN
		begin try
		    --запуск в цикле скриптов
			print @SQL
			exec sp_executesql @SQL
		end try
		begin catch
			insert into @tbl([index], [tbl],[schema_name],index_id, object_id, [type], [op])
			select top 1 [index], [tbl],[schema_name],index_id, object_id, [type], 1 as [op] from @tbl where k=@k

			select @SQL script,ERROR_MESSAGE() err_msg
		end catch
	FETCH NEXT FROM SSCur INTO @k, @SQL
	END
	CLOSE SSCur
	DEALLOCATE SSCur
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Анализ используемости, фрагментированности, важности индекса и его реорганизация/перестроение', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'Alter_index';

