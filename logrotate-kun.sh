#!/bin/bash
set -ex

if [ -f /var/log/mysql/mysqld-slow.log ]; then
    sudo mv /var/log/mysql/mysqld-slow.log /var/log/mysql/mysqld-slow.log.$(date "+%Y%m%d_%H%M%S")
fi
if [ -f /var/log/nginx/access_log.tsv ]; then
    sudo mv /var/log/nginx/access_log.tsv /var/log/nginx/access_log.tsv.$(date "+%Y%m%d_%H%M%S")
fi

#sudo systemctl restart mysql
sudo systemctl restart isucondition.ruby.service
sudo systemctl restart nginx
