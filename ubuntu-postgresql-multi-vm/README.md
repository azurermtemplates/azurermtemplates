# Create multiple Ubuntu 14.04 VMs with PostgreSQL 9.3 service and one jumpbox VM with a public IP

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create one master PostgreSQL 9.3 server with streaming-replication to multiple (based on the 'numberOfSlaveInstances' parameter) slave servers in a private-only subnet. Each database server is configured with 2 data disks that are stripped into RAID-0 configuration using mdadm. The template also creates one publicly accessible VM to serve as a jumpbox for ssh into the backend database servers.

The template creates the following deployment resources:
* Virtual Network with two subnets: Subnet-DMZ for the jumpbox VM and Subnet-DB for the PostgreSQL master and slave VMs
* Storage account to storage the VM VHDS
* Public IP address (named publicip) for accessing the jumpbox server via ssh
* Network Interface Card (NIC) for jumpbox VM (named nicapache)
* One Network Interface Card (NIC) for PostgreSQL master servers (named nicmaster)
* Multiple Network Interface Cards (NICs) for PostgreSQL slave servers (named nicslave0, nicslave1, etc.)
* Multiple remotely-hosted CustomScriptForLinux (install_postgresql.sh with passed in parameters) extensions to install and configure the PostgreSQL service on the master and each of the numberOfSlaveInstances VMs

NOTE: To access the PostgreSQL servers, you need to use the publicly accessble jumpbox VM and ssh from it into the backend servers.

Assuming your domainName parameter was "mypsqljumpbox", location was "West US", and subnetDbPrefix was 10.1.1.0/24:
* Master PostgreSQL server will be deployed at the first available IP address in the subnet: 10.1.1.4
* Slave PostgreSQL servers will be deployed in the other IP addresses: 10.1.1.5, 10.1.1.6, etc.
* From your computer, SSH into the jumpbox `ssh mypsqljumpbox.westus.cloudapp.net`
* From the jumpbox, SSH into the master PostgreSQL server `ssh 10.1.1.4`
* On the master (e.g. 10.1.1.4), use the following code to create table and some test data within your PostgreSQL master database.

```
sudo -u postgres psql
create table table1 (name varchar(100));
insert into table1 (name) values ('name1');
insert into table1 (name) values ('name2');
select * from table1;
```

* From the jumpbox, SSH into one of the slave PostgreSQL servers `ssh 10.1.1.5` and use psql to check that the data propaged properly

```
sudo -u postgres psql
select * from table1;
```

Template expects the following parameters

| Name   | Description    |
|:--- |:---|
| subscriptionId  | Subscription ID where the template will be deployed |
| newStorageAccountName  | Unique DNS name for the Storage Account where the Virtual Machines' disks will be placed |
| location | Location where the resources will be deployed |
| domainName | Domain name of the publicly accessible jumpbox VM |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| numberOfSlaveInstances  | Number of PostgreSQL slave servers to deploy |
| vmSize | Size of each of the virtual machines |
| replicatorPassword | Password to use for the pgsql replication user (replicator) |
| dbMasterName | Name of the master PostgreSQL server (e.g. dbmaster) |
| dbSlaveNamePrefix | Prefix for the name of the PostgreSQL slave-servers (e.g. dbslave will result in dbslave0, dbslave1, etc.) |
| dbAvailabilitySetName | Name of the availability set into which master and slave servers will be deployed |
| platformFaultDomainCount | Number of fault domains within the availability set |
| platformUpdateDomainCount | Number of update domains within the availability set |
| dataDiskSizeGB | Size of the data disks that will be attached to the PostgreSQL database servers and stripped together |
| virtualNetworkName | Virtual network name |
| addressPrefix | Address prefix for the virtual network specified in CIDR format |
| subnetDmzName | Name of Subnet-DMZ where the jumpbox server is deployed |
| subnetDbName | Name of Subnet-DB where PostgreSQL servers are deployed |
| subnetDmzPrefix | Prefix for the Subnet-DMZ specified in CIDR format |
| subnetDbPrefix | Prefix for the Subnet-DB specified in CIDR format |
