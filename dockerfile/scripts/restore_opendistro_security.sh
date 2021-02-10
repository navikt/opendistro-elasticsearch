#!/usr/bin/env bash
echo "restore config files, this will use /tmp/backup folder as config files folder"
read -p "Are you really really sure? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
cd /usr/share/elasticsearch/plugins/opendistro_security/tools
sh securityadmin.sh -cacert ../../../config/root-ca.pem -cert ../../../config/admin.pem -key ../../../config/admin-key.pem -icl -nhnv -cd /tmp/backup
echo "all config yml files has been restored"
fi

