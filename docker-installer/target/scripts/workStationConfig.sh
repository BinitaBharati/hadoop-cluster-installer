#!/bin/bash

editConfigFiles() {
sudo cp $1 $1.orig
sudo sed -i "/${2}/c\\${3}" $1
}


#Install pre-requisites to instal Hadoop cluster.
mkdir -p /home/vagrant/deploy
#Copy all the shared files under /vagrant/* /home/vagrant/deploy
#You can not run ansible-playbook from the /vagrant shared folder directly,
#as you can not run ansible-playbook from /vagrant folder.
#See: https://stackoverflow.com/questions/18385925/error-when-running-ansible-playbook#
cp -R /vagrant/* /home/vagrant/deploy/


sudo apt-get update

#install dos2unix
sudo apt-get -y install dos2unix

cd /home/vagrant/deploy
#Recursively run dos2unix on all files under deploy folder
find . -type f -exec dos2unix {} \;
#Recursively change permission to executable for all scripts under deploy
find . -type f -exec chmod +x {} \;

#install java
/home/vagrant/deploy/target/scripts/install_java.sh


#install hadoop client
export hostIp="192.168.50.11";export clusterInfo="192.168.10.12,net1mc1;192.168.10.14,net1mc3;192.168.10.15,net1mc4";export masterNodeIp="192.168.10.12";export slaveNodes="192.168.10.14,192.168.10.15";/home/vagrant/deploy/target/scripts/workstation/install_hadoop_client.sh

#install spark client
/home/vagrant/deploy/target/scripts/workstation/install_spark_client.sh

#install executables to build hadoop src code - start.This is required in case you need to debug hadoop code itself.
sudo apt-get install -y maven
#Install protobuf 2.5 as compilation of Hadoop 2.7 code needs it.
cd /usr/local/src/
sudo wget https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz
sudo tar xvf protobuf-2.5.0.tar.gz
sudo apt-get install -y autoconf
sudo apt-get install -y libtool
sudo chmod +x autogen.sh
sudo ./autogen.sh
sudo apt install -y g++
sudo ./configure --prefix=/usr
sudo apt-get install -y make
sudo make
sudo make install
#install executables to build hadoop src code - end



#install ansible
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update
sudo apt-get install ansible -y #installs 1.5.4
#Below does not get installed, need to check how to install ansible 2.2.1.0 at one go.
#After installation error comes, wrt playbook having ansible 2.0 syntax, and then only
#am installing ansible 2.0 manually.This should be fixed.
sudo apt-get update
sudo apt-get install ansible -y #installs 2.2.1.0


#install sshpass
sudo apt-get install sshpass


sudo chown -R vagrant:vagrant /home/vagrant/deploy

#In Ubuntu xenial vbox, ssh password authentication is switched off by default.Enable it.Once the work is done,
#you could disable password based authentication and let only key based authentication remain.
editConfigFiles /etc/ssh/sshd_config 'PasswordAuthentication no' 'PasswordAuthentication yes'

#Restart ssh servies for the above ssh config change to take effect.
sudo service ssh restart








