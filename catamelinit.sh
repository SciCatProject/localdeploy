#!/usr/bin/env bash
env="dev"



cd services/catanie

cd component
git pull
export tag=$(git rev-parse HEAD)
cd ..


envarray=(dev production qa)
for ((i=0;i<${#envarray[@]};i++)); do
    export env="${envarray[i]}"
    helm install --name=catamel-${env} dacat-gui  --namespace=${env} --set image.tag=$tag$env --wait 
done

cd ../..