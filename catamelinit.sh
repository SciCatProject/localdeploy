#!/usr/bin/env bash
env="dev"



cd services/catamel

cd component
git pull
export tag=$(git rev-parse HEAD)
cd ..


envarray=(dev production qa)
envarray=(dev qa)
for ((i=0;i<${#envarray[@]};i++)); do
    export env="${envarray[i]}"
    helm del --purge catamel-${env}
    helm install --name=catamel-${env} dacat-api-server  --namespace=${env} --set image.tag=$tag$env --wait 
done

cd ../..