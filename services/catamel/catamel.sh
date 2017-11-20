#!/bin/bash

export DACATHOME=/home/encima/dev/psi
export REPO=https://github.com/SciCatProject/catamel.git
envarray=(dev)


echo $1

for ((i=0;i<${#envarray[@]};i++)); do
   export LOCAL_ENV="${envarray[i]}"
   export LOCAL_IP="$1"
   echo $LOCAL_ENV
   helm del --purge catamel
   cd ./services/catamel/
   if [ -d "./component/" ]; then
     cd component/
     git pull origin master
   else
     git clone $REPO component
     cd component/
     npm install
     echo "Building release"
   fi
   export CATAMEL_IMAGE_VERSION=$(git rev-parse HEAD)
   docker build -t $3:$CATAMEL_IMAGE_VERSION$LOCAL_ENV .
   docker push $3:$CATAMEL_IMAGE_VERSION$LOCAL_ENV
   echo "Deploying to Kubernetes"
   cd ..
   helm install dacat-api-server --name catamel --namespace $LOCAL_ENV --set image.tag=$CATAMEL_IMAGE_VERSION$LOCAL_ENV --set image.repository=$3
   # envsubst < ../catanie-deployment.yaml | kubectl apply -f - --validate=false
done
