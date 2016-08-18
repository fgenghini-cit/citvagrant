#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import shutil
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

        # Configure Apache Vhost.
        token_mapping = {
            "[[DOCROOT]]": platform_path,
            "[[SERVERNAME]]": "%s.localhost" % repo_name,
        }

        apache_vhost_skel = "/files/provisioning/skel/vhost.skel.conf"
        vhost_content = replace_file_content(apache_vhost_skel, token_mapping)
        apache_vhost_dest = "/etc/apache2/sites-enabled/%s.localhost" % repo_name
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
    main()
