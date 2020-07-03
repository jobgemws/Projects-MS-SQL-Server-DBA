$SQLServer = $env:COMPUTERNAME;
$uid = "login";
$pwd = "password";

#$SQLServer = "$env:COMPUTERNAME"#.$env:USERDOMAIN"

#write-host $SQLServer

$connectionString = "Server = $SQLServer; Database=FortisAdmin; Integrated Security = False; User ID = $uid; Password = $pwd;";

$connection = New-Object System.Data.SqlClient.SqlConnection;
$connection.ConnectionString = $connectionString;

#Create a request directly to MSSQL
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand;
$SqlCmd.CommandType = [System.Data.CommandType]::StoredProcedure;
$SqlCmd.CommandText = "zabbix.GetWriteStallMSTempDB";
$SqlCmd.Connection = $Connection;

$connection.Open();
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter;
$SqlAdapter.SelectCommand = $SqlCmd;
$DataSet = New-Object System.Data.DataSet;
$SqlAdapter.Fill($DataSet) > $null;
$connection.Close();

$result = $DataSet.Tables[0].Rows[0]["valueMS"];

write-host $($result -replace ",",".");