#!/bin/bash

export DACATHOME=/home/encima/dev/psi
export REPO=git@gitlab.psi.ch:MELANIE/catanie.git
envarray=(dev)
portarray=(30021 30023)
hostextarray=('-qa' '')
certarray=('discovery' 'discovery')

echo $1

for ((i=0;i<${#envarray[@]};i++)); do
   export CATANIE_IMAGE_VERSION=$(git rev-parse HEAD)
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
     git pull origin master
     ./node_modules/@angular/cli/bin/ng build --environment $LOCAL_ENV -op dist/$LOCAL_ENV
   else
     git clone $REPO component
     cd component/
     npm install
     echo "Building release"
     ./node_modules/@angular/cli/bin/ng build --environment $LOCAL_ENV -op dist/$LOCAL_ENV
   fi
   docker build -t $2:$CATANIE_IMAGE_VERSION$LOCAL_ENV --build-arg env=$LOCAL_ENV .
   docker push $2:$CATANIE_IMAGE_VERSION$LOCAL_ENV
   echo "Deploying to Kubernetes"
   cd ..
   helm install dacat-gui --name catanie --namespace $LOCAL_ENV --set image.tag=$CATANIE_IMAGE_VERSION$LOCAL_ENV --set image.repository=$2
   # envsubst < ../catanie-deployment.yaml | kubectl apply -f - --validate=false
done
