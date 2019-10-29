#!/usr/bin/env bash
set -e
SCRIPTPATH=$(dirname $(realpath -s $0))
cd $SCRIPTPATH/..
NAMESPACE=$1 
RELEASE_NAME=$2
PASSWORD=$3
HASH=$(docker run amazon/opendistro-for-elasticsearch sh /usr/share/elasticsearch/plugins/opendistro_security/tools/hash.sh -p $PASSWORD)
echo "generate kubernetes secret for $RELEASE_NAME certificates" 
helm template  -n $RELEASE_NAME --set odfe.generate_secrets=true -x templates/odfe-cert-secrets.yaml . | kubectl apply -n $NAMESPACE -f -
echo "encrypting password"
echo "generate kubernetes secret for certificates"
helm template -n $RELEASE_NAME --set odfe.generate_secrets=true --set odfe.security.password.hash="$HASH" -x templates/odfe-config-secrets.yaml . | kubectl apply -n $NAMESPACE -f -
echo "generating secret for kibana"
helm template -n $RELEASE_NAME --set odfe.generate_secrets=true --set kibana.password="$PASSWORD" -x templates/odfe-kibana-secrets.yaml . | kubectl apply -n $NAMESPACE -f -
