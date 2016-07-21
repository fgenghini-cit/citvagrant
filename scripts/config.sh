#!/usr/bin/env bash

echo ">>> Configurando o servidor"

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

# Set MySQL password
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

# Locale system
echo -e "en_US.UTF-8 UTF-8\npt_BR ISO-8859-1\npt_BR.UTF-8 UTF-8" | sudo tee /var/lib/locales/supported.d/local
sudo dpkg-reconfigure locales

# Configura XDebug
cat << EOF | sudo tee -a /etc/php5/apache2/conf.d/xdebug.ini
xdebug.scream=0
xdebug.cli_color=1
xdebug.show_local_vars=1
xdebug.max_nesting_level=250

xdebug.remote_enable = on
xdebug.remote_connect_back = on
xdebug.idekey = "vagrant"
EOF

# Define para exibir todos os erros, warnings e notices
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL \& ~E_STRICT/" /etc/php5/cli/php.ini

sudo sed -i "s/html_errors = .*/html_errors = On/" /etc/php5/apache2/php.ini

sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/cli/php.ini

sudo sed -i "s/memory_limit = .*/memory_limit = ${VAGRANT_PHP_MEMORY_LIMIT}/" /etc/php5/apache2/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = ${VAGRANT_PHP_MEMORY_LIMIT}/" /etc/php5/cli/php.ini

sudo sed -i "s/max_execution_time = .*/max_execution_time = ${VAGRANT_PHP_MAX_EXECUTION_TIME}/" /etc/php5/apache2/php.ini
sudo sed -i "s/max_execution_time = .*/max_execution_time = ${VAGRANT_PHP_MAX_EXECUTION_TIME}/" /etc/php5/cli/php.ini

# http://stackoverflow.com/questions/6156259/sed-expression-dont-allow-optional-grouped-string
sudo sed -r -i "s,;?date.timezone =.*,date.timezone = ${VAGRANT_PHP_TIMEZONE}," /etc/php5/apache2/php.ini
sudo sed -r -i "s,;?date.timezone =.*,date.timezone = ${VAGRANT_PHP_TIMEZONE}," /etc/php5/cli/php.ini

sudo sed -i "s/post_max_size = .*/post_max_size = ${VAGRANT_PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
sudo sed -i "s/post_max_size = .*/post_max_size = ${VAGRANT_PHP_POST_MAX_SIZE}/" /etc/php5/cli/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = ${VAGRANT_PHP_UPLOAD_MAX_FILE_SIZE}/" /etc/php5/apache2/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = ${VAGRANT_PHP_UPLOAD_MAX_FILE_SIZE}/" /etc/php5/cli/php.ini

# MySQL Config
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf
sudo mysql --password=root -u root --execute="GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES;"
sudo service mysql restart

# cria arquivo com credenciais do MySQL - ele não pedirá mais a senha
MYCNFFILE=$(cat <<EOF
[client]
user=root
password=root

[mysqldump]
user=root
password=root
EOF
)
echo "${MYCNFFILE}" > /home/vagrant/.my.cnf
chmod 0600 /home/vagrant/.my.cnf
sudo chown vagrant /home/vagrant/.my.cnf

# Apache Config

# altera usuário que roda o apache
sudo sed -i 's/User ${APACHE_RUN_USER}/User vagrant/g' /etc/apache2/apache2.conf
sudo sed -i 's/Group ${APACHE_RUN_GROUP}/Group vagrant/g' /etc/apache2/apache2.conf

sudo a2enmod rewrite

sudo a2dissite 000-default
VHOST=$(cat <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    #ServerName vagrant.cfn

    DocumentRoot /var/www/others/

    <Directory /var/www/others/>
         RewriteBase /
         Options Indexes FollowSymLinks
         AllowOverride All
         Order allow,deny
         allow from all
    </Directory>


    # Possible values include: debug, info, notice, warn, error, crit,
    # alert, emerg.
    LogLevel warn

    CustomLog /var/log/apache2/access.log combined
    ErrorLog /var/log/apache2/error.log

</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/others.conf
sudo a2ensite others.conf

VHOST=$(cat <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName easysite.vagrant.cfn
    ServerAlias easysite.cfn

    DocumentRoot /var/www/cfn/

    <Directory /var/www/cfn/>
         RewriteBase /
         Options Indexes FollowSymLinks
         AllowOverride All
         Order allow,deny
         allow from all
    </Directory>


    # Possible values include: debug, info, notice, warn, error, crit,
    # alert, emerg.
    LogLevel warn

    CustomLog /var/log/apache2/access.log combined
    ErrorLog /var/log/apache2/error.log

</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/easysite.conf
sudo a2ensite easysite.conf

VHOST=$(cat <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName advisor1.vagrant.cfn
    ServerAlias advisor1.cfn
    ServerAlias advisor2.vagrant.cfn
    ServerAlias advisor3.vagrant.cfn
    ServerAlias advisor4.vagrant.cfn
    ServerAlias advisor.vagrant.cfn

    DocumentRoot /var/www/cfn/

    <Directory /var/www/cfn/>
         RewriteBase /
         Options Indexes FollowSymLinks
         AllowOverride All
         Order allow,deny
         allow from all
    </Directory>


    # Possible values include: debug, info, notice, warn, error, crit,
    # alert, emerg.
    LogLevel warn

    CustomLog /var/log/apache2/access.log combined
    ErrorLog /var/log/apache2/error.log

</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/advisor.conf
sudo a2ensite advisor.conf



echo ">>> Inicializando aplicação"
sudo ln -sf /files/vagrant/others /var/www/others
sudo ln -sf /files/docroot /var/www/cfn
sudo chown vagrant.vagrant /var/www/ -R

echo "<?php  phpinfo(); ?>" > /var/www/others/info.php

sudo service apache2 restart

# Ao efetuar login, já entra no diretório '/files'
echo "cd /files" | sudo tee -a /home/vagrant/.bashrc

echo ">>> Provisionamento realizado com sucesso"


sudo ln -sf /files/vagrant/bin /home/vagrant/bin
sudo chown -R vagrant.vagrant /home/vagrant/bin
sudo chmod +x /home/vagrant/bin/*
echo "export PATH=\"/home/vagrant/.composer/vendor/bin:/home/vagrant/bin:\$PATH\"" | sudo tee -a /home/vagrant/.bashrc

sudo ln -s /files/vagrant/faker/app.php /usr/bin/cfntools
sudo chmod +x /usr/bin/cfntools

# SSMTP
sudo apt-get install ssmtp -y
sudo sed -i "s/mailhub=.*/mailhub=${VAGRANT_SMTP_ADDRESS}/" /etc/ssmtp/ssmtp.conf
sudo sed -i "s/root=postmaster/root=${VAGRANT_SMTP_ROOT_EMAIL}/" /etc/ssmtp/ssmtp.conf
echo "UseSTARTTLS=YES" | sudo tee -a /etc/ssmtp/ssmtp.conf
echo "AuthUser=${VAGRANT_SMTP_ROOT_EMAIL}" | sudo tee -a /etc/ssmtp/ssmtp.conf
echo "AuthPass=${VAGRANT_SMTP_ROOT_EMAIL_PASSWORD}" | sudo tee -a /etc/ssmtp/ssmtp.conf
