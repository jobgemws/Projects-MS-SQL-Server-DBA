
CREATE procedure [srv].[sp_DriveSpace] 
    @DrivePath varchar(1024) --устройство (можно передать метку тома 'C:')
  , @TotalSpace float output --всего емкость в байтах
  , @FreeSpace float output	 --свободного пространства в байтах
as
begin
	/*
		Выводит информацию по устройству
		http://www.t-sql.ru/post/disk_size.aspx
	*/
  DECLARE @fso int
        , @Drive int
        , @DriveName varchar(255)
        , @Folder int
        , @Drives int
        , @source varchar(255)
        , @desc varchar(255)
        , @ret int
        , @Object int
  -- Создаем обект файловой системы
  exec @ret = sp_OACreate 'Scripting.FileSystemObject', @fso output
  set @Object = @fso
  if @ret != 0
    goto ErrorInfo
 
  -- Получаем папку по заданному пути
  exec @ret = sp_OAmethod @fso, 'GetFolder', @Folder output, @DrivePath  
  set @Object = @fso
  if @ret != 0
    goto ErrorInfo
 
  -- Получаем устройство
  exec @ret = sp_OAmethod @Folder, 'Drive', @Drive output
  set @Object = @Folder
  if @ret != 0
    goto ErrorInfo
 
  -- Определяем полный размер устройства
  exec @ret = sp_OAGetProperty @Drive, 'TotalSize', @TotalSpace output
  set @Object = @Drive
  if @ret != 0
    goto ErrorInfo
 
  -- Определяем свободное место не устройстве
  exec @ret = sp_OAGetProperty @Drive, 'AvailableSpace', @FreeSpace output
  set @Object = @Drive
  if @ret != 0
    goto ErrorInfo
 
  DestroyObjects:
    if @Folder is not null
      exec sp_OADestroy @Folder
    if @Drive is not null
      exec sp_OADestroy @Drive
    if @fso is not null
      exec sp_OADestroy @fso
 
    return (@ret)
 
  ErrorInfo:
    exec sp_OAGetErrorInfo @Object, @source output, @desc output
    print 'Source error: ' + isnull( @source, 'n/a' ) + char(13) + 'Description: ' + isnull( @desc, 'n/a' )
    goto DestroyObjects;
end

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Выводит информацию по устройству', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'PROCEDURE', @level1name = N'sp_DriveSpace';

