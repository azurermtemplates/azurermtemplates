# Install a Redis cluster on Ubuntu Virtual Machines using Custom Script Linux Extension

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template deploys a Redis cluster on the Ubuntu virtual machines. This template also provisions a storage account, virtual network, availability sets, public IP addresses and network interfaces required by the installation.

Below are the parameters that the template expects:

| Name   | Description    |
|:--- |:---|
| storageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| numberOfInstances | The number of VM instances to be configured for the Redis cluster |
| subscriptionId  | Subscription ID where the template will be deployed |
| region | Region name where the corresponding Azure artifacts will be created |
| virtualNetworkName | Name of Virtual Network |
| vmSize | Size of the Virtual Machine |
| dataDiskSize | Size of each disk attached to Redis nodes (in GB) |
| subnet1Name | Name of the primary Virtual Network subnet |
| subnet2Name | Name of the secondary Virtual Network subnet |
| addressPrefix | The IP address mask used by the Virtual Network |
| subnet1Prefix | The subnet mask used by primary Virtual Network subnet |
| subnet2Prefix | The subnet mask used by secondary Virtual Network subnet |
| redisVersion | Redis version number to be installed |
| redisClusterName | Name of the Redis cluster |

Topology
--------

The deployment topology is comprised of _numberOfInstances_ nodes joined into a cluster.
The AOF persistence is enabled by default, whereas the RDB persistence is tuned to perform less-frequent dumps (once every 60 minutes).

