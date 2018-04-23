$env:PSModulePath += ";C:\Users\JGS\Documents\GitHub\PSLegoEV3"
Import-Module PSLegoEV3 -Force

Connect-EV3 -IPAddress "192.168.2.8"

Invoke-EV3Forward
#Start-LiveControl 