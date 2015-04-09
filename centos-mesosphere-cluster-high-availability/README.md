# Spin up a single-Master (aka "dev") Mesosphere cluster

<a href="https://azuredeploy.net" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template deploys a 3-master Mesosphere cluster on a bunch of CentOS VMs. Having multiple master nodes means you will have to manage ZooKeeper to keep them all in sync, which can be a pain. But, the price means that you can tolerate some master nodes dying or becoming unavailable, which is not true of a 1-master cluster. In this sense, it can be considered a high-availability ("HA") Mesosphere cluster

Some notes about this template follow:

* The number of slave nodes is elastic, but due to limitations of the templating language, the number of masters is not.
  * So, feel free to change the number of slave nodes to be whatever you like. The script will scale those out. If you change the number of master nodes, there will be problems.
* This script requires you to log in with an SSH key *instead of* with a password. But, like a good devops person, you already do that, right? Riiiiiiight?
  * Practically speaking, this means you have to generate a public cert from your SSH key. See below for steps to generate and format the cert data for our system.
* This script gives public IPs to every node, master and slave alike.
  * For production settings this is not recommended. The "correct" way to do this is to put them all on a private network and VPN in. But, that's a bit heavy-handed for this template, which is really meant as an example.

## Generating public certs from private SSH keys, and formatting for deployment with this template

Usually there are about 5 steps:

1. You probably want to run a command like: `openssl req -x509 -days 365 -new -key $PATH_TO_YOUR_KEY -out $DESIRED_OUTPUT_FILENAME.cer`
2. The resulting .cer file will have a bunch of base64 digits and a header and a footer. The header will look something like `---- begin public cert ----` (or something, I don't remember specifically what), and the footer will look similar.
3. Chop off the header and footer.
4. Remove all the newlines, so you just have a bunch of base64 digits.
5. Paste that into the SSH parameter below.

And that's it. Now whenever you log in, as long as you have the right SSH private key loaded, you will be able to just log in without a password. It's more secure AND easier!

## Parameters

Here is the rundown on all the fields you might want to tweak when deploying this:

| Name   | Description    |
|:--- |:---|
| adminUsername  | Choose a good username for your VMs! |
| adminPassword  | A no-op for most purposes (including login) because you will be using an SSH key. |
| storageAccountName  | Choose a globally-unique string to name the storage thing we spin up for you. |
| numberOfMasterInstances  | **DO NOT TOUCH THIS PARAMETER.** It should always be 3. |
| numberOfSlaveInstances | Pick whatever number you like. 1, 1000, whatever. |
| vmSize | Pick a size for your VMs! Default is "Standard_A0". |
| subscriptionId | Your Azure subscription id. |
| region | Pick the region you want to deploy to. Defaults to "West US". |
| virtualNetworkName | Pick a name for your virtual network! Your nodes will use the PN to talk to each other. |
| addressPrefix | Pick a default address prefix for your private network. Default is "10.0.0.0/16". |
| subnet1Name | Pick a name for your subnet! Default is "Subnet-1". |
| subnet2Name | Pick another name for your subnet! Default is "Subnet-2". |
| subnet1Prefix | Pick a name for your subnet prefix! Default is "10.0.0.0/24". |
| subnet2Prefix | Pick another name for your subnet prefix! Default is "10.0.1.0/24". |
| subnet2Name | Number of data disks to attach to data storage instances (NOT IMPLEMENTED due to current limitation in the provider and fixed at 2) |
| masterConfigScriptFilePath | If you've changed your Mesos master config script from our default, you also might want to change the path to put/execute it. |
| slaveConfigScriptFilePath | If you've changed your Mesos slave config script from our default, you also might want to change the path to put/execute it. |
| masterConfigCommand | The command you issue in the shell to actually configure a master node. You might need to change this if you change the config script from our default. |
| slaveConfigCommand | The command you issue in the shell to actually configure a slave node. You might need to change this if you change the config script from our default. |
| sshKeyData | Allows you to log in to the machine without a password. Generate a public cert from your SSH key and remove the header and footer (see above), then paste the result here. |

