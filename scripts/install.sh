#!/usr/bin/env bash

source /files/scripts/variables.sh

echo ">>> Start provisioning the install file"

# Config locale
echo -e "en_US.UTF-8 UTF-8\npt_BR ISO-8859-1\npt_BR.UTF-8 UTF-8" | sudo tee /var/lib/locales/supported.d/local
sudo dpkg-reconfigure locales

sudo add-apt-repository ppa:ondrej/php -y
sudo add-apt-repository ppa:ondrej/apache2 -y

sudo apt-get update

echo ">>> Installing PHP 5.6"
sudo apt-get install php5.6 -y

echo ">>> Installing Git"
sudo apt-get install git-core -y

echo ">>> Installing MySQL"
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt-get install -y \
mysql-server \
mysql-client

echo ">>> Installing PHP extensions"
sudo apt-get install -y \
php5.6-mysql \
php5.6-curl \
php5.6-gd \
php5.6-imagick \
php5.6-mcrypt \
php5.6-dev \
php5.6-imap \
php5.6-xdebug \
php5.6-xml

echo ">>> Installing usefull stuff"
sudo apt-get install -y \
unzip

echo ">>> Installing Composer global"
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chown vagrant:vagrant /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

echo ">>> Installing Drush"
sudo -H -u vagrant bash -c 'composer global require "drush/drush":"'$VAGRANT_DRUSH_VERSION'"'
echo "export PATH=\"/home/vagrant/.composer/vendor/bin:\$PATH\"" | sudo tee -a /home/vagrant/.bashrc
source /home/vagrant/.bashrc

echo ">>> Installing Coder and Code Sniffer"
sudo -H -u vagrant bash -c 'composer global require "drupal/coder":"'${VAGRANT_CODER_VERSION}'"'
sudo ln -s /home/vagrant/.composer/vendor/bin/phpcs /usr/local/bin
sudo ln -s /home/vagrant/.composer/vendor/bin/phpcbf /usr/local/bin
phpcs --config-set installed_paths /home/vagrant/.composer/vendor/drupal/coder/coder_sniffer

# download coder module
#drush -vy dl coder-7.x-2.5 --destination=/home/vagrant/.drush/

# Clear drush cache
# drush cache-clear drush
