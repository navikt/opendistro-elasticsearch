#!/usr/bin/env bash
# Root CA
set -e

SCRIPTPATH=$(dirname $(realpath -s $0))
cd $SCRIPTPATH/..
mkdir -p .secrets
cd .secrets

echo "This will generate kubernetes certifications into folder $(PWD)"
read -p "Are you sure? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
echo "Generating root CA, keep this key private and safe"
openssl genrsa -out root-ca-key.pem 2048
openssl req -new -x509 -sha256 -key root-ca-key.pem -out root-ca.pem -subj "/C=NO/ST=OSLO/L=OSLO/O=NAV/CN=ROOT" -days 3650

echo "Generating admin cert"
openssl genrsa -out admin-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in admin-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out admin-key.pem
openssl req -new -key admin-key.pem -out admin.csr -subj "/C=NO/ST=OSLO/L=OSLO/O=NAV/CN=ADMIN"
openssl x509 -req -in admin.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out admin.pem -days 3650

echo "--------------------------------------------------------------"
echo "Remember to add this to opendistro_security.authcz.admin_dn:"
openssl x509 -subject -nameopt RFC2253 -noout -in admin.pem
echo "--------------------------------------------------------------"

echo "Generating node cert"
openssl genrsa -out node-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in node-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out node-key.pem
openssl req -new -key node-key.pem -out node.csr -subj "/C=NO/ST=OSLO/L=OSLO/O=NAV/CN=NODE"
openssl x509 -req -in node.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out node.pem -days 3650

echo "--------------------------------------------------------------"
echo "Remember to add this to opendistro_security.nodes_dn:"
openssl x509 -subject -nameopt RFC2253 -noout -in node.pem
echo "--------------------------------------------------------------"

echo "Generating monitor cert"
openssl genrsa -out monitor-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in monitor-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out monitor-key.pem
openssl req -new -key monitor-key.pem -out monitor.csr -subj "/C=NO/ST=OSLO/L=OSLO/O=NAV/CN=monitor"
openssl x509 -req -in monitor.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out monitor.pem -days 3650

# Cleanup
rm admin-key-temp.pem
rm admin.csr
rm node-key-temp.pem
rm node.csr
rm monitor-key-temp.pem
rm monitor.csr
echo "before deploying the cluster you also need to place gcs-key.json to the .secret folder"
fi
