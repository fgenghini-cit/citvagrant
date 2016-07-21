#!/usr/bin/env bash

source /files/scripts/variables.sh

echo ">>> Start provisioning the install file"

# Config locale
echo -e "en_US.UTF-8 UTF-8\npt_BR ISO-8859-1\npt_BR.UTF-8 UTF-8" | sudo tee /var/lib/locales/supported.d/local
sudo dpkg-reconfigure locales

sudo add-apt-repository ppa:ondrej/php -y
sudo add-apt-repository ppa:ondrej/apache2 -y

sudo apt-get update
sudo apt-get install php5.6 -y
sudo apt-get install git-core -y

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt-get install mysql-server -y
sudo apt-get install mysql-client -y

sudo apt-get install apache2 -y
sudo apt-get install libapache2-mod-php5.6 -y

sudo apt-get install php5.6-mysql -y
sudo apt-get install php5.6-curl -y
sudo apt-get install php5.6-gd -y
sudo apt-get install php5.6-imagick -y
sudo apt-get install php5.6-mcrypt -y
sudo apt-get install php5.6-dev -y
sudo apt-get install php5.6-imap -y
sudo apt-get install php5.6-xdebug -y
sudo apt-get install php5.6-xml -y

sudo apt-get install unzip -y

# Install composer global
echo ">>> installing composer"
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chown vagrant:vagrant /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

# Install drush
sudo -H -u vagrant bash -c 'composer global require "drush/drush":"'$VAGRANT_DRUSH_VERSION'"'

echo "export PATH=\"/home/vagrant/.composer/vendor/bin:\$PATH\"" | sudo tee -a /home/vagrant/.bashrc
source /home/vagrant/.bashrc

# Install coder and code sniffer
sudo -H -u vagrant bash -c 'composer global require "drupal/coder":"'${VAGRANT_CODER_VERSION}'"'
sudo ln -s /home/vagrant/.composer/vendor/bin/phpcs /usr/local/bin
sudo ln -s /home/vagrant/.composer/vendor/bin/phpcbf /usr/local/bin
phpcs --config-set installed_paths /home/vagrant/.composer/vendor/drupal/coder/coder_sniffer

# download coder module
#drush -vy dl coder-7.x-2.5 --destination=/home/vagrant/.drush/

# Clear drush cache
#drush cache-clear drush