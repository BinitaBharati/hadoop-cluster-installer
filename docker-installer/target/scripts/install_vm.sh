#!/bin/bash
#Ref for ubuntu/trusty: https://www.tutorialspoint.com/docker/installing_docker_on_linux.htm

#sudo apt-get -y install apt-transport-https ca-certificates

#sudo apt-key adv \ --keyserver hkp://ha.pool.sks-keyservers.net:80 \ --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

#echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' | sudo tee /etc/apt/sources.list.d/docker.list

#sudo apt-get update

#sudo apt-get -y install linux-image-extra-3.13.0-137-generic
#sudo apt-get -y install linux-image-extra-virtual

#sudo apt-get install -y docker-engine


#Ref for ubuntu/xenial: https://medium.com/@Grigorkh/how-to-install-docker-on-ubuntu-16-04-3f509070d29c

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
apt-cache policy docker-ce
sudo apt-get install -y docker-ce

#install python, by default, python does not come installed with ubuntu xenial.
sudo apt-get -y install python

editConfigFiles() {
sudo cp $1 $1.orig
sudo sed -i "/${2}/c\\${3}" $1
}


#In Ubuntu xenial vbox, ssh password authentication is switched off by default.Enable it.Once the work is done,
#you could disable password based authentication and let only key based authentication remain.
editConfigFiles /etc/ssh/sshd_config 'PasswordAuthentication no' 'PasswordAuthentication yes'

#Restart ssh servies for the above ssh config change to take effect.
sudo service ssh restart








  
  




