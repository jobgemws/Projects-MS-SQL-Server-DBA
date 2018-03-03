
CREATE PROCEDURE [srv].[ExcelGetTriggers]
as
begin
	/*
		возвращает информацию по триггерам
	*/
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	SELECT top(0) @@SERVERNAME as [Server]
      ,[TriggerName]
      ,[parent_class_desc]
      ,[TrigerType]
      ,[TriggerCreateDate]
      ,[TriggerModifyDate]
      ,[TriggerIsDisabled]
      ,[TriggerInsteadOfTrigger]
      ,[TriggerIsMSShipped]
      ,[is_not_for_replication]
      ,[SchenaName]
      ,[ObjectName]
      ,[ObjectTypeDesc]
      ,[ObjectType]
      ,[Trigger script]
	  into #ttt
  FROM [inf].[vTriggers];

  select [name]
  into #dbs
  from sys.databases;

  declare @dbs nvarchar(255);
  declare @sql nvarchar(max);

  while(exists(select top(1) 1 from #dbs))
  begin
	select top(1)
	@dbs=[name]
	from #dbs;

	set @sql=
	N'insert into #ttt([Server]
	    ,[TriggerName]
		,[parent_class_desc]
		,[TrigerType]
		,[TriggerCreateDate]
		,[TriggerModifyDate]
		,[TriggerIsDisabled]
		,[TriggerInsteadOfTrigger]
		,[TriggerIsMSShipped]
		,[is_not_for_replication]
		,[SchenaName]
		,[ObjectName]
		,[ObjectTypeDesc]
		,[ObjectType]
		,[Trigger script])
	select @@SERVERNAME
	    ,[TriggerName]
		,[parent_class_desc]
		,[TrigerType]
		,[TriggerCreateDate]
		,[TriggerModifyDate]
		,[TriggerIsDisabled]
		,[TriggerInsteadOfTrigger]
		,[TriggerIsMSShipped]
		,[is_not_for_replication]
		,[SchenaName]
		,[ObjectName]
		,[ObjectTypeDesc]
		,[ObjectType]
		,[Trigger script]
	from ['+@dbs+'].[inf].[vTriggers];';

	exec sp_executesql @sql;

	delete from #dbs
	where [name]=@dbs;
  end

  select *
  from #ttt;

  drop table #ttt;
  drop table #dbs;
end

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возвращает информацию по триггерам', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'ExcelGetTriggers';

