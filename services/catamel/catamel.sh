#!/usr/bin/env bash

export REPO=https://github.com/SciCatProject/catamel.git
envarray=(dev)


INGRESS_NAME=" "
if [ "$(hostname)" == "kubetest01.dm.esss.dk" ]; then
    INGRESS_NAME="-f ./dacat-api-server/dmsc.yaml"
    elif  [ "$(hostname)" == "scicat01.esss.lu.se" ]; then
    INGRESS_NAME="-f ./dacat-api-server/lund.yaml"
    elif  [ "$(hostname)" == "k8-lrg-serv-prod.esss.dk" ]; then
    INGRESS_NAME="-f ./dacat-api-server/dmscprod.yaml"
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
    fi
    export CATAMEL_IMAGE_VERSION=$(git rev-parse HEAD)
    echo "Deploying to Kubernetes"
    cd ..
    function docker_tag_exists() {
        curl --silent -f -lSL https://index.docker.io/v1/repositories/$1/tags/$2 > /dev/null
    }
    
    if docker_tag_exists dacat/catamel $CATAMEL_IMAGE_VERSION$LOCAL_ENV; then
        echo exists
        helm install dacat-api-server --name catamel --namespace $LOCAL_ENV --set image.tag=$CATAMEL_IMAGE_VERSION$LOCAL_ENV --set image.repository=$3 ${INGRESS_NAME}
    else
        echo not exists
    fi
    # envsubst < ../catanie-deployment.yaml | kubectl apply -f - --validate=false
done
