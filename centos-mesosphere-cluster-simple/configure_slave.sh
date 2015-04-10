#!/bin/bash

# Add the repository
rpm -Uvh http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm

echo "---                                         ---"
echo "--- Installing Mesos and ZooKeeper packages ---"
echo "---                                         ---"
yum -y install mesos

echo "---                       ---"
echo "--- Configuring ZooKeeper ---"
echo "---                       ---"
echo "zk://${2}:2181/mesos" | tee /etc/mesos/zk

echo "---                                ---"
echo "--- Stopping Mesos master services ---"
echo "---                                ---"
systemctl stop mesos-master.service
systemctl disable mesos-master.service

echo "---                               ---"
echo "--- Starting Mesos slave services ---"
echo "---                               ---"
service mesos-slave restart