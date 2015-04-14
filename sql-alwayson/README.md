# This template automats the deployment of SQL Server AlwaysOn cluster with Windows Server domain

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template automats the deployment of SQL Server AlwaysOn cluster with Windows Server domain. We also provided a powershell scripts to help deploy the template.  

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| serviceName  | Always deployment name |
| resourceLocation  | Resources location e.g. West US |
| certificateThumbprint  | Certificate thumbprint to encrypt credentials |
| certificateData  | Certificate data to encrypt credentials with, see attached PowerShell file for more help. |
| certificatePassword  | Certificate password to use when installing the cert |
| dcfswSourceImageName  | Windows Server image name. Suggested value is a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201502.01-en.us-127GB.vhd |
| sqlSourceImageName  | SQL Server image name. Suggested value is fb83b3509582419d99629ce476bcb5c8__SQL-Server-2014-RTM-12.0.2430.0-Ent-ENU-Win2012R2-cy14su11 |
| dcVMSize  | Domain Controller VM size. Suggested value is Small |
| sqlVMSize  | SQL VM size. Suggested value is A5 |
| administratorAccount  | VMs local administrator account name |
| administratorPassword  | VMs local administrator password |
| administratorPasswordEncrypted  | VMs local administrator password encrypted. See PowerShell helper functions |
| sqlServiceAccount  | SQL Server service account name |
| sqlServicePasswordEncrypted  | SQL Server service account encrypted password |
| domainName  | Windows domain name e.g. contoso.com| 
| domainNetBiosName  | Windows domain BIOS name e.g. contoso |





