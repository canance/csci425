#!/usr/bin/env bash
#title           :init.sh
#description     :This script will provision ubuntu 14.04 with couchdb, download book source code, and setup the environment.
#author		 :Cory Nance
#date            :201603026
#version         :0.1    
#usage		 :bash init.sh

# Update
export DEBIAN_FRONTEND=noninteractive
echo "Updating the system..."
apt-get update &>/dev/null
apt-get upgrade -y &>/dev/null

# Configure SSH
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/#UseLogin no/UseLogin yes/g' /etc/ssh/sshd_config
service ssh restart &>/dev/null

# Create swapfile
fallocate -l 2GB /swapfile
chmod 600 /swapfile
mkswap /swapfile &>/dev/null
swapon /swapfile &>/dev/null
echo /swapfile none swap defaults 0 0 >> /etc/fstab

# Download book code
cd /home/couch
echo "Downloading book code..."
sudo -u couch wget http://media.pragprog.com/titles/rwdata/code/rwdata-code.tgz &>/dev/null
sudo -u couch tar xvf rwdata-code.tgz code/couchdb --strip-components=2 &>/dev/null
rm rwdata-code.tgz
echo "Downloading dbdump_artistalbumtrack.xml.gz..."
sudo -u couch wget http://img.jamendo.com/data/dbdump_artistalbumtrack.xml.gz &>/dev/null

# copy authorized_keys
mkdir -p /home/couch/.ssh
cp /root/.ssh/authorized_keys /home/couch/.ssh/authorized_keys
chown -R couch:couch /home/couch/.ssh
chmod 700 /home/couch

# Configure bashrc
echo "alias node=nodejs" >> /home/couch/.bashrc
echo "curlpp(){ curl $@ 2>/dev/null | jq; }" >> /home/couch/.bashrc
cp /root/.profile /home/couch/.profile
chown couch:couch /home/couch/.bashrc /home/couch/.profile


# Install software
# source: https://launchpad.net/~couchdb/+archive/ubuntu/stable
echo "Installing CouchDB and dependencies..."
apt-get install software-properties-common -y &>/dev/null
add-apt-repository ppa:couchdb/stable -y &>/dev/null
apt-get update &>/dev/null
apt-get install build-essential jq ruby couchdb ruby1.9.1-dev ruby-libxml nodejs -y &>/dev/null
gem install couchrest &>/dev/null

# upstart
stop couchdb > /dev/null
start couchdb > /dev/null

#check for reboot
if [ -f /var/run/reboot-required ]; then
  echo "A reboot is required ..." 1>&2
  echo "Please allow time for reboot to finish before SSH'ing." 1>&2
  reboot
fi

