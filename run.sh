#!/bin/bash


NS_DIR=./namespaces/*.yaml

if [ "$(uname)" == "Darwin" ]; then
        LOCAL_IP=`ipconfig getifaddr en0`
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        LOCAL_IP=`hostname --ip-address`
fi

DOCKER_REPO="localhost:5000"
KAFKA=0 

while getopts 'hkd:' flag; do
  case "${flag}" in
    d) DOCKER_REPO=${OPTARG} ;;
    h) echo "-d for Docker Repo prefix"; exit 1 ;;
    k) KAFKA=1 ;;
  esac
done

CATANIE_REPO=$DOCKER_REPO/catanie
CATAMEL_REPO=$DOCKER_REPO/catamel

echo $CATANIE_REPO


helm del --purge local-mongodb
helm del --purge local-rabbit
helm del --purge local-node
helm del --purge local-kafka

for file in $NS_DIR; do
  f="$(basename $file)"
  ns="${f%.*}"
  kubectl create -f $file
  export LOCAL_ENV="$ns"
  helm install stable/mongodb --version 0.4.15 --namespace $LOCAL_ENV --name local-mongodb
        if [[ "KAFKA" -eq "1" ]]; then

helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
  helm install --name local-kafka incubator/kafka --namespace $LOCAL_ENV 
fi
  helm install stable/rabbitmq --version 0.6.3 --namespace $LOCAL_ENV --name local-rabbit --set rabbitmqUsername=admin,rabbitmqPassword=admin
  helm install services/node-red --namespace dev --name local-node
done

# Deploy services

SERVICES_DIR=./services/*/*.sh

for file in $SERVICES_DIR; do
  sh $file $LOCAL_IP $CATANIE_REPO $CATAMEL_REPO
done


