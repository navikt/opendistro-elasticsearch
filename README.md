# opendistro-elasticsearch
Helm chart for Open Distro For Elasticsearch (ODFE), the community-driven, 100% open source distribution of Elasticsearch with advanced security, alerting, deep performance analysis, and more. ODFE is supported by Amazon Web Services. 


## Installing the chart

Prerequisites:
* A kubernetes cluster
* Rook/ceph
* Helm
* openssl (for generating keys)

```
helm package opendistro-elasticsearch
helm package opendistro-elasticsearch-0.1.tgz
```

The chart will deploy an elasticsearch cluster consist of:

* 3 masters 
* 3 data
* 2 ingests
* 1 kibana 

Values can be changed in the values.yml file. By default 
security is disabled, but can be enabled by setting the flag **odfe.security.enabled:true**. 


