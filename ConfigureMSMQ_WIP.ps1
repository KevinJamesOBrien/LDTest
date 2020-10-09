###########################################################################################################
##@Script Name - "ConfigureMSMQ.ps1"
##@Team - Tech Services
##@Author - "Kevin O'Brien"<kevin.obrien@na.linedata.com>
##
##This script is intended to be used with SSM Documents that run powershell 
## scripts on EC2 instances to configure Longview
##Creates a new MSMQ Queue if there is none with the current name. 
## If there is one with the same name, then delete that one and create a new one with the below details. 
############################################################################################################

 
 Function ConfigureMSMQ {
    param(  [string]$Name )
    try {
        Write-Host "Configuring MSMQ `"$Name`"..."
		$MsmqQueue = Get-MsmqQueue -Name $Name
        if (-Not ([string]::IsNullOrEmpty($MsmqQueue))){
            Write-Host "MSMQ Queue `"$Name`" already exists. Deleting MSMQ $DSNName and recreating..."
            Get-MsmqQueue -Name $Name | Remove-MsmqQueue 
			Write-Host "MSMQ Queue `"$Name`" Deleted"
        }
        New-MsmqQueue -Name $Name
		Write-Host "MSMQ Queue `"$Name`" Created"
    }catch {
        Write-Host "Exception: $($_)"
       Throw "ConfigureMSMQ failed"
    }
}

#$Name = "AAANewmsmq"
$Name = "lv_notify_test_CLIENT_SOMETHING_ELSE"

Write-Host "Starting MSMQ Configuration..."
ConfigureMSMQ -Name $Name 
Write-Host "Finished MSMQ Configuration!"