#Has to run in windows PowerShell due to eventhub libraries ( i know, lazy)
Import-Module .\PSLegoEV3WindowsPowerShell -Force

$AzureIoTConnectionString = Get-Content "C:\Temp\lego.txt"
Connect-Ev3  -AzureIoTConnectionString $AzureIoTConnectionString
Set-Ev3AzureIoTDeviceName -AzureIoTDeviceName "mrrobot"

Invoke-EV3Gripp3rAction -Action Release
Invoke-EV3Forward -isForever -Speed 8
Wait-EV3Color -color Red -iotConnString $AzureIoTConnectionString
Invoke-EV3StopMotor
Invoke-EV3Turn -Direction Right -Steps 400 
Start-Sleep -Seconds 1
Invoke-EV3Forward -isForever -Speed 8
Wait-EV3Color -color 5 -iotConnString $AzureIoTConnectionString
Invoke-EV3StopMotor 
Invoke-EV3Turn -Direction Left -Steps 400
Start-Sleep -Seconds 1
Invoke-EV3Forward -isForever -Speed 8
Wait-EV3Color -color 5 -iotConnString $AzureIoTConnectionString
Invoke-EV3StopMotor 


Invoke-EV3Forward -isForever -Speed 8
$color = Wait-EV3Color -Color NoColor -iotConnString $AzureIoTConnectionString
Invoke-SayGoodbye

#Invoke-EV3Gripp3rAction -Action "Release"
#Invoke-EV3Gripp3rAction -Action "Grab"