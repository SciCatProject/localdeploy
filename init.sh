#!/usr/bin/env bash
env=dev
cd services/catanie
helm install catanie-${env} dacat-gui  --namespace=${env} --set image.tag=$tag$env