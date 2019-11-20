#!/usr/bin/env bash
env="dev"
cd services/catanie

cd component
git pull
export tag=$(git rev-parse HEAD)
cd ..

helm install --name=catanie-${env} dacat-gui  --namespace=${env} --set image.tag=$tag$env --wait

cd ../..