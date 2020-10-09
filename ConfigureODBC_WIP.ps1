###########################################################################################################
##@Script Name - "ConfigureODBC.ps1"
##@Team - Tech Services
##@Author - "Kevin O'Brien"<kevin.obrien@na.linedata.com>
##
##This script is intended to be used with SSM Documents that run powershell 
## scripts on EC2 instances to configure Longview
##Creates a new ODBC configuration if there is none with the current name. 
## If there is one with the same properties, then delete that one and create a new one with the below details. 
############################################################################################################

Function ConfigureODBC {
    param(  [string]$dsn, [string]$db, [string]$dbUser, [string]$dbPassword, [string]$serverInstance, [string]$platform)
    try {
        Write-Host "Configuring ODBC `"$dsn`" for database `"$db`"..."
        $DSNName=(Get-OdbcDSn | ?{$_.Name -eq $dsn -and $_.DsnType -eq 'System' -and $_.DriverName -eq 'SQL Server Native Client 11.0' -and $_.Platform -eq $platform} |Select Name).Name
        if (-Not ([string]::IsNullOrEmpty($DSNName))){
            Write-Host "ODBC `"$DSNName`" already exists. Deleting ODBC $DSNName and recreating..."
            Remove-OdbcDsn -Name  $DSNName -DsnType 'System' -DriverName 'SQL Server Native Client 11.0' -Platform $platform
			Write-Host "ODBC `"$DSNName`" Deleted"
        }
        Add-OdbcDsn -Name $dsn -DriverName "SQL Server Native Client 11.0" -DsnType "System" -SetPropertyValue @("Server=$serverInstance", "Database=$db") -Platform $platform
		Write-Host "ODBC `"$DSNName`" Created"
    }catch {
        Write-Host "Exception: $($_)"
       Throw "ConfigureODBC failed"
    }
}

#parameters. Currently they are populated with example text, but once we figure out the Parameter store integration, 
#then those parameters should integrate with the below variables
$dsn = "TEST_DSN"
$db = "test_db"
$dbUser = "sa_test"
$dbPassword = "sa_test-PASSWORD"
$serverInstance = "test_server"
$platform = "64-bit" #Can only be "32-bit" or "64-bit"

Write-Host "Starting ODBC Configuration..."
##ConfigureODBC("TEST", "TEST.test", "test", "test", "64-bit")
##ConfigureODBC -dsn TEST -db test_db -dbUser sa -dbPassword saPASSWORD -serverInstance TEST -platform "64-bit"
ConfigureODBC -dsn $dsn -db $db -dbUser $dbUser -dbPassword $dbPassword -serverInstance $serverInstance -platform $platform

Write-Host "Finished ODBC Configuration!"