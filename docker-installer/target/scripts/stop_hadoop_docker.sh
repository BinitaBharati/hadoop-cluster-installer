#!/bin/bash
set -x

getip()
{
/sbin/ifconfig ${1:-eth0} | awk '/inet addr/ {print $2}' | awk -F: '{print $2}';
}

#With ubuntu xenial, host ip interface is named as enp0s8.
myip=$(getip enp0s8)
echo "myip is $myip"

#get running hadoop docker container id
conId=$(sudo docker ps | grep hadoop:latest | cut -d " " -f 1)
echo "conId = $conId"

#Commenting this due to the "Input device is not a TTY error"
#sudo docker exec -it $conId sh -c "/home/vagrant/dockerws/hadoopInstaller/stopHadoop.sh $myip"
sudo docker exec -t $conId sh -c "/home/vagrant/dockerws/hadoopInstaller/stopHadoop.sh $myip"