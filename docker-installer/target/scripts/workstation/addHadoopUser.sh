#!/bin/bash
set -x

addEntryInEtcHosts() {
#Add entry in etc hosts
sudo -- sh -c -e "echo '192.168.10.12 net1mc1' >> /etc/hosts"
sudo -- sh -c -e "echo '192.168.10.14 net1mc3' >> /etc/hosts"
sudo -- sh -c -e "echo '192.168.10.15 net1mc4' >> /etc/hosts"
}

setPasswordlessSsh() {
	#Copy public key of NamedNode to itself
	#sudo -u hadoop -H sh -c "id;pwd;mkdir -p /home/hadoop/.ssh;touch /home/hadoop/.ssh/authorized_keys;/home/hadoop/sshhelper.sh"
	sudo -u $1 -H sh -c "id;pwd;mkdir -p /home/$1/.ssh;touch /home/$1/.ssh/authorized_keys;/home/$1/sshhelper.sh $1"
	
	
}

getip()
{
/sbin/ifconfig ${1:-eth0} | awk '/inet addr/ {print $2}' | awk -F: '{print $2}';
}

#create hadoop linux user.This user will be used to start the HDFS daemons viz NameNode, SecondaryNameNode, and DataNode(s).
id
sudo useradd -m -d /home/hadoop/ -s /bin/bash hadoop
#Add user to common hadoop group, so that hadoo, yarn and mapred user can write to common directories under hadoop home.
#sudo groupadd hadoop
#sudo usermod -g hadoop hadoop
sudo cp /home/vagrant/deploy/target/scripts/workstation/passwdset.sh /home/hadoop/
sudo chown -R hadoop:hadoop /home/hadoop/passwdset.sh
sudo cp /home/vagrant/deploy/target/scripts/workstation/sshhelper.sh /home/hadoop/
sudo chown -R hadoop:hadoop /home/hadoop/sshhelper.sh

#add hadoop user to sudo group with NOPASSWD
touch tmphadoopsudoers
echo "hadoop ALL=(ALL) NOPASSWD:ALL" > tmphadoopsudoers
sudo touch /etc/sudoers.d/hadoop
sudo cp tmphadoopsudoers /etc/sudoers.d/hadoop

echo "hadoop ALL=(ALL) NOPASSWD:ALL" >> sudo /etc/sudoers.d/hadoop

#Run command as hadoop user
id # Prints as root user
#So, even if you do a 'sudo su - hadoop' ,dont expect the commands to run as hadoop user.Linux commands are run by the same user that owns the command.
#Eg chmod is owned by root, so running it will always run as root user irrespective of what your current user is.
#Only way to run commands as other user is to do a sudo -u hadoop sh -c <Command to run>
sudo -u hadoop -H sh -c "id;pwd;dos2unix /home/hadoop/passwdset.sh /home/hadoop/passwdset.sh;chmod +x /home/hadoop/passwdset.sh;dos2unix /home/hadoop/sshhelper.sh /home/hadoop/sshhelper.sh;chmod +x /home/hadoop/sshhelper.sh"

#Add env variable in default .bashrc.
#echo "export HADOOP_HOME=/home/hadoop/hadoop/" >> /home/hadoop/.bashrc
sudo -u hadoop -H sh -c "id;pwd;echo 'export JAVA_HOME=/usr/lib/jvm/java-8-oracle' >> /home/hadoop/.bashrc;echo 'export PATH=$PATH:/sbin' >> /home/hadoop/.bashrc"
sudo -u hadoop -H sh -c "id;pwd;echo 'export HADOOP_MAPRED_HOME=/home/hadoop/hadoop/' >> /home/hadoop/.bashrc"

#set the passwd for the newly ceated hadoop user. Reference : https://stackoverflow.com/questions/27837674/changing-a-linux-password-via-script
sudo echo -e "hadoop\nhadoop" | /home/hadoop/passwdset.sh hadoop