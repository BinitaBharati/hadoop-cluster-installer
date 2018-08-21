#!/bin/bash
set -x

setPasswordlessSsh() {
	#Copy public key of NamedNode to itself
	 su -c "id;pwd;mkdir -p /home/$1/.ssh;touch /home/$1/.ssh/authorized_keys;/home/$1/sshhelper.sh $1 $2" $1
	
	
}

getip()
{
/sbin/ifconfig ${1:-eth0} | awk '/inet addr/ {print $2}' | awk -F: '{print $2}';
}

#Start YARN services ie ResourceManager, NodeManager.Has to be done as yarn user.
#add yarn user, set passwd for it in all servers. set passwordless ssh to all servers mentioned in workers file

#Add yarn user
 useradd -m -d /home/yarn/ -s /bin/bash yarn
 cp passwdset.sh /home/yarn/
 chown -R yarn:yarn /home/yarn/passwdset.sh
 cp sshhelper.sh /home/yarn/
 chown -R yarn:yarn /home/yarn/sshhelper.sh
 su -c "id;pwd;dos2unix /home/yarn/passwdset.sh /home/yarn/passwdset.sh;chmod +x /home/yarn/passwdset.sh;dos2unix /home/yarn/sshhelper.sh /home/yarn/sshhelper.sh;chmod +x /home/yarn/sshhelper.sh" yarn

#Set the password for the yarn user
 echo -e "yarn\nyarn" | /home/yarn/passwdset.sh yarn

#add yarn user to  group with NOPASSWD
touch tmpyarners
echo "yarn ALL=(ALL) NOPASSWD:ALL" > tmpyarners
 touch /etc/sudoers.d/yarn
 cp tmpyarners /etc/sudoers.d/yarn

echo "yarn ALL=(ALL) NOPASSWD:ALL" >>  /etc/sudoers.d/yarn

#Add yarn user to common hadoop group, so that hadoop, yarn and mapred user can write to common directories under hadoop home.
 usermod -g hadoop yarn

#Set passwordless ssh login from NamedNode(master) to others.
#myip=$(getip eth1)
echo "addYarnUser: $1 $2"
if [ $1 == $2 ]; then #Implies current m/c IP is the designated NamedNode
    #Silent ssh-keygen
     su -c "id;pwd;cat /dev/zero | ssh-keygen -q -N ''" yarn
    
    #Copy public key to itself
     su -c "id;pwd;touch /home/yarn/.ssh/authorized_keys" yarn
     su -c "id;pwd;cp /home/yarn/.ssh/id_rsa.pub /home/yarn/.ssh/authorized_keys" yarn  
   
 fi
 
 if [ $1 != $2 ]; then #Implies current m/c IP is a Slave node
     setPasswordlessSsh yarn
    
 fi