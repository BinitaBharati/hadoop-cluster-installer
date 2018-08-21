#!/bin/bash
set -x



getip()
{
/sbin/ifconfig ${1:-eth0} | awk '/inet addr/ {print $2}' | awk -F: '{print $2}';
}

sudo apt-get update

#install dos2unix
sudo apt-get -y install dos2unix

sudo docker build --no-cache -t hadoop:latest /home/vagrant/docker/input/

#Get current host ip, based on that IP we need to invoke docker run with varying input args.
#With ubuntu xenial, host ip interface is named as enp0s8.
myip=$(getip enp0s8)
echo "install-hadoop-docker.sh myip is $myip"
#sudo docker run --network=host -td -e env1=192.168.10.12 -e env2="192.168.10.12,net1mc1;192.168.10.14,net1mc3;192.168.10.15,net1mc4" -e env3="192.168.10.14,192.168.10.15" hadoop:latest
#sudo docker run --network=host -td --env-file /home/vagrant/docker/input/install/env  hadoop:latest
sudo docker run --network=host -td -e hostIp=$myip -e clusterInfo="192.168.10.12,net1mc1;192.168.10.14,net1mc3;192.168.10.15,net1mc4" -e masterNodeIp="192.168.10.12" -e slaveNodes="192.168.10.14,192.168.10.15"  hadoop:latest
