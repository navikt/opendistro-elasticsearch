#!/usr/bin/env bash
SCRIPTPATH=$(dirname $(realpath -s $0))
cd $SCRIPTPATH/..
RELEASE_NAME=$1
PASSWORD=$2
echo "generate kubernetes secret for $RELEASE_NAME certificates" 
helm template  -n $RELEASE_NAME  --set odfe.generate_secrets=true -x templates/odfe-cert-secrets.yaml . | kubectl apply -f -
echo "encrypting password"
HASH=$(docker run amazon/opendistro-for-elasticsearch sh /usr/share/elasticsearch/plugins/opendistro_security/tools/hash.sh -p $PASSWORD)
echo "generate kubernetes secret for certificates"
helm template -n stilling --set odfe.generate_secrets=true --set odfe.security.password.hash="$HASH" -x templates/odfe-config-secrets.yaml . | kubectl apply -f -
echo "generating secret for kibana"
helm template -n stilling --set odfe.generate_secrets=true --set kibana.password="$PASSWORD" -x templates/odfe-02-kibana-secrets.yaml . | kubectl apply -f -