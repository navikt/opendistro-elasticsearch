#!/usr/bin/env bash
echo "WARNING this will reset security settings to default state!"
read -p "Are you sure? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
./securityadmin.sh -cd ../securityconfig/ -icl -nhnv -cacert ../../../config/root-ca.pem -cert ../../../config/admin.pem -key ../../../config/admin-key.pem
fi
