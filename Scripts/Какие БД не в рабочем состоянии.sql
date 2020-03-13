SELECT  db.[name] as [DatabaseName],
        mf.Name as [FileName],
        mf.Physical_Name as [FileFullName],
        db.[state] as [DBState],
        mf.[state] as [FileState],
        db.[user_access],
        --db.[is_read_only],
        db.[is_auto_close_on]
FROM    sys.master_files as mf
inner join sys.databases as db on mf.database_id=db.database_id
where db.[state]<>0 --если база сама не доступна по каким-либо причинам
or mf.[state]<>0 --если файл БД не доступен по каким-либо причинам
or db.[user_access]<>0 --если установлен доступ не мнопользовательский
--or db.[is_read_only]=1
or db.[is_auto_close_on]=1 --если БД автозакрываемая
--where db.database_id=@id; --DB_ID(name) or DB_Name(id)