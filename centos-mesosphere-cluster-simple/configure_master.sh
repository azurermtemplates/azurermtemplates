#!/bin/bash

# Add the repository
rpm -Uvh http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm

echo "---                                         ---"
echo "--- Installing Mesos and ZooKeeper packages ---"
echo "---                                         ---"
yum -y install mesos marathon
yum -y install mesosphere-zookeeper

echo "---                       ---"
echo "--- Configuring ZooKeeper ---"
echo "---                       ---"
ID=1
ID=`expr "$1" + "$ID"`
echo $ID | tee /var/lib/zookeeper/myid

echo | tee -a /etc/zookeeper/conf/zoo.cfg
echo "server.1=${2}:2888:3888" | tee -a /etc/zookeeper/conf/zoo.cfg

echo "---                    ---"
echo "--- Starting ZooKeeper ---"
echo "---                    ---"
systemctl start zookeeper

echo "---                                ---"
echo "--- Configuring Mesos and Marathon ---"
echo "---                                ---"
echo "zk://${2}:2181/mesos" | tee /etc/mesos/zk
echo 1 | tee /etc/mesos-master/quorum

echo "---                                  ---"
echo "--- Starting Mesos/Marathon services ---"
echo "---                                  ---"
# Disable mesos-slave service
systemctl stop mesos-slave.service
systemctl disable mesos-slave.service

# Restart Mesos/Marathon services to bring them up at roughly the same time
service mesos-master restart
service marathon restart