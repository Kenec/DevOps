#!/bin/bash

master() {
  sudo yum install -y mysql mysql-server >/dev/null 2>&1
  sudo sed -i.bak 's/\[mysqld\]/[mysqld]\nlog-bin=mysql-bin\nserver-id=1/g' /etc/my.cnf
  sudo service mysqld start >/dev/null 2>&1
  mysqladmin -u root password 'abc1234!'
  cat <<EOF | mysql -uroot -pabc1234\!
        GRANT SELECT, PROCESS, REPLICATION CLIENT, REPLICATION SLAVE, RELOAD ON *.*  TO 'repl' IDENTIFIED BY 'slavepass';
        GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY 'abc1234!';
        FLUSH PRIVILEGES;
        FLUSH TABLES WITH READ LOCK;
        SHOW MASTER STATUS;
        UNLOCK TABLES;
EOF
}

slave() {
  sudo yum install -y mysql mysql-server >/dev/null 2>&1
  sudo sed -i.bak 's/\[mysqld\]/[mysqld]\nlog-bin=mysql-bin\nserver-id=2/g' /etc/my.cnf
  sudo service mysqld start >/dev/null 2>&1
  mysqladmin -u root password 'abc1234!'
  cat <<EOF | mysql -uroot -pabc1234\!
      CHANGE MASTER TO MASTER_HOST='10.203.30.61', MASTER_USER='repl', MASTER_PASSWORD='slavepass', MASTER_LOG_FILE='mysql-bin.000003', MASTER_LOG_POS=637;
      start slave;
EOF
mysql -uroot -pabc1234\! -e 'show slave status\G' | grep Slave_IO_State
}

create_database_and_populate_master() {
  cat <<EOF | mysql -uroot -pabc1234\!
      create database mydb;
      use mydb;
      create table people (
      id INT AUTO_INCREMENT PRIMARY KEY,
      firstname varchar(50),
      lastname varchar(50)
    );
EOF

for i in {1..10}; do
  random_text=$(tr -dc a-z0-9 </dev/urandom | tr 0-9 ' \n' | sed 's/^ *//' | fmt | grep -E '[a-z]+\s[a-z]+' | head -n 1)
  first_name=$(echo $random_text | awk '{print $1}')
  last_name=$(echo $random_text | awk '{print $2}')
  cat <<EOF | mysql -uroot -pabc1234\! mydb
  insert into people (firstname, lastname) values ('$first_name', '$last_name');
EOF
done

mysql -uroot -pabc1234\! mydb -e 'select count(*) from files;'
}