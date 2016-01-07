apt-get update
export DEBIAN_FRONTEND=noninteractive 
apt-get upgrade -y
apt-get install postgresql postgresql-contrib vim -y
cd /tmp
sudo -u postgres psql -c "create extension cube;"
sudo -u postgres psql -c "create extension tablefunc;"
sudo -u postgres psql -c "create extension dict_xsyn;"
sudo -u postgres psql -c "create extension fuzzystrmatch;"
sudo -u postgres psql -c "create extension pg_trgm;"
