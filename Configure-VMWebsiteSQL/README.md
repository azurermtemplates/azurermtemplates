# VM-DSC-Extension-IIS-Server

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to deploy a Web application a VM. It also configures the Web Applicatino to set the SQL Azure database server.
Please make sure you have your DSC powershell script published to an Azure storage using Publish-AzureVMDscConfiguration -ConfigurationPath '..\ConfigureWebServer.ps1' -Force
In addition, please upload your WebApplication.zip webdeploy package to a shared location. 
Will update the script to automate the entire process

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| location  | Location where to deploy the resource  |
| newStorageAccountName    | Name of the storage account to create    |
| storageAccountType      | Type of the storage account <br> <ul>**Allowed Values**<li>Standard_LRS **(default)**</li><li>Standard_GRS</li></ul> |
| publicIPAddressName | Name of the public IP address to create |
| publicIPAddressType | Type of Public IP Address |
| vmStorageAccountContainerName | Name of storage account container for the VM <br> <ul><li>vhds **(default)**</li></ul>|
| vmName | Name for the VM |
| vmSize | Size of the VM <br> <ul>**Allowed Values**<li>Standard_A0 **(default)**</li><li>Standard_A1</li><li>Standard_A2</li><li>Standard_A3</li><li>Standard_A4</li></ul>|
| vmSourceImageName | Name of image to use for the VM <br> <ul><li>a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201412.01-en.us-127GB.vhd **(default)**</li></ul>|
| adminUsername | Admin username for the VM |
| adminPassword | Admin password for the VM |
| virtualNetworkName | Name of the Virtual Network |
| addressPrefix | Virtual Network Address Prefix <br> <ul><li>10.0.0.0/16 **(default)**</li></ul> |
| subnet1Name | Name of Subnet 1 <br> <ul><li>Subnet-1 **(default)**</li></ul> |
| subnet2Name | Name of Subnet 2 <br> <ul><li>Subnet-2 **(default)**</li></ul> |
| subnet1Prefix | Address prefix for Subnet 1 <br> <ul><li>10.0.0.0/24 **(default)**</li></ul> |
| subnet2Prefix | Address prefix for Subnet 2 <br> <ul><li>10.0.0.0/24 **(default)**</li></ul> |
| dnsName | DNS for the VM |
| subscriptionId | Your Azure Subscription Id |
| nicName | Name for the Network Interface |
| vmExtensionName | Name for the Extension |
| modulesUrl | Url for the DSC configuration module <br> <ul> <li><b>Example:</b> https://xyz.blob.core.windows.net/abc/ContosoWebsite.ps1.zip</li></ul>|
| sasToken | SAS Token for the DSC configuration module |
| configurationFunction | Name of the function to run in the DSC configuration <br> <ul> <li><b>Example:</b> ContosoWebsite.ps1/ContosoWebsite </li></ul> |


