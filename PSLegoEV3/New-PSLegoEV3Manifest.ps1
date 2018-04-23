$ModulePath = "PSLegoEV3.psm1"
$ManifestPath = "C:\Users\JGS\Documents\GitHub\PSLegoEV3\PSLegoEV3\PSLegoEV3.psd1"
New-ModuleManifest -Path $ManifestPath -RootModule $ModulePath -Author "Jakob G. Svendsen" -ModuleVersion 0.0.1 -Copyright "Jakob G. Svendsen" -PowerShellVersion 6.0.0 -Description "LEGO Mindsstorms EV3 from PowerShell!"  -ProjectUri "http://www.ctglobalservices.com" -RequiredAssemblies "Lego.Ev3.NetCore.dll"
