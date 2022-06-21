param(
    [Parameter(Mandatory=$true)]
    [String]$IPAddress,
    [Parameter(Mandatory=$true)]
    [Int]$LengthInCm,
    [Parameter(Mandatory=$true)]
    [ValidateSet("grab", "release")]
    [String]$Action
)

$ErrorActionPreference = "stop"

#Init Robot
Import-Module PSLegoEV3WindowsPowerShell
Connect-EV3 -IPAddress $IPAddress

$lengthInSteps = $LengthInCm * 35

#Go forward
Invoke-EV3Forward -Steps $lengthInSteps

Start-Sleep -Seconds 1

Invoke-EV3Gripp3rAction -Action $Action
