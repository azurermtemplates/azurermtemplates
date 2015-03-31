# Azure Resource Manager Templates

# Contributing guide

This is a repo that contains all the currently available Azure Resource Manager templates contributed by the community. We'll soon allow a way for these templates to be indexed on [Azure.com](http://azure.microsoft.com) and be discoverable from there.

To make sure your template is added to Azure.com index, please follow these guidelines. Any templates that are out of compliance will be added to the **blacklist.json** file and not be indexed on Azure.com

1.	Every template must be contained in its own **folder**. Name this folder something that describes what your template does
2.	The template file must be named **azuredeploy.json**
3.	The template folder must host the **scripts** that are needed for successful template execution
4.	The template folder must contain a **metadata.json** file to allow the template to be indexed on [Azure.com](http://azure.microsoft.com)
  *	Guidelines on the metadata file below
5.	Every parameter in the template must have the **description** specified using the metadata property. See the starter template is provided [here](https://github.com/azurermtemplates/azurermtemplates/tree/master/_starter_template_with_validation) on how to do this
6.	OPTIONAL: The folder may contain a **Readme.md** file for any additional information about the template

## metadata.json file

Here are the required parameters for a valid metadata.json file

    {
      "TemplateName": "",
      "Description": "",
      "ShortDescription": "",
      "GithubUsername": "",
      "DateUpdated": "<e.g. 2015-12-20>"
    }

The metadata.json file will be validated using these rules

**TemplateName**
*	Cannot be more than 60 characters

**Description**
*	Cannot be more than 1000 characters
*	Cannot contain HTML

**ShortDescription**
*	Cannot be more than 200 characters

**GithubUsername**
*	Username must be the same as the username of the author submitting the Pull Request

**DateUpdated**
*	Must be in yyyy-mm-dd format.
*	The date must not be in the future to the date of the pull request

## Starter template

A starter template is provided [here](https://github.com/azurermtemplates/azurermtemplates/tree/master/_starter_template_with_validation) for you to follow


## Index
You can deploy the template to Azure by clicking the "Deploy to Azure" button below next to each template.

| Num | Deploy to Azure  | Author                          | Template Name   | Description     |
|:------|:-----------------|:--------------------------------| :---------------| :---------------|
| 1 | <a href="https://azuredeploy.net/?repository=https://github.com/singhkay/VM-DSC-Extension-IIS-Server" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [singhkay](https://github.com/singhkay) | [VM DSC Extension IIS Server](https://github.com/singhkay/VM-DSC-Extension-IIS-Server) | This template allows you to deploy a VM with with a DSC extension that sets up an IIS server |
| 2 | <a href="https://azuredeploy.net/?repository=https://github.com/coreysa/ubuntu-azure-dev-vm" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [coreysa](https://github.com/coreysa) | [Deploy Ubuntu Azure Dev VM](https://github.com/coreysa/ubuntu-azure-dev-vm) | This template deploys an Ubuntu VM with the Azure Dev tools installed, which includes node. This executes a bash script pulled from GitHub. |
| 3 | <a href="https://azuredeploy.net/?repository=https://github.com/coreysa/deploy-docker-container-simple" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [coreysa](https://github.com/coreysa) | [Deploy from DockerHub (Simple Template)](https://github.com/coreysa/deploy-docker-container-simple) | This template allows you to deploy a Docker container from DockerHub using Compose with a very small amount of parameters (simple). |
| 4 | <a href="https://azuredeploy.net/?repository=https://github.com/azurermtemplates/azurermtemplates/tree/master/vm-with-chocolatey-app" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [drewm3](https://github.com/drewm3) | [Chocolatey VM](https://github.com/azurermtemplates/azurermtemplates/tree/master/vm-with-chocolatey-app) | This template allows you to create a VM with an application from Chocolatey.org installed. |
| 5 | <a href="https://azuredeploy.net/?repository=https://github.com/coreysa/deploy-docker-container" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [coreysa](https://github.com/coreysa) | [Deploy from DockerHub](https://github.com/coreysa/deploy-docker-container) | This template allows you to deploy a Docker container from DockerHub using Compose. |
| 6 | <a href="https://azuredeploy.net/?repository=https://github.com/singhkay/VM-Chef-Extension" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [singhkay](https://github.com/singhkay) | [VM with Chef extension](https://github.com/singhkay/VM-Chef-Extension) | This template allows you to deploy a windows VM with Chef extension and run any recipe |
| 7 | <a href="https://azuredeploy.net/?repository=https://github.com/coreysa/ubuntu-azure-add-new-user" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [coreysa](https://github.com/coreysa) | [Deploy an Ubuntu VM with an additional sudo user](https://github.com/coreysa/ubuntu-azure-add-new-user) | The purpose of this script is to show how to execute a custom script with parameters passed throguh the template that will create an additional user with sudo access. The value of the sample is to show how to pass template parameter based input into a bash Linux script.|
| 8 | <a href="https://azuredeploy.net/?repository=https://github.com/liupeirong/Azure/tree/master/ARMPXC/ARMPXC.Deployment/Templates" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [paigeliu](https://github.com/liupeirong) | [Deploy a Percona XtraDB Cluster on CentOS or Ubuntu](https://github.com/liupeirong/Azure/tree/master/ARMPXC/ARMPXC.Deployment/Templates) | This template deploys a 3-node high availability MySQL Percona XtraDB Cluster 5.6 on CentOS 6.5 or Ubuntu 12.04 LTS.|
| 9 | <a href="https://azuredeploy.net/?repository=https://github.com/azurermtemplates/azurermtemplates/tree/master/deploy-lamp-app" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> |[gbowerman](https://github.com/gbowerman) | [Deploy LAMP app on Ubuntu](https://github.com/azurermtemplates/azurermtemplates/tree/master/deploy-lamp-app) | This template uses the Azure Linux CustomScript extension to deploy a LAMP application by creating an Ubuntu VM, doing a silent install of MySQL, Apache and PHP, then creating a simple PHP script.|
| 10 | <a href="https://azuredeploy.net/?repository=https://github.com/azurermtemplates/azurermtemplates/tree/master/ubuntu-vm-with-openjdkandTomcat" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [snallami](https://github.com/snallami) | [VM-Ubuntu - Tomcat and Open JDK installation](https://github.com/azurermtemplates/azurermtemplates/tree/master/ubuntu-vm-with-openjdkandTomcat) | This template allows you to create a Ubuntu VM with OpenJDK and Tomcat.|
| 11 | <a href="https://azuredeploy.net/?repository=https://github.com/azurermtemplates/azurermtemplates/tree/master/availability-set" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [mahthi](https://github.com/mahthi) | [Deploy an Availability Set](https://github.com/azurermtemplates/azurermtemplates/tree/master/availability-set) | This template allows you to create an Availability Set in your subscription.|
| 12 | <a href="https://azuredeploy.net/?repository=https://github.com/azurermtemplates/azurermtemplates/tree/master/loadbalancer-with-nat-rule" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [mahthi](https://github.com/mahthi) | [Deploy a Load Balancer with an Inbound NAT Rule](https://github.com/azurermtemplates/azurermtemplates/tree/master/loadbalancer-with-nat-rule) | This template allows you to create a load balancer with NAT rule in your subscription.|
| 13 | <a href="https://azuredeploy.net/?repository=https://github.com/azurermtemplates/azurermtemplates/tree/master/resource-loop-virtualmachines-vnet" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [mahthi](https://github.com/mahthi) | [Deploy 'N' Virtual Machines in a Single Click](https://github.com/azurermtemplates/azurermtemplates/tree/master/resource-loop-virtualmachines-vnet) | This template allows you to deploy 'n' virtual machines in a Single Click. |
| 14 | <a href="https://azuredeploy.net/?repository=https://github.com/azurermtemplates/azurermtemplates/tree/master/virtual-network" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [mahthi](https://github.com/mahthi) | [Deploy a Virtual Network](https://github.com/azurermtemplates/azurermtemplates/tree/master/virtual-network) | This template allows you to deploy a Virtual Network. |
| 15 | <a href="https://azuredeploy.net/?repository=https://github.com/azurermtemplates/azurermtemplates/tree/master/simple-virtual-machine-from-image" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [mahthi](https://github.com/mahthi) | [Deploy a Simple Virtual Machine from an  Image](https://github.com/azurermtemplates/azurermtemplates/tree/master/simple-virtual-machine-from-image) | This template allows you to deploy a Simple Virtual Machines from an Image. |
| 16 | <a href="https://azuredeploy.net/?repository=https://github.com/azurermtemplates/azurermtemplates/tree/master/mongodb-on-centos" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [mahthi](https://github.com/mahthi) | [Install Mongo DB on CentOS Virtual Machine](https://github.com/azurermtemplates/azurermtemplates/tree/master/mongodb-on-centos) | This template deploys Mongo DB on CentOS Virtual Machine. |
| 17 | <a href="https://azuredeploy.net/?repository=https://github.com/azurermtemplates/azurermtemplates/tree/master/mongodb-on-ubuntu" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [mahthi](https://github.com/mahthi) | [Install Mongo DB on Ubuntu Virtual Machine](https://github.com/azurermtemplates/azurermtemplates/tree/master/mongodb-on-ubuntu) | This template deploys Mongo DB on Ubuntu Virtual Machine. |
| 18 | <a href="https://azuredeploy.net/?repository=https://github.com/azurermtemplates/azurermtemplates/tree/master/zookeper-ubuntu-vm-cluster" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [singhkay](https://github.com/singhkay) | [Create a Zookeeper cluster](https://github.com/azurermtemplates/azurermtemplates/tree/master/zookeper-ubuntu-vm-cluster) | This template deploys a 3-node Zookeeper cluster on Ubuntu Virtual Machines. |
| 19 | <a href="https://azuredeploy.net/?repository=https://github.com/azurermtemplates/azurermtemplates/tree/master/networkinterface-with-publicip-vnet" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [mahthi](https://github.com/mahthi) | [Create a Network Interface in a Virtual Network and associate it with a Public IP](https://github.com/azurermtemplates/azurermtemplates/tree/master/networkinterface-with-publicip-vnet) | This template creates a simple Network Interface in a Virtual Network and attaches a Public IP Address to it. |
| 20 | <a href="https://azuredeploy.net/?repository=https://github.com/azurermtemplates/azurermtemplates/tree/master/linux-virtual-machine-with-customdata" target="_blank"><img src="http://azuredeploy.net/deploybutton_small.png"/></a> | [mahthi](https://github.com/mahthi) | [Deploy a Virtual Machine with Custom Data](https://github.com/azurermtemplates/azurermtemplates/tree/master/linux-virtual-machine-with-customdata) | This template allows you to deploy a Virtual Machines by passing Custom Data to the VM. |
| 21 | <a href="https://azuredeploy.net/?repository=https://github.com/azurermtemplates/azurermtemplates/tree/master/ubuntu-vm-with-apache2" target="_blank"><img src="https://cloud.githubusercontent.com/assets/6164178/6479117/bcb11198-c1f4-11e4-8f06-b6743d7d2e1c.png"/></a> | [gbowerman](https://github.com/gbowerman) | [Deploy an Apache webserver on Ubuntu](https://github.com/azurermtemplates/azurermtemplates/tree/master/ubuntu-vm-with-apache2) | This template uses the Azure Linux CustomScript extension to deploy an Apache web server. The deployment template creates an Ubuntu VM, installs Apache2 and creates a demo HTML file. |
| 22 | <a href="https://azuredeploy.net/?repository=https://github.com/azurermtemplates/azurermtemplates/tree/master/ubuntu-vm-with-chef" target="_blank"><img src="https://cloud.githubusercontent.com/assets/6164178/6479117/bcb11198-c1f4-11e4-8f06-b6743d7d2e1c.png"/></a> | [kundanap](https://github.com/kundanap) | [Bootstrap a Ubuntu VM with Chef Agent](https://github.com/azurermtemplates/azurermtemplates/tree/master/ubuntu-vm-with-chef) | This templates provisions a Ubuntu VM and bootstraps Chef Client on it.|
| 23 | <a href="https://github.com/azurermtemplates/azurermtemplates/blob/master/ubuntu-vm-with-chef%20-%20withjson%20parameters" target="_blank"><img src="https://cloud.githubusercontent.com/assets/6164178/6479117/bcb11198-c1f4-11e4-8f06-b6743d7d2e1c.png"/></a> | [kundanap](https://github.com/kundanap) | [Bootstrap a Ubuntu VM with Chef Agent with Json paramters](https://github.com/azurermtemplates/azurermtemplates/blob/master/ubuntu-vm-with-chef%20-%20withjson%20parameters) | This templates provisions a Ubuntu VM and bootstraps Chef Client on it by taking only json parameters.|
