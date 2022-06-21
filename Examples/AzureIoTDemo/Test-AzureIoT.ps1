cd "C:\Users\JGS\Documents\GitHub\PSLegoEV3"

Import-Module .\PSLegoEV3WindowsPowerShell -Force

$AzureIoTConnectionString = Get-Content "C:\Temp\lego.txt"
Connect-Ev3  -AzureIoTConnectionString $AzureIoTConnectionString
Set-Ev3AzureIoTDeviceName -AzureIoTDeviceName "mrrobot"



$duration 
$duration = $Steps * 1 #duration in seconds
            $commands = @{
                leftSpeed     = -1000 # 100% speed
                leftDuration  = $duration 
                rightSpeed    = -1000
                rightDuration = $duration
            }
            #region send message from Cloud
            $cloudMessageParams = @{
                deviceId      =  "mrrobot"
                messageString = $commands | convertto-json
                cloudClient   = $AzureIoTConnectionString 
            }
            Send-IoTCloudMessage @cloudMessageParams
#Invoke-EV3Forward -AzureIoTDeviceName "mrrobot"

#Invoke-EV3Gripp3rAction -Action "Release"
#Invoke-EV3Gripp3rAction -Action "Grab"