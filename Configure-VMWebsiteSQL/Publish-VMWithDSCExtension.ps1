Param(

)

Switch-AzureMode AzureServiceManagement

$ErrorActionPreference = "stop"

$StorageAccountContext = New-AzureStorageContext 'cawadscstrg' (Get-AzureStorageKey 'cawadscstrg').Primary
$DropLocationSasToken = New-AzureStorageContainerSASToken -Container 'windows-powershell-dsc' -Context $StorageAccountContext -Permission r 
$DropLocation = $StorageAccountContext.BlobEndPoint + 'windows-powershell-dsc'

Publish-AzureVMDscConfiguration -ConfigurationPath '.\ConfigureWebServer.ps1' -Force

Switch-AzureMode AzureResourceManager
New-AzureResourceGroup -Name "cawadscrg1123" `
                       -Location "westus" `
                       -TemplateFile '.\azuredeploy.json' `
                       -TemplateParameterFile '.\azuredeploy.param.json' `
 
