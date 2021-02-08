#!/bin/bash

USER=$1
PASSWORD=$2

curl -u "$USER:$PASSWORD" -XPOST -H "Content-type: application/json" -d '{
  "type": "gcs",
  "settings":
  {
    "bucket": "elasticsearch-arbeidsplassen-backup",
    "base_path": "es-backups"
  }
}' http://localhost:9200/_snapshot/arbeidsplassen
