#!/bin/bash
set -x

getip()
{
/sbin/ifconfig ${1:-eth0} | awk '/inet addr/ {print $2}' | awk -F: '{print $2}';
}

myip=$(getip eth1)
echo "myip is $myip"
if [ $myip == '192.168.10.12' ]; then #Implies current m/c IP is 192.168.10.12 which is the designated NamedNode
	#start HDFS services from NamedNode (master node)
	yes | sudo -u hadoop -H sh -c "/home/hadoop/hadoop/sbin/start-dfs.sh"
	sudo -u yarn -H sh -c "/home/hadoop/hadoop/sbin/start-yarn.sh"
	
fi

#if [ $myip == '192.168.10.14' ]; then #Implies current m/c IP is 192.168.10.14 which is the designated ResourceManager, JobHistory server
	#sudo -u yarn -H sh -c "/home/hdfs/hadoop/sbin/yarn-daemon.sh start resourcemanager"
	#sudo -u yarn -H sh -c "/home/hdfs/hadoop/bin/yarn --daemon start proxyserver"
	#sudo -u mapred -H sh -c "/home/hdfs/hadoop/bin/mapred --daemon start historyserver"
	
#fi
 