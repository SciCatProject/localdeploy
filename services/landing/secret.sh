openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout landing.key -out landing.crt -subj "/CN=scicat07.esss.lu.se" -days 3650
openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout landingdev.key -out landingdev.crt -subj "/CN=scicat06.esss.lu.se" -days 3650

kubectl delete secret -nproduction landingserverservice
kubectl delete secret -ndev landingserverservice

kubectl create secret -nproduction tls landingserverservice --key landing.key --cert landing.crt
kubectl create secret -ndev tls landingserverservice --key landingdev.key --cert landingdev.crt
