#!/usr/bin/env bash
env="dev"
cd services/catanie

helm install --name=catanie-${env} dacat-gui  --namespace=${env} --set image.tag=$tag$env --wait

cd ../..