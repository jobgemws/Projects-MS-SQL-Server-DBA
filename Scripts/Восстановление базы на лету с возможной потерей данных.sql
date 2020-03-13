use [master]
ALTER DATABASE SRV set single_user with rollback immediate
ALTER DATABASE SRV SET EMERGENCY;
DBCC CHECKDB (SRV, REPAIR_ALLOW_DATA_LOSS) WITH NO_INFOMSGS, ALL_ERRORMSGS; --c  возможным повреждением, для неважных БД
ALTER DATABASE SRV set multi_user with no_wait