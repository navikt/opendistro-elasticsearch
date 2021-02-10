#!/usr/bin/env bash
echo "backup up config files"
read -p "Are you sure? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
mkdir -p /tmp/backup
cd /usr/share/elasticsearch/plugins/opendistro_security/tools
sh securityadmin.sh -cacert ../../../config/root-ca.pem -cert ../../../config/admin.pem -key ../../../config/admin-key.pem -icl -nhnv -cd /tmp/backup -r
cd /tmp/backup/
mv action_groups* action_groups.yml
mv config* config.yml
mv internal_users* internal_users.yml
mv nodes_dn* nodes_dn.yml
mv roles_mapping* roles_mapping.yml
mv roles_2* roles.yml
mv security_tenants* tenants.yml
cd ..
tar -cvzf backup.tar.gz backup
echo "all config yml files has been backuped to /tmp/backup.tar.gz"
fi

