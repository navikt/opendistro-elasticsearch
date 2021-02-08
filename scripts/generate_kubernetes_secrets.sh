#!/usr/bin/env bash
set -e
SCRIPTPATH=$(dirname $(realpath -s $0))
cd $SCRIPTPATH/..
PASSWORD=$1
CLUSTER=$(kubectl config current-context)

if [[ -z $PASSWORD ]]; then
  echo "Password not set"
  exit 1
fi
if [[ -z "${ODFE_NAMESPACE}" ]]; then
  echo "ODFE_NAMESPACE is not defined"
  exit 1
fi
if [[ -z "${ODFE_RELEASE}" ]]; then
  echo "ODFE_RELEASE is not defined"
  exit 1
fi

echo "Generating kubernetes secrets for current cluster '$CLUSTER', release '${ODFE_RELEASE}', namespace '${ODFE_NAMESPACE}'"
read -p "Are you sure? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  HASH=$(docker run amazon/opendistro-for-elasticsearch sh /usr/share/elasticsearch/plugins/opendistro_security/tools/hash.sh -p $PASSWORD)
  echo "Generating secrets for certificates"
  helm template ${ODFE_RELEASE} --set odfe.generate_secrets=true  --set env.cluster=$CLUSTER --show-only templates/odfe-cert-secrets.yaml . | kubectl apply -n ${ODFE_NAMESPACE} -f -
  echo "generate kubernetes secret for config files"
  helm template ${ODFE_RELEASE} --set odfe.generate_secrets=true --set odfe.security.password.hash="$HASH" --show-only templates/odfe-config-secrets.yaml . | kubectl apply -n ${ODFE_NAMESPACE} -f -
  echo "generating secret for kibana"
  helm template ${ODFE_RELEASE} --set odfe.generate_secrets=true --set kibana.password="$PASSWORD" --show-only templates/odfe-kibana-secrets.yaml . | kubectl apply -n ${ODFE_NAMESPACE} -f -
  echo "generating secret for exporter"
  helm template ${ODFE_RELEASE} --set odfe.generate_secrets=true --set exporter.password="$PASSWORD" --show-only templates/odfe-prometheus-exporter-secrets.yaml . | kubectl apply -n ${ODFE_NAMESPACE} -f -
fi
