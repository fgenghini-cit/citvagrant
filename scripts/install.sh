#!/usr/bin/env bash

echo ">>> Start provisioning the install file"

sudo add-apt-repository ppa:ondrej/php5-"${VAGRANT_PHP_VERSION}"

sudo apt-get update

sudo apt-get install -y \
vim \
curl \
build-essential \
python-software-properties \
git-core \
nfs-common \
portmap \
mysql-server \
mysql-client \
apache2 \
libapache2-mod-php5 \
php5 \
php5-cli \
php5-mysql \
php5-curl \
php5-gd \
php5-imagick \
php5-mcrypt \
php5-xdebug \
php5-dev \
php-pear \
php5-intl \
php5-json \
php5-imap \
php5-oauth \
php5-readline \
imagemagick

# Install composer global
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chown vagrant.vagrant /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

# Install drush
sudo -H -u vagrant bash -c "composer global require drush/drush:${VAGRANT_DRUSH_VERSION}"

# Install coder and code sniffer
sudo -H -u vagrant bash -c "composer global require drupal/coder:${VAGRANT_CODER_VERSION}"
sudo ln -s /home/vagrant/.composer/vendor/bin/phpcs /usr/local/bin
sudo ln -s /home/vagrant/.composer/vendor/bin/phpcbf /usr/local/bin
phpcs --config-set installed_paths /home/vagrant/.composer/vendor/drupal/coder/coder_sniffer
echo "alias drupalcs=\"phpcs --standard=Drupal\"" | sudo tee -a /home/vagrant/.bashrc
echo "alias drupal-debug-theme=\"drush vset theme_debug\"" | sudo tee -a /home/vagrant/.bashrc
