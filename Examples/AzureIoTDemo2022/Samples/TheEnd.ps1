#Has to run in windows PowerShell due to eventhub libraries ( i know, lazy)
Import-Module .\PSLegoEV3WindowsPowerShell -Force

$AzureIoTConnectionString = Get-Content "C:\Temp\lego.txt"
Connect-Ev3  -AzureIoTConnectionString $AzureIoTConnectionString
Set-Ev3AzureIoTDeviceName -AzureIoTDeviceName "mrrobot"


Invoke-EV3SayGoodbye
Invoke-EV3Forward -isForever -Speed 8
Start-Sleep -Seconds 2
Invoke-EV3StopMotor
break
Invoke-EV3Forward -isForever -Speed 8
#Last Supper
Wait-EV3Color -Color NoColor -iotConnString $AzureIoTConnectionString
Set-EV3RestrictedMode -Enabled $true 
Invoke-EV3StopMotor
#Invoke-EV3PlaySound
#Start-Sleep -Seconds 25
Invoke-EV3SayGoodbye
Start-Sleep -Seconds 1
Invoke-EV3Forward -isForever -Speed 8

#Clear-EV3Queue -iotConnString $AzureIoTConnectionString
#Invoke-EV3Gripp3rAction -Action "Release"
#Invoke-EV3Gripp3rAction -Action "Grab"