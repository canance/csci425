#!/usr/bin/env bash
#title           :init.sh
#description     :This script will provision ubuntu 14.04 with neo4j, download book source code, and setup the environment.
#author		 :Cory Nance
#date            :20160409
#version         :0.1    
#usage		 :bash init.sh

# Update
export DEBIAN_FRONTEND=noninteractive
echo "Updating the system..."
apt-get update 
apt-get upgrade -y 

# Configure SSH
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/#UseLogin no/UseLogin yes/g' /etc/ssh/sshd_config
service ssh restart 

# Create swapfile
fallocate -l 2GB /swapfile
chmod 600 /swapfile
mkswap /swapfile &>/dev/null
swapon /swapfile &>/dev/null
echo /swapfile none swap defaults 0 0 >> /etc/fstab

# Increase ulimit
echo "* hard nofile 65536" >> /etc/security/limits.conf
echo "* soft nofile 4096" >> /etc/security/limits.conf
echo "session    required   pam_limits.so" >> /etc/pam.d/common-session
echo "session    required   pam_limits.so" >> /etc/pam.d/common-session-noninteractive

# Download book code and supplemental files
cd /home/neo4j
echo "Downloading book code..."
sudo -u neo4j wget http://media.pragprog.com/titles/rwdata/code/rwdata-code.tgz 
sudo -u neo4j tar xvf rwdata-code.tgz code/neo4j --strip-components=2 
rm rwdata-code.tgz
echo "Downloading performance.tsv..."
sudo -u neo4j wget http://ci.coastal.edu/~canance/7dbs7wks/performance.tsv 

# copy authorized_keys
mkdir -p /home/neo4j/.ssh
cp /root/.ssh/authorized_keys /home/neo4j/.ssh/authorized_keys
chown -R neo4j:neo4j /home/neo4j/.ssh
chmod 700 /home/neo4j

echo "Installing Ruby and gems..."
apt-get install build-essential ruby ruby-dev unzip -y 
gem install json faraday 

# install neo4j
# debian.neo4j.org
echo "Installing NEO4J-Enterprise version 1.9.1..."
wget -O - https://debian.neo4j.org/neotechnology.gpg.key  | sudo apt-key add - 
echo 'deb http://debian.neo4j.org/repo stable/' > /tmp/neo4j.list
mv /tmp/neo4j.list /etc/apt/sources.list.d
apt-get update 
apt-get install neo4j-enterprise=1.9.1 -y

# install gremlin
echo "Installing Gremlin..."
cd /home/neo4j
sudo -u neo4j wget https://github.com/downloads/tinkerpop/gremlin/gremlin-groovy-2.0.0.zip 
sudo -u neo4j unzip gremlin-groovy-2.0.0.zip 
sudo -u neo4j echo alias gremlin=\"bash /home/neo4j/gremlin-groovy-2.0.0/gremlin-groovy.sh\" >> /home/neo4j/.bash_profile

# reboot
echo "A reboot is required ..." 1>&2
echo "Please allow time for reboot to finish before SSH'ing." 1>&2
reboot
