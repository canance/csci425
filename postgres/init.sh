#!/usr/bin/env bash
#title           :init.sh
#description     :This script will provision ubuntu 15.10 with postgreSQL, download book source code, as well as supplemental files.
#author		 :Cory Nance
#date            :20160131
#version         :0.3    
#usage		 :bash init.sh



# Update
export DEBIAN_FRONTEND=noninteractive 
apt-get update
apt-get upgrade -y

# Install PostgreSQL
apt-get install postgresql postgresql-contrib vim -y

# Configure SSH
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
systemctl restart sshd.service

# Configure PostgreSQL to listen on localhost:5432
sed -i 's/#listen_addresses/listen_addresses/g' /etc/postgresql/9.4/main/postgresql.conf
systemctl restart postgresql.service

# Setup book and extensions
cd /tmp
sudo -u postgres createdb book
sudo -u postgres psql book -c "create extension cube;"
sudo -u postgres psql book -c "create extension tablefunc;"
sudo -u postgres psql book -c "create extension dict_xsyn;"
sudo -u postgres psql book -c "create extension fuzzystrmatch;"
sudo -u postgres psql book -c "create extension pg_trgm;"

# Set postgres password
sudo -u postgres psql book -c "ALTER User postgres WITH PASSWORD 'csci425';"

# Download book code
cd /home/postgres
wget http://media.pragprog.com/titles/rwdata/code/rwdata-code.tgz
tar xvf rwdata-code.tgz code/postgres --strip-components=2
chown postgres:postgres *.sql
rm rwdata-code.tgz

# copy authorized_keys
mkdir /home/postgres/.ssh
cp /root/.ssh/authorized_keys /home/postgres/.ssh/authorized_keys
chown -R postgres:postgres /home/postgres/.ssh

# fix permissions on home dir
chmod 700 /home/postgres
