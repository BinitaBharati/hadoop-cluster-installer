#!/bin/bash
set -x

#Copy the public key of 192.168.10.12 which is the NamedNode to authorized_keys of the current m/c
#hdfs@net1mc2:/home/hdfs$ sshpass -p 'hdfs' scp -o StrictHostKeyChecking=no hdfs@192.168.10.12:/home/hdfs/.ssh/id_rsa.pub /home/hdfs/test
#sshpass -p 'hdfs' scp -o StrictHostKeyChecking=no hdfs@192.168.10.12:/home/hdfs/.ssh/id_rsa.pub /home/hdfs/.ssh/authorized_keys
sshpass -p $1 scp -o StrictHostKeyChecking=no $1@192.168.10.12:/home/$1/.ssh/id_rsa.pub /home/$1/.ssh/authorized_keys




