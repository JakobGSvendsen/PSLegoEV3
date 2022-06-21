#Le Dirty Dev Code to import all sub files with functions
<#Get-ChildItem $PSScriptRoot\Functions\*.ps1 | ForEach-Object {
    Write-Verbose "Importing $($_.FullName)"
    & { . $_.FullName }
}#>

#TODO Add Bluebooth and usb communication
# Add multiple parameter sets depending on selected communications type

Function Connect-EV3 {
    param(
        [Parameter(Mandatory = $true, 
            ParameterSetName = 'local')]
        $IPAddress,
        [Parameter(Mandatory = $true, 
            ParameterSetName = 'azureIoT')]
        $AzureIoTConnectionString
    )
    #Init Robot

    #Dev hardcoded dll
    #[System.Reflection.Assembly]::LoadFrom("C:\Program Files\WindowsPowerShell\Modules\PSLegoEV3WindowsPowerShell\Lego.Ev3.Desktop.dll")
    $script:Mode = "local"
    if ($null -ne $AzureIoTConnectionString) {
        $script:Mode = "azureiot"
    }

    switch ($script:Mode) {
        "local" {
            
            try {
                $com = new-object Lego.Ev3.NetCore.NetworkCommunication -ArgumentList $IPAddress
                $script:brick = new-object Lego.Ev3.Core.Brick -ArgumentList $com, $true
                $brick.ConnectAsync().Wait()
            }
            catch [AggregateException] {
                $currentError = $_
                throw $currentError.Exception.InnerExceptions
            }
        }
        "azureiot" {
            #import-module C:\TFS\ev3dev\AzureIoT\AzureIoT.psm1 -Force
            import-module AzureIoT -Force
            #region Create a CloudClient
            $CloudClientParams = @{
                iotConnString = $AzureIoTConnectionString
            }
            $Script:azureIoTCloudClient = Get-IoTCloudClient @CloudClientParams 
        }
    }
}
Function Set-Ev3AzureIoTDeviceName($AzureIoTDeviceName) {
    $script:AzureIoTDeviceName = $AzureIoTDeviceName
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
    if($global:Mode -eq "azureiot"){ throw "Not supported yet in Azure IoT mode"}
    $script:brick.DirectCommand.StepMotorAtPowerAsync($OutputPort, $Speed, $RampUpSteps, $Steps, $RampDownSteps, $Brake); 
   
}


Function Invoke-EV3StopMotor {
    param(
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromPipeline = $true,
            Position = 0)]
        [Lego.Ev3.Core.OutputPort] $OutputPort,
        [Boolean] $Brake = $false
    )
    if($global:Mode -eq "azureiot"){ throw "Not supported yet in Azure IoT mode"}
    $script:brick.DirectCommand.StopMotorAsync($OutputPort, $Brake)
}

Function Start-EV3LiveControl {

    param(
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            ValueFromPipeline = $true,
            Position = 0)]
        [ValidateSet("GRIPP3R")] #Current only supports gripper robot
        $RobotType = "GRIPP3R"
    )
    Write-Output "Live Control Started. Use Arrows & PageUp/Down."
    switch ($RobotType) {
        "GRIPP3R" {
            #Forward
            Set-PSReadlineKeyHandler -key UpArrow -ScriptBlock { 
                Write-Host "Forward"
                Invoke-EV3Forward 
            }
        
            #Backward
            Set-PSReadlineKeyHandler -key DownArrow -ScriptBlock { 
                Write-Host "Backward"
                Invoke-EV3Backward 
            }
        
            #Right Turn
            Set-PSReadlineKeyHandler -key RightArrow -ScriptBlock { 
                Write-Host "Right"
                Invoke-EV3Turn -Direction Right 
            }
        
            #Left turn
            Set-PSReadlineKeyHandler -key LeftArrow -ScriptBlock { 
                Write-Host "Left"
                Invoke-EV3Turn -Direction Left 
            }

            #Grab
            Set-PSReadlineKeyHandler -key PageUp -ScriptBlock { 
                Write-Host "Grab"
                Invoke-EV3Gripp3rAction -Action "Grab" 
            }

            #Release
            Set-PSReadlineKeyHandler -key PageDown -ScriptBlock { 
                Write-Host "Release"
                Invoke-EV3Gripp3rAction -Action "Release" 
            }
        }
    }
}

Function Invoke-EV3Forward {
    param(
        [int] $Steps = 140,
        [Lego.Ev3.Core.OutputPort] $OutputPortLeft = "C",
        [Lego.Ev3.Core.OutputPort] $OutputPortRight = "B",
        [String] $AzureIoTDeviceName,
        [int] $Speed = 100
    )
    switch ($script:Mode) {
        "local" {
            $script:brick.BatchCommand.StepMotorAtPower($OutputPortLeft, $Speed, $Steps, $false)
            $script:brick.BatchCommand.StepMotorAtPower($OutputPortRight, $Speed, $Steps, $false)
            $script:brick.BatchCommand.SendCommandAsync().Wait()
        }
        "azureiot" {
            $duration = $Steps * 1 #duration in seconds
            $commands = @{
                leftSpeed     = 1000 # 100% speed
                leftDuration  = $duration 
                rightSpeed    = 1000
                rightDuration = $duration
               
            }
            #region send message from Cloud
            $cloudMessageParams = @{
                deviceId      = $script:AzureIoTDeviceName
                messageString = $commands | convertto-json
                cloudClient   = $script:azureIoTCloudClient
            }
            Send-IoTCloudMessage @cloudMessageParams
        }
    } #switch ($script:Mode) {

}
    
Function Invoke-EV3Backward {
    param(
        [int] $Steps = 140,
        [Lego.Ev3.Core.OutputPort] $OutputPortLeft = "C",
        [Lego.Ev3.Core.OutputPort] $OutputPortRight = "B"
    )
    switch ($script:Mode) {
        "local" {
            Invoke-EV3StepMotor -OutputPort $OutputPortLeft -Speed -100 -Steps $Steps 
            Invoke-EV3StepMotor -OutputPort $OutputPortRight -Speed -100 -Steps $Steps 
        }
        "azureiot" {
            $duration = $Steps * 1 #duration in seconds
            $commands = @{
                leftSpeed     = -1000 # 100% speed
                leftDuration  = $duration 
                rightSpeed    = -1000
                rightDuration = $duration
               
            }
            #region send message from Cloud
            $cloudMessageParams = @{
                deviceId      = $script:AzureIoTDeviceName
                messageString = $commands | convertto-json
                cloudClient   = $script:azureIoTCloudClient
            }
            Send-IoTCloudMessage @cloudMessageParams
        }
    } #switch ($script:Mode) {
}
    
Function Invoke-EV3Turn {
    param(
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromPipeline = $true,
            Position = 1)]
        [ValidateSet("Left", "Right")]
        [String] $Direction,
        [int] $Steps = 140,
        [Lego.Ev3.Core.OutputPort] $OutputPortLeft = "C",
        [Lego.Ev3.Core.OutputPort] $OutputPortRight = "B"
    )
    
    switch ($Direction) {
        "Left" {
            $LeftSpeed = -100
            $RightSpeed = 100
            break
        }
        "Right" {
            $LeftSpeed = 100
            $RightSpeed = -100
            break
        }
    }

    switch ($script:Mode) {
        "local" {
            Invoke-EV3StepMotor -OutputPort $OutputPortLeft -Speed $LeftSpeed -Steps $Steps 
            Invoke-EV3StepMotor -OutputPort $OutputPortRight -Speed $RightSpeed -Steps $Steps 
        }
        "azureiot" {
            $duration = $Steps * 1 #duration in seconds
            $commands = @{
                leftSpeed     = $LeftSpeed * 10 # 100% speed
                leftDuration  = $duration 
                rightSpeed    = $RightSpeed * 10
                rightDuration = $duration
               
            }
            #region send message from Cloud
            $cloudMessageParams = @{
                deviceId      = $script:AzureIoTDeviceName
                messageString = $commands | convertto-json
                cloudClient   = $script:azureIoTCloudClient
            }
            Send-IoTCloudMessage @cloudMessageParams
        }
    } #switch ($script:Mode) {
    
}
   
Function Invoke-EV3Gripp3rAction {
    param(
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromPipeline = $true,
            Position = 0)]
        [ValidateSet("Grab", "Release")]
        [String] $Action,
        [int] $Steps = 700,
        [Lego.Ev3.Core.OutputPort] $OutputPort = "A"
    )
    switch ($script:Mode) {
        "local" {
            switch ($Action) {
                "Grab" {
                    Invoke-EV3StepMotor -OutputPort $OutputPort -Speed 50 -Steps $Steps 
                    Start-sleep -Seconds 2
                    Invoke-EV3StopMotor -OutputPort $OutputPort
                    break
                }
                "Release" {
                    Invoke-EV3StepMotor -OutputPort $OutputPort -Speed -50 -Steps $Steps 
                    Start-sleep -Seconds 2
                    Invoke-EV3StopMotor -OutputPort $OutputPort
                    break
                }
            }
        }
        "azureiot" {
            $duration = $Steps + 1300 * 1 #duration in seconds

            switch ($Action) {
                "Grab" {
                    $commands = @{
                        grabSpeed    = 500
                        grabDuration = $duration
                    }
                    break
                }
                "Release" {
                    $commands = @{
                        grabSpeed    = -500
                        grabDuration = $duration
                    }
                    break
                }
            }
          
            #region send message from Cloud
            $cloudMessageParams = @{
                deviceId      = $script:AzureIoTDeviceName
                messageString = $commands | convertto-json
                cloudClient   = $script:azureIoTCloudClient
            }
            Send-IoTCloudMessage @cloudMessageParams
        }
    } #switch ($script:Mode) {
    
}
   
Function ConvertTo-Ev3Steps {
    param(
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromPipeline = $true,
            Position = 0)]
        $Value,    
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            ValueFromPipeline = $true,
            Position = 1)]
        [ValidateSet("Centimeters", "Inches")]
        $Type = "Centimeters",
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            ValueFromPipeline = $true,
            Position = 2)]
        [ValidateSet("GRIPP3R")] #Current only supports gripper robot
        $RobotType = "GRIPP3R"
    )
      
    switch ($RobotType) {
        "GRIPP3R" {
            switch ($Type) {
                "Centimeters" {
                    return $Value * 35
                }
        
                "Inches" {
                    return $Value * 89
                }
            }
        }
    }

       
}
    
Function Enable-EV3EdgeProtection {
    param(
        [Lego.Ev3.Core.OutputPort] $OutputPortLeft = "C",
        [Lego.Ev3.Core.OutputPort] $OutputPortRight = "B",
        [Lego.Ev3.Core.InputPort] $InputPort = "One",
        [ScriptBlock] $InvokeScriptBlock
    )
    if($global:Mode -eq "azureiot"){ throw "Not supported yet in Azure IoT mode"}
    #$brick.Ports[[Lego.Ev3.Core.InputPort]::One].SetMode([Lego.Ev3.Core.ColorMode]::Color)
    $brick.Ports[$InputPort].SetMode([Lego.Ev3.Core.ColorMode]::Color)

    $global:currentEdgeOutputPortLeft = $OutputPortLeft
    $global:currentEdgeOutputPortRight = $OutputPortRight
    $global:currentEdgeScriptBlock = $InvokeScriptBlock
    #start on transparent as we dont want it to stop right away if it is not setup yet
    $colorLast = "Transparent"

    $ActionBrickChanged = {
        #[int] [Lego.Ev3.Core.ColorSensorColor]::Black
        $colorCurrent = [string][Lego.Ev3.Core.ColorSensorColor] [int] $event.SourceArgs.Ports[0]["One"].SIValue
        $colorCurrent
        if ($colorCurrent -ne $global:colorLast) {
            if ("Transparent" -eq $colorCurrent) {
                Invoke-EV3StopMotor -OutputPort $global:currentEdgeOutputPortLeft
                Invoke-EV3StopMotor -OutputPort $global:currentEdgeOutputPortRight
                if ($null -ne $global:currentEdgeScriptBlock) {
                    & $global:currentEdgeScriptBlock
                }
            }
        
            $global:colorLast = $colorCurrent
            #Clear-Host
            $colorCurrent
        }
    }
    UnRegister-Event -SourceIdentifier "BrickChanged"  -ErrorAction SilentlyContinue
    Register-ObjectEvent -InputObject $brick -EventName BrickChanged -SourceIdentifier "BrickChanged" -Action $ActionBrickChanged  -Verbose
}
    
    