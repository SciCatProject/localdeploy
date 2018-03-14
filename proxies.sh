#!/bin/bash

kubectl proxy &
sleep 2
# Maybe remove (or add option for) backgrounding tasks as it makes the processes difficult to manage
kubectl port-forward --namespace kube-system $(kubectl get po -n kube-system | grep kube-registry-v0 | awk '{print $1;}') 5000:5000
kubectl port-forward --namespace dev $(kubectl get po -n dev | grep mongodb | awk '{print $1;}') 27017:27017
kubectl port-forward --namespace dev $(kubectl get po -n dev | grep rabbitmq | awk '{print $1;}') 15672:15672 5672:5672
kubectl port-forward --namespace dev $(kubectl get po -n dev | grep catanie | awk '{print $3;}') 8000:80
kubectl port-forward --namespace dev $(kubectl get po -n dev | grep node | awk '{print $1;}') 1880:1880
kubectl port-forward --namespace dev $(kubectl get po -n dev | grep catamel | awk '{print $1;}') 3000:3000
kubectl port-forward --namespace dev $(kubectl get po -n dev | grep fileserver  | awk '{print $1;}') 8888:8888
docker login localhost:5000
