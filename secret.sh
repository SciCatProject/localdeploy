openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout catanie.key -out catanie.crt -subj "/CN=kubetest01.dm.esss.dk" -days 3650
 openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout catamel.key -out catamel.crt -subj "/CN=kubetest02.dm.esss.dk" -days 3650
 openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout fileserver.key -out fileserver.crt -subj "/CN=kubetest04.dm.esss.dk" -days 3650

  kubectl create secret -ndmsc tls catanieservice --key catanie.key --cert catanie.crt
  kubectl create secret -ndev tls catamelservice --key catamel.key --cert catamel.crt
  kubectl create secret -ndev tls fileserverservice --key fileserver.key --cert fileserver.crt
