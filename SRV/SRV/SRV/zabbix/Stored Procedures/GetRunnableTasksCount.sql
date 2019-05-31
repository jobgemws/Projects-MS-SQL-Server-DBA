

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [zabbix].[GetRunnableTasksCount]
AS
BEGIN
	/*
		Максимальное количество ожидающих задач среди свободных ядер
	*/

	--SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT max([runnable_tasks_count]) as [runnable_tasks_count]
	from [inf].[vSchedulersOS];
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает максимальное количество ожидающих задач среди свободных ядер', @level0type = N'SCHEMA', @level0name = N'zabbix', @level1type = N'PROCEDURE', @level1name = N'GetRunnableTasksCount';

