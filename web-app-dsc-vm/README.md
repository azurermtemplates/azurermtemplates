# VM-DSC-Extension-IIS-Server

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to deploy a Web application a VM. It also configures the Web Applicatino to set the SQL Azure database server.
Please make sure you have your DSC powershell script published to an Azure storage using Publish-AzureVMDscConfiguration -ConfigurationPath '..\ConfigureWebServer.ps1' -Force
In addition, please upload your WebApplication.zip webdeploy package to a shared location. 
Will update the script to automate the entire process

