#Le Dirty Dev Code to import all sub files with functions
<#Get-ChildItem $PSScriptRoot\Functions\*.ps1 | ForEach-Object {
    Write-Verbose "Importing $($_.FullName)"
    & { . $_.FullName }
}#>

#TODO Add Bluebooth and usb communication
# Add multiple parameter sets depending on selected communications type

Function Connect-EV3 {
    param(
        $IPAddress = "192.168.2.8"    
    )
    $IPAddress = "192.168.2.8"    
    #Init Robot

    #Dev hardcoded dll
    [System.Reflection.Assembly]::LoadFrom("c:\DLLs\Lego.Ev3.NetCore.dll")

    
    $com = new-object Lego.Ev3.NetCore.NetworkCommunication -ArgumentList $IPAddress
    $global:brick = new-object Lego.Ev3.Core.Brick -ArgumentList $com, $true
    $result = $brick.ConnectAsync()

    While ($result.Status -eq "WaitingForActivation")
    {
        Start-Sleep -Milliseconds 100
        $result.Status

        #this loop is not optimal
        #TODO Timeout 5 seconds or find other property to check connection
    }
    
    if ($result.Status -eq "Faulted") {
        throw "Cannot connect to robot $($result.Exception)"
    }

}

Function Invoke-EV3StepMotor {
    param(
        [Lego.Ev3.Core.OutputPort] $OutputPort,
        [int] $Speed,
        [int] $Steps,
        [int] $RampUpSteps = 0,
        [int] $RampDownSteps = 0,
        [Boolean] $Brake = $false
    )
    $brick.DirectCommand.StepMotorAtPowerAsync($OutputPort, $Speed, $RampUpSteps, $Steps, $RampDownSteps, $true); 
}

#Invoke-EV3StepMotor -OutputPort "B" -Speed 100 -Steps 140 
#Invoke-EV3StepMotor -OutputPort "C" -Speed 100 -Steps 140 

Function Start-EV3LiveControl {

    #Forward
    Set-PSReadlineKeyHandler -key UpArrow -ScriptBlock {  Invoke-EV3Forward }
        
        #Backward
        Set-PSReadlineKeyHandler -key DownArrow -ScriptBlock { Invoke-EV3Backward }
        
        #Right Turn
        Set-PSReadlineKeyHandler -key RightArrow -ScriptBlock { Invoke-EV3Turn -Direction Right }
        
        #Left turn
        Set-PSReadlineKeyHandler -key LeftArrow -ScriptBlock { Invoke-EV3Turn -Direction Left }
    
    }
    
    Function Invoke-EV3Forward {
        param(
            [int] $Steps = 140
        )
        Invoke-EV3StepMotor -OutputPort "B" -Speed 100 -Steps $Steps 
        Invoke-EV3StepMotor -OutputPort "C" -Speed 100 -Steps $Steps 
    }
    
    Function Invoke-EV3Backward {
        param(
            [int] $Steps = 140
        )
        Invoke-EV3StepMotor -OutputPort "B" -Speed -100 -Steps $Steps 
        Invoke-EV3StepMotor -OutputPort "C" -Speed -100 -Steps $Steps 
    }
    
    Function Invoke-EV3Turn {
        param(
            [String] $Direction, #TODO Add validate script
            [int] $Steps = 140
        )
    
        switch($Direction) {
            "Left" {
                Invoke-EV3StepMotor -OutputPort "B" -Speed -100 -Steps $Steps 
                Invoke-EV3StepMotor -OutputPort "C" -Speed 100 -Steps $Steps 
                break
            }
            "Right"{
                Invoke-EV3StepMotor -OutputPort "B" -Speed -100 -Steps $Steps 
                Invoke-EV3StepMotor -OutputPort "C" -Speed 100 -Steps $Steps 
                break
            }
        }
    
    }
    
    Function ConvertTo-Ev3Steps {
        param(
            [Parameter(Mandatory=$true,
                       ValueFromPipelineByPropertyName=$true,
                       ValueFromPipeline= $true,
                       Position=0)]
            $Value,    
            [Parameter(Mandatory=$false,
                       ValueFromPipelineByPropertyName=$true,
                       ValueFromPipeline= $true,
                       Position=1)]
                       [ValidateSet("Centimeters","Inches")]
        $Type = "Centimeters" 
        )
    
        switch($Type) {
            "Centimeters" {
                return $Value * 35
            }
    
            "Inches" {
                return $Value * 89
            }
        }
    }
    
    
    