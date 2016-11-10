from __future__ import print_function

import sys
import json
import os
import os.path as osp
import uuid

import github
from swamp_api import SwampApi
from swamp_api import common


def lambda_handler(event, context):

    tmp_dir = '/tmp/github-to-swamp/{0}'.format(str(uuid.uuid4()))
    os.makedirs(tmp_dir)

    # Get from GitHub
    archive_url, archive_name, commit_hash = github.event_handler(event)
    archive_path = osp.join(tmp_dir, archive_name)
    github.download_zipball(archive_url, archive_path)
    pkg_conf = github.get_pkg_conf(archive_path, commit_hash, tmp_dir)
    # print(pkg_conf)

    # Upload to SWAMP
    swamp_api_obj = SwampApi(tmp_dir)
    user_info = common.conf_to_dict('./user-info.conf')
    user_uid = swamp_api_obj.login(user_info)

    proj_dict = {k: v for k, v in swamp_api_obj.list_projects({'user_uuid': user_uid})}
    proj_uuid = proj_dict[user_info['project']]

    (pkg_uuid, pkg_version_uuid) = swamp_api_obj.upload({'archive': archive_path,
                                                         'pkg_conf': pkg_conf,
                                                         'user_uuid': user_uid,
                                                         'project_uuid': proj_uuid})

    swamp_api_obj.run_assessment({'project_uuid': proj_uuid,
                                  'package_version_uuid': pkg_version_uuid,
                                  'package_uuid': pkg_uuid,
                                  'tool_uuid': '*',
                                  'notify_when_complete': 'true'})


def main(filepath):
    event = None
    with open(filepath) as fobj:
        event = json.load(fobj)

    lambda_handler(event, None)

if __name__ == '__main__':
    main(sys.argv[1])
