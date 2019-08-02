#!/bin/bash

envarray=(dmsc)

INGRESS_NAME=" "
BUILD="true"
if [ "$(hostname)" == "kubetest01.dm.esss.dk" ]; then
    envarray=(dmsc)
    INGRESS_NAME="-f ./dacat-gui/dmsc.yaml"
    BUILD="false"
    elif  [ "$(hostname)" == "scicat01.esss.lu.se" ]; then
    envarray=(ess)
    INGRESS_NAME="-f ./dacat-gui/lund.yaml"
    BUILD="false"
    elif  [ "$(hostname)" == "k8-lrg-serv-prod.esss.dk" ]; then
    envarray=(dmscprod)
    INGRESS_NAME="-f ./dacat-gui/dmscprod.yaml"
    BUILD="false"
fi

export REPO=https://github.com/SciCatProject/oai-provider-service.git

echo $1

for ((i=0;i<${#envarray[@]};i++)); do
    export LOCAL_ENV="${envarray[i]}"
    export LOCAL_IP="$1"
    echo $LOCAL_ENV $PORTOFFSET $HOST_EXT
    echo $LOCAL_ENV
    helm del --purge oai
    cd ./services/oai/
    if [ -d "./component/" ]; then
        cd component/
        git checkout develop
        git pull
    else
        git clone $REPO component
        cd component/
        git checkout develop
        git pull
    fi
    export CATANIE_IMAGE_VERSION=$(git rev-parse HEAD)
    echo "Deploying to Kubernetes"
    cd ..
    helm install oai --name oai --namespace $LOCAL_ENV --set image.tag=$CATANIE_IMAGE_VERSION$LOCAL_ENV --set image.repository=$2 ${INGRESS_NAME}
    echo helm install oai --name oai --namespace $LOCAL_ENV --set image.tag=$CATANIE_IMAGE_VERSION$LOCAL_ENV --set image.repository=$2
    # envsubst < ../catanie-deployment.yaml | kubectl apply -f - --validate=false
done
