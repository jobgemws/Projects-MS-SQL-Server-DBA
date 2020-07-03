#exec xp_cmdshell 'powershell.exe -file E:\SyncUserParameters.ps1 -ExecutionPolicy Unrestricted';
#откуда копируем (источник)
$SourcePath="\\backup-srv01\SQL_Backups\Zabbix\UserParameters";
#куда копируем (приемник)
$TargetPath="C:\zabbix_agent\conf.d\UserParameters";
#откуда копируем файл конфигурации по пользовательским счетчикам (источник)
$SourceConfigFile="\\backup-srv01\SQL_Backups\Zabbix\userparams.conf";
#куда копируем файл конфигурации по пользовательским счетчикам (приемник)
$TargetConfigFile="C:\zabbix_agent\conf.d\userparams.conf";

#файлы папки-источника
$FolderSource = Get-childitem $SourcePath;

#файлы папки-приемника
$FolderTarget = Get-childitem  $TargetPath;

#признак модификаций (что-то было скопировано или удалено)
$IsModify=0;
#сколько было скопировано и удалено файлов суммарно
$Count=0;

#сравниваем файлы источника с приемником и те файлы, которые отличаются названием и размером, копируются в приемник
Compare-Object $FolderSource $FolderTarget -Property Name, Length  | Where-Object {$_.SideIndicator -eq "<="} | ForEach-Object {
    $SourceFile=$SourcePath+"\$($_.name)";
    $IsModify=1;
    #непосредственно копирование файла
    Copy-Item $SourceFile -Destination $TargetPath -Force;
    $Count++;
}

#сравниваем файлы источника с приемником и те файлы и папки, которых нет в источнике, удаляются на приемнике
Compare-Object $FolderSource $FolderTarget -Property Name, Length  | Where-Object {$_.SideIndicator -eq "=>"} | ForEach-Object {
    $TargetPath=$TargetPath+"\$($_.name)";
    $IsModify=1;
    #непосредственно удаление файла или папки
    Remove-Item $TargetPath;
    $Count++;
}

#если что-то было скопировано или удалено, то нужно:
if($IsModify -EQ 1)
{
    #1) скопировать и файл конфигурации по пользовательским счетчикам
    Copy-Item $SourceConfigFile -Destination $TargetConfigFile -Force;
    write-host $Count;

    #2) презапустить службу Агента Zabbix
    $ZabbixAgent=Get-Service | Where-Object {$_.Name -EQ "Zabbix Agent"};
    Restart-Service -Name $ZabbixAgent.Name;
}

write-host $IsModify;

#$SourcePath=$SourcePath+"\*";
#Copy-Item -Path $SourcePath -Destination $TargetPath -Recurse;