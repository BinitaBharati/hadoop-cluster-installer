#!/bin/bash
set -x

#Copy the public key of 192.168.10.12 which is the NamedNode to authorized_keys of the current m/c
sshpass -p $1 scp -o StrictHostKeyChecking=no $1@$2:/home/$1/.ssh/id_rsa.pub /home/$1/.ssh/authorized_keys




