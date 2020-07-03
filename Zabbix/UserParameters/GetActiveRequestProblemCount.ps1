$SQLServer = $env:COMPUTERNAME;
$uid = "login";
$pwd = "password";

$diffSec=20;
$diffSecBackUp=300;
$Wait_Duration_ms=3000;
$Wait_Duration_semaphore_ms=500;

#$SQLServer = "$env:COMPUTERNAME"#.$env:USERDOMAIN"

#write-host $SQLServer

$connectionString = "Server = $SQLServer; Database=FortisAdmin; Integrated Security = False; User ID = $uid; Password = $pwd;";

$connection = New-Object System.Data.SqlClient.SqlConnection;
$connection.ConnectionString = $connectionString;

#Create a request directly to MSSQL
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand;
$SqlCmd.CommandType = [System.Data.CommandType]::StoredProcedure;
$SqlCmd.CommandText = "zabbix.GetActiveRequestProblemCount";
$SqlCmd.Connection = $Connection;

$paramdiffSec=$SqlCmd.Parameters.Add("@diffSec" , [System.Data.SqlDbType]::Int);
$paramdiffSec.Value = $diffSec;
$paramdiffSecBackUp=$SqlCmd.Parameters.Add("@diffSecBackUp" , [System.Data.SqlDbType]::Int);
$paramdiffSecBackUp.Value = $diffSecBackUp;
$paramWait_Duration_ms=$SqlCmd.Parameters.Add("@Wait_Duration_ms" , [System.Data.SqlDbType]::Int);
$paramWait_Duration_ms.Value = $Wait_Duration_ms;
$paramWait_Duration_semaphore_ms=$SqlCmd.Parameters.Add("@Wait_Duration_semaphore_ms" , [System.Data.SqlDbType]::Int);
$paramWait_Duration_semaphore_ms.Value = $Wait_Duration_semaphore_ms;

$connection.Open();
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter;
$SqlAdapter.SelectCommand = $SqlCmd;
$DataSet = New-Object System.Data.DataSet;
$SqlAdapter.Fill($DataSet) > $null;
$connection.Close();

$result = $DataSet.Tables[0].Rows[0]["count"];

write-host $($result -replace ",",".");