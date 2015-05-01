# Automated deployment of SQL Server AlwaysOn cluster with new Windows Server domain

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template automates the deployment of SQL Server AlwaysOn cluster with a new Windows Server domain. Included are the PowerShell scripts to deploy the template and the JSON file which is used to execute the template with the user provided inputs.

Below are the parameters that the template requires

| Name   | Description    |
|:--- |:---|
| SubscriptionName  | Name of the Azure subscription to deploy these resources to |
| ResourceGroupName  | Name of Resource Group; must be below 15 characters |
| TemplatePath  | Local path to the JSON file |
| TemplateStorage  | Storage account in the specified subscription where you prefer the JSON template to be saved and executed from |
| ResourceLocation  | Region where resources should be created, e.g. West US |
| ServiceName  | AlwaysOn deployment name |
| certificateThumbprint  | Certificate thumbprint to encrypt credentials |
| certificateData  | Certificate data to encrypt credentials with, see attached PowerShell file for more help. |
| certificatePassword  | Certificate password to use when installing the cert |
| dcfswSourceImageName  | Windows Server image name. Must be a Windows Server 2012 R2 image. Suggested value is a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201502.01-en.us-127GB.vhd |
| sqlSourceImageName  | SQL Server image name. Must be an image that supports AlwaysOn and Windows Server 2012 R2, this means a SQL Server 2012 or 2014 Enterprise image. Suggested value is fb83b3509582419d99629ce476bcb5c8__SQL-Server-2014-RTM-12.0.2430.0-Ent-ENU-Win2012R2-cy14su11 |
| DcVMSize  | Domain Controller VM size. Suggested value is Small |
| SqlVMSize  | SQL VM size. Suggested value is Standard_A3 |
| administratorAccount  | VMs local administrator account name |
| administratorPassword  | VMs local administrator password |
| administratorPasswordEncrypted  | VMs local administrator password encrypted. See PowerShell helper functions to see how this is generated |
| sqlServiceAccount  | SQL Server service account name |
| sqlServicePasswordEncrypted  | SQL Server service account encrypted password |
| domainName  | Windows domain name e.g. contoso.com| 
| domainNetBiosName  | Windows domain BIOS name e.g. contoso |





