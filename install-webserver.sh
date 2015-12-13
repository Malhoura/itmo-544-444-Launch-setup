#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y php5 php5-imagick apache2 git php5-curl mysql-client curl php5-mysql 
sudo apt-get apache2 reload
sudo apt-get install libmagickwand-dev
curl -sS https://getcomposer.org/installer | sudo php &> /tmp/getcomposer.txt
sudo php composer.phar require aws/aws-sdk-php &> /tmp/runcomposer.txt
cp -R vendor/ /var/www/html
git clone https://github.com/Malhoura/itmo-544-444-Application-setup.git
cp -R itmo-544-444-Application-setup/* /var/www/html/
sudo php /var/www/html/setup.php &> /tmp/database-setup.txt
chmod 600 /var/www/html/setup.php
mkdir /var/www/html/uploads
mkdir /var/www/html/uploads/thumb_
sudo chmod -R 0755 /var/www/html/uploads
sudo chmod -R 0755 /var/www/html/uploads/thumb_
chmod 777 /var/www/html/uploads
sudo chown nobody /var/www/html/uploads
rm /var/www/html/index.html
