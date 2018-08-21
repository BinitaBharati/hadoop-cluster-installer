#!/bin/bash

if [ ! -f /home/vagrant/init ] 
then
    #Ensure that you have the ~/.ssh/id_rsa.pub file present by running 'ssh-keygen -t rsa'


#Need silent ssh-kegen that does not ask for passphrase or ask to override the private and public key files
cat /dev/zero | ssh-keygen -q -N ""

#Enable passwordless SSH to the remote m/c.


cat ~/.ssh/id_rsa.pub | sshpass -p vagrant ssh -o StrictHostKeyChecking=no vagrant@192.168.10.12 ' cat >> ~/.ssh/authorized_keys'

cat ~/.ssh/id_rsa.pub | sshpass -p vagrant ssh -o StrictHostKeyChecking=no vagrant@192.168.10.14 'cat >> ~/.ssh/authorized_keys'

cat ~/.ssh/id_rsa.pub | sshpass -p vagrant ssh -o StrictHostKeyChecking=no vagrant@192.168.10.15 'cat >> ~/.ssh/authorized_keys'

touch /home/vagrant/init

fi

cd /home/vagrant/deploy
#Recursively run dos2unix on all files under deploy folder
find . -type f -exec dos2unix {} \;
#Recursively change permission to executable for all scripts under deploy
find . -type f -exec chmod +x {} \;
chmod 666 ansible/playbook-install-hadoop.yml ansible/ansible_inventory
ansible-playbook ansible/playbook-install-hadoop.yml -i ansible/ansible_inventory



