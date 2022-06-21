$iotConnString  = Get-Content "C:\Temp\lego.txt"
          $deviceId = "mrrobot"

          Import-Module "C:\TFS\MrBrick\.github\workflows\dll\Microsoft.Azure.Devices.dll" -Verbose

          $cloudClient = [Microsoft.Azure.Devices.ServiceClient]::CreateFromConnectionString($iotConnString)
          
            $content = "left:1000","right:1000"

            $Speed = 8
            $commands = @{}
            foreach($line in $content){
                $cmd  = $line.Replace(" ","").split(":")[0]
                $value = $line.Replace(" ","").split(":")[1]
                switch($cmd){
                    "left" {
                        $commands["leftDuration"] = $value 
                        $commands["leftSpeed"] = $Speed * 10 # 100% speed
                    }
                  "right" {
                        $commands["rightDuration"] = $value 
                        $commands["rightSpeed"] = $Speed * 10 # 100% speed
                    }
                }
            }
            $commands["isPublic"] = 1
            $messageString = $commands | convertto-json
            $messageString

            while($true){
            $messagetosend = [Microsoft.Azure.Devices.Message]([Text.Encoding]::ASCII.GetBytes($messageString))
            $cloudClient.SendAsync($deviceId, $messagetosend)
            Start-Sleep -Milliseconds 1000
            }
 