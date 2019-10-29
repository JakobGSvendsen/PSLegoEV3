param(
    [Parameter(Mandatory=$true)]
    [String]$AzureIoTDeviceName,
    [Parameter(Mandatory=$true)]
    [Int]$LengthInCm,
    [Parameter(Mandatory=$true)]
    [ValidateSet("grab", "release")]
    [String]$Action
)

$ErrorActionPreference = "stop"

#Init Robot
Import-Module PSLegoEV3WindowsPowerShell

$AzureIoTConnectionString = Get-AutomationVariable -Name "AzureIotConnectionString"
Connect-Ev3  -AzureIoTConnectionString $AzureIoTConnectionString
Set-Ev3AzureIoTDeviceName -AzureIoTDeviceName $AzureIoTDeviceName

$lengthInSteps = $LengthInCm * 35

#Go forward
Invoke-EV3Forward -Steps $lengthInSteps

Start-Sleep -Seconds 1

Invoke-EV3Gripp3rAction -Action $Action
