Param(

)

Switch-AzureMode AzureServiceManagement

$ErrorActionPreference = "stop"

#Obtain Storage SAS token
#$StorageAccountKey = (Get-AzureStorageKey -StorageAccountName 'cawadscstrg').Primary
#param: 'cawadscstrg' - $StorageAccountName
#param: 'windows-powershell-dsc'- $ContainerName
$StorageAccountContext = New-AzureStorageContext 'cawadscstrg' (Get-AzureStorageKey 'cawadscstrg').Primary
$DropLocationSasToken = New-AzureStorageContainerSASToken -Container 'windows-powershell-dsc' -Context $StorageAccountContext -Permission r 
$DropLocation = $StorageAccountContext.BlobEndPoint + 'windows-powershell-dsc'

#AzCopy WebPI MSI to Azure Storage

#& "$AzCopyPath" """$LocalWebPIPath"" $DropLocation /DestKey:$StorageAccountKey /S /Y /Z:""$env:LocalAppData\Microsoft\Azure\AzCopy\$ResourceGroupName"""
#& "$AzCopyPath" "/Source:$LocalWebPIPath" "/Dest:$DropLocation" "/DestKey:$StorageAccountKey" /S /Y "/Z:$AzCopyLog"

#Publsh PowerShel DSC script to Azure storage account
#param: '.\ConfigureWebServer.ps1' - $configurationPath
Publish-AzureVMDscConfiguration -ConfigurationPath '.\ConfigureWebServer.ps1' -Force

#Publish Azure Resource Manager template
#param: "cawadscrg0510" - $resourceGroupName
#param: "westus" - $location
#param: '..\Templates\WindowsVirtualMachine.json' - $templateFile
#param: '..\Templates\WindowsVirtualMachine.param.dev.json' - $templateParameterFile
Switch-AzureMode AzureResourceManager
New-AzureResourceGroup -Name "cawadscrg1107" `
                       -Location "westus" `
                       -TemplateFile '..\Templates\WindowsVirtualMachine.json' `
                       -TemplateParameterFile '..\Templates\WindowsVirtualMachine.param.dev.json' `
 
 #deploy web application to the Virtual Machine
 #param: 'C:\Program Files (x86)\IIS\Microsoft Web Deploy V3\msdeploy.exe' - $msdeployPath
 #param: "C:\WebDeployLocation\WebApplication3.zip" - $sourcePackage
 #param: "cawaiisdns10.westus.cloudapp.azure.com" - $computerName
 #param: "vmuser" - $userName
 #param: "test.123" - $password
 #& 'C:\Program Files (x86)\IIS\Microsoft Web Deploy V3\msdeploy.exe' '-source:package="C:\WebDeployLocation\WebApplication3.zip"' '-dest:auto,ComputerName="cawaiisdns10.westus.cloudapp.azure.com",username="vmuser",password="test.123"' '-verb:sync' '-allowUntrusted'               