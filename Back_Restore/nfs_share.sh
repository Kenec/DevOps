#!/bin/bash

sudo yum install -y nfs-utils nfs-utils-lib >/dev/null 2>&1
sudo mkdir /opt/shared && echo $'/opt/shared 0.0.0.0/0.0.0.0(rw,sync,no_root_squash,no_subtree_check)' | sudo tee -a /etc/exports/opt/shared 0.0.0.0/0.0.0.0(rw)
for i in rpcbind nfs nfslock; do sudo service $i start; done
sudo exportfs –a
