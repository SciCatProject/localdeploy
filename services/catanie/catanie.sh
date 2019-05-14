#!/bin/bash

envarray=(dmsc)

INGRESS_NAME=" "
BUILD = "true"
if [ "$(hostname)" == "kubetest01.dm.esss.dk" ]; then
    envarray=(dmsc)
    INGRESS_NAME="-f ./dacat-gui/dmsc.yaml"
    BUILD = "false"
    elif  [ "$(hostname)" == "scicat01.esss.lu.se" ]; then
    envarray=(ess)
    INGRESS_NAME="-f ./dacat-gui/lund.yaml"
    BUILD = "false"
    elif  [ "$(hostname)" == "k8-lrg-serv-prod.esss.dk" ]; then
    envarray=(dmscprod)
    INGRESS_NAME="-f ./dacat-gui/dmscprod.yaml"
    BUILD = "false"
fi

export DACATHOME=/home/encima/dev/psi
export REPO=https://github.com/SciCatProject/catanie.git
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
    helm del --purge catanie
    cd ./services/catanie/
    if [ -d "./component/" ]; then
        cd component/
        git checkout develop
        git pull
        ./CI/ESS/copyimages.sh
        if  [[ $BUILD == "true" ]]; then
            npm install
            ./node_modules/@angular/cli/bin/ng build --configuration $LOCAL_ENV --output-path dist/$LOCAL_ENV
        fi
    else
        git clone $REPO component
        cd component/
        git checkout develop
        git pull
        
        ./CI/ESS/copyimages.sh
        echo "Building release"
        if  [[ $BUILD == "true" ]]; then
            npm install
            ./node_modules/@angular/cli/bin/ng build --configuration $LOCAL_ENV --output-path dist/$LOCAL_ENV
        fi
    fi
    export CATANIE_IMAGE_VERSION=$(git rev-parse HEAD)
    if  [[ $BUILD == "true" ]]; then
        docker build -t $2:$CATANIE_IMAGE_VERSION$LOCAL_ENV -t $2:latest --build-arg env=$LOCAL_ENV .
        echo docker build -t $2:$CATANIE_IMAGE_VERSION$LOCAL_ENV --build-arg env=$LOCAL_ENV .
        docker push $2:$CATANIE_IMAGE_VERSION$LOCAL_ENV
        echo docker push $2:$CATANIE_IMAGE_VERSION$LOCAL_ENV
    fi
    echo "Deploying to Kubernetes"
    cd ..
    helm install dacat-gui --name catanie --namespace $LOCAL_ENV --set image.tag=$CATANIE_IMAGE_VERSION$LOCAL_ENV --set image.repository=$2 ${INGRESS_NAME}
    echo helm install dacat-gui --name catanie --namespace $LOCAL_ENV --set image.tag=$CATANIE_IMAGE_VERSION$LOCAL_ENV --set image.repository=$2
    # envsubst < ../catanie-deployment.yaml | kubectl apply -f - --validate=false
done
