#!/bin/bash

envarray=(dmsc)

INGRESS_NAME=" "
BUILD="true"
if [ "$(hostname)" == "kubetest01.dm.esss.dk" ]; then
    envarray=(dmsc)
    INGRESS_NAME="-f ./synapse/dmsc.yaml"
    BUILD="false"
    elif  [ "$(hostname)" == "scicat01.esss.lu.se" ]; then
    envarray=(ess)
    INGRESS_NAME="-f ./synapse/lund.yaml"
    BUILD="false"
    elif  [ "$(hostname)" == "k8-lrg-serv-prod.esss.dk" ]; then
    envarray=(dmscprod)
    INGRESS_NAME="-f ./synapse/dmscprod.yaml"
    BUILD="false"
fi

export REPO=https://github.com/SciCatProject/synapse.git
portarray=(30021 30023)
hostextarray=('-qa' '')
certarray=('discovery' 'discovery')

echo $1

for ((i=0;i<${#envarray[@]};i++)); do
    export LOCAL_ENV="${envarray[i]}"
    export PORTOFFSET="${portarray[i]}"
    export HOST_EXT="${hostextarray[i]}"
    export CERTNAME="${certarray[i]}"
    export LOCAL_IP="$1"
    echo $LOCAL_ENV $PORTOFFSET $HOST_EXT
    echo $LOCAL_ENV
    helm del --purge synapse
    cd ./services/synapse/
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
    export SYNAPSE_IMAGE_VERSION=$(git rev-parse HEAD)
    if  [[ $BUILD == "true" ]]; then
        docker build -t $2:$SYNAPSE_IMAGE_VERSION$LOCAL_ENV -t $2:latest --build-arg env=$LOCAL_ENV .
        echo docker build -t $2:$SYNAPSE_IMAGE_VERSION$LOCAL_ENV --build-arg env=$LOCAL_ENV .
        docker push $2:$SYNAPSE_IMAGE_VERSION$LOCAL_ENV
        echo docker push $2:$SYNAPSE_IMAGE_VERSION$LOCAL_ENV
    fi
    echo "Deploying to Kubernetes"
    cd ..
    helm install synapse --name synapse --namespace $LOCAL_ENV --set image.tag=$SYNAPSE_IMAGE_VERSION$LOCAL_ENV --set image.repository=$2 ${INGRESS_NAME}
    echo helm install synapse --name synapse --namespace $LOCAL_ENV --set image.tag=$SYNAPSE_IMAGE_VERSION$LOCAL_ENV --set image.repository=$2
    # envsubst < ../synapse-deployment.yaml | kubectl apply -f - --validate=false
done
