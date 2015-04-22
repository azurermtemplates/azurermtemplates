#!/bin/bash

#--------------------------------------------------------------------------------------------------
# MongoDB Template for Azure Resource Manager (brought to you by Full Scale 180 Inc)
#
# This script installs MongoDB on each Azure virtual machine. The script will be supplied with
# runtime parameters declared from within the corresponding ARM template.
#--------------------------------------------------------------------------------------------------
help()
{
	echo "This script installs MongoDB on the Ubuntu virtual machine image."
	echo "Options:"
	echo "		-l Installation package URL"
	echo "		-i Installation package name"
	echo "		-r Replica set name"
	echo "		-k Replica set key"
	echo "		-u System administrator's user name"
	echo "		-p System administrator's password"
	echo "		-a (arbiter indicator)"	
}

log()
{
	# If you want to enable this logging add a un-comment the line below and add your account key 
	curl -X POST -H "content-type:text/plain" --data-binary "$(date) | ${HOSTNAME} | $1" https://logs-01.loggly.com/inputs/681451c7-fb5e-409b-a263-b06b29c9560f/tag/redis-extension,${HOSTNAME}
	echo "$1"
}

log "Begin execution of MongoDB installation script extension on ${HOSTNAME}"

if [ "${UID}" -ne 0 ];
then
    log "Script executed without root permissions"
    echo "You must be root to run this program." >&2
    exit 3
fi

PACKAGE_URL=http://repo.mongodb.org/apt/ubuntu
PACKAGE_NAME=mongodb-org
REPLICA_SET_KEY_DATA=""
REPLICA_SET_NAME=""
REPLICA_SET_KEY_FILE="/etc/mongo-replicaset-key"
DATA_DISKS="/datadisks"
DATA_MOUNTPOINT="$DATA_DISKS/disk1"
MONGODB_DATA="$DATA_MOUNTPOINT/mongodb"
MONGODB_PORT=27017
IS_ARBITER=false
JOURNAL_ENABLED=true
ADMIN_USER_NAME=""
ADMIN_USER_PASSWORD=""

# Parse script parameters
while getopts :l:i:r:k:u:p:ah optname; do
  log "Option $optname set with value ${OPTARG}"
  
  case $optname in
	l) # Installation package location
		PACKAGE_URL=${OPTARG}
		;;
	i) # Installation package name
		PACKAGE_NAME=${OPTARG}
		;;		
	r) # Replica set name
		REPLICA_SET_NAME=${OPTARG}
		;;	
	k) # Replica set key
		REPLICA_SET_KEY_DATA=${OPTARG}
		;;	
	u) # Administrator's user name
		ADMIN_USER_NAME=${OPTARG}
		;;		
	p) # Administrator's user name
		ADMIN_USER_PASSWORD=${OPTARG}
		;;	
	a) # Arbiter indicator
		IS_ARBITER=true
		JOURNAL_ENABLED=false
		;;			
    h)  # Helpful hints
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

# Validate parameters
if [ "$ADMIN_USER_NAME" -eq "" ] -o [ "$ADMIN_USER_PASSWORD" -eq "" ];
then
    log "Script executed without admin credentials"
    echo "You must provide a name and password for the system administrator." >&2
    exit 3
fi

#############################################################################
tune_memory()
{
	# Disable THP
	# We may not reboot yet, so disable for this time first
	# Disable THP on a running system
	echo never > /sys/kernel/mm/transparent_hugepage/enabled
	echo never > /sys/kernel/mm/transparent_hugepage/defrag

	# Backup rc.local
	cp -p /etc/rc.local /etc/rc.local.`date +%Y%m%d-%H:%M`
	sed -i -e '$i \ if test -f /sys/kernel/mm/transparent_hugepage/enabled; then \
 			 echo never > /sys/kernel/mm/transparent_hugepage/enabled \
		  fi \ \
		if test -f /sys/kernel/mm/transparent_hugepage/defrag; then \
		   echo never > /sys/kernel/mm/transparent_hugepage/defrag \
		fi \
		\n' /etc/rc.local
}

#############################################################################
install_mongodb()
{
	log "Downloading MongoDB package $PACKAGE_NAME from $PACKAGE_URL..."

	# Configure mongodb.list file with the correct location
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
	echo "deb ${PACKAGE_URL} "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list

	# Install updates
	apt-get -y update

	# Remove any previously created configuration file to avoid a prompt
	rm /etc/mongod.conf
	
	#Install Mongo DB
	log "Installing MongoDB package $PACKAGE_NAME..."
	apt-get -y install $PACKAGE_NAME
}

#############################################################################
configure_datadisks()
{
	# Stripe all of the data 
	log "Formatting and configuring the data disks..."
	
	bash ./vm-disk-utils-0.1.sh -b $DATA_DISKS -s
}

#############################################################################
configure_replicaset()
{
	log "Configuring a replica set $REPLICA_SET_NAME"
	
	echo "$REPLICA_SET_KEY_DATA" | tee "$REPLICA_SET_KEY_FILE" > /dev/null
	chown -R mongodb:mongodb "$REPLICA_SET_KEY_FILE"
	chmod 600 "$REPLICA_SET_KEY_FILE"
}

#############################################################################
configure_mongodb()
{
	log "Configuring MongoDB..."

	mkdir -p "$MONGODB_DATA"
	mkdir "$MONGODB_DATA/log"
	mkdir "$MONGODB_DATA/db"
	
	chown -R mongodb:mongodb "$MONGODB_DATA"
	chmod 755 "$MONGODB_DATA"
	
	mkdir /var/run/mongodb
	touch /var/run/mongodb/mongod.pid
	chmod 777 /var/run/mongodb/mongod.pid 
	
	tee /etc/mongod.conf > /dev/null <<EOF
systemLog:
    destination: file
    path: "/var/log/mongodb/mongod.log"
    quiet: true
    logAppend: true
processManagement:
    fork: true
    pidFilePath: "/var/run/mongodb/mongod.pid"
net:
    port: $MONGODB_PORT
security:
    keyFile: "$REPLICA_SET_KEY_FILE"
    authorization: "disabled"
storage:
    dbPath: "$MONGODB_DATA/db"
    directoryPerDB: true
    journal:
        enabled: $JOURNAL_ENABLED
replication:
    replSetName: "$REPLICA_SET_NAME"
EOF
}

start_mongodb()
{
	log "Starting MongoDB daemon processes..."
	service mongod start
}

configure_db_permissions()
{
	# Create a system administrator
	mongo master --host 127.0.0.1 --eval "db.createUser({user: '${ADMIN_USER_NAME}', pwd: '${ADMIN_USER_PASSWORD}', roles:[{ role: 'userAdminAnyDatabase', db: 'admin' } ]})"
}

# Step 1
configure_datadisks

# Step 2
tune_memory

# Step 3
install_mongodb

# Step 4
configure_mongodb

# Step 5
configure_replicaset

# Step 6
start_mongodb

# Step 7
configure_db_permissions

# Exit proudly
exit 0