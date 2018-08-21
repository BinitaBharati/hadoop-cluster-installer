s#!/bin/bash
set -x

getip()
{
/sbin/ifconfig ${1:-eth0} | awk '/inet addr/ {print $2}' | awk -F: '{print $2}';
}

#Start JobHistory server.Has to be done as mapred user.

#Add mapred user
 useradd -m -d /home/mapred/ -s /bin/bash mapred

#add mapred user to  group with NOPASSWD
#touch tmpmapreders
#echo "mapred ALL=(ALL) NOPASSWD:ALL" > tmpmapreders
#touch /etc/sudoers.d/mapred
#cp tmpmapreders /etc/sudoers.d/mapred

#echo "mapred ALL=(ALL) NOPASSWD:ALL" >>  /etc/sudoers.d/mapred

#Add mapred user to hadoop group, so that hadoop, yarn and mapred user can write to common directories under hadoop home.
 usermod -g hadoop mapred