CREATE   PROCEDURE [inf].[InfoAgentJobs]
AS
BEGIN
	--Необходимые типовые задания
	SET NOCOUNT ON;
	
		--Необходимо выполнить на каждой нужной БД, включая системные:

		--CREATE SCHEMA [inf]
		--GO

		--CREATE SCHEMA [srv]
		--GO
		
		--SET ANSI_NULLS ON
		--GO
		
		--SET QUOTED_IDENTIFIER ON
		--GO
		
		
		--CREATE VIEW [inf].[vCountRows]
				 
		--CREATE VIEW [inf].[vIndexDefrag]
				 
		--CREATE VIEW [inf].[vTableSize]
				 
		--CREATE PROCEDURE [srv].[AutoDefragIndex]
				 
		--CREATE PROCEDURE [srv].[AutoUpdateStatistics]

    /*
		1) syspolicy_purge_history – Удаляет журнал выполнения политик в соответствии с параметром интервала хранения журнала
		2) Автосбор данных о выполненных заданиях – запускается ежедневно:
		USE [SRV];
		go
		
		begin try
				declare @body nvarchar(max);
		        exec [SRV].[srv].[AutoShortInfoRunJobs]
						@second=60
					   ,@body=@body output;
		
				EXEC [msdb].[dbo].[sp_send_dbmail]
				-- Созданный нами профиль администратора почтовых рассылок
					@profile_name = 'profile_name',
				-- Адрес получателя
					@recipients = 'Gribkov@mkis.su;',--'Gribkov@mkis.su',
				-- Текст письма
					@body = @body,
				-- Тема
					@subject = N'ИНФОРМАЦИЯ ПО ОШИБКАМ ВЫПОЛНЕНИЯ',
					@body_format='HTML'--,
		end try
		begin catch
		    declare @str_mess nvarchar(max)=ERROR_MESSAGE(),
		            @str_num  nvarchar(max)=cast(ERROR_NUMBER() as nvarchar(max)),
		            @str_line nvarchar(max)=cast(ERROR_LINE()   as nvarchar(max)),
		            @str_proc nvarchar(max)=ERROR_PROCEDURE(),
		            @str_title nvarchar(max)=N'Автосбор данных о выполненных заданиях на сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255)),
		            @str_pred_mess nvarchar(max)=N'На сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255))+N' возникла ошибка автосбора данных о выполненных заданиях';
		
		    exec [SRV].srv.ErrorInfoIncUpd
		         @ERROR_TITLE           = @str_title,
		         @ERROR_PRED_MESSAGE    = @str_pred_mess,
		         @ERROR_NUMBER          = @str_num,
		         @ERROR_MESSAGE         = @str_mess,
		         @ERROR_LINE            = @str_line,
		         @ERROR_PROCEDURE       = @str_proc,
		         @ERROR_POST_MESSAGE    = NULL,
		         @RECIPIENTS            = 'DBA;';
		
		     declare @err int=@@error;
		     raiserror(@str_mess,16,1);
		end catch
		3) Автосбор данных файлов баз данных – запускается ежедневно:
		USE [SRV];
		go
		
		begin try
				exec [srv].[MergeDBFileInfo];
				--exec [srv].[MergeDriverInfo]; --о дисках
		end try
		begin catch
		    declare @str_mess nvarchar(max)=ERROR_MESSAGE(),
		            @str_num  nvarchar(max)=cast(ERROR_NUMBER() as nvarchar(max)),
		            @str_line nvarchar(max)=cast(ERROR_LINE()   as nvarchar(max)),
		            @str_proc nvarchar(max)=ERROR_PROCEDURE(),
		            @str_title nvarchar(max)=N'Автосбор данных о дисках и файлов баз данных на сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255)),
		            @str_pred_mess nvarchar(max)=N'На сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255))+N' возникла ошибка автосбора данных о дисках и файлов баз данных';
		
		    exec [SRV].srv.ErrorInfoIncUpd
		         @ERROR_TITLE           = @str_title,
		         @ERROR_PRED_MESSAGE    = @str_pred_mess,
		         @ERROR_NUMBER          = @str_num,
		         @ERROR_MESSAGE         = @str_mess,
		         @ERROR_LINE            = @str_line,
		         @ERROR_PROCEDURE       = @str_proc,
		         @ERROR_POST_MESSAGE    = NULL,
		         @RECIPIENTS            = 'DBA;';
		
		     declare @err int=@@error;
		     raiserror(@str_mess,16,1);
		end catch
		4) Автосбор данных об активных запросах для группировки – запускается ежедневно:
		USE [SRV];
		go
		
		begin try
		                exec [srv].[RunRequestGroupStatistics];
		end try
		begin catch
		    declare @str_mess nvarchar(max)=ERROR_MESSAGE(),
		            @str_num  nvarchar(max)=cast(ERROR_NUMBER() as nvarchar(max)),
		            @str_line nvarchar(max)=cast(ERROR_LINE()   as nvarchar(max)),
		            @str_proc nvarchar(max)=ERROR_PROCEDURE(),
		            @str_title nvarchar(max)=N'Автосбор данных об активных запросах на сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255)),
		            @str_pred_mess nvarchar(max)=N'На сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255))+N' возникла ошибка автосбора данных об активных запросах';
		
		    exec [SRV].srv.ErrorInfoIncUpd
		         @ERROR_TITLE           = @str_title,
		         @ERROR_PRED_MESSAGE    = @str_pred_mess,
		         @ERROR_NUMBER          = @str_num,
		         @ERROR_MESSAGE         = @str_mess,
		         @ERROR_LINE            = @str_line,
		         @ERROR_PROCEDURE       = @str_proc,
		         @ERROR_POST_MESSAGE    = NULL,
		         @RECIPIENTS            = 'DBA;';
		
		     declare @err int=@@error;
		     raiserror(@str_mess,16,1);
		end catch
		5) Автосбор данных об активных подключениях – запускается каждые 10 минут:
		USE [SRV];
		go
		
		begin try
		    exec [srv].[AutoStatisticsActiveConnections];
		end try
		begin catch
		    declare @str_mess nvarchar(max)=ERROR_MESSAGE(),
		            @str_num  nvarchar(max)=cast(ERROR_NUMBER() as nvarchar(max)),
		            @str_line nvarchar(max)=cast(ERROR_LINE()   as nvarchar(max)),
		            @str_proc nvarchar(max)=ERROR_PROCEDURE(),
		            @str_title nvarchar(max)=N'Автосбор данных об активных подключениях на сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255)),
		            @str_pred_mess nvarchar(max)=N'На сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255))+N' возникла ошибка автосбора данных об активных подключениях';
		
		    exec [SRV].srv.ErrorInfoIncUpd
		         @ERROR_TITLE           = @str_title,
		         @ERROR_PRED_MESSAGE    = @str_pred_mess,
		         @ERROR_NUMBER          = @str_num,
		         @ERROR_MESSAGE         = @str_mess,
		         @ERROR_LINE            = @str_line,
		         @ERROR_PROCEDURE       = @str_proc,
		         @ERROR_POST_MESSAGE    = NULL,
		         @RECIPIENTS            = 'DBA;';
		
		     declare @err int=@@error;
		     raiserror(@str_mess,16,1);
		end catch
		6) Автосбор данных об производительности СУБД – запускается ежедневно:
		USE [SRV];
		go
		
		begin try
		                exec [srv].[AutoStatisticsTimeRequests];
		end try
		begin catch
		    declare @str_mess nvarchar(max)=ERROR_MESSAGE(),
		            @str_num  nvarchar(max)=cast(ERROR_NUMBER() as nvarchar(max)),
		            @str_line nvarchar(max)=cast(ERROR_LINE()   as nvarchar(max)),
		            @str_proc nvarchar(max)=ERROR_PROCEDURE(),
		            @str_title nvarchar(max)=N'Автосбор данных об производительности СУБД на сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255)),
		            @str_pred_mess nvarchar(max)=N'На сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255))+N' возникла ошибка автосбора данных об производительности СУБД';
		
		    exec [SRV].srv.ErrorInfoIncUpd
		         @ERROR_TITLE           = @str_title,
		         @ERROR_PRED_MESSAGE    = @str_pred_mess,
		         @ERROR_NUMBER          = @str_num,
		         @ERROR_MESSAGE         = @str_mess,
		         @ERROR_LINE            = @str_line,
		         @ERROR_PROCEDURE       = @str_proc,
		         @ERROR_POST_MESSAGE    = NULL,
		         @RECIPIENTS            = 'DBA;';
		
		     declare @err int=@@error;
		     raiserror(@str_mess,16,1);
		end catch
		7) Автосбор кол-ва строк кластерных структур и размера таблиц – запускается ежедневно:
		USE [SRV];
		go
		
		begin try
		                exec [srv].[InsertTableStatistics];
		end try
		begin catch
		    declare @str_mess nvarchar(max)=ERROR_MESSAGE(),
		            @str_num  nvarchar(max)=cast(ERROR_NUMBER() as nvarchar(max)),
		            @str_line nvarchar(max)=cast(ERROR_LINE()   as nvarchar(max)),
		            @str_proc nvarchar(max)=ERROR_PROCEDURE(),
		            @str_title nvarchar(max)=N'Автосбор кол-ва строк кластерных структур  и размер таблиц на сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255)),
		            @str_pred_mess nvarchar(max)=N'На сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255))+N' возникла ошибка автосбора кол-ва строк кластерных структур и размера таблиц';
		
		    exec [SRV].srv.ErrorInfoIncUpd
		         @ERROR_TITLE           = @str_title,
		         @ERROR_PRED_MESSAGE    = @str_pred_mess,
		         @ERROR_NUMBER          = @str_num,
		         @ERROR_MESSAGE         = @str_mess,
		         @ERROR_LINE            = @str_line,
		         @ERROR_PROCEDURE       = @str_proc,
		         @ERROR_POST_MESSAGE    = NULL,
		         @RECIPIENTS            = 'DBA;';
		
		     declare @err int=@@error;
		     raiserror(@str_mess,16,1);
		end catch
		8) Автосбор статистики роста файлов БД – запускается ежедневно:
		USE [SRV];
		go
		
		begin try
		    exec [srv].[AutoStatisticsFileDB]
		end try
		begin catch
		    declare @str_mess nvarchar(max)=ERROR_MESSAGE(),
		            @str_num  nvarchar(max)=cast(ERROR_NUMBER() as nvarchar(max)),
		            @str_line nvarchar(max)=cast(ERROR_LINE()   as nvarchar(max)),
		            @str_proc nvarchar(max)=ERROR_PROCEDURE(),
		            @str_title nvarchar(max)=N'Автосбор статистики роста файлов БД на сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255)),
		            @str_pred_mess nvarchar(max)=N'На сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255))+N' возникла ошибка автосбора статистики роста файлов БД';
		
		    exec [SRV].srv.ErrorInfoIncUpd
		         @ERROR_TITLE           = @str_title,
		         @ERROR_PRED_MESSAGE    = @str_pred_mess,
		         @ERROR_NUMBER          = @str_num,
		         @ERROR_MESSAGE         = @str_mess,
		         @ERROR_LINE            = @str_line,
		         @ERROR_PROCEDURE       = @str_proc,
		         @ERROR_POST_MESSAGE    = NULL,
		         @RECIPIENTS            = 'DBA;';
		
		     declare @err int=@@error;
		     raiserror(@str_mess,16,1);
		end catch
		
		9) Автоудаление зависших неактивных подключений – запускается ежедневно:
		USE [SRV];
		go
		
		begin try
		                exec [srv].[KillFullOldConnect];
		end try
		begin catch
		    declare @str_mess nvarchar(max)=ERROR_MESSAGE(),
		            @str_num  nvarchar(max)=cast(ERROR_NUMBER() as nvarchar(max)),
		            @str_line nvarchar(max)=cast(ERROR_LINE()   as nvarchar(max)),
		            @str_proc nvarchar(max)=ERROR_PROCEDURE(),
		            @str_title nvarchar(max)=N'Автоудаление зависших неактивных подключений на сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255)),
		            @str_pred_mess nvarchar(max)=N'На сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255))+N' возникла ошибка автоудаления зависших подключений';
		
		    exec [SRV].srv.ErrorInfoIncUpd
		         @ERROR_TITLE           = @str_title,
		         @ERROR_PRED_MESSAGE    = @str_pred_mess,
		         @ERROR_NUMBER          = @str_num,
		         @ERROR_MESSAGE         = @str_mess,
		         @ERROR_LINE            = @str_line,
		         @ERROR_PROCEDURE       = @str_proc,
		         @ERROR_POST_MESSAGE    = NULL,
		         @RECIPIENTS            = 'DBA;';
		
		     declare @err int=@@error;
		     raiserror(@str_mess,16,1);
		end catch
		10) Автоудаление старых записей – запускается ежедневно:
		USE [SRV];
		go
		
		begin try
		                exec [srv].[DeleteArchive];
		end try
		begin catch
		    declare @str_mess nvarchar(max)=ERROR_MESSAGE(),
		            @str_num  nvarchar(max)=cast(ERROR_NUMBER() as nvarchar(max)),
		            @str_line nvarchar(max)=cast(ERROR_LINE()   as nvarchar(max)),
		            @str_proc nvarchar(max)=ERROR_PROCEDURE(),
		            @str_title nvarchar(max)=N'Автоудаление старых записей на сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255)),
		            @str_pred_mess nvarchar(max)=N'На сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255))+N' возникла ошибка автоудаления старых записей';
		
		    exec [SRV].srv.ErrorInfoIncUpd
		         @ERROR_TITLE           = @str_title,
		         @ERROR_PRED_MESSAGE    = @str_pred_mess,
		         @ERROR_NUMBER          = @str_num,
		         @ERROR_MESSAGE         = @str_mess,
		         @ERROR_LINE            = @str_line,
		         @ERROR_PROCEDURE       = @str_proc,
		         @ERROR_POST_MESSAGE    = NULL,
		         @RECIPIENTS            = 'DBA;';
		
		     declare @err int=@@error;
		     raiserror(@str_mess,16,1);
		end catch
		11) ИНФОРМИРОВАНИЕ – запускается каждые 30 минут:
		USE [SRV];
		go
		
		EXECUTE [srv].[RunErrorInfoProc] 
		   @IsRealTime=0;
		12) ИНФОРМИРОВАНИЕ РЕАЛЬНОГО ВРЕМЕНИ – запускается каждые 60 секунд:
		USE [SRV];
		go
		
		EXECUTE [srv].[RunErrorInfoProc] 
		   @IsRealTime=1;
		13) Обслуживание до и после полного резервного копирования – запускается ежедневно, состоит из следующих этапов:
		13.1) Автоочистка кеша с последующим обновлением статистики по всем несистемным БД:
		USE [SRV];
		go
		
		begin try
				EXEC [srv].[AutoUpdateStatisticsCache] 
				@DB_Name=NULL
				,@IsUpdateStatistics=1;
		end try
		begin catch
		    declare @str_mess nvarchar(max)=ERROR_MESSAGE(),
		            @str_num  nvarchar(max)=cast(ERROR_NUMBER() as nvarchar(max)),
		            @str_line nvarchar(max)=cast(ERROR_LINE()   as nvarchar(max)),
		            @str_proc nvarchar(max)=ERROR_PROCEDURE(),
		            @str_title nvarchar(max)=N'Автоочистка кеша с последующим обновлением статистики по всем несистемным БД на сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255)),
		            @str_pred_mess nvarchar(max)=N'На сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255))+N' возникла ошибка авточистки кеша с последующим обновлением статистики по всем несистемным БД';
		
		    exec [SRV].srv.ErrorInfoIncUpd
		         @ERROR_TITLE           = @str_title,
		         @ERROR_PRED_MESSAGE    = @str_pred_mess,
		         @ERROR_NUMBER          = @str_num,
		         @ERROR_MESSAGE         = @str_mess,
		         @ERROR_LINE            = @str_line,
		         @ERROR_PROCEDURE       = @str_proc,
		         @ERROR_POST_MESSAGE    = NULL,
		         @RECIPIENTS            = 'DBA;';
		
		     declare @err int=@@error;
		     raiserror(@str_mess,16,1);
		end catch
		13.2) Оптимизация индексов:
		USE [SRV];
		go
		
		begin try
			EXECUTE [srv].[AutoDefragIndexDB] @count=100000;
		end try
		begin catch
		    declare @str_mess nvarchar(max)=ERROR_MESSAGE(),
		            @str_num  nvarchar(max)=cast(ERROR_NUMBER() as nvarchar(max)),
		            @str_line nvarchar(max)=cast(ERROR_LINE()   as nvarchar(max)),
		            @str_proc nvarchar(max)=ERROR_PROCEDURE(),
		            @str_title nvarchar(max)=N'Оптимизация индексов на сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255)),
		            @str_pred_mess nvarchar(max)=N'На сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255))+N' возникла ошибка оптимизации индексов';
		
		    exec [SRV].srv.ErrorInfoIncUpd
		         @ERROR_TITLE           = @str_title,
		         @ERROR_PRED_MESSAGE    = @str_pred_mess,
		         @ERROR_NUMBER          = @str_num,
		         @ERROR_MESSAGE         = @str_mess,
		         @ERROR_LINE            = @str_line,
		         @ERROR_PROCEDURE       = @str_proc,
		         @ERROR_POST_MESSAGE    = NULL,
		         @RECIPIENTS            = 'DBA;';
		
		     declare @err int=@@error;
		     raiserror(@str_mess,16,1);
		end catch
		13.3) Создание полных резервных копий:
		USE [SRV];
		go
		
		begin try
		                exec [srv].[RunFullBackupDB];
		end try
		begin catch
		    declare @str_mess nvarchar(max)=ERROR_MESSAGE(),
		            @str_num  nvarchar(max)=cast(ERROR_NUMBER() as nvarchar(max)),
		            @str_line nvarchar(max)=cast(ERROR_LINE()   as nvarchar(max)),
		            @str_proc nvarchar(max)=ERROR_PROCEDURE(),
		            @str_title nvarchar(max)=N'Создание полных резервных копий на сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255)),
		            @str_pred_mess nvarchar(max)=N'На сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255))+N' возникла ошибка создания полных резервных копий';
		
		    exec [SRV].srv.ErrorInfoIncUpd
		         @ERROR_TITLE           = @str_title,
		         @ERROR_PRED_MESSAGE    = @str_pred_mess,
		         @ERROR_NUMBER          = @str_num,
		         @ERROR_MESSAGE         = @str_mess,
		         @ERROR_LINE            = @str_line,
		         @ERROR_PROCEDURE       = @str_proc,
		         @ERROR_POST_MESSAGE    = NULL,
		         @RECIPIENTS            = 'DBA;';
		
		     declare @err int=@@error;
		     raiserror(@str_mess,16,1);
		end catch
		13.4) Удаление старых файлов:
		USE [SRV];
		go
		
		begin try
			EXECUTE [srv].[XPDeleteFile] 
					@FolderPath=N'D:\Backup\LOG'
					,@FileExtension=N'*'
					,@OldDays=3
					,@SubFolder=1;
			EXECUTE [srv].[XPDeleteFile] 
					@FolderPath=N'D:\Backup\Diff'
					,@FileExtension=N'*'
					,@OldDays=3
					,@SubFolder=1;
			EXECUTE [srv].[XPDeleteFile] 
					@FolderPath=N'D:\Backup\FULL'
					,@FileExtension=N'*'
					,@OldDays=10
					,@SubFolder=1;
		end try
		begin catch
		    declare @str_mess nvarchar(max)=ERROR_MESSAGE(),
		            @str_num  nvarchar(max)=cast(ERROR_NUMBER() as nvarchar(max)),
		            @str_line nvarchar(max)=cast(ERROR_LINE()   as nvarchar(max)),
		            @str_proc nvarchar(max)=ERROR_PROCEDURE(),
		            @str_title nvarchar(max)=N'Удаление старых файлов на сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255)),
		            @str_pred_mess nvarchar(max)=N'На сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255))+N' возникла ошибка удаления старых файлов';
		
		    exec [SRV].srv.ErrorInfoIncUpd
		         @ERROR_TITLE           = @str_title,
		         @ERROR_PRED_MESSAGE    = @str_pred_mess,
		         @ERROR_NUMBER          = @str_num,
		         @ERROR_MESSAGE         = @str_mess,
		         @ERROR_LINE            = @str_line,
		         @ERROR_PROCEDURE       = @str_proc,
		         @ERROR_POST_MESSAGE    = NULL,
		         @RECIPIENTS            = 'DBA;';
		
		     declare @err int=@@error;
		     raiserror(@str_mess,16,1);
		end catch
		14) Сбор данных о запросах – запускается ежедневно:
		USE [SRV];
		go
		
		begin try
		    exec [srv].[AutoStatisticsQuerys];
		end try
		begin catch
		    declare @str_mess nvarchar(max)=ERROR_MESSAGE(),
		            @str_num  nvarchar(max)=cast(ERROR_NUMBER() as nvarchar(max)),
		            @str_line nvarchar(max)=cast(ERROR_LINE()   as nvarchar(max)),
		            @str_proc nvarchar(max)=ERROR_PROCEDURE(),
		            @str_title nvarchar(max)=N'Сбор данных о запросах на сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255)),
		            @str_pred_mess nvarchar(max)=N'На сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255))+N' возникла ошибка сбора данных о запросах';
		
		    exec [SRV].srv.ErrorInfoIncUpd
		         @ERROR_TITLE           = @str_title,
		         @ERROR_PRED_MESSAGE    = @str_pred_mess,
		         @ERROR_NUMBER          = @str_num,
		         @ERROR_MESSAGE         = @str_mess,
		         @ERROR_LINE            = @str_line,
		         @ERROR_PROCEDURE       = @str_proc,
		         @ERROR_POST_MESSAGE    = NULL,
		         @RECIPIENTS            = 'DBA;';
		
		     declare @err int=@@error;
		     raiserror(@str_mess,16,1);
		end catch
		15) Сбор данных об активных запросах – запускается каждые 10 секунд (а также по событию Новый запрос в Предупреждениях Агента) (необходимо обеспечить наивысшую скорость отработки, несмотря на то, что скан и сбор идут методом грязного чтения):
		USE [SRV];
		go
		
		begin try
		                exec [srv].[AutoStatisticsActiveRequests];
		end try
		begin catch
		    declare @str_mess nvarchar(max)=ERROR_MESSAGE(),
		            @str_num  nvarchar(max)=cast(ERROR_NUMBER() as nvarchar(max)),
		            @str_line nvarchar(max)=cast(ERROR_LINE()   as nvarchar(max)),
		            @str_proc nvarchar(max)=ERROR_PROCEDURE(),
		            @str_title nvarchar(max)=N'Сбор данных об активных запросах на сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255)),
		            @str_pred_mess nvarchar(max)=N'На сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255))+N' возникла ошибка сбора данных об активных запросах';
		
		    exec [SRV].srv.ErrorInfoIncUpd
		         @ERROR_TITLE           = @str_title,
		         @ERROR_PRED_MESSAGE    = @str_pred_mess,
		         @ERROR_NUMBER          = @str_num,
		         @ERROR_MESSAGE         = @str_mess,
		         @ERROR_LINE            = @str_line,
		         @ERROR_PROCEDURE       = @str_proc,
		         @ERROR_POST_MESSAGE    = NULL,
		         @RECIPIENTS            = 'DBA;';
		
		     declare @err int=@@error;
		     raiserror(@str_mess,16,1);
		end catch
		16) Создание разностных резервных копий – по необходимости:
		USE [SRV];
		go
		
		begin try
		                exec [srv].[RunDiffBackupDB];
		end try
		begin catch
		    declare @str_mess nvarchar(max)=ERROR_MESSAGE(),
		            @str_num  nvarchar(max)=cast(ERROR_NUMBER() as nvarchar(max)),
		            @str_line nvarchar(max)=cast(ERROR_LINE()   as nvarchar(max)),
		            @str_proc nvarchar(max)=ERROR_PROCEDURE(),
		            @str_title nvarchar(max)=N'Создание разностных резервных копий на сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255)),
		            @str_pred_mess nvarchar(max)=N'На сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255))+N' возникла ошибка создания разностных резервных копий';
		
		    exec [SRV].srv.ErrorInfoIncUpd
		         @ERROR_TITLE           = @str_title,
		         @ERROR_PRED_MESSAGE    = @str_pred_mess,
		         @ERROR_NUMBER          = @str_num,
		         @ERROR_MESSAGE         = @str_mess,
		         @ERROR_LINE            = @str_line,
		         @ERROR_PROCEDURE       = @str_proc,
		         @ERROR_POST_MESSAGE    = NULL,
		         @RECIPIENTS            = 'DBA;';
		
		     declare @err int=@@error;
		     raiserror(@str_mess,16,1);
		end catch
		17) Восстановление БД из их полных резервных копий:
		USE [SRV];
		go
		
		begin try
		                exec [srv].[RunFullRestoreDB];
		end try
		begin catch
		    declare @str_mess nvarchar(max)=ERROR_MESSAGE(),
		            @str_num  nvarchar(max)=cast(ERROR_NUMBER() as nvarchar(max)),
		            @str_line nvarchar(max)=cast(ERROR_LINE()   as nvarchar(max)),
		            @str_proc nvarchar(max)=ERROR_PROCEDURE(),
		            @str_title nvarchar(max)=N'Восстановление БД из их полных резервных копий на сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255)),
		            @str_pred_mess nvarchar(max)=N'На сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255))+N' возникла ошибка восстановления БД из их полных резервных копий';
		
		    exec [SRV].srv.ErrorInfoIncUpd
		         @ERROR_TITLE           = @str_title,
		         @ERROR_PRED_MESSAGE    = @str_pred_mess,
		         @ERROR_NUMBER          = @str_num,
		         @ERROR_MESSAGE         = @str_mess,
		         @ERROR_LINE            = @str_line,
		         @ERROR_PROCEDURE       = @str_proc,
		         @ERROR_POST_MESSAGE    = NULL,
		         @RECIPIENTS            = 'DBA;';
		
		     declare @err int=@@error;
		     raiserror(@str_mess,16,1);
		end catch
		18) Автоудаление забытых транзакций:
		USE [SRV];
		go
		
		begin try
		                exec  [srv].[AutoKillSessionTranBegin];
		end try
		begin catch
		    declare @str_mess nvarchar(max)=ERROR_MESSAGE(),
		            @str_num  nvarchar(max)=cast(ERROR_NUMBER() as nvarchar(max)),
		            @str_line nvarchar(max)=cast(ERROR_LINE()   as nvarchar(max)),
		            @str_proc nvarchar(max)=ERROR_PROCEDURE(),
		            @str_title nvarchar(max)=N'Автоудаление забытых транзакций на сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255)),
		            @str_pred_mess nvarchar(max)=N'На сервере '+cast(SERVERPROPERTY(N'MachineName') as nvarchar(255))+N' возникла ошибка автоудаления забытых транзакций';
		
		    exec [SRV].srv.ErrorInfoIncUpd
		         @ERROR_TITLE           = @str_title,
		         @ERROR_PRED_MESSAGE    = @str_pred_mess,
		         @ERROR_NUMBER          = @str_num,
		         @ERROR_MESSAGE         = @str_mess,
		         @ERROR_LINE            = @str_line,
		         @ERROR_PROCEDURE       = @str_proc,
		         @ERROR_POST_MESSAGE    = NULL,
		         @RECIPIENTS            = 'DBA;';
		
		     declare @err int=@@error;
		     raiserror(@str_mess,16,1);
		end catch

	*/
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Необходимые типовые задания (можно автоматизировать или изменить под конкретные нужды)', @level0type = N'SCHEMA', @level0name = N'inf', @level1type = N'PROCEDURE', @level1name = N'InfoAgentJobs';

