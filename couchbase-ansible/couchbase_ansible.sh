#!/bin/bash

#########################################################
# Script Name: couchbase_ansible.sh
# Author: Gonzalo Ruiz 
# Version: 0.1
# Date Created:           01st Marh 2015
# Last Modified:          14th April 17:26 GMT
# Last Modified By:       Gonzalo Ruiz
# Description:
#  This script automates the installation of a multi VM Couchbase cluster using Ansible. It will
#     Configur this VM as an Ansible Controller
#     Configure SSH keys
#     Configure STorage on all the VMs using an Ansible Playbook
#     Download Couchbase Ansible roles from Ansible Galaxy
#     Install Couchbase using the couchbase.couchbase-server Ansible role
#
# Parameters :
#  1 - i: IP Pattern
#  2 - n: Number of nodes
#  3 - r: Configure RAID 
#  4 - f: filesystem : ext4 or xfs
#  5 - u: Couchbase user
#  6 - p: Couchbase password
# Note : 
# This script has only been tested on CentOS 6.5 and Ubuntu 12.04 LTS 
######################################################### 

#---BEGIN VARIABLES---
IP_ADDRESS_SPACE=''
NUMBER_OF_NODES=''
NODE_LIST_IPS=()
CONFIGURE_RAID=''
FILE_SYSTEM=''
USER_NAME=''
USER_PASSWORD=''
TEMPLATE_ROLE='couchbase'
START_IP_INDEX=0
CB_USER=''
CB_PWD=''


 function usage()
 {
    echo "INFO:"
    echo "Usage: configure-ansible.sh [-i IP_ADDRESS_SPACE ] [-n NUMBER_OF_NODES ] [-r CONFIGURE_RAID ] [-f FILE_SYSTEM] [-u CB_USER] [-p CB_PWD]"
    echo "The -i (ipAddressSpace) parameters specifies the starting IP space for the vms.For instance if you specify 10.0.2.2, and 3 nodes, the script will find for the VMS 10.0.2.20, 10.0.2.21,10.0.2.22.Plase note that Azure reserves the first 4 IPs, so you will have to specify an IP space in which IP x.x.x0 is available"
    echo "The -n (numberOfNodes) parameter specifies the number of VMs"
    echo "The -r (configureRAID) parameter specifies whether you want to create a RAID with all the available data disks.Allowed values : true or false"
    echo "The -f (fileSystem) parameter specifies the file system you want to use.Allowed values : ext4 or xfs"    
    echo "The -u (couchbaseUser) parameter specifies the Couchbase Admin user"
    echo "The -p (couchbasePassword) parameter specifies the Couchbase Password "
}


function log()
{
    # If you want to enable this logging add a un-comment the line below and add your account id
    #curl -X POST -H "content-type:text/plain" --data-binary "${HOSTNAME} - $1" https://logs-01.loggly.com/inputs/<key>/tag/es-extension,${HOSTNAME}
    echo "$1"
}


#---PARSE AND VALIDATE PARAMETERS---
if [ $# -ne 12 ]; then
    log "ERROR:Wrong number of arguments specified. Parameters received $#. Terminating the script."
    usage
    exit 1
fi

while getopts :i:n:r:f:u:p: optname; do
    log "INFO:Option $optname set with value ${OPTARG}"
  case $optname in
    i) # IP address space 
      IP_ADDRESS_SPACE=${OPTARG}
      ;;
    n) # Number of VMS
      NUMBER_OF_NODES=${OPTARG}     
      IDX=${START_IP_INDEX}
      while [ "${IDX}" -lt "${NUMBER_OF_NODES}" ];
      do
        NODE_LIST_IPS[$IDX]="${IP_ADDRESS_SPACE}${IDX}"
        IDX=$((${IDX} + 1))       
      done
      ;;
    r) # Configure RAID
      CONFIGURE_RAID=${OPTARG}
      if [[ "${CONFIGURE_RAID}" != "true" &&  "${CONFIGURE_RAID}" != "false" ]] ; then
          log "ERROR:Configure RAID (-r) value ${CONFIGURE_RAID} not allowed"
          usage
          exit 1
      fi
      ;;
    f) # File system  : ext4 or xfs
      FILE_SYSTEM=${OPTARG}
      if [[ "${FILE_SYSTEM}" != "ext4" &&  "${FILE_SYSTEM}" != "xfs" ]] ; then
          log "ERROR:File system (-f) ${FILE_SYSTEM} not allowed"
          usage
          exit 1
      fi
      ;;
    u) # COUCHBASE ADMIN USER 
      CB_USER=${OPTARG}
      ;;
    p) # COUCHBASE ADMIN PASSWORD 
      CB_USER=${OPTARG}
      ;;    
    \?) #Invalid option - show help
      log "ERROR:Option -${BOLD}$OPTARG${NORM} not allowed."
      usage
      exit 1
      ;;
  esac
done



function check_OS()
{
    OS=`uname`
    KERNEL=`uname -r`
    MACH=`uname -m`

      
    if [ -f /etc/redhat-release ] ; then
            DistroBasedOn='RedHat'
            DIST=`cat /etc/redhat-release |sed s/\ release.*//`
            PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
            REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
    elif [ -f /etc/SuSE-release ] ; then
            DistroBasedOn='SuSe'
            PSUEDONAME=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
            REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
    elif [ -f /etc/debian_version ] ; then
            DistroBasedOn='Debian'
            if [ -f /etc/lsb-release ] ; then
                 DIST=`cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
                 PSUEDONAME=`cat /etc/lsb-release | grep '^DISTRIB_CODENAME' | awk -F=  '{ print $2 }'`
                 REV=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }'`
            fi
    fi
            
            OS=$OS
            DistroBasedOn=$DistroBasedOn
            readonly OS
            readonly DIST
            readonly DistroBasedOn
            readonly PSUEDONAME
            readonly REV
            readonly KERNEL
            readonly MACH

            log "INFO: Detected OS : ${OS}  Distribution: ${DIST}-${DistroBasedOn}-${PSUEDONAME} Revision: ${REV} Kernel: ${KERNEL}-${MACH}"
    
}


function install_ansible_ubuntu()
{
    
    
    apt-get --yes --force-yes install software-properties-common
    apt-add-repository ppa:ansible/ansible
    apt-get --yes --force-yes update
    apt-get --yes --force-yes install ansible
    # install sshpass
    apt-get --yes --force-yes install sshpass
    # install Git
    apt-get --yes --force-yes install git

 }

 function install_ansible_centos()
 {

    # install EPEL Packages - sshdpass
    wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm    
    rpm -ivh epel-release-6-8.noarch.rpm
    # install ansible
    yum -y install ansible
    yum -y install  libselinux-python

    # needed to copy the keys to all the vms
    yum -y install sshpass
    # install Git
    yum -y install git 

 }

function configure_ssh()
{

    # copy ssh private key
    mkdir -p ~/.ssh
    mv id_rsa ~/.ssh

    # set permissions
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/id_rsa     


    # copy root ssh key   
    cat id_rsa.pub >> ~/.ssh/authorized_keys
    rm id_rsa.pub
    
    # set permissions
    chmod 600 ~/.ssh/authorized_keys 

    if [[ "${DIST}" == "Ubuntu" ]]; then
        #restart sshd service - Ubuntu
        service ssh restart

    elif [[ "${DIST}" == "CentOS" ]] ; then
        # configure SELinux
        restorecon -Rv ~/.ssh 
    
        #restart sshd service - CentOS
        service sshd restart
    fi

}


 function configure_ansible()
 {
    # Copy ansible hosts file
    ANSIBLE_HOST_FILE=/etc/ansible/hosts
    ANSIBLE_CONFIG_FILE=/etc/ansible/ansible.cfg

    mv ${ANSIBLE_HOST_FILE} ${ANSIBLE_HOST_FILE}.backup
    mv ${ANSIBLE_CONFIG_FILE} ${ANSIBLE_CONFIG_FILE}.backup
    
    # Accept ssh keys by default    
    printf  "[defaults]\nhost_key_checking = False\n\n" >> "${ANSIBLE_CONFIG_FILE}"   
    # Shorten the ControlPath to avoid errors with long host names , long user names or deeply nested home directories
    echo  $'[ssh_connection]\ncontrol_path = ~/.ssh/ansible-%%h-%%r' >> "${ANSIBLE_CONFIG_FILE}"   
    
    # Generate a new ansible host file    
    printf  "[${TEMPLATE_ROLE}]\n${IP_ADDRESS_SPACE}[0:$(($NUMBER_OF_NODES - 1))]" >> "${ANSIBLE_HOST_FILE}"    

    # Validate ansible configuration
    ansible ${TEMPLATE_ROLE} -m ping -v 
   

 }


 function configure_storage()
 {
    log "INFO: Configuring Storage "
    log "WARNING: This process is not incremental, don't use it if you don't want to lose your existing storage configuration"
    
    # Run ansible template to configure Storage : Create RAID and Configure Filesystem 
    ansible-playbook InitStorage_RAID.yml  --extra-vars "target=${TEMPLATE_ROLE} file_system=${FILE_SYSTEM}" 
    
 }


function install_couchbase()
{
   # Role copied in /etc/ansible/roles/couchbase.couchbase-server/
   # ansible-galaxy install couchbase.couchbase-server 
   log "INFO: ******** Installing Couchbase "
   git clone https://github.com/couchbaselabs/ansible-couchbase-server.git

   # Run ansible template to Install and Initialise Couchbase 
   # ansible-playbook couchbase_setup.yml  --extra-vars "target=${TEMPLATE_ROLE} file_system=${FILE_SYSTEM} couchbase_server_admin=${CB_USER} couchbase_server_password=${CB_PWD}" 



}


InitializeVMs()
{
    check_OS
    
    configure_ssh

    if [[ "${DIST}" == "Ubuntu" ]];
    then
        log "INFO:Installing Ansible for Ubuntu"
        install_ansible_ubuntu
    elif [[ "${DIST}" == "CentOS" ]] ; then
        log "INFO:Installing Ansible for CentOS"
        install_ansible_centos
    else
       log "ERROR:Unsupported OS ${DIST}"
       exit 2
    fi
    
    configure_ansible
    configure_storage


}

InitializeVMs
