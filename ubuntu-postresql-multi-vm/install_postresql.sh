#!/bin/bash

# Log to /var/log/syslog

# Get today's date into YYYYMMDD format
now=$(date +"%Y%m%d")
 
# Get passed in parameters $1, $2, $3, $4, and others...
MASTERIP=$1
SUBNETADDRESS=$2
NODETYPE=$3
NODEIP=$4
NUMBEROFSLAVES=$5
REPLICATORPASSWORD=$6

export PGPASSWORD=$REPLICATORPASSWORD

logger "NOW=$now MASTERIP=$MASTERIP SUBNETADDRESS=$SUBNETADDRESS NODETYPE=$NODETYPE NODEIP=$NODEIP NUMBEROFSLAVES=$NUMBEROFSLAVES"

install_postgresql() {
	logger "Start installing PostreSQL..."
	# Re-synchronize the package index files from their sources. An update should always be performed before an upgrade.
	apt-get -y update

	# Install PostgreSQL if it is not yet installed
	if [ $(dpkg-query -W -f='${Status}' postgresql 2>/dev/null | grep -c "ok installed") -eq 0 ];
	then
	  apt-get -y install postgresql=9.3* postgresql-contrib=9.3* postgresql-client=9.3*
	fi
	
	logger "Done installing PostreSQL..."
}

configure_streaming_replication() {
	logger "Starting configuring PostgreSQL streaming replication..."
	
	# Configure the MASTER node
	if [ "$NODETYPE" == "MASTER" ]; then
		logger "Create user replicator..."
		echo "CREATE USER replicator WITH REPLICATION PASSWORD '$PGPASSWORD';"
		sudo -u postgres psql -c "CREATE USER replicator WITH REPLICATION PASSWORD '$PGPASSWORD';"
	fi

	# Stop service
	service postgresql stop

	# Update configuration files
	cd /etc/postgresql/9.3/main

	if grep -Fxq "# install_postgresql.sh" pg_hba.conf
	then
		logger "Already in pg_hba.conf"
		echo "Already in pg_hba.conf"
	else
		# Allow access from other servers in the same subnet
		echo -e "\n# install_postgresql.sh" >> pg_hba.conf
		echo "host replication replicator $SUBNETADDRESS md5" >> pg_hba.conf
		echo "hostssl replication replicator $SUBNETADDRESS md5" >> pg_hba.conf
		echo -e "\n" >> pg_hba.conf 
		
		logger "Updated pg_hba.conf"
		echo "Updated pg_hba.conf"
	fi

	if grep -Fxq "# install_postgresql.sh" postgresql.conf
	then
		logger "Already in postgresql.conf"
		echo "Already in postgresql.conf"
	else
		# Change configuration including both master and slave configuration settings
		echo -e "\n# install_postgresql.sh" >> postgresql.conf
		echo "listen_addresses = '*'" >> postgresql.conf
		echo "wal_level = hot_standby" >> postgresql.conf
		echo "max_wal_senders = 10" >> postgresql.conf
		echo "wal_keep_segments = 500" >> postgresql.conf
		echo "checkpoint_segments = 8" >> postgresql.conf
		echo "archive_mode = on" >> postgresql.conf
		echo "archive_command = 'cd .'" >> postgresql.conf
		echo "hot_standby = on" >> postgresql.conf
		echo -e "\n" >> postgresql.conf
		
		logger "Updated postgresql.conf"
		echo "Updated postgresql.conf"
	fi

	if [ "$NODETYPE" == "MASTER" ]; then
		# Start service on MASTER
		service postgresql start
	fi

	# Synchronize the slave
	if [ "$NODETYPE" == "SLAVE" ]; then
		# Remove all files from the slave data directory
		logger "Remove all files from the slave data directory"
		sudo -u postgres rm -rf /var/lib/postgresql/9.3/main

		# Make a binary copy of the database cluster files while making sure the system is put in and out of backup mode automatically
		logger "Make binary copy of the data directory from master"
		sudo PGPASSWORD=$PGPASSWORD -u postgres pg_basebackup -h $MASTERIP -D /var/lib/postgresql/9.3/main -U replicator -v -P -x
	 
		# Create recovery file
		logger "Create recovery.conf file"
		cd /var/lib/postgresql/9.3/main/
		
		sudo -u postgres echo "standby_mode = 'on'" > recovery.conf
		sudo -u postgres echo "primary_conninfo = 'host=$MASTERIP port=5432 user=replicator password=$PGPASSWORD'" >> recovery.conf
		sudo -u postgres echo "trigger_file = '/var/lib/postgresql/9.3/main/failover'" >> recovery.conf

		# Start service on SLAVE
		service postgresql start
	fi
	
	logger "Done configuring PostgreSQL streaming replication"
}

# MAIN ROUTINE
install_postgresql
configure_streaming_replication