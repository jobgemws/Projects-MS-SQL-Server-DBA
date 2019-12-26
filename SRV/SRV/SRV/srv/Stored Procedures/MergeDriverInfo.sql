



CREATE   PROCEDURE [srv].[MergeDriverInfo]
AS
BEGIN
	/*
		обновляет таблицу устройств-дисков
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @servername nvarchar(255)=cast(SERVERPROPERTY(N'MachineName') as nvarchar(255));

	declare @Drivers table (
							[Server] nvarchar(255),
							Name nvarchar(8),
							TotalSpace float,
							FreeSpace float,
							DiffFreeSpace float NULL
						   );
	insert into @Drivers   (
							[Server],
							Name,
							TotalSpace,
							FreeSpace
						   )
	select					[Server],
							Name,
							TotalSpace,
							FreeSpace
	from				srv.Drivers
	where [Server]=@servername;

	declare @TotalSpace float;
    declare @FreeSpace float;
	declare @DrivePath nvarchar(8);

	while(exists(select top(1) 1 from @Drivers where DiffFreeSpace is null))
	begin
		select top(1)
		@DrivePath=Name
		from @Drivers
		where DiffFreeSpace is null;

		exec srv.sp_DriveSpace @DrivePath = @DrivePath
						 , @TotalSpace = @TotalSpace out
						 , @FreeSpace = @FreeSpace out;

		update @Drivers
		set TotalSpace=@TotalSpace
		   ,FreeSpace=@FreeSpace
		   ,DiffFreeSpace=case when FreeSpace>0 then round(FreeSpace-@FreeSpace,3) else 0 end
		where Name=@DrivePath;
	end

	;merge [srv].[Drivers] as d
	using @Drivers as dd
	on d.Name=dd.Name and d.[Server]=dd.[Server]
	when matched then
		update set UpdateUTcDate = getUTCDate()
				 ,[TotalSpace]	 = dd.[TotalSpace]	 
				 ,[FreeSpace]	 = dd.[FreeSpace]	 
				 ,[DiffFreeSpace]= dd.[DiffFreeSpace];
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Обновляет таблицу по устройствам-дискам', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'MergeDriverInfo';

