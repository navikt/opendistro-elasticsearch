# opendistro-elasticsearch
Helm chart for Open Distro For Elasticsearch (ODFE), the community-driven, 100% open source distribution of Elasticsearch with advanced security, alerting, deep performance analysis, and more. ODFE is supported by Amazon Web Services. 

## Installing the chart

Prerequisites:
* A kubernetes cluster
* Rook/ceph
* Helm
* openssl (for generating keys)

### TL;DR
```
helm package 
helm install opendistro-elasticsearch
```
Security is disabled by default, but can be enabled by setting the flag odfe.security.enabled:true. 


