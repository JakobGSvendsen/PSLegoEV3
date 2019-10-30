Set-Location $PSScriptRoot

<#
Install-Module Az
Connect-AzAccount
Select-AzSubScription -SubscriptionName "Microsoft Azure Sponsorship" -Tenant "runbookguru.onmicrosoft.com" 
Select-AzSubScription -SubscriptionName "Microsoft Azure Sponsorship - CTGlobal" -Tenant "coretechdk.onmicrosoft.com" 

#>

$ResourceGroupName = 'psLegoEV3Demojgs'
$ResourceGroupLocation = "west europe"
New-AzResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation -force
New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile '.\azuredeploy.json' `
-TemplateParameterFile '.\azuredeploy.parameters.json' -Verbose