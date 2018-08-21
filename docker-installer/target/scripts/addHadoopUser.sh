#!/bin/bash
set -x

#Master node - HDFS's NameNode,SecondaryNameNode & YARN's ResourceManager.
#Slave node - HDFS's Datanode a& YARN's NodeManager.
if [ "$#" -ne 3 ]; then
  echo "Usage: addHadoopUser.sh <host IP> <cluster hostIPs,cluster hostNames seperated by semi colon> <Master Node IP>" >&2
  exit 1
fi

curHostIp=$1
clusterInfo=($(echo $2 | tr ';' '\n'))

addEntryInEtcHosts() {
#Remove entry for localhost
sed 's/^127.0.0.1/#127.0.0.1/g' /etc/hosts > etchostscopy
cp etchostscopy /etc/hosts
#Somehow, runing docker file with network=host is adding the IP of 127.0.1.1 for the host.
#This needs to be prevented, so that the sockets can LISTEN on public ip and not on the weird host ip. 
sed 's/^127.0.1.1/#127.0.1.1/g' /etc/hosts > etchostscopy
cp etchostscopy /etc/hosts

#Add entry in etc hosts
 for eachHost in "${clusterInfo[@]}"
 do
 	echo $eachHost
 	eachHostInfo=($(echo $eachHost | tr ',' '\n'))
 	echo ${eachHostInfo[0]} ${eachHostInfo[1]} >> /etc/hosts
 done
}

setPasswordlessSsh() {
	#Copy public key of NamedNode to itself
	# -u hadoop -H sh -c "id;pwd;mkdir -p /home/hadoop/.ssh;touch /home/hadoop/.ssh/authorized_keys;/home/hadoop/sshhelper.sh"
	 su -c "id;pwd;mkdir -p /home/$1/.ssh;touch /home/$1/.ssh/authorized_keys;/home/$1/sshhelper.sh $1 $2" $1 
	
	
}

getip()
{
/sbin/ifconfig ${1:-eth0} | awk '/inet addr/ {print $2}' | awk -F: '{print $2}';
}

#create hadoop linux user.This user will be used to start the HDFS daemons viz NameNode, SecondaryNameNode, and DataNode(s).
id
 useradd -m -d /home/hadoop/ -s /bin/bash hadoop
#Add user to common hadoop group, so that hadoo, yarn and mapred user can write to common directories under hadoop home.
# groupadd hadoop
# usermod -g hadoop hadoop
 cp passwdset.sh /home/hadoop/
 chown -R hadoop:hadoop /home/hadoop/passwdset.sh
 cp sshhelper.sh /home/hadoop/
 chown -R hadoop:hadoop /home/hadoop/sshhelper.sh

#add hadoop user to sudo group with NOPASSWD
#touch tmphadoopers
#echo "hadoop ALL=(ALL) NOPASSWD:ALL" > tmphadoopers
#touch /etc/sudoers.d/hadoop
#cp tmphadoopers /etc/sudoers.d/hadoop

#echo "hadoop ALL=(ALL) NOPASSWD:ALL" >>  /etc/sudoers.d/hadoop

#Run command as hadoop user
id # Prints as root user
#So, even if you do a ' su - hadoop' ,dont expect the commands to run as hadoop user.Linux commands are run by the same user that owns the command.
#Eg chmod is owned by root, so running it will always run as root user irrespective of what your current user is.
#Only way to run commands as other user is to do a  -u hadoop sh -c <Command to run>
 su -c "id;pwd;dos2unix /home/hadoop/passwdset.sh /home/hadoop/passwdset.sh;chmod +x /home/hadoop/passwdset.sh;dos2unix /home/hadoop/sshhelper.sh /home/hadoop/sshhelper.sh;chmod +x /home/hadoop/sshhelper.sh" hadoop

#Add env variable in default .bashrc.
#echo "export HADOOP_HOME=/home/hadoop/hadoop/" >> /home/hadoop/.bashrc
 su -c "id;pwd;echo 'export JAVA_HOME=/usr/lib/jvm/java-8-oracle' >> /home/hadoop/.bashrc;echo 'export PATH=$PATH:/sbin' >> /home/hadoop/.bashrc" hadoop
 su -c "id;pwd;echo 'export HADOOP_MAPRED_HOME=/home/hadoop/hadoop/' >> /home/hadoop/.bashrc" hadoop

#set the passwd for the newly ceated hadoop user. Reference : https://stackoverflow.com/questions/27837674/changing-a-linux-password-via-script
 echo -e "hadoop\nhadoop" | /home/hadoop/passwdset.sh hadoop

#Set passwordless SSH login from NameNode to itself, secondary named node and all the data nodes. This is to enable us to start all the HDFS
#daemons by logging into the NamedNode alone.
#Generate ssh-key par on NameNode alone.
#Get current m/c IP
id
#myip=$(getip eth1)
if [ $1 == $3 ]; then #Implies current m/c IP is the designated NamedNode
    #Silent ssh-keygen
     su -c "id;pwd;cat /dev/zero | ssh-keygen -q -N ''" hadoop
    
    #Copy public key to itself
     su -c "id;pwd;touch /home/hadoop/.ssh/authorized_keys" hadoop
     su -c "id;pwd;cp /home/hadoop/.ssh/id_rsa.pub /home/hadoop/.ssh/authorized_keys" hadoop
    
    #Make edits to /etc/hosts file
    addEntryInEtcHosts
    #Comment out all references to 127.0.0.1 in NamedNode /etc/hosts file.This is so that the sockets can LISTEN on public ip and not on local host ip. 
     sed '/^127.0.0.1/s/127.0.0.1/#127.0.0.1/' /etc/hosts > etchostscopy
     cp etchostscopy /etc/hosts
   
 fi
 
 if [ $1 == $3 ]; then #Implies current m/c IP is the designated NamedNode
      #Comment out all references to 127.0.0.1 in ResourceManager /etc/hosts file .This is so that the sockets can LISTEN on public ip and not on local host ip.  
       sed '/^127.0.0.1/s/127.0.0.1/#127.0.0.1/' /etc/hosts > etchostscopy
       cp etchostscopy /etc/hosts
     
 fi
 
 if [ $1 != $3 ]; then #Implies current m/c IP is a SlaveNode
     setPasswordlessSsh hadoop $3 
     #Make edits to /etc/hosts file
     addEntryInEtcHosts
    
 fi