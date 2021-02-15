#!/bin/bash

USER=$1
PASSWORD=$2
SNAPSHOT=$3

curl -u "$USER:$PASSWORD" -XPOST -H "Content-type: application/json" -d '
{
  "indices": "-opendistro-security*",
  "ignore_unavailable": true,
  "include_global_state": false,
  "partial": false,
}' http://localhost:9200/_snapshot/stilling/$SNAPSHOT/_restore
