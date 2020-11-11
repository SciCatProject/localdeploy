#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "Usage ./landing.sh ENVIRONMENT" >&2
    exit 1
fi

export env=$1
export REPO=https://github.com/SciCatProject/landingpageserver.git

INGRESS_NAME=" "
if [ "$(hostname)" == "kubetest01.dm.esss.dk" ]; then
    INGRESS_NAME="-f ./landingserver/dmsc.yaml"
elif  [ "$(hostname)" == "scicat09.esss.lu.se" ]; then
    INGRESS_NAME="-f ./landingserver/lund.yaml"
elif  [ "$(hostname)" == "k8-lrg-serv-prod.esss.dk" ]; then
    INGRESS_NAME="-f ./landingserver/dmscprod.yaml"
fi

cd ./services/landing/
if [ -d "./component/" ]; then
    cd component
    git checkout develop
    git pull
else
    git clone $REPO  component
    cd component
    git checkout develop
fi
export tag=$(git rev-parse HEAD)
echo "Deploying to Kubernetes"
cd ..

function docker_tag_exists() {
    curl --silent -f -lSL https://index.docker.io/v1/repositories/$1/tags/$2 > /dev/null
}

if docker_tag_exists dacat/landing $tag$env; then
    echo exists
    if [ "${env}" == "dev" ]; then
        helm upgrade landingserver-${env} landing --wait --recreate-pods --namespace=${env} --set image.tag=$tag$env
    elif [ "${env}" == "production" ]; then
        helm upgrade landingserver-${env} landing --wait --recreate-pods --namespace=${env} --set image.tag=$tag$env ${INGRESS_NAME}
    fi
    helm history landingserver-${env}
else
    echo not exists
fi

