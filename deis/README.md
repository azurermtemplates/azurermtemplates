# Deploy a Deis cluster

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create a Deis cluster. This template also deploys a Storage Account, Virtual Network, Public IP addresses and a Network Interface. 

##Deploy the cluster

1. Generate an OpenSSH key pair:
		ssh-keygen -t rsa -b 4096 -c "[your_email@domain.com]"
2. Generate a certificate using the private key above:
		openssl req -x509 -days 365 -new -key [your private key file] -out [cert file to be generated]
3. Go to https://discovery.etcd.io/new to generate a new cluster token.
4. Modify **cloud-config.yaml** to replace the existing **discovery** token with the new token.
5. Modify **azuredeploy-parameters.json**: Open the certificate you created in step 2. Copy all text between  *----BEGIN CERTIFICATE-----* and *-----END CERTIFICATE-----* into the **sshKeyData** parameter (you'll need to remove all newline characters).
6. Modify other parameters such as **newStorageAccountName**, **vmNamePrefix**, **virtualNetworkName** to values of your choice. 
5. Provision the resource group:

>Note: If you chose to use the "Deploy to Azure" button experience, you'll need to manually encode **cloud-config.yaml** as a Base64 string and enter the encoded string to the **customData** parameter. Although the template can be updated to use the built-in base64() founction, I found the triple-encoding is rather troublesome especially for readability and maintenance.
		
##Install the client
You need **deisctl** to control your Deis cluster. *deisctl* is automatically installed in all the cluster nodes. However, it's a good practice to use *deisctl* on a separate administrative machine. Because all nodes are configured with public IP addresses, you'll be able to use *deisctl* from any client machines. The following are the steps of setting up *deisctl* on a separate machine.

1. Install *deisctl*
		mkdir deis
		cd deis
		curl -sSL http://deis.io/deisctl/install.sh | sh -s 1.6.1
		sudo ln -fs $PWD/deisctl /usr/local/bin/deisctl
2. Add private key to ssh agent
		eval `ssh-agent -s`
		ssh-add [path to the private key file, see step 1 in the previous section]
3. Configure *deisctl*
		export DEISCTL_TUNNEL=[public ip of one of the nodes]

##Install and start platform
Now you can use **deisctl** to install and start the platform

		deisctl config platform set domain=test.cloudapp.net
		deisctl config platform set sshPrivateKey=[path to the private key file]
		deisctl install platform
		deisctl start platform

>Note: starting the platform takes a while (>10 minutes). Especially, starting the builder service can take a long time. And sometimes it takes a few tries to succeed. If you found the operation seems to hang after a few minutes. You can use *ctrl+c* to break execution of the command and retry. Or, you can use the commands in the debugging tips section to find out the root causes of the problems.

##Other parameters

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| location | location where the resources will be deployed |
| newStorageAccountName | new storage account for the VMs OS disk |
| vmNamePrefix | prefix for the names of each VM |
| virtualNetworkName | name for the new VNET |
| vmSourceImageName | name of the CoreOS image |
| vmSize | Instance size for the VMs |
| adminUsername | Name of the admin user | 
| sshKeyData | Explained above |
| customData | Explained above |

##Deis debugging tips

1. First, verify if the VM machines have been provisioned correctly. When you ssh into the machines, you should see the Deis logo as ASCII art. If you don't see it, something has gone wrong with the cloud-init process. Probably you have an invalid cloud-init file.
2. As you ssh into the machine, verify if Docker daemon is running by running some Docker command such as *docker ps*.
3. Use *deisctl list* to list all services. Check if all services are running. If you found a service is in faulted state, you can try to use the following commands to find out why the service is failing:
	- List service journal
			deisctl journal [service]  #example: deisctl journal builder
	- Restart a service
			deisctl restart [service] #example: deisctl restart controller
	
	>Note: For more information, see http://docs.deis.io/en/latest/troubleshooting_deis/
