#!/bin/bash
 
# Get passed in parameters
memcachedIndex=$1
privateIP=$2
apacheIP=$3
 
# Get today's date into YYYYMMDD format
now=$(date +"%Y%m%d")
 
# Re-synchronize the package index files from their sources. An update should always be performed before an upgrade.
apt-get -y update
 
# Install the newest versions of all packages currently installed on the system from the sources enumerated in /etc/apt/sources.list.
# Packages currently installed with new versions available are retrieved and upgraded.
# Currently installed packages are not removed.
# Packages that are not already installed are not retrieved nor installed.
# New versions of currently installed packages that cannot be upgraded without changing the install status of another package are left at their current version.
apt-get -y upgrade
 
# Memcached is a C program and depends on a recent version of GCC and a recent version of libevent.
apt-get -y install memcached
 
echo "Memcached installed on $now index $memcachedIndex, private ip $privateIP, and apache ip $apacheIP" >> /var/log/memcached_install.log
 
# By default memcached listens on TCP and UDP ports 11211. You must not expose memcached directly to the internet.
 
# Change memcached.conf to listen on all IPs not just 127.0.0.1 and use 512MB of RAM instead of default 64MB
sed -i "s/-l 127.0.0.1/#-l 127.0.0.1/g" /etc/memcached.conf
sed -i "s/^-m 64$/-m 512/g" /etc/memcached.conf
 
# Restart memcached service with the new configuration
service memcached restart
 
# Inspect running configuration by issuing a "stats settings" command to the proper ports
echo "stats settings" | nc localhost 11211 > /var/log/memcached_stats_$now.log