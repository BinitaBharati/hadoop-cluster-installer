#!/bin/bash
set -x

#This script will install a 3 node cluster viz:
#192.168.10.12 - HDFS's NameNode,SecondaryNameNode & YARN's ResourceManager
#On slave nodes ie 192.168.10.14 and 192.168.10.15, HDFS's Datanode a& YARN's NodeManager

editConfigFiles() {
cp $1 $1.orig
sed -i "/${2}/c\\${3}" $1
}

setPasswordlessSsh() {
	#Copy public key of NamedNode to itself
	sudo -u $1 -H sh -c "id;pwd;mkdir -p /home/$1/.ssh;touch /home/$1/.ssh/authorized_keys;/home/$1/sshhelper.sh $1"
	
	
}

addEntryInEtcHosts() {
#Add entry in etc hosts
sudo -- sh -c -e "echo '192.168.10.12 net1mc1' >> /etc/hosts"
sudo -- sh -c -e "echo '192.168.10.14 net1mc3' >> /etc/hosts"
sudo -- sh -c -e "echo '192.168.10.15 net1mc4' >> /etc/hosts"
}

getip()
{
/sbin/ifconfig ${1:-eth0} | awk '/inet addr/ {print $2}' | awk -F: '{print $2}';
}

dos2unix /vagrant/target/scripts/addHadoopUser.sh /vagrant/target/scripts/addHadoopUser.sh
chmod +x /vagrant/target/scripts/addHadoopUser.sh
/vagrant/target/scripts/addHadoopUser.sh

dos2unix /vagrant/target/scripts/addYarnUser.sh /vagrant/target/scripts/addYarnUser.sh
chmod +x /vagrant/target/scripts/addYarnUser.sh
/vagrant/target/scripts/addYarnUser.sh

dos2unix /vagrant/target/scripts/addMapRedUser.sh /vagrant/target/scripts/addMapRedUser.sh
chmod +x /vagrant/target/scripts/addMapRedUser.sh
/vagrant/target/scripts/addMapRedUser.sh
 
#Reference: https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/ClusterSetup.html
mkdir -p /home/hadoop/Downloads
wget "http://www-us.apache.org/dist/hadoop/common/hadoop-2.7.6/hadoop-2.7.6.tar.gz" -O /home/hadoop/Downloads/hadoop.tar.gz
mkdir -p /home/hadoop/hadoop && cd /home/hadoop/hadoop
tar -xvzf /home/hadoop/Downloads/hadoop.tar.gz --strip 1
 
 #Add env variable in default .bashrc.
 echo "export HADOOP_HOME=/home/hadoop/hadoop/" >> /home/hadoop/.bashrc
 echo "export JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> /home/hadoop/hadoop/etc/hadoop/hadoop-env.sh
 echo "export HADOOP_SSH_OPTS='-o StrictHostKeyChecking=no'" >> /home/hadoop/hadoop/etc/hadoop/hadoop-env.sh
 
 #General configs - start
 editConfigFiles etc/hadoop/core-site.xml '<\/configuration>' '<property>\n<name>fs.defaultFS</name>\n<value>hdfs://192.168.10.12:9000</value>\n<description>NameNode URI</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/core-site.xml '<\/configuration>' '<property>\n<name>io.file.buffer.size</name>\n<value>131072</value>\n<description>Size of read or write buffer used in SequenceFiles</description>\n</property>\n</configuration>'
 #General configs - ends
 
 #Named Node configs - start
 mkdir -p /home/hadoop/hadoop/data/namenode
 editConfigFiles etc/hadoop/hdfs-site.xml '<\/configuration>' '<property>\n<name>dfs.namenode.name.dir</name>\n<value>/home/hadoop/hadoop/data/namenode</value>\n<description>Path on the local filesystem where the NameNode stores the namespace and transactions logs persistently</description>\n</property>\n</configuration>'
 
 editConfigFiles etc/hadoop/hdfs-site.xml '<\/configuration>' '<property>\n<name>dfs.replication</name>\n<value>2</value>\n<description>Indicates how many times data is replicated in the cluster.Do not enter a value higher than the actual number of slave nodes.</description>\n</property>\n</configuration>'
 #editConfigFiles etc/hadoop/hdfs-site.xml '<\/configuration>' '<property>\n<name>dfs.permissions.enabled</name>\n<value>true</value>\n<description>Detemines whether permission checking is enabled in HDFS</description>\n</property>\n</configuration>'
 #editConfigFiles etc/hadoop/hdfs-site.xml '<\/configuration>' '<property>\n<name>dfs.hosts</name>\n<value>192.168.10.14,192.168.10.15</value>\n<description>List of permitted/excluded DataNodes.</description>\n</property>\n</configuration>'
 #Edit etc/hadoop/workers file to contain DataNode IPs. worker file will already contain entry for localhost, that we need to remove.
 rm -rf /home/hadoop/hadoop/etc/hadoop/slaves
 touch /home/hadoop/hadoop/etc/hadoop/slaves
 echo "192.168.10.14" >> /home/hadoop/hadoop/etc/hadoop/slaves
 echo "192.168.10.15" >> /home/hadoop/hadoop/etc/hadoop/slaves
 editConfigFiles etc/hadoop/hdfs-site.xml '<\/configuration>' '<property>\n<name>dfs.blocksize</name>\n<value>268435456</value>\n<description>HDFS blocksize of 256MB for large file-systems.</description>\n</property>\n</configuration>'
 #By default, HDFS's SecondaryNameNode daemon wil start on same server as the HDFS's NameNode.
 #editConfigFiles etc/hadoop/hdfs-site.xml '<\/configuration>' '<property>\n<name>dfs.namenode.secondary.http-address</name>\n<value>192.168.10.13:50090</value>\n<description>HDFS secondary named node address.</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/hdfs-site.xml '<\/configuration>' '<property>\n<name>dfs.namenode.handler.count</name>\n<value>100</value>\n<description>More NameNode server threads to handle RPCs from large number of DataNodes.</description>\n</property>\n</configuration>'
 #Named Node configs - end
 
 #Data Node configs - start
 mkdir -p /home/hadoop/hadoop/data/datanode
 editConfigFiles etc/hadoop/hdfs-site.xml '<\/configuration>' '<property>\n<name>dfs.datanode.data.dir</name>\n<value>/home/hadoop/hadoop/data/datanode</value>\n<description>Comma separated list of paths on the local filesystem of a DataNode where it should store its blocks.</description>\n</property>\n</configuration>'
 
 #Data Node configs - end
 
 #Configurations for ResourceManager and NodeManager - start
 editConfigFiles etc/hadoop/yarn-site.xml '<\/configuration>' '<property>\n<name>yarn.acl.enable</name>\n<value>false</value>\n<description>Enable ACLs? Defaults to false.</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/yarn-site.xml '<\/configuration>' '<property>\n<name>yarn.admin.acl</name>\n<value>*</value>\n<description>ACL to set admins on the cluster. ACLs are of for comma-separated-usersspacecomma-separated-groups. Defaults to special value of * which means anyone. Special value of just space means no one has access.</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/yarn-site.xml '<\/configuration>' '<property>\n<name>yarn.log-aggregation-enable</name>\n<value>false</value>\n<description>Configuration to enable or disable log aggregation</description>\n</property>\n</configuration>'
 #Configurations for ResourceManager and NodeManager - end
 
 #Configurations for ResourceManager - start
 #By default, start-yarn.sh will start yarn's ResourceManager on same server as the hdfs's NameNode.
 editConfigFiles etc/hadoop/yarn-site.xml '<\/configuration>' '<property>\n<name>yarn.resourcemanager.hostname</name>\n<value>192.168.10.12</value>\n<description>ResourceManager host.host Single hostname that can be set in place of setting all yarn.resourcemanager*address resources. Results in default ports for ResourceManager components.</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/yarn-site.xml '<\/configuration>' '<property>\n<name>yarn.resourcemanager.scheduler.class</name>\n<value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler</value>\n<description>CapacityScheduler (recommended), FairScheduler (also recommended), or FifoScheduler. Use a fully qualified class name, e.g., org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/yarn-site.xml '<\/configuration>' '<property>\n<name>yarn.scheduler.minimum-allocation-mb</name>\n<value>1024</value>\n<description>Minimum limit of memory to allocate to each container request at the Resource Manager.</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/yarn-site.xml '<\/configuration>' '<property>\n<name>yarn.scheduler.maximum-allocation-mb</name>\n<value>1536</value>\n<description>Maximum limit of memory to allocate to each container request at the Resource Manager.</description>\n</property>\n</configuration>'
 #editConfigFiles etc/hadoop/yarn-site.xml '<\/configuration>' '<property>\n<name>yarn.resourcemanager.nodes.include-path</name>\n<value>192.168.10.14</value>\n<description>List of permitted NodeManagers.</description>\n</property>\n</configuration>'
 #Configurations for ResourceManager - end
 
 #Configurations for NodeManager - start
 editConfigFiles etc/hadoop/yarn-site.xml '<\/configuration>' '<property>\n<name>yarn.nodemanager.resource.memory-mb</name>\n<value>1536</value>\n<description>Resource i.e. available physical memory, in MB, for given NodeManager.Defines total available resources on the NodeManager to be made available to running containers</description>\n</property>\n</configuration>'
 mkdir -p /home/hadoop/hadoop/data/nodemgr
 editConfigFiles etc/hadoop/yarn-site.xml '<\/configuration>' '<property>\n<name>yarn.nodemanager.local-dirs</name>\n<value>/home/hadoop/hadoop/data/nodemgr</value>\n<description>Comma-separated list of paths on the local filesystem where intermediate data is written.</description>\n</property>\n</configuration>'
 
 mkdir -p /home/hadoop/hadoop/logs/nodemgr
 editConfigFiles etc/hadoop/yarn-site.xml '<\/configuration>' '<property>\n<name>yarn.nodemanager.log-dirs</name>\n<value>/home/hadoop/hadoop/logs/nodemgr</value>\n<description>Comma-separated list of paths on the local filesystem where logs are written.</description>\n</property>\n</configuration>'
 
 #The below config is required to debug map reduce applications.By default, map reduce container related files will get deleted as soon as the map reduce job finshes
 #So, in order to see teh files generated by  the map reduce job, we need to configure this property appropriately.
 editConfigFiles etc/hadoop/yarn-site.xml '<\/configuration>' '<property>\n<name>yarn.nodemanager.log.retain-seconds</name>\n<value>10800</value>\n<description>Default time (in seconds) to retain log files on the NodeManager Only applicable if log-aggregation is disabled.</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/yarn-site.xml '<\/configuration>' '<property>\n<name>yarn.nodemanager.remote-app-log-dir</name>\n<value>/logs</value>\n<description>HDFS directory where the application logs are moved on application completion. Need to set appropriate permissions. Only applicable if log-aggregation is enabled.</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/yarn-site.xml '<\/configuration>' '<property>\n<name>yarn.nodemanager.remote-app-log-dir-suffix</name>\n<value>/logs</value>\n<description>Suffix appended to the remote log dir. Logs will be aggregated to ${yarn.nodemanager.remote-app-log-dir}/${user}/${thisParam} Only applicable if log-aggregation is enabled.</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/yarn-site.xml '<\/configuration>' '<property>\n<name>yarn.nodemanager.aux-services</name>\n<value>mapreduce_shuffle</value>\n<description>Shuffle service that needs to be set for Map Reduce applications.</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/yarn-site.xml '<\/configuration>' '<property>\n<name>yarn.nodemanager.env-whitelist</name>\n<value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value>\n<description>Environment properties to be inherited by containers from NodeManagers.For mapreduce application in addition to the default values HADOOP_MAPRED_HOME should to be added. Property value should JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</description>\n</property>\n</configuration>'
 #editConfigFiles etc/hadoop/yarn-site.xml '<\/configuration>' '<property>\n<name>yarn.nodemanager.delete.debug-delay-sec</name><value>1800</value>\n<description>Number of seconds after an application finishes before the nodemanager's DeletionService will delete the application's localized file directory and log directory. To diagnose YARN application problems, set this property's value large enough to permit examination of these directories</description>\n</property>\n</configuration>'
 
 #Configurations for NodeManager - end
 
 editConfigFiles etc/hadoop/yarn-site.xml '<\/configuration>' '<property>\n<name>yarn.log-aggregation.retain-seconds</name>\n<value>-1</value>\n<description>How long to keep aggregation logs before deleting them. -1 disables. Be careful, set this too small and you will spam the name node.</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/yarn-site.xml '<\/configuration>' '<property>\n<name>yarn.log-aggregation.retain-check-interval-seconds</name>\n<value>-1</value>\n<description>Time between checks for aggregated log retention. If set to 0 or a negative value then the value is computed as one-tenth of the aggregated log retention time. Be careful, set this too small and you will spam the name node.</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/yarn-site.xml '<\/configuration>' '<property>\n<name>yarn.application.classpath</name>\n<value>$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/*,$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/lib/*</value>\n</property>\n</configuration>'
 
 #Configurations for proxy server
 #editConfigFiles etc/hadoop/yarn-site.xml '<\/configuration>' '<property>\n<name>yarn.web-proxy.address</name>\n<value>192.168.10.14:9046</value>\n</property>\n</configuration>'

 
 #Configurations for MapReduce - start
 cp etc/hadoop/mapred-site.xml.template etc/hadoop/mapred-site.xml
 editConfigFiles etc/hadoop/mapred-site.xml '<\/configuration>' '<property>\n<name>mapreduce.framework.name</name>\n<value>yarn</value>\n<description>Execution framework set to Hadoop YARN.</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/mapred-site.xml '<\/configuration>' '<property>\n<name>mapreduce.map.memory.mb</name>\n<value>1</value>\n<description>Larger resource limit for maps.</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/mapred-site.xml '<\/configuration>' '<property>\n<name>mapreduce.map.java.opts</name>\n<value>-Xmx1024M</value>\n<description>Larger heap-size for child jvms of maps.</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/mapred-site.xml '<\/configuration>' '<property>\n<name>mapreduce.reduce.memory.mb</name>\n<value>3072</value>\n<description>Larger resource limit for reduces.</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/mapred-site.xml '<\/configuration>' '<property>\n<name>mapreduce.reduce.java.opts</name>\n<value>-Xmx2560M</value>\n<description>Larger heap-size for child jvms of reduces.</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/mapred-site.xml '<\/configuration>' '<property>\n<name>mapreduce.task.io.sort.mb</name>\n<value>512</value>\n<description>Higher memory-limit while sorting data for efficiency.</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/mapred-site.xml '<\/configuration>' '<property>\n<name>mapreduce.task.io.sort.factor</name>\n<value>100</value>\n<description>More streams merged at once while sorting files.</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/mapred-site.xml '<\/configuration>' '<property>\n<name>mapreduce.reduce.shuffle.parallelcopies</name>\n<value>50</value>\n<description>Higher number of parallel copies run by reduces to fetch outputs from very large number of maps.</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/mapred-site.xml '<\/configuration>' '<property>\n<name>yarn.app.mapreduce.am.resource.mb</name>\n<value>1</value>\n<description>The amount of memory the MR AppMaster needs.</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/mapred-site.xml '<\/configuration>' '<property>\n<name>mapreduce.application.classpath</name>\n<value>$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/*,$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/lib/*</value>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/mapred-site.xml '<\/configuration>' '<property>\n<name>mapreduce.cluster.local.dir</name>\n<value>/home/hadoop/mapred/data/</value>\n</property>\n</configuration>'
 
 #Configurations for MapReduce - end
 
 #Configurations for MapReduce JobHistory server - start
 editConfigFiles etc/hadoop/mapred-site.xml '<\/configuration>' '<property>\n<name>mapreduce.jobhistory.address</name>\n<value>192.168.10.14:10020</value>\n<description>MapReduce JobHistory Server host:port.Default port is 10020.</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/mapred-site.xml '<\/configuration>' '<property>\n<name>mapreduce.jobhistory.webapp.address</name>\n<value>192.168.10.14</value>\n<description>MapReduce JobHistory Server Web UI host:port.Default port is 19888.</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/mapred-site.xml '<\/configuration>' '<property>\n<name>mapreduce.jobhistory.intermediate-done-dir</name>\n<value>/user/mapred/mr-history/tmp</value>\n<description>Directory where history files are written by MapReduce jobs.</description>\n</property>\n</configuration>'
 editConfigFiles etc/hadoop/mapred-site.xml '<\/configuration>' '<property>\n<name>mapreduce.jobhistory.done-dir</name>\n<value>/user/mapred/mr-history/done</value>\n<description>Directory where history files are managed by the MR JobHistory Server.</description>\n</property>\n</configuration>'
#Configurations for MapReduce JobHistory server - end

#Change all dir permissions to hadoop user.
sudo chown -R hadoop:hadoop /home/hadoop/*

#Add write permission to relevant directories directory for all users belonging to hadoop group. Down the line, you will also add yarn and mapred user that will
#belong to both their own group and hadoop group.These users also should be able to write to the said directory along with hadoop user.
sudo -u hadoop -H sh -c "chmod 777 /home/hadoop/hadoop/logs/"
sudo -u hadoop -H sh -c "chmod 777 /home/hadoop/hadoop/data/nodemgr/"
sudo -u hadoop -H sh -c "chmod 777 /home/hadoop/hadoop/logs/nodemgr"

#Format NamedNode for the first time.This command should only be run on the designated NamedNode.
myip=$(getip eth1)
echo "myip is $myip"
if [ $myip == '192.168.10.12' ]; then #Implies current m/c IP is 192.168.10.12 which is the designated NamedNode
	sudo -u hadoop -H sh -c "cat /home/hadoop/hadoop/etc/hadoop/hadoop-env.sh | grep JAVA_HOME"
	sudo -u hadoop -H sh -c "id;/home/hadoop/hadoop/bin/hdfs namenode -format test_cluster"
	
fi

########################################################################################################


##########################################################################################################








