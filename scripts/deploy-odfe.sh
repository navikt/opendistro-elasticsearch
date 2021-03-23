#!/bin/bash
set -e
CLUSTER=$(kubectl config current-context)
ODFE_DIR=$(pwd)
PAMCOPS=$(dirname $ODFE_DIR)/pam-cops

if [[ -z $CLUSTER ]]; then
  echo "Cluster is not set"
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
if [ "$CLUSTER" == "dev-gcp" ]; then
  VALUES_FILE="$PAMCOPS/conf/odfe/clusters/dev-gcp/$ODFE_RELEASE-dev-gcp.yaml"
elif [ "$CLUSTER" == "prod-gcp" ]; then
  VALUES_FILE="$PAMCOPS/conf/odfe/clusters/prod-gcp/$ODFE_RELEASE-prod-gcp.yaml"
elif [ "$CLUSTER" == "docker-desktop" ]; then
  VALUES_FILE="docker-desktop/values-docker-desktop.yaml"
else
  echo "Uknown cluster $CLUSTER"
  exit 1
fi
if [ ! -f $VALUES_FILE ]; then
  echo "$VALUES_FILE does not exist"
  exit 1
fi
echo "current ODFE dir ${ODFE_DIR}"
echo "current CONF dir ${PAMCOPS}"
echo "deploying Opendistro Elasticsearch with release name: ${ODFE_RELEASE} cluster: $CLUSTER, namespace: ${ODFE_NAMESPACE} and value file: $VALUES_FILE"
read -p "Are you sure? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  cd $ODFE_DIR
  pwd
  kubectl config use-context $CLUSTER
  kubens ${ODFE_NAMESPACE}
  helm upgrade --install ${ODFE_RELEASE} -f $VALUES_FILE .
fi
