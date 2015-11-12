#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y apache2 git php5 php5-curl mysql-client curl php5-mysql 

git clone https://github.com/Malhoura/itmo-544-444-Application-setup.git

mv ./itmo-544-444-Application-setup/images /var/www/html/images
mv ./itmo-544-444-Application-setup/index.html /var/www/html
mv ./itmo-544-444-Application-setup/*.php /var/www/html

curl -sS https://getcomposer.org/installer | sudo php &> /tmp/getcomposer.txt

sudo php composer.phar require aws/aws-sdk-php &> /tmp/runcomposer.txt

sudo mv vendor /var/www/html &> /tmp/movevendor.txt

sudo php /var/www/html/setup.php &> /tmp/database-setup.txt

echo "Hello" > /tmp/hello.txt 
