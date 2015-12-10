#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y php5 php5-imagick apache2 git php5-curl mysql-client curl php5-mysql 
sudo service apache2 reload
sudo apt-get install libmagickwand-dev
curl -sS https://getcomposer.org/installer | sudo php &> /tmp/getcomposer.txt
sudo php composer.phar require aws/aws-sdk-php &> /tmp/runcomposer.txt
cp -R vendor/ /var/www/html
git clone https://github.com/Malhoura/itmo-544-444-Application-setup.git
mv ./itmo-544-444-Application-setup/images /var/www/html/images
mv ./itmo-544-444-Application-setup/index.html /var/www/html
mv ./itmo-544-444-Application-setup/*.php /var/www/html
cp -R itmo-544-444-Application-setup/* /var/www/html/
sudo php /var/www/html/setup.php &> /tmp/database-setup.txt
chmod 755 /var/www/html/setup.php
mkdir /var/www/html/uploads
chmod 755 /var/www/html/uploads
chmod 777 /var/www/html/uploads
chmod 700 /var/www/html/uploads
rm /var/www/html/index.html
