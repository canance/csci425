#!/usr/bin/env bash
#title           :init.sh
#description     :This script will provision ubuntu 14.04 with mongodb, download book source code, and setup the environment.
#author		 :Cory Nance
#date            :20160309
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
cd /home/mongo
sudo -u mongo wget http://media.pragprog.com/titles/rwdata/code/rwdata-code.tgz 2>&1
sudo -u mongo tar xvf rwdata-code.tgz code/mongo --strip-components=2
rm rwdata-code.tgz

# copy authorized_keys
mkdir -p /home/mongo/.ssh
cp /root/.ssh/authorized_keys /home/mongo/.ssh/authorized_keys
chown -R mongo:mongo /home/mongo/.ssh
chmod 700 /home/mongo

# Install software
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo  "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
apt-get update && apt-get install mongodb-org -y

# Patch mongod.conf
cat > /tmp/mongod.patch << EOF 
24a25,30
>   if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
>     echo never > /sys/kernel/mm/transparent_hugepage/enabled
>   fi
>   if test -f /sys/kernel/mm/transparent_hugepage/defrag; then
>     echo never > /sys/kernel/mm/transparent_hugepage/defrag
>   fi
EOF
patch /etc/init/mongod.conf /tmp/mongod.patch
rm /tmp/mongod.patch

# check for reboot
if [ -f /var/run/reboot-required ]; then
  echo "A reboot is required ..." 1>&2
  echo "Please allow time for reboot to finish before SSH'ing." 1>&2
  reboot
fi

