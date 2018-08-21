#!/bin/bash
#Ref: https://linode.com/docs/databases/hadoop/install-configure-run-spark-on-top-of-hadoop-yarn-cluster/
set -x

getip()
{
/sbin/ifconfig ${1:-eth0} | awk '/inet addr/ {print $2}' | awk -F: '{print $2}';
}

#create Downloads directory if it does not exist.
#sudo -u root -H sh -c "mkdir -p /home/hadoop/Downloads/"
sudo mkdir -p /home/hadoop/spark/
sudo chown -R hadoop:hadoop /home/hadoop/*
sudo su -c "wget http://www-us.apache.org/dist/spark/spark-2.3.1/spark-2.3.1-bin-hadoop2.7.tgz -O /home/hadoop/Downloads/spark.tgz" hadoop
sudo su -c "tar -xvzf /home/hadoop/Downloads/spark.tgz --strip 1 -C /home/hadoop/spark/" hadoop

#Add env variables.
sudo su -c "echo 'export PATH=/home/hadoop/spark/bin:$PATH' >> /home/hadoop/.bashrc" hadoop
sudo su -c "echo 'export HADOOP_CONF_DIR=/home/hadoop/hadoop/etc/hadoop' >> /home/hadoop/.bashrc" hadoop
sudo su -c "echo 'export SPARK_HOME=/home/hadoop/spark' >> /home/hadoop/.bashrcs" hadoop
sudo su -c "echo 'export LD_LIBRARY_PATH=/home/hadoop/hadoop/lib/native:$LD_LIBRARY_PATH' >> /home/hadoop/.bashrc" hadoop

sudo su -c "mv /home/hadoop/spark/conf/spark-defaults.conf.template /home/hadoop/spark/conf/spark-defaults.conf" hadoop
#Declared spark is using hadoop yarn
sudo su -c "echo 'spark.master yarn' >> /home/hadoop/spark/conf/spark-defaults.conf" hadoop

#Memory settings.Remeber that all spark memory settings revolve around yarn.scheduler.maximum-allocation-mb in yarn-site.xml.
#yarn.scheduler.maximum-allocation-mb is the maximum memory allowed for the job container.
#Cluster mode config for spark driver
sudo su -c "echo 'spark.driver.memory 1g' >> /home/hadoop/spark/conf/spark-defaults.conf" hadoop
#Client mode config
sudo su -c "echo 'spark.yarn.am.memory 512m' >> /home/hadoop/spark/conf/spark-defaults.conf" hadoop
#Executor's memory config
sudo su -c "echo 'spark.executor.memory 1g' >> /home/hadoop/spark/conf/spark-defaults.conf" hadoop
sudo su -c "echo 'spark.executor.memoryOverhead 512m' >> /home/hadoop/spark/conf/spark-defaults.conf" hadoop

#Add SPARK_LOCAL_IP env variable
sudo su -c "echo 'export SPARK_LOCAL_IP=$1' >> /home/hadoop/spark/bin/load-spark-env.sh" hadoop
