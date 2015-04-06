# Deploy Docker Containers on Virtual Machines across 5 regions using Loops & Template Linking

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create 'N' number of Virtual Machines based on the 'numberOfInstances' parameter specified during the template deployment and deploys 2 docker containers [nginx & redis] on each VM. This template also deploys a Storage Account, Virtual Network, 'N' number of Public IP addresses/Network Inerfaces/Virtual Machines.

Note: The Recommended limit of number of disks per Storage Account is 40.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| storageAccountNamePrefix  | Storage Account Name Prefix where the Virtual Machine's disks will be placed. |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machines  |
| subscriptionId  | Subscription ID where the template will be deployed |
| scaleNumberPerRegion  | Number of Virtual Machine instances to create per Region  |
| virtualNetworkNamePrefix | Virtual Network Name Prefix |
| vmNamePrefix | Virtual Machine Name Prefix |
| publicIPAddressNamePrefix | Public IP address Name Prefix |
| nicNamePrefix | Network Interface Name Prefix |
