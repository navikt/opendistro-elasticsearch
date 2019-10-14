# opendistro-elasticsearch
Helm chart for Open Distro For Elasticsearch (ODFE), the community-driven, 100% open source distribution of Elasticsearch with advanced security, alerting, deep performance analysis, and more. ODFE is supported by Amazon Web Services. 


## Installing the chart

Prerequisites:
* A kubernetes cluster
* Rook/ceph 
* Helm
* openssl (for generating keys)

### Virtual memory
Elasticsearch uses a mmapfs directory to store indices. It wont start if it detects low mmap counts.
Set the limits with following command:
```
> sudo sysctl -w vm.max_map_count=262144
```

Install with:
```
> cd opendistro-elasticsearch
> helm install -n stilling .
```

All pods should be in running state, by default it will deploy an elasticsearch cluster consist of:
```
> kubectl get pods
NAME                                                      READY   STATUS    RESTARTS   AGE
stilling-opendistro-elasticsearch-data-0                    1/1     Running   0          23h
stilling-opendistro-elasticsearch-data-1                    1/1     Running   0          23h
stilling-opendistro-elasticsearch-data-2                    1/1     Running   0          23h
stilling-opendistro-elasticsearch-ingest-5b59f65c9c-776gs   1/1     Running   0          23h
stilling-opendistro-elasticsearch-ingest-5b59f65c9c-ldxl5   1/1     Running   0          23h
stilling-opendistro-elasticsearch-kibana-84645c75c9-xt7rj   1/1     Running   0          23h
stilling-opendistro-elasticsearch-master-0                  1/1     Running   0          23h
stilling-opendistro-elasticsearch-master-1                  1/1     Running   0          23h
stilling-opendistro-elasticsearch-master-2                  1/1     Running   0          23h
```

You can check the health of the cluster with this
```
> kubectl get service
stilling-opendistro-elasticsearch             ClusterIP   10.102.125.108   <none>        9200/TCP,9300/TCP,9600/TCP   23h
stilling-opendistro-elasticsearch-discovery   ClusterIP   None             <none>        9200/TCP,9300/TCP            23h
stilling-opendistro-elasticsearch-kibana      ClusterIP   10.96.76.33      <none>        5601/TCP                     23h

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
Before going to production, you should change settings in the values.yaml file, according to your need.
Depending on traffic load and index size, you definitly need to increase the memory for data and master nodes.
[More about settings](https://www.elastic.co/guide/en/elasticsearch/guide/current/hardware.html#_memory)

### Security

Security is disabled by default, but can be enabled by setting the flag **odfe.security.enabled:true**, this requires you to generate keys and certificats,
You can use the script generate_certs.sh to generate self signed certs.
When generating keys, you will be asked to type in certs DN, this has to be changed in the config accordingly.

For instance:

```
> ./scripts/generate_certs.sh
...
Country Name (2 letter code) [AU]:NO
State or Province Name (full name) [Some-State]:OSLO
Locality Name (eg, city) []:OSLO
Organization Name (eg, company) [Internet Widgits Pty Ltd]:NAV
Organizational Unit Name (eg, section) []:NAVIKT
Common Name (e.g. server FQDN or YOUR name) []:ADMIN
...

--------------------------------------------------------------
Remember to add this to opendistro_security.authcz.admin_dn:
subject=CN=ADMIN,OU=NAVIKT,O=NAV,L=OSLO,ST=OSLO,C=NO
--------------------------------------------------------------
...
Country Name (2 letter code) [AU]:NO
State or Province Name (full name) [Some-State]:OSLO
Locality Name (eg, city) []:OSLO
Organization Name (eg, company) [Internet Widgits Pty Ltd]:NAV
Organizational Unit Name (eg, section) []:NAVIKT
Common Name (e.g. server FQDN or YOUR name) []:NODE
Email Address []:
...
--------------------------------------------------------------
Remember to add this to opendistro_security.nodes_dn:
subject=CN=NODE,OU=NAVIKT,O=NAV,L=OSLO,ST=OSLO,C=NO
--------------------------------------------------------------

```

Type in the DN three times, the first is for generating the root key, second is for the admin key and last the node key.
NOTE, admin and node key must have **different** DNs. All keys are saved under .secrets/ folder. 

Apply the secrets to kubernetes using following command:

```
> helm template  -n stilling --set odfe.generate_secrets=true -x templates/odfe-cert-secrets.yaml . | kubectl apply -f -
```

### Internal users
ODFE has many ways of doing authentication and authorization, it supports LDAP, Kerberos, SAML, OpenID and [more](https://opendistro.github.io/for-elasticsearch-docs/docs/security-configuration/). The easiest is basic authentication with a list of internal users. The example below shows how to generate the users with belonging password. NOTE by convenient all users is set to the same password on startup, you can change this by logging into
kibana and change the password [there](https://aws.amazon.com/blogs/opensource/change-passwords-open-distro-for-elasticsearch/). 

```
> docker run amazon/opendistro-for-elasticsearch sh /usr/share/elasticsearch/plugins/opendistro_security/tools/hash.sh -p <password>
```

The hash script will encrypt the password into a hash, copy and paste this to the next script like shown below

```
>helm template -n stilling --set odfe.generate_secrets=true --set odfe.security.password.hash='hashbetweensinglequote' -x templates/odfe-config-secrets.yaml . | kubectl apply -f -

> k get secret
NAME                                       TYPE                                  DATA   AGE
default-token-p7nfn                        kubernetes.io/service-account-token   3      15d
stilling-opendistro-elasticsearch-certs    Opaque                                5      15m
stilling-opendistro-elasticsearch-config   Opaque                                2      14m
```

If kibana is enabled, generate secrets for it aswell:
```
helm template -n stilling --set odfe.generate_secrets=true --set kibana.password='thesamepasswordbutinplaintext' -x templates/odfe-02-kibana-secrets.yaml . | kubectl apply -f -
``` 

Finally deploy with security enabled:

```
helm install -n stilling --set odfe.security.enabled=true .
```

## Acknowledgements
* This helm chart is based on the work by [Pires](https://github.com/pires/kubernetes-elasticsearch-cluster)
  