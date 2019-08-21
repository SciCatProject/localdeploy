#!/bin/bash

export DACATHOME=/home/encima/dev/psi
export REPO=https://github.com/SciCatProject/catamel.git
envarray=(dev)


INGRESS_NAME=" "
BUILD="false"
DOCKERNAME="-f ./Dockerfile"
if [ "$(hostname)" == "kubetest01.dm.esss.dk" ]; then
    INGRESS_NAME="-f ./dacat-api-server/dmsc.yaml"
    DOCKERNAME="-f ./CI/ESS/Dockerfile.proxy"
    elif  [ "$(hostname)" == "scicat01.esss.lu.se" ]; then
    INGRESS_NAME="-f ./dacat-api-server/lund.yaml"
    DOCKERNAME="-f ./Dockerfile"
    elif  [ "$(hostname)" == "k8-lrg-serv-prod.esss.dk" ]; then
    INGRESS_NAME="-f ./dacat-api-server/dmscprod.yaml"
    DOCKERNAME="-f ./CI/ESS/Dockerfile.proxy"
fi


echo $1

for ((i=0;i<${#envarray[@]};i++)); do
    export LOCAL_ENV="${envarray[i]}"
    export LOCAL_IP="$1"
    echo $LOCAL_ENV
    helm del --purge catamel
    cd ./services/catamel/
    if [ -d "./component/" ]; then
        cd component/
        git checkout develop
        git pull
    else
        git clone $REPO component
        cd component/
        git checkout develop
        if  [[ $BUILD == "true" ]]; then
            npm install
        fi
        echo "Building release"
    fi
    export CATAMEL_IMAGE_VERSION=$(git rev-parse HEAD)
    if  [[ $BUILD == "true" ]]; then
        docker build ${DOCKERNAME} -t $3:$CATAMEL_IMAGE_VERSION$LOCAL_ENV -t $3:latest .
        docker push $3:$CATAMEL_IMAGE_VERSION$LOCAL_ENV
    fi
    echo "Deploying to Kubernetes"
    cd ..
    helm install dacat-api-server --name catamel --namespace $LOCAL_ENV --set image.tag=$CATAMEL_IMAGE_VERSION$LOCAL_ENV --set image.repository=$3 ${INGRESS_NAME}
    # envsubst < ../catanie-deployment.yaml | kubectl apply -f - --validate=false
done
