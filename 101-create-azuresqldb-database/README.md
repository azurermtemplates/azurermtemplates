# Create Azure SQL DB
 <a href="https://azuredeploy.net" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>


This template deploys an Azure SQL Database logical server, database and server firewall rule. The Azure SQL Database will be in the S0 performance tier. You can modify the azuredeploy file to change these defaults.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| administratorLogin | Server Admin login username |
| administratorLoginPassword  | Server Admin login password  |
| databaseName  | name of the database   |
| serverLocation | location where the resources will be deployed |
| location | location where the resources will be deployed |
| firewallStartIP | The starting ip of the server firewall rule range |
| firewallEndIP |  The ending ip of the server firewall rule range |

