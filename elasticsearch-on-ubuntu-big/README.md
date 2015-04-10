# Install Elasticsearch cluster on Ubuntu Virtual Machines with data node storage scale units

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template deploys an Elasticsearch cluster on Ubuntu Virtual Machines.  The template provisions 3 dedicated master and client nodes in separate availability sets and storage accounts. Data node scale unit count and nodes int a scale unit can be configured as parameters.  A load balancer is configured with a rule to route traffic on port 9200 to the client nodes, and also includes a single SSH nat management rule for a single node.  Multiple data disks are attached and data is striped across them as an approach to improve disk throughput.

This template also deploys a Storage Account, Virtual Network, Availability Sets, Public IP addresses, Load Balancer, and a Network Interface.

Warning!  This template provisions a large number of resources.  At a minimum, with the current defaults, 14 virtual machines and 3 storage accounts are provisioned.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| storageAccountPrefix  | Unique DNS Name for the Storage Account and the template will use this to create at storage account for each data node scale unit |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameforLBIP  | Unique DNS Name for the Public IP used for load balancer. |
| region | region where the resources will be deployed |
| virtualNetworkName | Name of Virtual Network |
| vmSizeMasterNodes | Size of the Cluster Master Virtual Machine Instances |
| vmSizeClientNodes | Size of the Cluster Data Virtual Machine Instances |
| vmSizeDataNodes | Size of the Cluster Data Virtual Machine Instances |
| dataNodeScaleUnits | Number of Elasticsearch data scale units which include a configurable number of nodes and a storage account|
| dataNodesPerUnit | Number of Elasticsearch data nodes to provision with each scale unit|
| esClusterName | Name of the Elasticsearch cluster (elasticsearch) |
| esVersion | Elasticsearch version to deploy (1.5.0) |
| dataDisksCount * | Number of data disks to attach to data storage instances (NOT IMPLEMENTED due to current limitation in the provider and fixed at 2) |
| dataDiskSize | The size of each data disk attached in Gb (default 200GB) |

##Notes
Warning!  The cluster currently uses a publically load balanced enpoint that is currently unsecured. Ideally this template would use internally load balanced endpoints and Elasticsearch Sheild product should be considered.

One of the primary advantages to this approach is that you can distribute data nodes across multiple storage accounts.  At the moment if you want to increase the number of disks attached to each node you will need to modify the data node template (data-nodes-base.json) and add more data disk resources.
