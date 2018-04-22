Import-Module C:\Users\JGS\Documents\GitHub\PSLegoEV3\PSLegoEV3\PSLegoEV3.psm1 -Force

Connect-EV3 -IPAddress "192.168.2.8"

Invoke-EV3Forward
#Start-LiveControl 