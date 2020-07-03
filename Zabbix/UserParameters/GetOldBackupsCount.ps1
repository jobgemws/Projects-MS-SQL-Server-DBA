$SQLServer = $env:COMPUTERNAME;
$uid = "login";
$pwd = "password";

$hours_full=25;
$hours_log=1;

#$SQLServer = "$env:COMPUTERNAME"#.$env:USERDOMAIN"

#write-host $SQLServer

$connectionString = "Server = $SQLServer; Database=FortisAdmin; Integrated Security = False; User ID = $uid; Password = $pwd;";

$connection = New-Object System.Data.SqlClient.SqlConnection;
$connection.ConnectionString = $connectionString;

#Create a request directly to MSSQL
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand;
$SqlCmd.CommandType = [System.Data.CommandType]::StoredProcedure;
$SqlCmd.CommandText = "zabbix.GetOldBackupsCount";
$SqlCmd.Connection = $Connection;

$paramdiffSec=$SqlCmd.Parameters.Add("@hours_full" , [System.Data.SqlDbType]::Int);
$paramdiffSec.Value = $hours_full;
$paramdiffSecBackUp=$SqlCmd.Parameters.Add("@hours_log" , [System.Data.SqlDbType]::Int);
$paramdiffSecBackUp.Value = $hours_log;

$connection.Open();
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter;
$SqlAdapter.SelectCommand = $SqlCmd;
$DataSet = New-Object System.Data.DataSet;
$SqlAdapter.Fill($DataSet) > $null;
$connection.Close();

$result = $DataSet.Tables[0].Rows[0]["count"];

write-host $($result -replace ",",".");