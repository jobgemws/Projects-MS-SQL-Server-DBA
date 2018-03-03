-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [srv].[KillConnect]
	@databasename nvarchar(255), --БД
	@loginname	  nvarchar(255)=NULL  --Логин
AS
BEGIN
	/*
		Удаляет соединения для указанной БД и указаного логина входа
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	if(@databasename is null)
	begin
		;THROW 50000, 'База данных не задана!', 0;
	end
	else
	begin
		declare @dbid int=db_id(@databasename);

		if(@dbid is NULL)
		begin
			;THROW 50000, 'Такой базы данных не существует!', 0;
		end
		else if @dbid <= 4
		begin
			;THROW 50000, 'Удаления подключений к системной БД запрещены!', 0;
		end
		else
		begin
			declare @query nvarchar(max);
			set @query = '';

			select @query=coalesce(@query,',' )
						+'kill '
						+convert(varchar, spid)
						+'; '
			from master..sysprocesses
			where dbid=db_id(@databasename)
			and spid<>@@SPID
			and (loginame=@loginname or @loginname is null);
	
			if len(@query) > 0
			begin
				begin try
					exec(@query);
				end try
				begin catch
				end catch
			end
		end
	end
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Удаляет соединения для указанной БД и указаного логина входа', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'KillConnect';

