

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [zabbix].[GetValRAMTypeWait]
AS
BEGIN
	/*
		Сколько в миллисекундах занимают типы ожиданий по ОЗУ (максимальное значение из всех средних задержках по всем таким типам ожиданий)
	*/

	--SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT --sum([Percentage]) as [Percentage]
		   coalesce(max([AvgWait_S])*1000, 0.00)  as [AvgWait_S]
	FROM [inf].[vWaits]
	where [WaitType] in (
    --'PAGEIOLATCH_XX',
    'RESOURCE_SEMAPHORE',
    'RESOURCE_SEMAPHORE_QUERY_COMPILE'
    )
	or [WaitType] like 'PAGEIOLATCH%';
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает сколько в миллисекундах занимают типы ожиданий по ОЗУ (максимальное значение из всех средних задержках по всем таким типам ожиданий)', @level0type = N'SCHEMA', @level0name = N'zabbix', @level1type = N'PROCEDURE', @level1name = N'GetValRAMTypeWait';

