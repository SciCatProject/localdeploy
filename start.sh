#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
        LOCAL_IP=`ipconfig getifaddr en0`
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        LOCAL_IP=`hostname --ip-address`
fi
echo $LOCAL_IP
#minikube start -v7  --insecure-registry localhost:5000 --extra-config=apiserver.GenericServerRunOptions.AuthorizationMode=RBAC

kubectl config use-context minikube #should auto set, but added in case

kubectl -n kube-system create sa tiller
kubectl create -f rbac-config.yaml
helm init --service-account tiller
helm repo update
#kubectl apply -f ./deployments/registry.yaml
#kubectl apply -f ./deployments/ingress/nginx-controller.yaml

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml

sleep 5

kubectl apply -f service-nodeport.yaml
kubectl apply -f configmap.yaml


NS_DIR=./namespaces/*.yaml

for file in $NS_DIR; do
  f="$(basename $file)"
   ns="${f%.*}"
   kubectl delete namespace $ns
done

