#This is a sample Image 
FROM ubuntu 
MAINTAINER binita.bharati@gmail.com 

RUN mkdir -p /home/vagrant/dockerws/hadoopInstaller
WORKDIR /home/vagrant/dockerws/hadoopInstaller

#Copy all the required files from host's file system to the container file system.
COPY install/install_hadoop_container.sh .
COPY install/install_hadoop_docker.sh .
COPY install/install_java.sh .
COPY install/install_hadoop.sh .
COPY install/addHadoopUser.sh .
COPY install/addYarnUser.sh .
COPY install/addMapRedUser.sh .
COPY install/sshhelper.sh .
COPY install/passwdset.sh .
COPY install/startServices.sh .
COPY install/stopServices.sh .
COPY install/restartServices.sh .
COPY install/env .
COPY install/stopHadoop.sh .
COPY install/startHadoop.sh .
COPY install/install_spark.sh .



RUN apt-get update;apt-get -y install dos2unix
RUN dos2unix stopHadoop.sh stopHadoop.sh;chmod +x stopHadoop.sh
RUN dos2unix startHadoop.sh startHadoop.sh;chmod +x startHadoop.sh
RUN dos2unix install_spark.sh install_spark.sh;chmod +x install_spark.sh


RUN dos2unix install_hadoop_container.sh install_hadoop_container.sh;chmod +x install_hadoop_container.sh

ENTRYPOINT ["/home/vagrant/dockerws/hadoopInstaller/install_hadoop_container.sh"]