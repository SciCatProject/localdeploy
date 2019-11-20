#!/usr/bin/env bash
env="dev"
cd services/catanie

cd component
export tag=$(git rev-parse HEAD)
cd ..

helm install --name=catanie-${env} dacat-gui  --namespace=${env} --set image.tag=$tag$env --wait

cd ../..