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
apt-get install git libssl-dev build-essential libpam0g-dev libncurses5-dev ruby ruby-dev -y

# Download, build, and install erlang-R14B02
cd /tmp
wget http://erlang.org/download/otp_src_R14B02.tar.gz
tar xf otp_src_R14B02.tar.gz 
cd otp_src_R14B02/
./configure
make
make install

# Download and build riak dev
su - riak << EOSU
# Clone repo
git clone -b 1.0.2-release https://github.com/basho/riak.git
cd riak

# Build
make
make devrel
EOSU

# Download book code
cd /home/riak
sudo -u riak wget http://media.pragprog.com/titles/rwdata/code/rwdata-code.tgz
tar xvf rwdata-code.tgz code/riak --strip-components=2
sudo -u riak wget http://www.naumik.com/3d/antibiotics.jpg
rm rwdata-code.tgz

# copy authorized_keys
mkdir -p /home/riak/.ssh
cp /root/.ssh/authorized_keys /home/riak/.ssh/authorized_keys
chown -R riak:riak /home/riak/.ssh
chmod 700 /home/riak

# add eXecute bit to dev scripts
chmod +x {start_,stop_}dev.sh

# Install riak and json driver
gem install riak-client -v 1.0.2
gem install json
