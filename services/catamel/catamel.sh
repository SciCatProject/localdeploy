#!/usr/bin/env bash
if [ "$#" -ne 1 ]; then
  echo "Usage ./catamel.sh ENVIRONMENT" >&2
  exit 1
fi
export env=$1

export REPO=https://github.com/SciCatProject/catamel.git


echo $1

#export LOCAL_ENV="${envarray[i]}"
#export LOCAL_IP="$1"
#echo $LOCAL_ENV
#helm del --purge catamel
cd ./services/catamel/
if [ -d "./component/" ]; then
    cd component/
    git checkout develop
    git pull
else
    git clone $REPO component
    cd component/
    git checkout develop
fi
tag=$(git rev-parse HEAD)

echo "Deploying to Kubernetes"
cd ..
function docker_tag_exists() {
    curl --silent -f -lSL https://index.docker.io/v1/repositories/$1/tags/$2 > /dev/null
}

if docker_tag_exists dacat/catamel $tag$env; then
    echo exists
    #helm install dacat-api-server --name catamel --namespace $LOCAL_ENV --set image.tag=$CATAMEL_IMAGE_VERSION$LOCAL_ENV --set image.repository=$3 ${INGRESS_NAME}
    helm upgrade dacat-api-server-${env} dacat-api-server --namespace=${env} --set image.tag=$tag$env
    helm history catamel-${env}
    echo "To roll back do: helm rollback --wait --recreate-pods dacat-api-server-${env} revision-number"
else
    echo not exists
fi
# envsubst < ../catanie-deployment.yaml | kubectl apply -f - --validate=false
