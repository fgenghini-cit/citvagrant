#!/usr/bin/env bash

# PHP
export VAGRANT_PHP_VERSION="5.6"
export VAGRANT_PHP_MEMORY_LIMIT="128M"
export VAGRANT_PHP_MAX_EXECUTION_TIME="300"
export VAGRANT_PHP_TIMEZONE="America/Sao_Paulo"
export VAGRANT_PHP_POST_MAX_SIZE="256M"
export VAGRANT_PHP_UPLOAD_MAX_FILE_SIZE="256M"

# Drush
export VAGRANT_DRUSH_VERSION="8.*"

# Drupal Coder
export VAGRANT_CODER_VERSION="~8.2.3"

# SMTP
export VAGRANT_SMTP_ADDRESS="smtp.gmail.com:587"
export VAGRANT_SMTP_ROOT_EMAIL="youremail@ciandt.com"
export VAGRANT_SMTP_ROOT_EMAIL_PASSWORD="{your email password}"
