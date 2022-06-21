$env:PSModulePath += ";C:\TFS\CTG\PSLegoEV3"
Import-Module PSLegoEV3 -Force

Connect-EV3 -IPAddress "192.168.0.18"

#Invoke-EV3Forward
Start-LiveControl 



break

Import-Module PSLegoEV3WindowsPowerShell -Force

Connect-EV3 -IPAddress "192.168.0.18"

#Invoke-EV3Forward
Start-LiveControl 