#!/bin/bash

wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u75-b13/jdk-7u75-linux-x64.tar.gz"
tar -xvf jdk-7*
mkdir /usr/lib/jvm
mv ./jdk1.7* /usr/lib/jvm/jdk1.7.0

update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.7.0/bin/java" 1
update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.7.0/bin/javac" 1
update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/lib/jvm/jdk1.7.0/bin/javaws" 1

chmod a+x /usr/bin/java
chmod a+x /usr/bin/javac
chmod a+x /usr/bin/javaws

cd /usr/local

# get latest hadoop

wget "http://mirrors.ukfast.co.uk/sites/ftp.apache.org/hadoop/common/stable/hadoop-2.6.0.tar.gz"
tar -xvf "hadoop-2.6.0.tar.gz"

touch hadoop-2.6.0/conf/hadoop.cfg

#
# conf/core-site.xml
# conf/hdfd-site.xml
# conf/mapred-site.xml
#

echo "HADOOP_NAMENODE_OPT=" >> hadoop-2.6.0/conf/hadoop.cfg
echo "HADOOP_DATANODE_OPTS=" >> hadoop-2.6.0/conf/hadoop.cfg
echo "HADOOP_SECONDARYNAMENODE_OPTS=" >> hadoop-2.6.0/conf/hadoop.cfg
echo "HADOOP_JOBTRACKER_OPTS=" >> hadoop-2.6.0/conf/hadoop.cfg
echo "HADOOP_TASKTRACKER_OPTS=" >> hadoop-2.6.0/conf/hadoop.cfg
echo "HADDOP_LOGDIR=/var/lib/hadoop" >> hadoop-2.6.0/conf/hadoop.cfg
echo "HADOOP_HEAPSIZE=100" >> hadoop-2.6.0/conf/hadoop.cfg

mkdir -p /var/lib/hadoop
echo $(($1+1)) >> /var/lib/hadoop/myid

#################3
#
# build the sample
#
javac wordcount.java
jar cf wordcount.jar wordcount.class 

#########################
# 
# example showing word count 
#

# input is state of the union address from gov site
wget "http://www.gpo.gov/fdsys/pkg/DCPD-201500036/pdf/DCPD-201500036.pdf" > wcinput

# 'wcoutput' is the name of my wordcount output directory.
# you need to delete it before running the wordcount program.
rm -rf wcoutput 2> /dev/null

# simple word count sample

hadoop-2.6.0/bin/hadoop jar \
        wordcount.jar \
        wordcount.WordCount \
        wcinput \
        wcoutput \
        2> wordcount.log

