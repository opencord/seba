# SEBA Helm Charts

This directory contains Helm charts used to install SEBA components on
a Kubernetes cluster.

To install SEBA:

```
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
helm repo add cord https://charts.opencord.org/master
helm repo add cord6 https://charts.opencord.org/cord-6.0
helm dep update nem-core
helm dep update profile/bng-in-fabric
helm dep update seba-substrate
helm install nem-core -n nem-core
helm install profile/bng-in-fabric -n nem-svc
helm install seba-substrate -n seba-substrate
helm upgrade seba-substrate --set voltha.etcd-operator.customResources.createEtcdClusterCRD=true seba-substrate
```

After installing the SEBA charts above, the following commands can be used to
wait until all pods have started successfully:

```
../tools/wait-for-pods.sh
../tools/wait-for-pods.sh voltha
```