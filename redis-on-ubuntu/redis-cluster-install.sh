#!/bin/bash

# Script parameters and their defaults
VERSION="3.0.0"
CLUSTER_NAME="redis-cluster"
IS_LAST_NODE=0
INSTANCE_COUNT=1
SLAVE_COUNT=0
IP_PREFIX="10.0.0."

########################################################
# This script will install Redis from sources
########################################################
help()
{
	echo "This script installs a Redis cluster on the Ubuntu virtual machine image"
	echo "Available parameters:"
	echo "-n Cluster_Name"
	echo "-v Redis_Version_Number"
}

log()
{
	# If you want to enable this logging add a un-comment the line below and add your account key 
    #curl -X POST -H "content-type:text/plain" --data-binary "$(date) | ${HOSTNAME} | $1" https://logs-01.loggly.com/inputs/[account-key]/tag/redis-extension,${HOSTNAME}
	echo "$1"
}

tuneMemory()
{
	# Resolve a "Background save may fail under low memory condition." warning
	sysctl vm.overcommit_memory=1

	# Disable the Transparent Huge Pages (THP) support in the kernel
	sudo hugeadm --thp-never
}

tuneNetwork()
{
>/etc/sysctl.conf cat << EOF 

	# Disable syncookies (syncookies are not RFC compliant and can use too muche resources)
	net.ipv4.tcp_syncookies = 0

	# Basic TCP tuning
	net.ipv4.tcp_keepalive_time = 600
	net.ipv4.tcp_synack_retries = 3
	net.ipv4.tcp_syn_retries = 3

	# RFC1337
	net.ipv4.tcp_rfc1337 = 1

	# Defines the local port range that is used by TCP and UDP to choose the local port
	net.ipv4.ip_local_port_range = 1024 65535

	# Log packets with impossible addresses to kernel log
	net.ipv4.conf.all.log_martians = 1

	# Minimum interval between garbage collection passes This interval is in effect under high memory pressure on the pool
	net.ipv4.inet_peer_gc_mintime = 5

	# Disable Explicit Congestion Notification in TCP
	net.ipv4.tcp_ecn = 0

	# Enable window scaling as defined in RFC1323
	net.ipv4.tcp_window_scaling = 1

	# Enable timestamps (RFC1323)
	net.ipv4.tcp_timestamps = 1

	# Enable select acknowledgments
	net.ipv4.tcp_sack = 1

	# Enable FACK congestion avoidance and fast restransmission
	net.ipv4.tcp_fack = 1

	# Allows TCP to send "duplicate" SACKs
	net.ipv4.tcp_dsack = 1

	# Controls IP packet forwarding
	net.ipv4.ip_forward = 0

	# No controls source route verification (RFC1812)
	net.ipv4.conf.default.rp_filter = 0

	# Enable fast recycling TIME-WAIT sockets
	net.ipv4.tcp_tw_recycle = 1
	net.ipv4.tcp_max_syn_backlog = 20000

	# How may times to retry before killing TCP connection, closed by our side
	net.ipv4.tcp_orphan_retries = 1

	# How long to keep sockets in the state FIN-WAIT-2 if we were the one closing the socket
	net.ipv4.tcp_fin_timeout = 20

	# Don't cache ssthresh from previous connection
	net.ipv4.tcp_no_metrics_save = 1
	net.ipv4.tcp_moderate_rcvbuf = 1

	# Increase Linux autotuning TCP buffer limits
	net.ipv4.tcp_rmem = 4096 87380 16777216
	net.ipv4.tcp_wmem = 4096 65536 16777216

	# increase TCP max buffer size
	net.core.rmem_max = 16777216
	net.core.wmem_max = 16777216
	net.core.netdev_max_backlog = 2500

	# Increase number of incoming connections
	net.core.somaxconn = 65000
EOF

	# Reload the networking settings
	/sbin/sysctl -p /etc/sysctl.conf
}

log "Begin execution of Redis installation script extension on ${HOSTNAME}"

if [ "${UID}" -ne 0 ];
then
    log "Script executed without root permissions"
    echo "You must be root to run this program." >&2
    exit 3
fi

# Parse script parameters
while getopts :n:v:c:s:p:lh optname; do
  log "Option $optname set with value ${OPTARG}"
  
  case $optname in
    n)  # Cluster name
		CLUSTER_NAME=${OPTARG}
		;;
    v)  # Version to be installed
		VERSION=${OPTARG}
		;;
	c) # Number of instances
		INSTANCE_COUNT=${OPTARG}
		;;
	s) # Number of slave nodes
		SLAVE_COUNT=${OPTARG}
		;;		
	p) # Private IP address prefix
		IP_PREFIX=${OPTARG}
		;;			
    l)  # Indicator of the last node
		IS_LAST_NODE=1
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

log "Installing Redis v${VERSION}... "

# Installing build essentials (if missing) and other required tools
apt-get -y update
apt-get -y install build-essential
apt-get -y install hugepages

wget http://download.redis.io/releases/redis-$VERSION.tar.gz
tar xzf redis-$VERSION.tar.gz
cd redis-$VERSION
make
make install prefix=/usr/local/bin/

log "Redis package v${VERSION} was downloaded and built locally"

# Configure the general settings
sed -i "s/^daemonize no$/daemonize yes/g" redis.conf
sed -i 's/^logfile ""/logfile \/var\/log\/redis.log/g' redis.conf
sed -i "s/^loglevel verbose$/loglevel notice/g" redis.conf
sed -i "s/^dir \.\//dir \/var\/redis\//g" redis.conf 
sed -i "s/\${REDISPORT}.conf/redis.conf/g" utils/redis_init_script 
sed -i "s/_\${REDISPORT}.pid/.pid/g" utils/redis_init_script 

# Enable the AOF persistence
sed -i "s/^appendonly no$/appendonly yes/g" redis.conf

# Tune the RDB persistence
sed -i "s/^save.*$/# save/g" redis.conf
echo "save 3600 1" >> redis.conf

# Add cluster configuration (expected to be commented out in the default configuration file)
echo "cluster-enabled yes" >> redis.conf
echo "cluster-node-timeout 5000" >> redis.conf
echo "cluster-config-file ${CLUSTER_NAME}.conf" >> redis.conf

# Create all essentials directories and copy files to the correct locations
mkdir /etc/redis
mkdir /var/redis
cp redis.conf /etc/redis/redis.conf
cp utils/redis_init_script /etc/init.d/redis-server
cp src/redis-trib.rb /usr/local/bin/

# Clean up after the build
cd ..
rm redis-$VERSION -R
rm redis-$VERSION.tar.gz

log "Redis cluster configuration was applied successfully"

# Create service user and configure for permissions
useradd -r -s /bin/false redis
chown redis:redis /var/run/redis.pid
chmod 755 /etc/init.d/redis-server

# Initialize and perform auto-start
update-rc.d redis-server defaults
log "Redis service was created successfully"

# Apply memory-specific optimizations
tuneMemory

# Tune network settings for better performance
tuneNetwork

# Start the Redis service
/etc/init.d/redis-server start
log "Redis service was started successfully"

# Cluster setup must run on the last node (a nasty workaround until ARM can recognize multiple CSEs)
if [ "$IS_LAST_NODE" -eq 1 ]; then
	sudo bash redis-cluster-setup.sh -c $INSTANCE_COUNT -s $SLAVE_COUNT -p $IP_PREFIX
fi