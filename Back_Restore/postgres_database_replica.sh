#1/usr/bin/env bash

set -o errexit

download_postgres() {
  # add the Postgres 9.6 repository to the source.list.d directory
  echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' | tee /etc/apt/sources.list.d/postgresql.list
  # Dowload PostgresSQL key to the system
  wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
  # Update the system repository
  sudo apt-get update
  # Install the PostgresSQL 9.6 package
  sudo apt-get install -y postgresql-9.6 postgresql-contrib-9.6
  # Start automatically at boot time
  systemctl enable postgresql
  # check the IP on which the postgres is running
  netstat -plntu
  # Change the password of the postgres
  # su - postgres
  # psql
  # \password postgres
  # \conninfo

  # Edit the postgres configuration file
  sudo vi /etc/postgresql/9.6/main/postgresql.conf # find the listen_address and change to the IP that it will listen to

  # Edit the pg_hba inorder to allow the IP that can connect to it
  sudo vi /etc/postgresql/9.6/main/pg_hba.conf # find the 127.0.0.1/32 and change it to the IP range that can connect to the database

  # Restart the postgres server
  sudo systemctl restart postgresql

  # Create a replication Role so that the slave can use it to connect to the master
  sudo su postgres # run psql and then CREATE ROLE replication WITH REPLICATION PASSWORD 'password' LOGIN;

  # Start the replication setup
  sudo vi /etc/postgresql/9.6/main/postgresql.conf
  # wal_level = hot_standby
  # max_wal_senders = 5
  # wal_keep_segment = 32
  # archive_mode = on
  # archive_command = 'cp %p /var/lib/postgresql/9.6/archive/%f' 

  # make archive directory
  mkdir /var/lib/postgresql/9.6/archive

  # change the owner and group od the archive to postgres
  sudo chown postgres.postgres /var/lib/postgresql/9.6/archive/

  # Add the replication user to the pg_hba.conf
  sudo vi /etc/postgresql/9.6/main/pg_hba.conf # host replication replication SLAVE_IP md5

  # Restart the postgres 
  sudo systemctl start postgresql

}

# slave 
slave() {
  # remove the data in the slave database
  sudo rm -rf /var/lib/postgresql/9.6/main/*

  # login with postgres user
  sudo su postgres

  # take a backup of the master
  pg_basebackup -h 52.90.248.191 -D /var/lib/postgresql/9.6/main -P -U replication --xlog-method=stream

  # tell slave to coninously pull data from the master
  sudo vi /etc/postgresql/9.6/main/postgresql.conf # set hot_standby = on

  sudo vi /var/lib/postgresql/9.6/main/recovery.conf

  # standby_mode = 'on'
  # primary_conninfo = 'host=52.90.248.191 port=5432 user=replication password=password'
  # trigger_file = '/var/lib/postgresql/9.6/trigger'
  # restore_command = 'cp /var/lib/postgresql/9.6/archive/%f "%p"'
  


}
