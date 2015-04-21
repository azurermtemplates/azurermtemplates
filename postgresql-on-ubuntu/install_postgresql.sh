#!/bin/bash

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

install_postgresql_service() {
	logger "Start installing PostgreSQL..."
	# Re-synchronize the package index files from their sources. An update should always be performed before an upgrade.
	apt-get -y update

	# Install PostgreSQL if it is not yet installed
	if [ $(dpkg-query -W -f='${Status}' postgresql 2>/dev/null | grep -c "ok installed") -eq 0 ];
	then
	  apt-get -y install postgresql=9.3* postgresql-contrib=9.3* postgresql-client=9.3*
	fi
	
	logger "Done installing PostgreSQL..."
}

stripe_datadisks() {
	logger "Install mdadm"

	export DEBIAN_FRONTEND=noninteractive
	apt-get -y install mdadm

	RAIDDISK="/dev/md127"
	RAIDPARTITION="/dev/md127p1"
	MOUNTPOINT="/datadrive"

	ls -l $RAIDPARTITION >/dev/null 2>&1
	if [ ${?} -eq 0 ];
	then
		logger "$RAIDPARTITION is already created"
		echo "$RAIDPARTITION is already created"
	else
		# Create RAID-0 array to stripe the partitions together
		logger "Create RAID-0 $RAIDDISK"
		echo "yes" | mdadm --create "$RAIDDISK" --name=data --level=0 --chunk=64 --raid-devices=2 /dev/sdc /dev/sdd

	# Create partition on the RAID disk
	logger "Create partition on RAID $RAIDDISK"
echo "n
p
1


w
" | fdisk $RAIDDISK
	fi

	# Create filesystem and mount point
	ls -l $MOUNTPOINT >/dev/null 2>&1
	if [ ${?} -eq 0 ];
	then
		logger "$MOUNTPOINT already exists"
		echo "$MOUNTPOINT already exists"
	else
		logger "Create ext4 file system on $RAIDPARTITION"
		mkfs -t ext4 $RAIDPARTITION
		mkdir $MOUNTPOINT
	fi

	# This redirection is specific to the bash shell
	read UUID FS_TYPE < <(blkid -u filesystem ${RAIDPARTITION} | awk -F "[= ]" '{print $3" "$5}' | tr -d "\"")

	grep "${UUID}" /etc/fstab >/dev/null 2>&1
	if [ ${?} -eq 0 ];
	then
		logger "$UUID is already in /etc/fstab"
        echo "$UUID is already in /etc/fstab"
	else
        LINE="UUID=$UUID $MOUNTPOINT ext4 defaults,nobootwait 0 0"
        logger "Added $LINE to /etc/fstab"
        echo "Added $LINE to /etc/fstab"
        echo $LINE >> /etc/fstab
	fi

	# Mount based on what is defined in /etc/fstab
	logger "Mounting disk $RAIDPARTITION on $MOUNTPOINT"
	mount -a

	# Move database files to the striped disk
	if [ -L /var/lib/postgresql/9.3 ];
	then
		logger "Symbolic link from /var/lib/postgresql/9.3 already exists"
		echo "Symbolic link from /var/lib/postgresql/9.3 already exists"
	else
		logger "Moving PostgreSQL data to the $MOUNTPOINT/pgdata/9.3"
		echo "Moving PostgreSQL data to the $MOUNTPOINT/pgdata/9.3"
		service postgresql stop
		mkdir $MOUNTPOINT/pgdata
		mv /var/lib/postgresql/9.3 $MOUNTPOINT/pgdata

		# Create symbolic link so that configuration files continue to use the default folders
		logger "Create symbolic link from /var/lib/postgresql/9.3 to $MOUNTPOINT/pgdata/9.3"
		ln -s $MOUNTPOINT/pgdata/9.3 /var/lib/postgresql/9.3
		service postgresql start
	fi
}

configure_streaming_replication() {
	logger "Starting configuring PostgreSQL streaming replication..."
	
	# Configure the MASTER node
	if [ "$NODETYPE" == "MASTER" ];
	then
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
		echo "" >> pg_hba.conf
		echo "# install_postgresql.sh" >> pg_hba.conf
		echo "host replication replicator $SUBNETADDRESS md5" >> pg_hba.conf
		echo "hostssl replication replicator $SUBNETADDRESS md5" >> pg_hba.conf
		echo "" >> pg_hba.conf
			
		logger "Updated pg_hba.conf"
		echo "Updated pg_hba.conf"
	fi

	if grep -Fxq "# install_postgresql.sh" postgresql.conf
	then
		logger "Already in postgresql.conf"
		echo "Already in postgresql.conf"
	else
		# Change configuration including both master and slave configuration settings
		echo "" >> postgresql.conf
		echo "# install_postgresql.sh" >> postgresql.conf
		echo "listen_addresses = '*'" >> postgresql.conf
		echo "wal_level = hot_standby" >> postgresql.conf
		echo "max_wal_senders = 10" >> postgresql.conf
		echo "wal_keep_segments = 500" >> postgresql.conf
		echo "checkpoint_segments = 8" >> postgresql.conf
		echo "archive_mode = on" >> postgresql.conf
		echo "archive_command = 'cd .'" >> postgresql.conf
		echo "hot_standby = on" >> postgresql.conf
		echo "" >> postgresql.conf
		
		logger "Updated postgresql.conf"
		echo "Updated postgresql.conf"
	fi

	if [ "$NODETYPE" == "MASTER" ];
	then
		# Start service on MASTER
		service postgresql start
	fi

	# Synchronize the slave
	if [ "$NODETYPE" == "SLAVE" ];
	then
		# Remove all files from the slave data directory
		logger "Remove all files from the slave data directory"
		sudo -u postgres rm -rf /var/lib/postgresql/9.3/main

		# Make a binary copy of the database cluster files while making sure the system is put in and out of backup mode automatically
		logger "Make binary copy of the data directory from master"
		sudo PGPASSWORD=$PGPASSWORD -u postgres pg_basebackup -h $MASTERIP -D /var/lib/postgresql/9.3/main -U replicator -x
		 
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
install_postgresql_service
stripe_datadisks
configure_streaming_replication