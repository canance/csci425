#!/usr/bin/env bash
#title           :init.sh
#description     :This script will provision ubuntu 14.04 with hbase, download book source code, as well as supplemental files.
#author		 :Cory Nance
#date            :20160214
#version         :0.1    
#usage		 :bash init.sh

# Update
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y

# Configure SSH
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/#UseLogin no/UseLogin yes/g' /etc/ssh/sshd_config
service ssh restart

# Create swapfile
fallocate -l 2GB /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo /swapfile none swap defaults 0 0 >> /etc/fstab

# Download book code
cd /home/hbase
sudo -u hbase wget http://media.pragprog.com/titles/rwdata/code/rwdata-code.tgz 2>&1
sudo -u hbase tar xvf rwdata-code.tgz code/hbase --strip-components=2
rm rwdata-code.tgz

# copy authorized_keys
mkdir -p /home/hbase/.ssh
cp /root/.ssh/authorized_keys /home/hbase/.ssh/authorized_keys
chown -R hbase:hbase /home/hbase/.ssh
chmod 700 /home/hbase

# Install software
apt-get install curl git openjdk-8-jdk vim -y

# Download hbase
mkdir /opt
cd /opt
wget http://mirrors.koehn.com/apache/hbase/hbase-1.0.3/hbase-1.0.3-bin.tar.gz 2>&1
tar xzvf hbase-1.0.3-bin.tar.gz
rm hbase-1.0.3-bin.tar.gz

# Configure hbase
cd hbase-1.0.3
sed -i 's/<configuration>//g' conf/hbase-site.xml
sed -i 's/<\/configuration>//g' conf/hbase-site.xml
echo "
<configuration>
  <property>
    <name>hbase.rootdir</name>
    <value>file:///home/hbase/hbase_data</value>
  </property>
  <property>
    <name>hbase.zookeeper.property.dataDir</name>
    <value>/home/hbase/zookeeper</value>
  </property>
</configuration>" >> conf/hbase-site.xml
chown -R hbase:hbase /opt/hbase-1.0.3/

# Setup ENV variables
sudo -u hbase echo "
export JAVA_HOME='/usr'
export PATH='/opt/hbase-1.0.3/bin:$PATH'
export HBASE_HOME='/opt/hbase-1.0.3'" >> /home/hbase/.bashrc
sudo -u hbase echo ". ~/.bashrc" >> /home/hbase/.bash_profile

