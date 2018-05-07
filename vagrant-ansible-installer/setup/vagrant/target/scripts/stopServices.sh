#!/bin/bash

cd /home/vagrant/deploy
#Recursively run dos2unix on all files under deploy folder
find . -type f -exec dos2unix {} \;
chmod 666 playbook-stop-services.yml ansible_inventory
ansible-playbook playbook-stop-services.yml -i ansible_inventory



