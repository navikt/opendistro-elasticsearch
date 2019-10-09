# opendistro-elasticsearch
Helm chart for Open Distro For Elasticsearch (odfe). 

Default this chart will deploy an elasticsearch cluster consist of:

* 3 masters 
* 3 data
* 2 ingests
* 1 kibana 

Everything can be configured in the values.yml file. 
Security is disabled by default, but can be enabled by setting the flag odfe.security.enabled:true. 

## Installing the chart in localhost
You will need to install:
* Kubernetes cluster (minikube, or kubeadm)
* Helm

