from __future__ import print_function

import sys
import os.path as osp
import urllib2
import zipfile

from swamp_api import common


def download_zipball(url, outfile):
    rfobj = urllib2.urlopen(url)
    with open(outfile, 'wb') as wfobj:
        wfobj.write(rfobj.read())


def get_top_level_dir(archive):
    with zipfile.ZipFile(archive) as zf:
        file_list = zf.namelist()
        return file_list[0]


def read_pkg_conf_file(archive, tmp_dir):
    pkg_dir = get_top_level_dir(archive)

    with zipfile.ZipFile(archive) as zf:
        pkg_conf_blob = zf.read(osp.join(pkg_dir, 'package.conf'))

    return (pkg_dir, common.conf_to_dict(pkg_conf_blob.split('\n')))


def get_pkg_conf(archive, version, tmp_dir):

    pkg_dir, pkg_conf = read_pkg_conf_file(archive, tmp_dir)

    pkg_conf['package-archive'] = archive
    pkg_conf['package-version'] = version
    pkg_conf['package-dir'] = pkg_dir

    return pkg_conf


def event_handler(event):
    msg = common.json_loads(event['Records'][0]['Sns']['Message'])
    commit_hash = msg['after']
    archive_url = msg['repository']['archive_url']
    full_name = msg['repository']['full_name']
    archive_url = archive_url.replace('/ref', 'master')
    archive_url = archive_url.format(archive_format='zipball/', master='master')
    archive_name = '{0}-{1}.zip'.format(full_name.replace('/', '-'), commit_hash[:7])
    return (archive_url, archive_name, commit_hash[:7])


def main(filepath):
    event = None
    with open(filepath) as fobj:
        event = common.json_load(fobj)

    archive_url, archive_name = event_handler(event)
    common.download_zipball(archive_url, archive_name)
    print(common.get_top_level_dir(archive_name))


if __name__ == '__main__':
    main(sys.argv[1])
