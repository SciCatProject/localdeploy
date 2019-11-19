#!/usr/bin/env bash
envarray=(dmsc)
export REPO=https://github.com/SciCatProject/catanie.git

INGRESS_NAME=" "
if [ "$(hostname)" == "kubetest01.dm.esss.dk" ]; then
    envarray=(dmsc)
    INGRESS_NAME="-f ./dacat-gui/dmsc.yaml"
    elif  [ "$(hostname)" == "scicat01.esss.lu.se" ]; then
    envarray=(ess)
    INGRESS_NAME="-f ./dacat-gui/lund.yaml"
    elif  [ "$(hostname)" == "k8-lrg-serv-prod.esss.dk" ]; then
    envarray=(dmscprod)
    INGRESS_NAME="-f ./dacat-gui/dmscprod.yaml"
fi


echo $1

for ((i=0;i<${#envarray[@]};i++)); do
    export LOCAL_ENV="${envarray[i]}"
    export LOCAL_IP="$1"
    echo $LOCAL_ENV
    helm del --purge catanie
    cd ./services/catanie/
    if [ -d "./component/" ]; then
        cd component/
        git checkout develop
        git pull
        ./CI/ESS/copyimages.sh
    else
        git clone $REPO component
        cd component/
        git checkout develop
        git pull
        ./CI/ESS/copyimages.sh
    fi
    export CATANIE_IMAGE_VERSION=$(git rev-parse HEAD)
    echo "Deploying to Kubernetes"
    cd ..
    helm install dacat-gui --name catanie --namespace $LOCAL_ENV --set image.tag=${CATANIE_IMAGE_VERSION}dmscdev --set image.repository=$2 ${INGRESS_NAME}
done
