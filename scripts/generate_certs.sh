#!/usr/bin/env bash
# Root CA
SCRIPTPATH=$(dirname $(realpath -s $0)) 
echo $SCRIPTPATH
cd $SCRIPTPATH/..
mkdir -p .secrets
cd .secrets

echo "Generating root CA, keep this key private and safe"
openssl genrsa -out root-ca-key.pem 2048 -subj "/C=NO/ST=OSLO/L=OSLO/O=NAV/CN=ADMIN"
openssl req -new -x509 -sha256 -key root-ca-key.pem -out root-ca.pem

echo "Generating admin cert"
openssl genrsa -out admin-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in admin-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out admin-key.pem
openssl req -new -key admin-key.pem -out admin.csr -subj "/C=NO/ST=OSLO/L=OSLO/O=NAV/CN=ADMIN"
openssl x509 -req -in admin.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out admin.pem

echo "--------------------------------------------------------------"
echo "Remember to add this to opendistro_security.authcz.admin_dn:"
openssl x509 -subject -nameopt RFC2253 -noout -in admin.pem
echo "--------------------------------------------------------------"

echo "Generating node cert"
openssl genrsa -out node-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in node-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out node-key.pem
openssl req -new -key node-key.pem -out node.csr -subj "/C=NO/ST=OSLO/L=OSLO/O=NAV/CN=NODE"
openssl x509 -req -in node.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out node.pem

echo "--------------------------------------------------------------"
echo "Remember to add this to opendistro_security.nodes_dn:"
openssl x509 -subject -nameopt RFC2253 -noout -in node.pem
echo "--------------------------------------------------------------"

echo "Generating client cert"
openssl genrsa -out client-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in client-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out client-key.pem
openssl req -new -key client-key.pem -out client.csr -subj "/C=NO/ST=OSLO/L=OSLO/O=NAV/CN=readall"
openssl x509 -req -in client.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out client.pem

# Cleanup
rm admin-key-temp.pem
rm admin.csr
rm node-key-temp.pem
rm node.csr
rm client-key-temp.pem
rm client.csr