# opendistro-elasticsearch
Helm chart for Open Distro For Elasticsearch (ODFE), the community-driven, 100% open source distribution of Elasticsearch with advanced security, alerting, deep performance analysis, and more. ODFE is supported by Amazon Web Services. 


## Installing the chart

Prerequisites:
* A kubernetes cluster
* Rook/ceph 
* Helm 3.x
* openssl (for generating keys)

### Virtual memory
Elasticsearch uses a mmapfs directory to store indices. It wont start if it detects low mmap counts.
Set the limits with following command:
```
> sudo sysctl -w vm.max_map_count=262144
```

### Test templates:
```
> helm lint
> helm template stilling . --debug
```
### Install with:
```
> cd opendistro-elasticsearch
> export ODFE_RELEASE=arbeidsplassen
> export ODFE_NAMESPACE=teampam
> ./scripts/generate_certs.sh
> ./scripts/generate_kubernetes_secrets.sh <verydifficultpassword>
> ./scripts/deploy-odfe.sh
```

All pods should be in running state, by default it will deploy an elasticsearch cluster consist of:
```
> kubectl get pods
NAME                                                      READY   STATUS    RESTARTS   AGE
arbeidsplassen-opendistro-elasticsearch-data-0                    1/1     Running   0          23h
arbeidsplassen-opendistro-elasticsearch-data-1                    1/1     Running   0          23h
arbeidsplassen-opendistro-elasticsearch-data-2                    1/1     Running   0          23h
arbeidsplassen-opendistro-elasticsearch-ingest-5b59f65c9c-776gs   1/1     Running   0          23h
arbeidsplassen-opendistro-elasticsearch-ingest-5b59f65c9c-ldxl5   1/1     Running   0          23h
arbeidsplassen-opendistro-elasticsearch-kibana-84645c75c9-xt7rj   1/1     Running   0          23h
arbeidsplassen-opendistro-elasticsearch-master-0                  1/1     Running   0          23h
arbeidsplassen-opendistro-elasticsearch-master-1                  1/1     Running   0          23h
arbeidsplassen-opendistro-elasticsearch-master-2                  1/1     Running   0          23h
```

You can check the health of the cluster with this
```
> kubectl get service
arbeidsplassen-opendistro-elasticsearch             ClusterIP   10.102.125.108   <none>        9200/TCP,9300/TCP,9600/TCP   23h
arbeidsplassen-opendistro-elasticsearch-discovery   ClusterIP   None             <none>        9200/TCP,9300/TCP            23h
arbeidsplassen-opendistro-elasticsearch-kibana      ClusterIP   10.96.76.33      <none>        5601/TCP                     23h

> curl http://10.102.125.108:9200/_cluster/health

{
  "cluster_name": "milkyway",
  "status": "green",
  "timed_out": false,
  "number_of_nodes": 8,
  "number_of_data_nodes": 3,
  "active_primary_shards": 3,
  "active_shards": 7,
  "relocating_shards": 0,
  "initializing_shards": 0,
  "unassigned_shards": 0,
  "delayed_unassigned_shards": 0,
  "number_of_pending_tasks": 0,
  "number_of_in_flight_fetch": 0,
  "task_max_waiting_in_queue_millis": 0,
  "active_shards_percent_as_number": 100
}
```

## Deploy to production:
Before going to production, reconfigure the settings in the values.yaml file  according to your need.
Depending on traffic load and index size, increase the memory for data and master nodes.
[More about settings](https://www.elastic.co/guide/en/elasticsearch/guide/current/hardware.html#_memory)

### Istio support
This chart is compatible with istio, you can enable/disable istio by setting the flag "odfe.istio.inject" to true/false.
When running with istio, it will create some access policy, you need to change those access policy according to your services need.

### Using GCP Bucket for snapshot backup
The docker image installs repository-gcs for use with GCP Bucket as snapshot backup.
The image is available here ghcr.io/navikt/opendistro-elasticsearch. The dockerfile to create this image is in this folder [dockerfile](dockerfile/Dockerfile)

## Security
Security is now enabled by default. 
ODFE supports a varity of authentication and authorization protocols like LDAP, Kerberos, SAML, OpenID and [more](https://opendistro.github.io/for-elasticsearch-docs/docs/security-configuration/). By default this installation creates a list of internal users with passwords. NOTE by convenient all users is set to the same password on startup, you can change this by logging into kibana and change the password [there](https://aws.amazon.com/blogs/opensource/change-passwords-open-distro-for-elasticsearch/). 

Use the script generate_certs.sh to generate self signed certs:
```
> ./scripts/generate_certs.sh
```

The script creates all keys necessary needed for this setup, and are placed under .secrets/ folder. Keep root-ca-key.pem and root-ca.pem incase you need to add more keys and need to sign them.

Apply the secrets to kubernetes using following command:

```
> ./scripts/generate_kubernetes_secrets.sh <password>
```
Remember to change the password later in kibana. Finally deploy with security enabled:

```
> ./scripts/deploy-odfe.sh
```

The chart is made to work for us, it is not fully generalized to work with other setups.
We are open for pull request to make it work for other setups as well.

## Acknowledgements
* This helm chart is based on the work of [Pires](https://github.com/pires/kubernetes-elasticsearch-cluster)
* Elasticsearch prometheus exporter by [justwatch](https://github.com/justwatchcom/elasticsearch_exporter) 
