

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [zabbix].[GetPercRAMTypeWait]
AS
BEGIN
	/*
		Сколько в процентах занимают типы ожиданий по ОЗУ (сумма по всем таким типам ожиданий)
	*/

	--SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT coalesce(sum([Percentage]), 0.00) as [Percentage]
		  --,max([AvgWait_S])  as [AvgWait_S]
	FROM [inf].[vWaits]
	where [WaitType] in (
    --'PAGEIOLATCH_XX',
    'RESOURCE_SEMAPHORE',
    'RESOURCE_SEMAPHORE_QUERY_COMPILE'
    )
	or [WaitType] like 'PAGEIOLATCH%';
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает сколько в процентах занимают типы ожиданий по ОЗУ (сумма по всем таким типам ожиданий)', @level0type = N'SCHEMA', @level0name = N'zabbix', @level1type = N'PROCEDURE', @level1name = N'GetPercRAMTypeWait';

