 
CREATE PROCEDURE [srv].[usp_Find_Problems] ( @count_locks BIT = 1 )
AS 
    SET NOCOUNT ON
-- подсчет блокировок
    IF @count_locks = 0 
        GOTO Get_Blocks
    ELSE 
        IF @count_locks = 1 
            BEGIN
 
                    CREATE TABLE #Hold_sp_lock
                        (
                          spid INT,
                          dbid INT,
                          ObjId INT,
                          IndId SMALLINT,
                          Type VARCHAR(20),
                          Resource VARCHAR(50),
                          Mode VARCHAR(20),
                          Status VARCHAR(20)
                        )
                INSERT  INTO #Hold_sp_lock
                        EXEC sp_lock
                SELECT  COUNT(spid) AS lock_count,
                        SPID,
                        Type,
                        CAST(DB_NAME(DBID) AS VARCHAR(30)) AS DBName,
                        mode
                FROM    #Hold_sp_lock
                GROUP BY SPID,
                        Type,
                        CAST(DB_NAME(DBID) AS VARCHAR(30)),
                        MODE
                ORDER BY lock_count DESC,
                        DBName,
                        SPID,
                        MODE
 
-- Вывод заблокированных или блокирующих процессов
-- Show any blocked or blocking processes
 
                Get_Blocks:
 
 
                    CREATE TABLE #Catch_SPID
                        (
                          bSPID INT,
                          BLK_Status CHAR(10)
                        )
 
                INSERT  INTO #Catch_SPID
                        SELECT DISTINCT
                                SPID,
                                'BLOCKED'
                        FROM    master..sysprocesses
                        WHERE   blocked <> 0
                        UNION
                        SELECT DISTINCT
                                blocked,
                                'BLOCKING'
                        FROM    master..sysprocesses
                        WHERE   blocked <> 0
 
                DECLARE @tSPID INT 
                DECLARE @blkst CHAR(10)
                SELECT TOP 1
                        @tSPID = bSPID,
                        @blkst = BLK_Status
                FROM    #Catch_SPID
                
 
 
                WHILE( @@ROWCOUNT > 0 )
                    BEGIN
 
                        PRINT 'DBCC Results for SPID '
                            + CAST(@tSPID AS VARCHAR(5)) + '( ' + RTRIM(@blkst)
                            + ' )'
                        PRINT '-----------------------------------'
                        PRINT ''
                        DBCC INPUTBUFFER(@tSPID)
 
 
                        SELECT TOP 1
                                @tSPID = bSPID,
                                @blkst = BLK_Status
                        FROM    #Catch_SPID
                        WHERE   bSPID > @tSPID
                        ORDER BY bSPID
 
                    END
 
            END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Вывод заблокированных или блокирующих процессов', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'usp_Find_Problems';

