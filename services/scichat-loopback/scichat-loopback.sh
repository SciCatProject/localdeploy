#!/bin/bash

envarray=(dev)

INGRESS_NAME=" "
BUILD="true"
if [ "$(hostname)" == "kubetest01.dm.esss.dk" ]; then
    envarray=(dev)
    INGRESS_NAME="-f ./scichat/dmsc.yaml"
    BUILD="false"
    elif  [ "$(hostname)" == "scicat01.esss.lu.se" ]; then
    envarray=(dev)
    INGRESS_NAME="-f ./scichat/lund.yaml"
    BUILD="false"
    elif  [ "$(hostname)" == "k8-lrg-serv-prod.esss.dk" ]; then
    envarray=(dev)
    INGRESS_NAME="-f ./scichat/dmscprod.yaml"
    BUILD="false"
fi

export DACATHOME=/home/encima/dev/psi
export REPO=https://github.com/SciCatProject/scichat-loopback.git
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
    helm del --purge scichat-loopback
    cd ./services/scichat-loopback/
    if [ -d "./component/" ]; then
        cd component/
        git checkout master
        git pull
        if  [[ $BUILD == "true" ]]; then
            npm install
        fi
    else
        git clone $REPO component
        cd component/
        git checkout master
        git pull
        
        echo "Building release"
        if  [[ $BUILD == "true" ]]; then
            npm install
        fi
    fi
    export SCICHAT_IMAGE_VERSION=$(git rev-parse HEAD)
	repo="dacat/scichat-loopback"
    if  [[ $BUILD == "true" ]]; then
        docker build -t ${repo}:$SCICHAT_IMAGE_VERSION$LOCAL_ENV -t ${repo}:latest --build-arg env=$LOCAL_ENV .
        echo docker build -t ${repo}:$SCICHAT_IMAGE_VERSION$LOCAL_ENV --build-arg env=$LOCAL_ENV .
        docker push ${repo}:$SCICHAT_IMAGE_VERSION$LOCAL_ENV
        echo docker push ${repo}:$SCICHAT_IMAGE_VERSION$LOCAL_ENV
    fi
    echo "Deploying to Kubernetes"
    cd ..
    helm install scichat --name scichat-loopback --namespace $LOCAL_ENV --set image.tag=$SCICHAT_IMAGE_VERSION$LOCAL_ENV --set image.repository=${repo} ${INGRESS_NAME}

    echo helm install scichat --name scichat-loopback --namespace $LOCAL_ENV --set image.tag=$SCICHAT_IMAGE_VERSION$LOCAL_ENV --set image.repository=${repo}
done
