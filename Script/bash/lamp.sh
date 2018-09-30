#!/usr/bin/env bash

sudo yum update -y
sudo yum install -y httpd24 php56 mysql55-server php56-mysqlnd
sudo groudadd wwww
usermod -a -G www ec2-user
chown -R root:www /var/www
chmod 2755 /var/www
find /var/www -type d -exec chmod 2775 {} +
find /var/www -type f -exec chomd 0664 {} +
echo "<?php phpinfo(); ?>" > /var/www/html/index.php
service httpd start
chkconfig httpd on
