#!/bin/bash

sudo apt-get -y update
sudo apt-get install -y apache2 git

git clone https://github.com/Malhoura/itmo-544-444-Application-setup.git

mv ./itmo-544-444-Application-setup/images /var/www/html/images
mv ./itmo-544-444-Application-setup/index.html /var/www/html
mv ./itmo-544-444-Application-setup/page2.html /var/www/html

echo "Mazen Al Hourani /tmp/hello.txt
