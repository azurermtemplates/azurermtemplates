#!/bin/bash

### Cognosys Technologies
### 
### Warning! This script partitions and formats disk information be careful where you run it
###          This script is currently under development and has only been tested on Ubuntu images in Azure
###          This script is not currently idempotent and only works for provisioning at the moment

### Remaining work items
### -Alternate discovery options (Azure Storage)
### -Implement Idempotency and Configuration Change Support
### -Implement OS Disk Striping Option (Currenlty using multiple kafka data paths)
### -Implement Non-Durable Option (Put data on resource disk)
### -Configure Work/Log Paths
### -Recovery Settings (These can be changed via API)

help()
{
    #TODO: Add help text here
    echo "This script installs kafka cluster on Ubuntu"
    echo "Parameters:"
    echo "-k kafka version like 0.8.2.1"
    echo "-b broker id"
    echo "-h view this help content"
}

log "Begin execution of kafka script extension on ${HOSTNAME}"

if [ "${UID}" -ne 0 ];
then
    log "Script executed without root permissions"
    echo "You must be root to run this program." >&2
    exit 3
fi

# TEMP FIX - Re-evaluate and remove when possible
# This is an interim fix for hostname resolution in current VM
grep -q "${HOSTNAME}" /etc/hosts
if [ $? -eq $SUCCESS ];
then
  echo "${HOSTNAME}found in /etc/hosts"
else
  echo "${HOSTNAME} not found in /etc/hosts"
  # Append it to the hsots file if not there
  echo "127.0.0.1 $(hostname)" >> /etc/hosts
  log "hostname ${HOSTNAME} added to /etc/hosts"
fi

#Script Parameters
KF_VERSION="0.8.2.1"
BROKER_ID=0
ZOOKEEPER1KAFKA0="0"
ZOOKEEPER_IPPORT="10.0.0.40:2181"

#Loop through options passed
while getopts :k:b:z:i:h optname; do
    log "Option $optname set with value ${OPTARG}"
  case $optname in
    k)  #kafka version
      KF_VERSION=${OPTARG}
      ;;
    b)  #broker id
      BROKER_ID=${OPTARG}
      ;;
    z)  #zookeeper not kafka
      ZOOKEEPER1KAFKA0=${OPTARG}
      ;;
    i)  #zookeeper not kafka
      ZOOKEEPER_IPPORT=${OPTARG}
      ;;
    h)  #show help
      help
      exit 2
      ;;
    \?) #unrecognized option - show help
      echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
      help
      exit 2
      ;;
  esac
done

# Install Oracle Java
install_java()
{
    log "Installing Java"
    add-apt-repository -y ppa:webupd8team/java
    apt-get -y update 
    echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
    echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
    apt-get -y install oracle-java7-installer
}

# Install Zookeeper
install_zookeeper()
{
	mkdir -p /var/lib/zookeeper
	cd /var/lib/zookeeper
	wget "http://mirrors.ukfast.co.uk/sites/ftp.apache.org/zookeeper/stable/zookeeper-3.4.6.tar.gz"
	tar -xvf "zookeeper-3.4.6.tar.gz"

	touch zookeeper-3.4.6/conf/zoo.cfg

	echo "tickTime=2000" >> zookeeper-3.4.6/conf/zoo.cfg
	echo "dataDir=/var/lib/zookeeper" >> zookeeper-3.4.6/conf/zoo.cfg
	echo "clientPort=2181" >> zookeeper-3.4.6/conf/zoo.cfg
	echo "initLimit=5" >> zookeeper-3.4.6/conf/zoo.cfg
	echo "syncLimit=2" >> zookeeper-3.4.6/conf/zoo.cfg
	echo "server.1=10.0.0.40:2888:3888" >> zookeeper-3.4.6/conf/zoo.cfg

	echo $(($1+1)) >> /var/lib/zookeeper/myid

	zookeeper-3.4.6/bin/zkServer.sh start
}

# Install kafka
install_kafka()
{
# wait for kafka - zookeeper
# Ping --- 
	cd /usr/local
	name=kafka
	version=${KF_VERSION}
	kafkaversion=2.10
	description="Apache Kafka is a distributed publish-subscribe messaging system."
	url="https://kafka.apache.org/"
	arch="all"
	section="misc"
	license="Apache Software License 2.0"
	package_version="-1"
	src_package="kafka_${kafkaversion}-${version}.tgz"
	download_url=http://mirror.sdunix.com/apache/kafka/${version}/${src_package} 

	rm -rf kafka
	mkdir -p kafka
	cd kafka
	#_ MAIN _#
	if [[ ! -f "${src_package}" ]]; then
	  wget ${download_url}
	fi
	tar zxf ${src_package}
	cd kafka_${kafkaversion}-${version}
	
	sed -r -i "s/(broker.id)=(.*)/\1=${BROKER_ID}/g" config/server.properties 
	sed -r -i "s/(zookeeper.connect)=(.*)/\1=${ZOOKEEPER_IPPORT}/g" config/server.properties 
#	cp config/server.properties config/server-1.properties 
#	sed -r -i "s/(broker.id)=(.*)/\1=1/g" config/server-1.properties 
#	sed -r -i "s/^(port)=(.*)/\1=9093/g" config/server-1.properties````
	chmod u+x /usr/local/kafka/kafka_${kafkaversion}-${version}/bin/kafka-server-start.sh
	/usr/local/kafka/kafka_${kafkaversion}-${version}/bin/kafka-server-start.sh /usr/local/kafka/kafka_${kafkaversion}-${version}/config/server.properties &
}

# Primary Install Tasks
#########################
#NOTE: These first three could be changed to run in parallel
#      Future enhancement - (export the functions and use background/wait to run in parallel)

#Install Oracle Java
#------------------------
install_java

if [ ${ZOOKEEPER1KAFKA0} -eq "1" ];
then
	#
	#Install zookeeper
	#-----------------------
	install_zookeeper
else
	#
	#Install kafka
	#-----------------------
	install_kafka
fi

