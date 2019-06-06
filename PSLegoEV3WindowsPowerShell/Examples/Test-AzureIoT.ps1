cd "C:\Users\JGS\Documents\GitHub\PSLegoEV3"

Import-Module .\PSLegoEV3WindowsPowerShell -Force

$AzureIoTConnectionString = Get-Content "C:\Temp\azureIotConnectionString.txt"
Connect-Ev3  -AzureIoTConnectionString $AzureIoTConnectionString
Set-Ev3AzureIoTDeviceName -AzureIoTDeviceName "mrrobot"
Invoke-EV3Forward
#Invoke-EV3Forward -AzureIoTDeviceName "mrrobot"

#Invoke-EV3Gripp3rAction -Action "Release"
#Invoke-EV3Gripp3rAction -Action "Grab"