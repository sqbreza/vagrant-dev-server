#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

installpkg(){
    dpkg-query --status $1 >/dev/null || apt-get install -y $1
}

installMariaDB(){
	sudo apt-get install software-properties-common
	sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
	sudo add-apt-repository 'deb [arch=amd64,i386] http://ftp.yz.yamagata-u.ac.jp/pub/dbms/mariadb/repo/10.1/ubuntu trusty main'
	apt-get update
}

installComnposer(){
	echo -e "\n--- Installing Composer for PHP package management ---\n"
	curl --silent https://getcomposer.org/installer | php > /dev/null 2>&1
	mv composer.phar /usr/local/bin/composer
}

installPHP(){
	sudo add-apt-repository ppa:ondrej/php5-5.6
	apt-get update
	sudo apt-get install python-software-properties
	apt-get update
}

installMongoDB(){
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
	echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
	sudo apt-get update
	sudo apt-get install -y mongodb-org
	
}

installNodeNPM(){
	sudo apt-get update
	sudo apt-get install -y nodejs
	sudo apt-get install -y npm
}

# Update
apt-get update

# PHP
echo "----- Provision: Installing php..."
installPHP
installpkg php5

# Redis Server
echo "----- Provision: Installing redis-server..."
installpkg redis-server

# Mariadb Server
echo "----- Provision: Installing mariadb..."
installMariaDB
installpkg mariadb-client
installpkg mariadb-server

# Composer
echo "----- Provision: Installing composer..."
installComnposer

# MongoDB
echo "----- Provision: Installing MongoDB..."
installMongoDB

# Apache
echo "----- Provision: Installing apache..."
installpkg apache2 apache2-utils
echo "ServerName localhost" > "/etc/apache2/conf-available/server.conf"
a2enconf server
a2enmod rewrite
a2dissite 000-default.conf

#echo "----- Provision: Setup /var/www to point to /vagrant ..."
#rm -rf /var/www
#ln -fs /vagrant /var/www

# Apache / Virtual Host Setup
echo "----- Provision: Install Host File..."
cp /vagrant/vm_provision/hostfile /etc/apache2/sites-available/project.conf
a2ensite project.conf


#Apache startup script
echo "----- Provision: Install Auto Start Apache"
cp /vagrant/vm_provision/httpd.conf /etc/init/httpd.conf

# Cleanup
installpkg autoremove

# Restart Apache
echo "----- Provision: Restarting Apache..."
service apache2 restart