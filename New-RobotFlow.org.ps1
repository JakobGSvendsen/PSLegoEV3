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
[System.Reflection.Assembly]::LoadFrom("C:\DLLs\Lego.Ev3.Desktop.dll")
$com = new-object Lego.Ev3.Desktop.NetworkCommunication -ArgumentList $IPAddress
$brick = new-object Lego.Ev3.Core.Brick -ArgumentList $com, $true
$result = $brick.ConnectAsync()

Start-Sleep -Seconds 1
if($result.Status -eq "Faulted")
{
    throw "Cannot connect to robot $($result.Exception)"
}

#$LengthInCm = 30
$lengthInSteps = $LengthInCm * 35

#Go forward
$brick.DirectCommand.StepMotorAtPowerAsync("B", 100, 0, $lengthInSteps, 0, $true); 
$brick.DirectCommand.StepMotorAtPowerAsync("C", 100, 0, $lengthInSteps, 0, $true); 
start-sleep -Seconds 1

switch($Action) {
    "grab" {
        #Release grab
        $brick.DirectCommand.StepMotorAtPowerAsync("A",50, 0, 700, 0, $true)
        start-sleep -Seconds 2
        $brick.DirectCommand.StopMotorAsync("A",$false)
    }

    "release" {
        #Release grab
        $brick.DirectCommand.StepMotorAtPowerAsync("A",-50, 0, 700, 0, $true)
        start-sleep -Seconds 2
        $brick.DirectCommand.StopMotorAsync("A",$false)
    }
} 