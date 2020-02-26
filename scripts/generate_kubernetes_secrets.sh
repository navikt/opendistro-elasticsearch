#!/usr/bin/env bash
set -e
SCRIPTPATH=$(dirname $(realpath -s $0))
cd $SCRIPTPATH/..
NAMESPACE=$1 
RELEASE_NAME=$2
PASSWORD=$3
HASH=$(docker run amazon/opendistro-for-elasticsearch sh /usr/share/elasticsearch/plugins/opendistro_security/tools/hash.sh -p $PASSWORD)
echo "generate kubernetes secret for $RELEASE_NAME certificates" 
helm template $RELEASE_NAME --set odfe.generate_secrets=true --show-only templates/odfe-cert-secrets.yaml . | kubectl apply -n $NAMESPACE -f -
echo "encrypting password"
echo "generate kubernetes secret for certificates"
helm template $RELEASE_NAME --set odfe.generate_secrets=true --set odfe.security.password.hash="$HASH" --show-only templates/odfe-config-secrets.yaml . | kubectl apply -n $NAMESPACE -f -
echo "generating secret for kibana"
helm template $RELEASE_NAME --set odfe.generate_secrets=true --set kibana.password="$PASSWORD" --show-only templates/odfe-kibana-secrets.yaml . | kubectl apply -n $NAMESPACE -f -
echo "generating secret for exporter"
helm template $RELEASE_NAME --set odfe.generate_secrets=true --set exporter.password="$PASSWORD" --show-only templates/odfe-prometheus-exporter-secrets.yaml . | kubectl apply -n $NAMESPACE -f -
