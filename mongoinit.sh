#!/usr/bin/env bash
envarray=( dev production qa)
for ((i=0;i<${#envarray[@]};i++)); do
    export env="${envarray[i]}"
    helm install stable/mongodb --version 0.4.15  --namespace $env --name mongodb-$env --set persistence.enabled=false
done
