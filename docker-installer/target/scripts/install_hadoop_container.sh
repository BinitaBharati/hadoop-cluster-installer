#!/bin/bash
set -x

editConfigFiles() {
cp $1 $1.orig
sed -i "/${2}/c\\${3}" $1
}

#Master node - HDFS's NameNode,SecondaryNameNode & YARN's ResourceManager.
#Slave node - HDFS's Datanode a& YARN's NodeManager.
echo "install-hadoop-container : your env are hostIp=$hostIp clusterInfo=$clusterInfo masterNodeIp=$masterNodeIp slaveNodes=$slaveNodes"

#install ifconfig command within container
apt-get update;apt-get install -y net-tools
#install wget command
apt-get update;apt-get install -y wget
#install ssh command
apt-get install -y openssh-server
#Enable Password based Authentication - disabled by default on Ubuntu Xenial
editConfigFiles /etc/ssh/sshd_config '#PasswordAuthentication yes' 'PasswordAuthentication yes'


dos2unix install_java.sh install_java.sh
chmod +x install_java.sh
./install_java.sh

dos2unix install_hadoop.sh install_hadoop.sh
chmod +x install_hadoop.sh
./install_hadoop.sh

