#!/usr/bin/env bash

source variables.sh

echo ">>> Start provisioning"

# Config to allow mysql installation
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

echo ">>> Installing..."

# Locale do sistema
echo -e "en_US.UTF-8 UTF-8\npt_BR ISO-8859-1\npt_BR.UTF-8 UTF-8" | sudo tee /var/lib/locales/supported.d/local
sudo dpkg-reconfigure locales

# PHP 5.6
sudo add-apt-repository ppa:ondrej/php5-5.6

# Update Again
sudo apt-get update

# Install the Rest
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

echo ">>> Instalando composer"
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chown vagrant.vagrant /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

# instalando Drush
sudo -H -u vagrant bash -c 'composer global require drush/drush:8.*'

# instalando coder + Code Sniffer
sudo -H -u vagrant bash -c 'composer global require drupal/coder:~8.2.3'
sudo ln -s /home/vagrant/.composer/vendor/bin/phpcs /usr/local/bin
sudo ln -s /home/vagrant/.composer/vendor/bin/phpcbf /usr/local/bin
phpcs --config-set installed_paths /home/vagrant/.composer/vendor/drupal/coder/coder_sniffer
echo "alias drupalcs=\"phpcs --standard=Drupal\"" | sudo tee -a /home/vagrant/.bashrc
echo "alias drupal-debug-theme=\"drush vset theme_debug\"" | sudo tee -a /home/vagrant/.bashrc

# acertando CodeSniffer
sudo -H -u vagrant bash -c 'ln -s /home/vagrant/.composer/vendor/drupal/coder/coder_sniffer/Drupal /home/vagrant/.composer/vendor/squizlabs/php_codesniffer/CodeSniffer/Standards/Drupal'
sudo -H -u vagrant bash -c 'ln -s /home/vagrant/.composer/vendor/drupal/coder/coder_sniffer/drupalcs.drush.inc /home/vagrant/.composer/vendor/squizlabs/php_codesniffer/CodeSniffer/Standards/drupalcs.drush.inc'
sudo -H -u vagrant bash -c 'ln -s /home/vagrant/.composer/vendor/drupal/coder/coder_sniffer/DrupalPractice /home/vagrant/.composer/vendor/squizlabs/php_codesniffer/CodeSniffer/Standards/DrupalPractice'
sudo -H -u vagrant bash -c 'mkdir /home/vagrant/.app/'
sudo -H -u vagrant bash -c 'git clone --branch master http://git.drupal.org/sandbox/coltrane/1921926.git /home/vagrant/.app/drupalsecure_code_sniffs'
sudo -H -u vagrant bash -c 'ln -s /home/vagrant/.app/drupalsecure_code_sniffs/DrupalSecure /home/vagrant/.composer/vendor/squizlabs/php_codesniffer/CodeSniffer/Standards/DrupalSecure'

sudo chown -R vagrant.vagrant /home/vagrant/.app
sudo chown -R vagrant.vagrant /home/vagrant/.composer

sudo -H -u vagrant bash -c 'cd /files/docroot/sites && /home/vagrant/.composer/vendor/bin/drush dl registry_rebuild -y && /home/vagrant/.composer/vendor/bin/drush cache-clear drush'

