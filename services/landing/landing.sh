envarray=(dev)


echo $1

   export LOCAL_ENV="${envarray[i]}"
   echo $LOCAL_ENV
helm del --purge landing
cd services/landing/
   if [ -d "./component/" ]; then
	cd component
     git pull 
   else
git clone https://github.com/garethcmurphy/landingpageserver.git component
	cd component
   fi
export FILESERVER_IMAGE_VERSION=$(git rev-parse HEAD)
docker build . -t garethcmurphy/landingpageserver:$FILESERVER_IMAGE_VERSION$LOCAL_ENV
docker push garethcmurphy/landingpagerserver:$FILESERVER_IMAGE_VERSION$LOCAL_ENV
echo "Deploying to Kubernetes"
cd ..
cd ..
pwd
echo helm install landing --name landing --namespace $LOCAL_ENV --set image.tag=$FILESERVER_IMAGE_VERSION$LOCAL_ENV --set image.repository=garethcmurphy/landingpageserver
helm install landing --name landing --namespace $LOCAL_ENV --set image.tag=$FILESERVER_IMAGE_VERSION$LOCAL_ENV --set image.repository=garethcmurphy/landingpageserver
# envsubst < ../catanie-deployment.yaml | kubectl apply -f - --validate=false



