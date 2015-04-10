#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
sudo apt-get -y update

# install Python
sudo apt-get -y install python-setuptools
# install DJango
sudo easy_install django
# install Apache
sudo apt-get -y install apache2 libapache2-mod-wsgi

# write some PHP
#echo \<center\>\<h1\>My Demo App\</h1\>\<br/\>\</center\> > /var/www/html/phpinfo.php
#echo \<\?php phpinfo\(\)\; \?\> >> /var/www/html/phpinfo.php

# restart Apache
#apachectl restart
