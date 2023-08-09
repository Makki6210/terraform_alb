#!/bin/bash
yum update -y

## Apache Setup
yum install -y httpd
chown -R apache:apache /var/www/html
systemctl start httpd
systemctl enable httpd
uname -n > /var/www/html/index.html
mkdir /var/www/html/static/
cp /var/www/html/index.html /var/www/html/static/index.html