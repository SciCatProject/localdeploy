#!/usr/bin/env bash
envarray=(dev)


INGRESS_NAME=" "
DOCKERNAME="-f ./Dockerfile"
if [ "$(hostname)" == "kubetest01.dm.esss.dk" ]; then
	envarray=(dmsc)
    INGRESS_NAME="-f ./landingserver/dmsc.yaml"
	DOCKERNAME="-f ./CI/ESS/Dockerfile.dmsc"
elif  [ "$(hostname)" == "scicat01.esss.lu.se" ]; then
	envarray=(ess)
    INGRESS_NAME="-f ./landingserver/lund.yaml"
	DOCKERNAME="-f ./CI/ESS/Dockerfile.ess"
elif  [ "$(hostname)" == "k8-lrg-prod.esss.dk" ]; then
	envarray=(dmscprod)
    INGRESS_NAME="-f ./landingserver/dmscprod.yaml"
	DOCKERNAME="-f ./CI/ESS/Dockerfile.dmscprod"
fi

echo $1

   export LOCAL_ENV="${envarray[i]}"
   echo $LOCAL_ENV
helm del --purge landingserver
cd services/landing/
   if [ -d "./component/" ]; then
	cd component
     git pull 
   else
git clone https://github.com/SciCatProject/landingpageserver.git component
	cd component
   fi
export LANDING_IMAGE_VERSION=$(git rev-parse HEAD)
echo $DOCKERNAME
docker build $DOCKERNAME . -t dacat/landing:$LANDING_IMAGE_VERSION$LOCAL_ENV
docker push dacat/landing:$LANDING_IMAGE_VERSION$LOCAL_ENV
echo "Deploying to Kubernetes"
cd ..
pwd
echo helm install landingserver --name landingserver --namespace $LOCAL_ENV --set image.tag=$LANDING_IMAGE_VERSION$LOCAL_ENV --set image.repository=dacat/landingpageserver ${INGRESS_NAME}
helm install landingserver --name landingserver --namespace $LOCAL_ENV --set image.tag=$LANDING_IMAGE_VERSION$LOCAL_ENV --set image.repository=dacat/landing ${INGRESS_NAME}
# envsubst < ../catanie-deployment.yaml | kubectl apply -f - --validate=false



