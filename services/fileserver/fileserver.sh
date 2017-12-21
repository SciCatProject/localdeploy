cd services/fileserver/
   if [ -d "./minitornado/" ]; then
	cd minitornado
     git pull 
   else
git clone https://github.com/garethcmurphy/minitornado.git
	cd minitornado
   fi
cd tornado
docker build . -t garethcmurphy/tornado



