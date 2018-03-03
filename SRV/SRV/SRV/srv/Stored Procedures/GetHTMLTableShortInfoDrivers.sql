-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[GetHTMLTableShortInfoDrivers]
	@body nvarchar(max) OUTPUT
AS
BEGIN
	/*
			формирует HTML-код для таблицы запоминающих устройств (жестких дисков)
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @tbl table (
						Driver_GUID				uniqueidentifier
						,[Name]					nvarchar(255)
						,[TotalSpaceGb]			float
						,[FreeSpaceGb]			float
						,[DiffFreeSpaceMb]		float
						,[FreeSpacePercent]		float
						,[DiffFreeSpacePercent]	float
						,UpdateUTCDate			datetime
						,[Server]				nvarchar(255)
						,ID						int identity(1,1)
					   );

	declare
	@Driver_GUID			uniqueidentifier
	,@Name					nvarchar(255)
	,@TotalSpaceGb			float
	,@FreeSpaceGb			float
	,@DiffFreeSpaceMb		float
	,@FreeSpacePercent		float
	,@DiffFreeSpacePercent	float
	,@UpdateUTCDate			datetime
	,@Server				nvarchar(255)
	,@ID					int;

	insert into @tbl(
						Driver_GUID				
						,[Name]					
						,[TotalSpaceGb]			
						,[FreeSpaceGb]			
						,[DiffFreeSpaceMb]		
						,[FreeSpacePercent]		
						,[DiffFreeSpacePercent]	
						,UpdateUTCDate			
						,[Server]				
					)
			select		Driver_GUID				
						,[Name]					
						,[TotalSpaceGb]			
						,[FreeSpaceGb]			
						,[DiffFreeSpaceMb]		
						,[FreeSpacePercent]		
						,[DiffFreeSpacePercent]	
						,UpdateUTCDate			
						,[Server]
			from	srv.vDrivers
			where [DiffFreeSpacePercent]<=-5
			or [FreeSpacePercent]<=15
			order by [Server] asc, [Name] asc;

	if(exists(select top(1) 1 from @tbl))
	begin
		set @body='В ходе анализа были выявлены следующие носители иформации, у которых либо свободного объема осталось меньше 15%, либо свободное место уменьшается свыше 5% за день:<br><br>'+'<TABLE BORDER=5>';

		set @body=@body+'<TR>';

		set @body=@body+'<TD>';
		set @body=@body+'№ п/п';
		set @body=@body+'</TD>';
	
		set @body=@body+'<TD>';
		set @body=@body+'ГУИД';
		set @body=@body+'</TD>';

		set @body=@body+'<TD>';
		set @body=@body+'СЕРВЕР';
		set @body=@body+'</TD>';

		set @body=@body+'<TD>';
		set @body=@body+'ТОМ';
		set @body=@body+'</TD>';
	
		set @body=@body+'<TD>';
		set @body=@body+'ЕМКОСТЬ, ГБ.';
		set @body=@body+'</TD>';

		set @body=@body+'<TD>';
		set @body=@body+'СВОБОДНО, ГБ.';
		set @body=@body+'</TD>';

		set @body=@body+'<TD>';
		set @body=@body+'ИЗМЕНЕНИЕ СВОБОДНОГО МЕСТА, МБ.';
		set @body=@body+'</TD>';

		set @body=@body+'<TD>';
		set @body=@body+'СВОБОДНО, %';
		set @body=@body+'</TD>';

		set @body=@body+'<TD>';
		set @body=@body+'ИЗМЕНЕНИЕ СВОБОДНОГО МЕСТА, %';
		set @body=@body+'</TD>';

		set @body=@body+'<TD>';
		set @body=@body+'UTC ВРЕМЯ ОБНАРУЖЕНИЯ';
		set @body=@body+'</TD>';

		set @body=@body+'</TR>';

		while((select top 1 1 from @tbl)>0)
		begin
			set @body=@body+'<TR>';

			select top 1
			@Driver_GUID			= Driver_GUID			
			,@Name					= Name					
			,@TotalSpaceGb			= TotalSpaceGb			
			,@FreeSpaceGb			= FreeSpaceGb			
			,@DiffFreeSpaceMb		= DiffFreeSpaceMb		
			,@FreeSpacePercent		= FreeSpacePercent		
			,@DiffFreeSpacePercent	= DiffFreeSpacePercent	
			,@UpdateUTCDate			= UpdateUTCDate			
			,@Server				= [Server]				
			,@ID					= [ID]					
			from @tbl;

			set @body=@body+'<TD>';
			set @body=@body+cast(@ID as nvarchar(max));
			set @body=@body+'</TD>';
		
			set @body=@body+'<TD>';
			set @body=@body+cast(@Driver_GUID as nvarchar(255));
			set @body=@body+'</TD>';
		
			set @body=@body+'<TD>';
			set @body=@body+coalesce(@Server,'');
			set @body=@body+'</TD>';
		
			set @body=@body+'<TD>';
			set @body=@body+coalesce(@Name,'');
			set @body=@body+'</TD>';

			set @body=@body+'<TD>';
			set @body=@body+cast(@TotalSpaceGb as nvarchar(255));
			set @body=@body+'</TD>';

			set @body=@body+'<TD>';
			set @body=@body+cast(@FreeSpaceGb as nvarchar(255));
			set @body=@body+'</TD>';

			set @body=@body+'<TD>';
			set @body=@body+cast(@DiffFreeSpaceMb as nvarchar(255));
			set @body=@body+'</TD>';

			set @body=@body+'<TD>';
			set @body=@body+cast(@FreeSpacePercent as nvarchar(255));
			set @body=@body+'</TD>';

			set @body=@body+'<TD>';
			set @body=@body+cast(@DiffFreeSpacePercent as nvarchar(255));
			set @body=@body+'</TD>';

			set @body=@body+'<TD>';
			set @body=@body+rep.GetDateFormat(@UpdateUTCDate, default)+' '+rep.GetTimeFormat(@UpdateUTCDate, default);
			set @body=@body+'</TD>';

			delete from @tbl
			where ID=@ID;

			set @body=@body+'</TR>';
		end

		set @body=@body+'</TABLE>';

		set @body=@body+'<br><br>Для более детальной информации обратитесь к представлению SRV.srv.vDrivers<br><br>Для просмотра информации по файлам баз данных обратитесь к представлению SRV.srv.vDBFiles';
	end
	--else
	--begin
	--	set @body='В ходе анализа последних выполнений заданий, задания с ошибочным завершением, а также те, что выполнились по времени более 30 секунд, не выявлены';
	--end
END


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Формирует и возвращает HTML-код для таблицы запоминающих устройств (логических дисков)', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'GetHTMLTableShortInfoDrivers';

