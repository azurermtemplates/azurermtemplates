#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
sudo apt-get -y update

# install Python
sudo apt-get -y install python-setuptools

# install DJango
sudo easy_install django

# install Apache
sudo apt-get -y install apache2 libapache2-mod-wsgi

# create a django app
cd /var/www
sudo django-admin startproject helloworld

# Create a new file named views.py in the /var/www/helloworld/helloworld directory. This will contain the view that renders the "hello world" page
echo -e 'from django.http import HttpResponse
def home(request):
    html = "<html><body>Hello World!</body><html>"
    return HttpResponse(html)' | sudo tee /var/www/helloworld/helloworld/views.py

# Update urls.py
echo -e "from django.conf.urls import patterns, url
          urlpatterns = patterns('',
            url(r'^$', 'helloworld.views.home', name='home'),
        )"   | sudo tee /var/www/helloworld/helloworld/urls.py

# Setup Apache
echo -e "<VirtualHost *:80>
ServerName $1
</VirtualHost>
WSGIScriptAlias / /var/www/helloworld/helloworld/wsgi.py
WSGIPythonPath /var/www/helloworld" | sudo tee /etc/apache2/sites-available/helloworld.conf

#enable site
sudo a2ensite helloworld

#restart apache
sudo service apache2 reload
