




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [zabbix].[GetActiveUserTransaction]
AS
BEGIN
	/*
		Количество активных пользовательских транзакций
	*/

	--SET QUERY_GOVERNOR_COST_LIMIT 0;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET XACT_ABORT ON;

	select count(*) as [count]
	from sys.dm_tran_session_transactions
	where [is_user_transaction]=1;
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает количество активных пользовательских транзакций', @level0type = N'SCHEMA', @level0name = N'zabbix', @level1type = N'PROCEDURE', @level1name = N'GetActiveUserTransaction';

