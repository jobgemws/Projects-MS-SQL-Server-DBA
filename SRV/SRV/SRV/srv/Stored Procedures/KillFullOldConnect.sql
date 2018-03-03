-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[KillFullOldConnect]
	@OldHour int=24
AS
BEGIN
	/*
		Удаляет те подключения, последнее выполнение которых было более суток назад.
		Внимание! Системные БД master, tempdb, model и msdb не участвуют в процессе.
		Однако, БД distribution для репликаций будет затронута и это нормально.
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @query nvarchar(max);
	set @query = '';

	select @query=coalesce(@query,',' )
				+'kill '
				+convert(varchar, spid)
				+'; '
	from master..sysprocesses
	where dbid>4
	and [last_batch]<dateadd(hour,-@OldHour,getdate())
	order by [last_batch]
	
	if len(@query) > 0
	begin
		begin try
			exec(@query);
		end try
		begin catch
		end catch
	end
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Удаляет те подключения, последнее выполнение которых было более суток назад', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'KillFullOldConnect';

