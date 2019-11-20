#!/usr/bin/env bash
if [ "$#" -ne 1 ]; then
  echo "Usage ./catanie.sh ENVIRONMENT" >&2
  exit 1
fi
export env=$1

#envarray=(dmsc)
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


#echo $1

#for ((i=0;i<${#envarray[@]};i++)); do
#export LOCAL_ENV="${envarray[i]}"
#export LOCAL_IP="$1"
#echo $LOCAL_ENV
#helm del --purge catanie
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
export tag=$(git rev-parse HEAD)
echo "Deploying to Kubernetes"
cd ..

function docker_tag_exists() {
    curl --silent -f -lSL https://index.docker.io/v1/repositories/$1/tags/$2 > /dev/null
}

if docker_tag_exists dacat/catanie latest; then
    echo exists
    helm upgrade catanie dacat-gui --wait --recreate-pods --namespace=${env} --set image.tag=$tag$env
    helm history catanie
else
    echo not exists
fi
#done
