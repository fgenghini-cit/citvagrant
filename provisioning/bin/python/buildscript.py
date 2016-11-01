#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
import os
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

        repo = "/files/projects/repos/%s" % repo_name
        repo_docroot = "%s/source/deploy" % repo
        if not os.path.isdir(repo_docroot):
            logging.warning("%s dir not found. Check repo configuration on projects.yml." % repo_docroot)
            continue

        # Set the drush variable.
        drush = "drush -r %s -l %s.localhost" % (platform_path, repo_name)

        os.system("%s rr" % drush)
        os.system("%s updb -y" % drush)
        os.system("%s fra -y" % drush)
        #TODO: switch to vagrat-config.sh and change the user before execute it.
        os.system("cd %s;git config core.filemode false;git config push.default nothing;" % repo_docroot)

if __name__ == '__main__':
    # Setup logging.
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    main()
