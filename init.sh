#!/usr/bin/env bash
env="dev"


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


cd services/catanie

cd component
git pull
export tag=$(git rev-parse HEAD)
cd ..


#helm install --name=catanie-${env} dacat-gui  --namespace=${env} --set image.tag=$tag$env --wait  ${INGRESS_NAME}
envarray=( production qa)
for ((i=0;i<${#envarray[@]};i++)); do
    export env="${envarray[i]}"
    helm install --name=catanie-${env} dacat-gui  --namespace=${env} --set image.tag=$tag$env --wait 
done

cd ../..