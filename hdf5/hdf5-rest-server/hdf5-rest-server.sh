envarray=(dev)


echo $1

   export LOCAL_ENV="${envarray[i]}"
   echo $LOCAL_ENV
helm del --purge hdf5-rest-server
cd hdf5/hdf5-rest-server
   if [ -d "./component/" ]; then
	cd component
#     git pull 
   else
#git clone https://github.com/garethcmurphy/minitornado.git component
	cd component
   fi
export FILESERVER_IMAGE_VERSION=$(git rev-parse HEAD)
docker build . -t garethcmurphy/hdf5-rest-server:$FILESERVER_IMAGE_VERSION$LOCAL_ENV
docker push garethcmurphy/hdf5-rest-server:$FILESERVER_IMAGE_VERSION$LOCAL_ENV
echo "Deploying to Kubernetes"
cd ..
cd ..
pwd
echo helm install hdf5-rest-server --name hdf5-rest-server --namespace $LOCAL_ENV --set image.tag=$FILESERVER_IMAGE_VERSION$LOCAL_ENV --set image.repository=garethcmurphy/hdf5-rest-server
helm install hdf5-rest-server --name hdf5-rest-server --namespace $LOCAL_ENV --set image.tag=$FILESERVER_IMAGE_VERSION$LOCAL_ENV --set image.repository=garethcmurphy/hdf5-rest-server
# envsubst < ../catanie-deployment.yaml | kubectl apply -f - --validate=false



