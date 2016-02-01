#!/usr/bin/env bash
#title           :init.sh
#description     :This script will provision ubuntu 14.04 with riak, download book source code, as well as supplemental files.
#author		 :Cory Nance
#date            :20160131
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

# Increase ulimit
echo "* hard nofile 65536" >> /etc/security/limits.conf
echo "* soft nofile 4096" >> /etc/security/limits.conf
echo "session    required   pam_limits.so" >> /etc/pam.d/common-session
echo "session    required   pam_limits.so" >> /etc/pam.d/common-session-noninteractive

# Install software
apt-get install git erlang libssl-dev build-essential libpam0g-dev iptables-persistent ruby -y

# Download and build riak
su - riak << EOSU
# Clone repo
git clone https://github.com/basho/riak.git
cd riak

# Build
make devrel
EOSU

# Download book code
cd /home/riak
wget http://media.pragprog.com/titles/rwdata/code/rwdata-code.tgz
tar xvf rwdata-code.tgz code/riak --strip-components=2
chown riak:riak *
rm rwdata-code.tgz

# copy authorized_keys
mkdir -p /home/riak/.ssh
cp /root/.ssh/authorized_keys /home/riak/.ssh/authorized_keys
chown -R riak:riak /home/riak/.ssh
chmod 700 /riak/home

# add eXecute bit to dev scripts
chmod +x {start_,stop_}dev.sh

# iptables rules to match ports used in book
iptables -t nat -A OUTPUT -p tcp -d 127.0.0.0/8 --dport 8091 -j REDIRECT --to-port 10018
iptables -t nat -A OUTPUT -p tcp -d 127.0.0.0/8 --dport 8092 -j REDIRECT --to-port 10028
iptables -t nat -A OUTPUT -p tcp -d 127.0.0.0/8 --dport 8093 -j REDIRECT --to-port 10038
invoke-rc.d iptables-persistent save

# Download antibotics img
cd /home/riak
sudo -u riak wget http://www.naumik.com/3d/antibiotics.jpg

# Install riak and json driver
gem install riak-client json

# Fix hotels.rb
# :http-port no longer a valid option, instead use pb_port
# Keynames are required to be strings
# https://stackoverflow.com/questions/33170823/ruby-script-hangs-when-storing-riak-object
sed -i 's/http_port => 8091/pb_port => 10017/g' hotel.rb
sed -i 's/(current_rooms_block + room)/"#{current_rooms_block + room}"/g' hotel.rb
