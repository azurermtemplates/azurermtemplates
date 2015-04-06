# Install Elasticsearch cluster on Ubuntu Virtual Machines using Custom Script Linux Extension

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template deploys an Elasticsearch cluster on Ubuntu Virtual Machines.  The template provisions 3 dedicated master nodes in one availability set, and a configurable number of data nodes in another availability set.  A load balancer is configured with a rule to route traffic on port 9200 to the client/data nodes, and also includes SSH nat rules for management.  Elasticsearch data nodes are configured to store indexes using multiple data disks attached to each virtual machine.

This template also deploys a Storage Account, Virtual Network, Availability Sets, Public IP addresses, Load Balancer, and a Network Interface.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| storageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameforLBIP  | Unique DNS Name for the Public IP used for load balancer. |
| subscriptionId  | Subscription ID where the template will be deployed |
| region | region where the resources will be deployed |
| virtualNetworkName | Name of Virtual Network |
| vmSizeMasterNodes | Size of the Cluster Master Virtual Machine Instances |
| vmSizeDataNodes | Size of the Cluster Data Virtual Machine Instances |
| dataNodes | Number of Elasticsearch data storage instances in the cluster |
| esClusterName | Name of the Elasticsearch cluster (elasticsearch) |
| esVersion | Elasticsearch version to deploy (1.5.0) |
| dataDisksCount * | Number of data disks to attach to data storage instances (NOT IMPLEMENTED due to current limitation in the provider and fixed at 2) |
| dataDiskSize | The size of each data disk attached in Gb (default 200GB) |
| installMarvel | Optionally add the marvel plugin (yes/no)|



##Known Issues and Limitations
- Fixed number of data disks (This is due to a current template feature limitation and is fixed at 2 in order to all A0 instances for testing)
- Only first two data instances are added to the load balancer and only the first two are accessible via SSH (This is due to a current limitation in the template providers)
- No security control on the external endpoint or internal load balancing (This is due to some current limitations and requirements that need to further defined)
- Scripts are not yet idempotent and cannot handle updates (This currently works for create ONLY)
- Not yet monitoring the instances or Elasticsearch process using probes or monit
- Fixed configuration of data, master, and client nodes
- Storage option is currently limited to persistent data disks that utilize Elasticsearch multi-path storage features as opposed to OS striping
- Not all Elasticsearch configurations are exposed through parameters
- Cluster nodes are not aware of upgrade/fault domains so there is no way to ensure Elasticsearch places replicas across these when cluster node size exceeds the maximum and multiple nodes are in the same upgrade or fault domain
- Cannot pass a reference to an Elasticsearch configuration file to load from an arbitrary Url
- Work, Log, and plugin paths have not yet been reconfigured from their defaults
- SSH Key is not yet implemented and the template currently takes a password for the user
