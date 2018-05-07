#!/bin/bash
set -x

getip()
{
/sbin/ifconfig ${1:-eth0} | awk '/inet addr/ {print $2}' | awk -F: '{print $2}';
}

myip=$(getip eth1)
echo "myip is $myip"
if [ $myip == '192.168.10.12' ]; then #Implies current m/c IP is 192.168.10.12 which is the designated NamedNode
	#stop HDFS services from NamedNode (master node)
	yes | sudo -u hadoop -H sh -c "/home/hadoop/hadoop/sbin/stop-dfs.sh"
	sudo -u yarn -H sh -c "/home/hadoop/hadoop/sbin/stop-yarn.sh"
	
fi
 