#!/bin/bash
set -x

setPasswordlessSsh() {
	#Copy public key of NamedNode to itself
	sudo -u $1 -H sh -c "id;pwd;mkdir -p /home/$1/.ssh;touch /home/$1/.ssh/authorized_keys;/home/$1/sshhelper.sh $1"
	
	
}

getip()
{
/sbin/ifconfig ${1:-eth0} | awk '/inet addr/ {print $2}' | awk -F: '{print $2}';
}

#Start YARN services ie ResourceManager, NodeManager.Has to be done as yarn user.
#add yarn user, set passwd for it in all servers. set passwordless ssh to all servers mentioned in workers file

#Add yarn user
sudo useradd -m -d /home/yarn/ -s /bin/bash yarn
sudo cp /home/vagrant/deploy/target/scripts/workstation/passwdset.sh /home/yarn/
sudo chown -R yarn:yarn /home/yarn/passwdset.sh
sudo cp /home/vagrant/deploy/target/scripts/workstation/sshhelper.sh /home/yarn/
sudo chown -R yarn:yarn /home/yarn/sshhelper.sh
sudo -u yarn -H sh -c "id;pwd;dos2unix /home/yarn/passwdset.sh /home/yarn/passwdset.sh;chmod +x /home/yarn/passwdset.sh;dos2unix /home/yarn/sshhelper.sh /home/yarn/sshhelper.sh;chmod +x /home/yarn/sshhelper.sh"

#Set the password for the yarn user
sudo echo -e "yarn\nyarn" | /home/yarn/passwdset.sh yarn

#add yarn user to sudo group with NOPASSWD
touch tmpyarnsudoers
echo "yarn ALL=(ALL) NOPASSWD:ALL" > tmpyarnsudoers
sudo touch /etc/sudoers.d/yarn
sudo cp tmpyarnsudoers /etc/sudoers.d/yarn

echo "yarn ALL=(ALL) NOPASSWD:ALL" >> sudo /etc/sudoers.d/yarn

#Add yarn user to common hadoop group, so that hadoop, yarn and mapred user can write to common directories under hadoop home.
sudo usermod -g hadoop yarn

#Set passwordless ssh login from NamedNode(master) to others.
myip=$(getip eth1)
if [ $myip == '192.168.10.12' ]; then #Implies current m/c IP is 192.168.10.12 which is the designated NamedNode
    #Silent ssh-keygen
    sudo -u yarn -H sh -c "id;pwd;cat /dev/zero | ssh-keygen -q -N ''"
    
    #Copy public key to itself
    sudo -u yarn -H sh -c "id;pwd;touch /home/yarn/.ssh/authorized_keys"
    sudo -u yarn -H sh -c "id;pwd;cp /home/yarn/.ssh/id_rsa.pub /home/yarn/.ssh/authorized_keys"  
   
 fi
 
 if [ $myip == '192.168.10.13' ] || [ $myip == '192.168.10.14' ] || [ $myip == '192.168.10.15' ]; then #Implies current m/c IP is 192.168.10.13/.14/.15
     setPasswordlessSsh yarn
    
 fi