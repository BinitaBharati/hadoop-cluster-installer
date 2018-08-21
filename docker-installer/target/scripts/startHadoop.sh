#!/bin/bash
set -x

getip()
{
/sbin/ifconfig ${1:-eth0} | awk '/inet addr/ {print $2}' | awk -F: '{print $2}';
}

echo "stop_hadoop : your args are hostIp=$1"
if [ $1 == '192.168.10.12' ]; then #Implies current m/c IP is 192.168.10.12 which is the designated NamedNode
	#stop HDFS namenode services on master node
	su -c "/home/hadoop/hadoop/sbin/hadoop-daemon.sh --config /home/hadoop/hadoop/etc/hadoop --script /home/hadoop/hadoop/sbin/hdfs start namenode" hadoop
	su -c "/home/hadoop/hadoop/sbin/hadoop-daemon.sh --config /home/hadoop/hadoop/etc/hadoop --script /home/hadoop/hadoop/sbin/hdfs start secondarynamenode" hadoop
	
	#stop Yarn's resource manager services on master node
	su -c "/home/hadoop/hadoop/sbin/yarn-daemon.sh --config /home/hadoop/hadoop/etc/hadoop  start resourcemanager" yarn
else
	#curHost is not MasterNode
	#Stop HDFS datanode services
	su -c "/home/hadoop/hadoop/sbin/hadoop-daemon.sh --config /home/hadoop/hadoop/etc/hadoop --script /home/hadoop/hadoop/sbin/hdfs start datanode" hadoop
	#Stop Yarn's nodemanager services
	su -c "/home/hadoop/hadoop/sbin/yarn-daemon.sh --config /home/hadoop/hadoop/etc/hadoop  start nodemanager" yarn	
	chown -R yarn:hadoop /home/hadoop/hadoop/data/nodemgr/
 	chown -R yarn:hadoop /home/hadoop/hadoop/logs/nodemgr/
 	sleep 60
 	su -c "chmod 777 /home/hadoop/hadoop/data/nodemgr/nmPrivate" yarn
	
fi
 