$env:PSModulePath += ";C:\TFS\CTG\PSLegoEV3;C:\TFS\CTG\LEGOController\Modules"
$AzureIoTConnectionString = Get-Content "C:\Temp\AzureIoTConnectionString.txt"
$AzureIoTDeviceName = "mrrobot"

Import-Module AzureIoT

$cloudClient = Get-IoTCloudClient -iotConnString $AzureIoTConnectionString 

$steps = -1
$speed = 500
$commands = @{
    leftSpeed     = -$Speed
    leftDuration  = $steps
    rightSpeed    = $Speed
    rightDuration = $steps
   
} | ConvertTo-Json 

#region send message from Cloud
$cloudMessageParams = @{
    deviceId      = $AzureIoTDeviceName
    messageString = $commands 
    cloudClient   = $cloudClient
}
Send-IoTCloudMessage @cloudMessageParams


#Stop
$commands = @{
    stopMotors = 1
}

#region send message from Cloud
$cloudMessageParams = @{
    deviceId      = $AzureIoTDeviceName
    messageString = $commands | convertto-json
    cloudClient   = $cloudClient
}
Send-IoTCloudMessage @cloudMessageParams

#Module


Import-Module PSLegoEV3 -Force

Connect-Ev3  -AzureIoTConnectionString $AzureIoTConnectionString
Set-Ev3AzureIoTDeviceName -AzureIoTDeviceName $AzureIoTDeviceName

Invoke-EV3Turn -Direction Left
Invoke-EV3Turn -Direction Right

Invoke-EV3Forward

Invoke-EV3Backward

Invoke-EV3Gripp3rAction -Action Grab 
Invoke-EV3Gripp3rAction -Action Release

#Invoke-EV3Forward
Start-EV3LiveControl 



break

Import-Module PSLegoEV3WindowsPowerShell -Force

Connect-EV3 -IPAddress "192.168.0.18"

#Invoke-EV3Forward
Start-LiveControl 