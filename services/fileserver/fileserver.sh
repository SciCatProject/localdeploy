envarray=(dev)


echo $1

   export LOCAL_ENV="${envarray[i]}"
   echo $LOCAL_ENV
helm del --purge fileserver
cd services/fileserver/
   if [ -d "./minitornado/" ]; then
	cd minitornado
     git pull 
   else
git clone https://github.com/garethcmurphy/minitornado.git
	cd minitornado
   fi
export FILESERVER_IMAGE_VERSION=$(git rev-parse HEAD)
docker build . -t garethcmurphy/tornado:$FILESERVER_IMAGE_VERSION$LOCAL_ENV
docker push garethcmurphy/tornado:$FILESERVER_IMAGE_VERSION$LOCAL_ENV
echo "Deploying to Kubernetes"
cd ..
cd ..
pwd
echo helm install fileserver --name fileserver --namespace $LOCAL_ENV --set image.tag=$FILESERVER_IMAGE_VERSION$LOCAL_ENV --set image.repository=garethcmurphy/tornado
helm install fileserver --name fileserver --namespace $LOCAL_ENV --set image.tag=$FILESERVER_IMAGE_VERSION$LOCAL_ENV --set image.repository=garethcmurphy/tornado
# envsubst < ../catanie-deployment.yaml | kubectl apply -f - --validate=false



