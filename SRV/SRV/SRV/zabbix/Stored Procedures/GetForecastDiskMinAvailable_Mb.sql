





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [zabbix].[GetForecastDiskMinAvailable_Mb]
AS
BEGIN
	/*
		Наиболее вероятное минимальное свободное место по всем дискам, которое будет через определенный промежуток времени
		Промежуток времени берется ровно столько, за сколько удалось собрать данные
	*/

	--SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET XACT_ABORT ON;

	declare @servername nvarchar(255)=cast(SERVERPROPERTY(N'MachineName') as nvarchar(255));

	declare @tbl table ([DATE] date, [MinAvailable_Mb] decimal(18,6), [MinAvailable_Percent] decimal(18,6), [Disk] nvarchar(255));
	declare @tbl_res table ([DiffMinAvailable_Mb] decimal(18,6), [DiffMinAvailable_Percent] decimal(18,6), [Disk] nvarchar(255));
	declare @curr table ([Disk] nvarchar (255), [MinAvailable_Mb] decimal(18,6));
	declare @diff table ([Disk] nvarchar (255), [Val] decimal(18,6));
	
	insert into @tbl ([DATE], [MinAvailable_Mb], [MinAvailable_Percent], [Disk])
	SELECT cast([InsertUTCDate] as date) as [DATE]
		  ,min([Available_Mb])			 as [MinAvailable_Mb]
	      ,min([Available_Percent])		 as [MinAvailable_Percent]
		  ,[Disk]
	  FROM [srv].[DiskSpaceStatistics]
	  where [Server]=@servername
	  group by cast([InsertUTCDate] as date), [Disk];
	
	;with tbl as (
		select [Disk], max([DATE]) as [DATE]
		from @tbl
		group by [Disk]
	)
	insert into @curr ([Disk], [MinAvailable_Mb])
	select t.[Disk], min(tt.[MinAvailable_Mb]) as [MinAvailable_Mb]
	from tbl as t
	inner join @tbl as tt on t.[Disk]=tt.[Disk] and t.[DATE]=tt.[DATE]
	group by t.[Disk];
	
	insert into @tbl_res ([DiffMinAvailable_Mb], [DiffMinAvailable_Percent], [Disk])
	select t.[MinAvailable_Mb]		-tt.[MinAvailable_Mb]				as [DiffMinAvailable_Mb]
		  ,t.[MinAvailable_Percent]	-tt.[MinAvailable_Percent]			as [DiffMinAvailable_Percent]
		  ,t.[Disk]
	from @tbl as t
	inner join @tbl as tt on t.[Disk]=tt.[Disk] and t.[DATE]=DateAdd(day,-1,tt.[DATE]);

	insert into @diff ([Disk], [Val])
	select t.[Disk],
		   (t.[MinAvailable_Mb]-(
								 select avg([DiffMinAvailable_Mb])*(
																	select count(*)
																	from @tbl_res as t0 
																	where t0.[Disk]=t.[Disk]
																   )
								 from @tbl_res as t0
								 where t0.[Disk]=t.[Disk]
								)
		   ) as [Val]
	from @curr as t;

	select coalesce(min([Val]), 8192) as [valueMB]
	from @diff;
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает наиболее вероятное минимальное свободное место по всем дискам, которое будет через определенный промежуток времени', @level0type = N'SCHEMA', @level0name = N'zabbix', @level1type = N'PROCEDURE', @level1name = N'GetForecastDiskMinAvailable_Mb';

