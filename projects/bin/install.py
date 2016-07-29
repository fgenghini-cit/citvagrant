#!/usr/bin/env python

import os
import yaml

def main():
    """
    Project Installation Steps
    """

    for project, cfg in yaml.load(open("../projects.yml", 'r')).iteritems():
        repo_name = cfg['link']['repo']
        platform_path = "/files/projects/platforms/%s" % cfg['link']['platform']
        repo_docroot = "/files/projects/repos/%s/source/deploy" % repo_name
        multisite_path = "%s/sites/%s.localhost" % (platform_path, repo_name)
        sites_php = "%s/sites/sites.php" % platform_path

        # Creates symbolic link from repo to platform.
        if not os.path.islink(multisite_path):
            os.symlink(repo_docroot, multisite_path)

        # Add project to sites.php
        # TODO: It sites.php doesn't exist, create it.
        # TODO: Check if repo exist on sites.php, if not add new entry.


if __name__ == '__main__':
    main()
