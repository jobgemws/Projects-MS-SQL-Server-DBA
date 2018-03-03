

create view [inf].[vSessionThreadOS] as
/*
	ГЕМ: Представление возвращает информацию, связывающую идентификатор сеанса с идентификатором потока Windows.
		 За производительностью потока можно наблюдать в системном мониторе Windows.
		 Запрос не возвращает идентификаторы сеансов, которые в настоящий момент находятся в ждущем режиме.
*/
SELECT STasks.session_id, SThreads.os_thread_id
    FROM sys.dm_os_tasks AS STasks
    INNER JOIN sys.dm_os_threads AS SThreads
        ON STasks.worker_address = SThreads.worker_address
    WHERE STasks.session_id IS NOT NULL;



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Представление возвращает информацию, связывающую идентификатор сеанса с идентификатором потока Windows экземпляра MS SQL Server', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'VIEW', @level1name = N'vSessionThreadOS';

