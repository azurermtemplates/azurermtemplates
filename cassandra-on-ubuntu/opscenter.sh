#!/bin/bash

help()
{
    #TODO: Add help text here
    echo "This script installs Datastax Opscenter and configures nodes"
    echo "Parameters:"
    echo "-u username used to connect to and configure data nodes"
    echo "-p password used to connect to and configure data nodes"
    echo "-d dse nodes to manage (suuccessive ip range 10.0.0.4-8 for 8 nodes)"
    echo "-e use ephemeral storage (yes/no)"
}

# Log method to control/redirect log output
log()
{
    # If you want to enable this logging add a un-comment the line below and add your account id
    #curl -X POST -H "content-type:text/plain" --data-binary "${HOSTNAME} - $1" https://logs-01.loggly.com/inputs/<key>/tag/es-extension,${HOSTNAME}
    echo "$1"
}

log "Begin execution of cassandra script extension on ${HOSTNAME}"

# You must be root to run this script
if [ "${UID}" -ne 0 ];
then
    log "Script executed without root permissions"
    echo "You must be root to run this program." >&2
    exit 3
fi

# TEMP FIX - Re-evaluate and remove when possible
# This is an interim fix for hostname resolution in current VM (If it does not exist add it)
grep -q "${HOSTNAME}" /etc/hosts
if [ $? -eq $SUCCESS ]
then
  echo "${HOSTNAME}found in /etc/hosts"
else
  echo "${HOSTNAME} not found in /etc/hosts"
  # Append it to the hsots file if not there
  echo "127.0.0.1 $(hostname)" >> /etc/hosts
  log "hostname ${HOSTNAME} added to /etchosts"
fi

#Script Parameters
EPHEMERAL=0
DSE_ENDPOINTS=""
ADMIN_USER=""
SSH_KEY_PATH=""

#Loop through options passed
while getopts :d:u:p:e optname; do
    log "Option $optname set with value ${OPTARG}"
  case $optname in
  	u) #Credentials used for node install
      ADMIN_USER=${OPTARG}
      ;;
    p) #Credentials used for node install
      ADMIN_PASSWORD=${OPTARG}
      ;;
    d) #Static dicovery endpoints
      DSE_ENDPOINTS=${OPTARG}
      ;;
    e) #place data on local resource disk
      EPHEMERAL=1
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

source /etc/lsb-release

#Install Java
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu ${DISTRIB_CODENAME} main" | tee /etc/apt/sources.list.d/webupd8team-java.list
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu ${DISTRIB_CODENAME} main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
apt-get update
echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
apt-get -y install oracle-java7-installer
 
 #Tune environment
cat >> /etc/security/limits.d/cassandra.conf <<EOF
* - memlock unlimited
* - nofile 100000
* - nproc 32768
* - as unlimited
EOF
 
echo "vm.max_map_count = 131072" >> /etc/sysctl.conf
sudo sysctl -p

#Install opscenter
echo "deb http://debian.datastax.com/community stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.community.list
curl -L http://debian.datastax.com/debian/repo_key | sudo apt-key add -
apt-get update
apt-get install opscenter

# Start Ops Center
sudo service opscenterd start

# CONFIGURE NODES

# Expand a list of successive ip range and filter my local local ip from the list
# This increments the last octet of an IP start range using a defined value
# 10.0.0.4-3 would be converted to "10.0.0.4 10.0.0.5 10.0.0.6"
expand_ip_range() {
    IFS='-' read -a IP_RANGE <<< "$1"
    BASE_IP=`echo ${IP_RANGE[0]} | cut -d"." -f1-3`
    LAST_OCTET=`echo ${IP_RANGE[0]} | cut -d"." -f4-4`

    #Get the IP Addresses on this machine
    declare -a MY_IPS=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
    declare -a EXPAND_STATICIP_RANGE_RESULTS=()

    for (( n=LAST_OCTET; n<("${IP_RANGE[1]}"+LAST_OCTET) ; n++))
    do
        HOST="${BASE_IP}.${n}"
        if ! [[ "${MY_IPS[@]}" =~ "${HOST}" ]]; then
            EXPAND_STATICIP_RANGE_RESULTS+=($HOST)
        fi
    done
    echo "${EXPAND_STATICIP_RANGE_RESULTS[@]}"
}

# Convert the DSE endpoint range to a list for the provisioniing configuration
S=$(expand_ip_range "$DSE_ENDPOINTS")
NODE_LIST="\"${S// /\",\"}\""


# Create node provisioning document
sudo tee provision.json > /dev/null <<EOF
{
    "cassandra_config": {
        "authenticator": "org.apache.cassandra.auth.AllowAllAuthenticator",
        "authority": "org.apache.cassandra.auth.AllowAllAuthority",
        "auto_snapshot": true,
        "cluster_name": "Test Cluster",
        "column_index_size_in_kb": 64,
        "commitlog_directory": "/var/lib/cassandra/commitlog",
        "commitlog_sync": "periodic",
        "commitlog_sync_period_in_ms": 10000,
        "compaction_preheat_key_cache": true,
        "compaction_throughput_mb_per_sec": 16,
        "concurrent_reads": 32,
        "concurrent_writes": 32,
        "data_file_directories": [
            "/var/lib/cassandra/data"
        ],
        "dynamic_snitch_badness_threshold": 0.1,
        "dynamic_snitch_reset_interval_in_ms": 600000,
        "dynamic_snitch_update_interval_in_ms": 100,
        "encryption_options": {
            "internode_encryption": "none",
            "keystore": "conf/.keystore",
            "keystore_password": "cassandra",
            "truststore": "conf/.truststore",
            "truststore_password": "cassandra"
        },
        "endpoint_snitch": "SimpleSnitch",
        "flush_largest_memtables_at": 0.75,
        "hinted_handoff_enabled": true,
        "hinted_handoff_throttle_delay_in_ms": 1,
        "in_memory_compaction_limit_in_mb": 64,
        "incremental_backups": false,
        "index_interval": 128,
        "initial_token": null,
        "key_cache_save_period": 14400,
        "key_cache_size_in_mb": null,
        "max_hint_window_in_ms": 3600000,
        "memtable_flush_queue_size": 4,
        "multithreaded_compaction": false,
        "partitioner": "org.apache.cassandra.dht.RandomPartitioner",
        "reduce_cache_capacity_to": 0.6,
        "reduce_cache_sizes_at": 0.85,
        "request_scheduler": "org.apache.cassandra.scheduler.NoScheduler",
        "row_cache_provider": "SerializingCacheProvider",
        "row_cache_save_period": 0,
        "row_cache_size_in_mb": 0,
        "rpc_keepalive": true,
        "rpc_port": 9160,
        "rpc_server_type": "sync",
        "rpc_timeout_in_ms": 10000,
        "saved_caches_directory": "/var/lib/cassandra/saved_caches",
        "snapshot_before_compaction": false,
        "ssl_storage_port": 7001,
        "storage_port": 7000,
        "thrift_framed_transport_size_in_mb": 15,
        "thrift_max_message_length_in_mb": 16,
        "trickle_fsync": false,
        "trickle_fsync_interval_in_kb": 10240
    },
    "install_params": {
        "username": "${ADMIN_USER}",
        "password": "${ADMIN_PASSWORD}",
        "package": "dsc",
        "version": "2.1.1"
    },
    "nodes": [
        $NODE_LIST
    ]
}
EOF

# sleep 10

# curl -X POST localhost:8888/provision -d @provision.json

