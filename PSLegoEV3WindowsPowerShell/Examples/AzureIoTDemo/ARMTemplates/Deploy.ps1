Set-Location $PSScriptRoot

<#
Connect-AzAccount
Select-AzSubScription -SubscriptionName "Microsoft Azure Sponsorship" -Tenant "runbookguru.onmicrosoft.com" 

#>

$ResourceGroupName = 'PSLegoEV3Demo'
$ResourceGroupLocation = "west europe"
New-AzResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation -force
New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile '.\azuredeploy.json' `
-TemplateParameterFile '.\azuredeploy.parameters.json' -Verbose