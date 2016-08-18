#!/usr/bin/env python

import os
import yaml

def main():
    """
    Project Installation Steps
    """

    for project, cfg in yaml.load(open("/files/projects/projects.yml", 'r')).iteritems():
        repo_name = cfg['link']['repo']
        platform_path = "/files/projects/platforms/%s" % cfg['link']['platform']
        repo_docroot = "/files/projects/repos/%s/source/deploy" % repo_name
        multisite_path = "%s/sites/%s.localhost" % (platform_path, repo_name)
        sites_php = "%s/sites/sites.php" % platform_path

        # Creates symbolic link from repo to platform.
        if not os.path.islink(multisite_path):
            os.symlink(repo_docroot, multisite_path)

        # Creates the sites.php file if does not exists.
        if not os.path.exists(sites_php):
            sites_php_file = open(sites_php, 'w+')
            sites_php_file.close()

        # Append the multi-site repo variable if it does not exists.
        sites_php_file = open(sites_php, 'ab+')
        if repo_name not in sites_php_file.read():
            sites_php_file.write("$sites['%s.localhost'] = '%s.localhost';\n" % (repo_name, repo_name))
        sites_php_file.close()

        mysql = cfg['drupal']['settings']['mysql']
        mapping = {
            '[[DATABASENAME]]': mysql['db'],
            '[[USERNAME]]': mysql['user'],
            '[[PASSWORD]]': mysql['passwd'],
            '[[LOCALHOST]]': mysql['host'],
        }
        settings_php_content = replace_file_content('/files/provisioning/skel/default.settings.php', mapping)
        settings_php_file = open(repo_docroot + '/settings.php', 'w+')
        settings_php_file.write(settings_php_content)
        settings_php_file.close()

def replace_file_content(file, dic):
    """ Find and replace file content. """
    source = open(file)
    content = source.read()
    for i, j in dic.items():
        content = content.replace(i, j)
    return content

if __name__ == '__main__':
    main()
