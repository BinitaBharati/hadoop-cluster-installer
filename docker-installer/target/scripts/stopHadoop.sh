#!/bin/bash
set -x

getip()
{
/sbin/ifconfig ${1:-eth0} | awk '/inet addr/ {print $2}' | awk -F: '{print $2}';
}

echo "stop_hadoop : your args are hostIp=$1"
#Comment all references to 127.0.0.1 in etc hosts file, so that sockets can listen on the public IP.
#sed '/^127.0.0.1/s/127.0.0.1/#127.0.0.1/' /etc/hosts > etchostscopy
#cp etchostscopy /etc/hosts
if [ $1 == '192.168.10.12' ]; then #Implies current m/c IP is 192.168.10.12 which is the designated NamedNode
	#stop HDFS namenode services on master node
	su -c "/home/hadoop/hadoop/sbin/hadoop-daemon.sh --config /home/hadoop/hadoop/etc/hadoop --script /home/hadoop/hadoop/sbin/hdfs stop namenode" hadoop
	#stop HDFS secondary namenode services on master node	
	su -c "/home/hadoop/hadoop/sbin/hadoop-daemon.sh --config /home/hadoop/hadoop/etc/hadoop --script /home/hadoop/hadoop/sbin/hdfs stop secondarynamenode" hadoop
	#stop Yarn's resource manager services on master node
	su -c "/home/hadoop/hadoop/sbin/yarn-daemon.sh --config /home/hadoop/hadoop/etc/hadoop  stop resourcemanager" yarn
else
	#curHost is not MasterNode
	#Stop HDFS datanode services
	su -c "/home/hadoop/hadoop/sbin/hadoop-daemon.sh --config /home/hadoop/hadoop/etc/hadoop --script /home/hadoop/hadoop/sbin/hdfs stop datanode" hadoop
	#Stop Yarn's nodemanager services
	su -c "/home/hadoop/hadoop/sbin/yarn-daemon.sh --config /home/hadoop/hadoop/etc/hadoop  stop nodemanager" yarn
fi
 