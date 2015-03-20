# VM-Chocolatey

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create a nice VM with an application from Chocolatey.org installed. Currently the custom script to launch the choco install is being pulled from https://iaasscripts.blob.core.windows.net/scripts/InstallApplication.ps1. Once the Custom Script Extension is updated to pull from any URL it will be updated to pull directly from GitHub.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| location  | Location where to deploy the resource  |
| newStorageAccountName    | Name of the storage account to create    |
| storageAccountType      | Type of the storage account <br> <ul>**Allowed Values**<li>Standard_LRS **(default)**</li><li>Standard_GRS</li></ul> |
| uniqueDNSNameBase | Name of VM and suffix for resources |
| vmSize | Size of the VM <br> <ul>**Allowed Values**<li>Standard_A0 **(default)**</li><li>Standard_A1</li><li>Standard_A2</li><li>Standard_A3</li><li>Standard_A4</li></ul>|
| adminUsername | Admin username for the VM |
| adminPassword | Admin password for the VM |
| subscriptionId | Your Azure Subscription Id |
| applicationToInstall | Name of Chocolatey Application (default notepadplusplus.install) |
| vmSourceImageName | Any version of Windows |
| virtualNetworkName | Name of new or existing VNet |
