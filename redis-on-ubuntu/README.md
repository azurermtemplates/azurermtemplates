# Install a Redis cluster on Ubuntu Virtual Machines using Custom Script Linux Extension

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template deploys a Redis cluster on the Ubuntu virtual machines. This template also provisions a storage account, virtual network, availability sets, public IP addresses and network interfaces required by the installation.

The example expects the following parameters:

| Name   | Description    |
|:--- |:---|
| storageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed |
| adminUsername  | Admin user name for the Virtual Machines  |
| adminPassword  | Admin password for the Virtual Machine  |
| numberOfInstances | The number of VM instances to be configured for the Redis cluster |
| region | Region name where the corresponding Azure artifacts will be created |
| virtualNetworkName | Name of Virtual Network |
| vmSize | Size of the Virtual Machine |
| dataDiskSize | Size of each disk attached to Redis nodes (in GB) |
| subnetName | Name of the Virtual Network subnet |
| addressPrefix | The IP address mask used by the Virtual Network |
| subnetPrefix | The subnet mask used by the Virtual Network subnet |
| redisVersion | Redis version number to be installed |
| redisClusterName | Name of the Redis cluster |

Topology
--------

The deployment topology is comprised of _numberOfInstances_ nodes running in the cluster mode.
The AOF persistence is enabled by default, whereas the RDB persistence is tuned to perform less-frequent dumps (once every 60 minutes).
In addition, some critical memory- and network-specific optimizations are applied to ensure the optimal performance and throughput.

##Known Issues and Limitations
- The deployment script is not yet idempotent and cannot handle updates (it currently works for initial cluster provisioning only)
- Health monitoring of the Redis instances is not currently enabled
- SSH key is not yet implemented and the template currently takes a password for the admin user
- Redis cluster is not enabled automatically (due to inability to compose a single list of private IP addresses of all instances from within the ARM template)
- Redis version 3.0.0 or above is a requirement for the cluster (although the older versions can still be deployed without clustered configuration)