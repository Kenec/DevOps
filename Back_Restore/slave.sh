#!/bin/bash
[[ ! -d /home/ec2-user/.ssh ]] && (mkdir /home/ec2-user/.ssh && chmod 644 /home/ec2-user/.ssh)
echo $'Host *\nStrictHostKeyChecking no\nHost 10.203.10.79\nIdentityFile ~/.ssh/cdr-pcs.pem' > /home/ec2-user/.ssh/config 
chmod 644 /home/ec2-user/.ssh/config
cat <<EOF >/home/ec2-user/.ssh/cdr-pcs.pem
-----BEGIN RSA PRIVATE KEY-----
...your ssh key contents here....
-----END RSA PRIVATE KEY-----
EOF
chmod 400 /home/ec2-user/.ssh/cdr-pcs.pem
chown ec2-user:ec2-user /home/ec2-user -R
echo $'* * * * * ec2-user rsync -avz 10.203.10.79:/var/www/html/upload/ /var/www/html/upload/' >> /etc/crontab
echo $'<VirtualHost *:80>\n\tServerName *\n\tProxyPass\t/ http://10.203.10.79/\n\tProxyPassReverse / http://10.203.10.79/\n</VirtualHost>' >> /etc/httpd/conf.d/php.conf
service httpd restart