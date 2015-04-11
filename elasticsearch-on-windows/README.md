# ElasticSearch On Windows

<a href="https://azuredeploy.net" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template creates a loadbalanced ElasticSearch cluster running on Windows 2012. 

It allows you to define the number of nodes in the cluster. It will install the jdk, download elasticsearch, install it, install the head plugin to make it easier to visualise the cluster, sets up the cluster so all the nodes can talk to each other. The loadbalancer is also set up and exposes RDP ports (on the first two nodes) as well as port 9200.

Since it exposes the ElasticSearch cluster over the load balancer on port 9200 you may want to look at adding some layer of security in. After deployment you can visualize the cluster by browsing to: http://<public_ip>:9200/_plugin/head/.

This template deploys a Storage Account, Virtual Network, Public IP addresses, Load Balancer, Virtual Machines and a Network Interface.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| storageName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed |
| nodeAdminUsername  | Username for the Virtual Machines  |
| nodeAdminPassword  | Password for the Virtual Machine  |
| dnsName  | Unique DNS Name for the Public IP (dnsName.westus.cloudapp.azure.com) |
| location | location where the resources will be deployed |
| virtualNetworkName | Name of Virtual Network |
| nodeSize | Size of the Virtual Machine Instance |
| vnetPrefix | Virtual Network Address Prefix <br> <ul><li>10.0.0.0/16 **(default)**</li></ul> |
| vnetSubnet1Name | Name of Subnet 1 <br> <ul><li>Subnet-1 **(default)**</li></ul> |
| vnetSubnet1Prefix | Address prefix for Subnet 1 <br> <ul><li>10.0.0.0/24 **(default)**</li></ul> |
| subscriptionId | Your Azure Subscription Id |
| storageType | Storage redundancy type |
| nodeStorageAccountContainerName | Name for the container to place the vhds in |
| nodeSourceImageName | Image name to use for node vm |
| publicIpAddressName | Name of public ip address |
| publicIpAddressType | Type of public ip address |
| nodes | Total of how many nodes you want |
| nodeIpAddresses | Array of internal ip addresses for each node |
| nodeIPAddressesString | A comma separated list of the values in nodeIpAddresses for passing to powershell script |
| clusterName | Name for the elasticsearch cluster |
