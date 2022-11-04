#!/usr/bin/bash

# remove postgres if it exist
#sudo apt-get --purge remove postgresql -y

# Update Server Package
sudo apt update

# Install Postgresql
sudo apt install postgresql postgresql-contrib -y

# Start postgresql service
sudo systemctl start postgresql.service

# Create password for postgres user
sudo -i -u postgres psql -c"ALTER user postgres WITH PASSWORD 'password'"

# Create Database
# sudo -u postgres createdb ridwan
sudo -u postgres psql -c"SELECT 1 FROM pg_database WHERE datname = 'database_name'" | grep -q 1 || sudo -u postgres psql -c"CREATE DATABASE ridwan"
