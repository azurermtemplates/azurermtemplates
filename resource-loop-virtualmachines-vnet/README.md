# Create Virtual Machines using Resource Loops

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create 'N' number of Virtual Machines based on the 'numberOfInstances' parameter specified during the template deployment. This template also deploys a Storage Account, Virtual Network, 'N' number of Public IP addresses/Network Inerfaces/Virtual Machines.

Note: Please limit the number of VMs to 40 per Storage Account.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| storageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| subscriptionId  | Subscription ID where the template will be deployed |
| numberOfInstances  | Number of Virtual Machine instances to create  |
| region | Region where the resources will be deployed |
| virtualNetworkName | Name of Virtual Network |
| vmSize | Size of the Virtual Machine |
| subnet1Name | Name of Subnet-1 |
| subnet2Name | Name of Subnet-2 |
| subnet1Prefix | Prefix for the Subnet-1 specified in CIDR format |
| subnet2Prefix | Prefix for the Subnet-2 specified in CIDR format |
| addressPrefix | Address prefix for the Virtual Network specified in CIDR format |
