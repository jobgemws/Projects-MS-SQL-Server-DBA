
CREATE PROCEDURE [srv].[ConnectValid]
@SERVER_IP nvarchar(255) -- IP сервера
AS
BEGIN
	/*
		проверка доступности серверов (1-доступен, ничего-недоступен)
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @msg nvarchar(1000);
	declare @str nvarchar(max);

	set @str='SELECT TOP 1 1 FROM '
	+'['+@SERVER_IP+']'+'.'+'['+'SRV'+']'+'.'+'['+'dbo'+']'+'.'+'['+'TEST'+']';

	exec sp_executesql @str;
END


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Проверка доступности серверов', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'ConnectValid';

