#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
        LOCAL_IP=`ipconfig getifaddr en0`
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        LOCAL_IP=`hostname --ip-address`
fi
echo $LOCAL_IP
minikube start --insecure-registry localhost:5000
/usr/local/bin/helm init
kubectl config use-context minikube #should auto set, but added in case
helm init
helm repo update
kubectl apply -f ./deployments/registry.yaml
kubectl apply -f ./deployments/ingress/nginx-controller.yaml
sleep 5

NS_DIR=./namespaces/*.yaml

for file in $NS_DIR; do
  f="$(basename $file)"
   ns="${f%.*}"
   kubectl delete namespace $ns
done

