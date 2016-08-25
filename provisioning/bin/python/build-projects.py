#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
import os
import shutil
import yaml

def main():
    """
    Project Installation Steps
    """

    for project, cfg in yaml.load(open("/files/projects/projects.yml", 'r')).iteritems():
        repo_name = cfg['link']['repo']
        platform_name = cfg['link']['platform']
        platform_path = "/files/projects/platforms/%s" % platform_name

        logging.info('Building "%s" with "%s" platform' % (repo_name, platform_name))

        if not os.path.isdir(platform_path):
            logging.warning("%s dir not found. Check platform configuration on projects.yml." % platform_path)
            continue

        repo_docroot = "/files/projects/repos/%s/source/deploy" % repo_name
        if not os.path.isdir(repo_docroot):
            logging.warning("%s dir not found. Check repo configuration on projects.yml." % repo_docroot)
            continue

        # Creates symbolic link from repo to platform.
        logging.info("Creating Symbolic link %s --> %s" % (platform_path, repo_name))
        create_site_symbolic_link(platform_path, repo_name)

        # Creates sites.php.
        logging.info("Creating and configuring sites.php")
        create_sites_php(platform_path, repo_name)

        # Creates settings.php.
        if not 'drupal' in cfg:
            cfg['drupal'] = dict()
            cfg['drupal']['settings'] = dict()

        settings = cfg['drupal']['settings']
        logging.info("Creating and configuring settings.php")
        create_settings_php(settings, repo_docroot, repo_name)

        # Configure Apache Vhost.
        logging.info("Creating and configuring apache vhost file.")
        configure_site_apache_vhost(platform_path, repo_name)

        # Configure database.



def create_site_symbolic_link(platform_path, repo_name):
    """ Creates symbolic link from repo to platform. """

    multisite_path = "%s/sites/%s" % (platform_path, repo_name)
    repo_docroot = "/files/projects/repos/%s/source/deploy" % repo_name

    if not os.path.islink(multisite_path):
        os.symlink(repo_docroot, multisite_path)

def create_sites_php(platform_path, repo_name):
    """ Creates and populates sites.php """
    # Creates the sites.php file if does not exists.
    sites_php = "%s/sites/sites.php" % platform_path
    if not os.path.exists(sites_php):
        sites_php_file = open(sites_php, 'w+')
        sites_php_file.close()

    # Append the multi-site repo variable if it does not exists.
    sites_php_file = open(sites_php, 'ab+')
    if repo_name not in sites_php_file.read():
        sites_php_file.write("$sites['%s'] = '%s.localhost';\n" % (repo_name, repo_name))
    sites_php_file.close()

def create_settings_php(settings, repo_docroot, repo_name):
    """ Creates and populates settings.php """

    if (settings is None):
        settings = dict()

    # Add MySQL settings.
    if not 'mysql' in settings:
        # Default values, if the configuration are not defined on projects.yml.
        settings['mysql'] = {
            'db': repo_name,
            'user': 'root',
            'passwd': 'root',
            'host': 'localhost',
        }

    mysql = settings['mysql']
    mapping = {
        '[[DATABASENAME]]': mysql['db'],
        '[[USERNAME]]': mysql['user'],
        '[[PASSWORD]]': mysql['passwd'],
        '[[LOCALHOST]]': mysql['host'],
    }
    settings_php_path = "%s/settings.php" % repo_docroot
    settings_php_content = replace_file_content('/files/provisioning/skel/default.settings.php', mapping)
    settings_php_file = open(settings_php_path, 'w+')
    settings_php_file.write(settings_php_content)
    settings_php_file.close()

    # Add conf variables.
    if 'confs' in settings and settings['confs'] is not None:
        with open(settings_php_path, "a") as settings_php_file:
            for conf, conf_value in settings['confs'].iteritems():
                settings_php_file.write("$conf['%s.localhost'] = \"%s\";\n" % (conf, conf_value))
        settings_php_file.close()

def configure_site_apache_vhost(platform_path, repo_name):
    """ Creates and populates Apache Vhost """

    token_mapping = {
        "[[DOCROOT]]": platform_path,
        "[[SERVERNAME]]": "%s.localhost" % repo_name,
    }

    apache_vhost_skel = "/files/provisioning/skel/vhost.skel.conf"
    vhost_content = replace_file_content(apache_vhost_skel, token_mapping)
    apache_vhost_dest = "/etc/apache2/sites-enabled/%s.localhost.conf" % repo_name
    vhost = open(apache_vhost_dest, 'w+')
    vhost.write(vhost_content)
    vhost.close()

def replace_file_content(file, dic):
    """ Find and replace file content. """

    source = open(file)
    content = source.read()
    for i, j in dic.items():
        content = content.replace(i, j)
    return content

if __name__ == '__main__':
    # Setup logging.
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    main()
