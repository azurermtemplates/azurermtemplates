# Deploy 'n' Virtual Machines from a user image across 3 storage accounts in the same region

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create VMs from User image across 3 Storage accounts in the same region. You can also chose to specify the number of Virtual Machines that you want to spin up per storage accounts where the user image is placed [Recommended number is 40]. There are some critical pre-requisties for this template, please refer to them below. This template also deploys a Virtual Network, 'N' number of Network Inerfaces/Virtual Machines.

Prerequisite:

The Storage Accounts with the User Image VHD should already exist in the same resource group with correct prefixes. For example: The Storage Accounts could 'mystgacct0', 'mystgacct1' & 'mystgacct2'. The Storage account suffixes should end in 0, 1 & 2.


Note: The Recommended limit of number of disks per Storage Account is 40.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| userImageStorageAccountNamePrefix  | Name Prefix of the Storage Account where the User Image disk is placed. |
| userImageStorageContainerName  | Name of the Container Name in the Storage Account where the User Image disk is placed. |
| userImageVhdName  | Name of the User Image VHD file. |
| userImageOsType  | Specify the type of the OS of the User Image (Windows|Linux) |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| vmNamePrefix  | VM Name Prefix for the Virtual Machine Instances |
| nicNamePrefix  | NIC Name Prefix for the Network Interfaces |
| scaleNumberPerStorageAccount  | Number of Virtual Machine Instances per Storage Account. Recommended number is 40 |
| subscriptionId  | Subscription ID where the template will be deployed |
| numberOfInstances  | Number of Virtual Machine instances to create  |
| region | Region where the resources will be deployed |
| virtualNetworkName | Name of Virtual Network |
| vmSize | Size of the Virtual Machine |
