#!/usr/bin/env bash


if [ "$(hostname)" == "kubetest01.dm.esss.dk" ]; then
    kubectl create ns dmsc
	openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout catanie.key -out catanie.crt -subj "/CN=kubetest01.dm.esss.dk" -days 3650
	openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout catamel.key -out catamel.crt -subj "/CN=kubetest02.dm.esss.dk" -days 3650
	openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout landingserver.key -out landingserver.crt -subj "/CN=kubetest03.dm.esss.dk" -days 3650
	openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout fileserver.key -out fileserver.crt -subj "/CN=kubetest04.dm.esss.dk" -days 3650

	kubectl create secret -ndmsc tls catanieservice --key catanie.key --cert catanie.crt
	kubectl create secret -ndev tls catamelservice --key catamel.key --cert catamel.crt
	kubectl create secret -ndmsc tls landingserverservice --key landingserver.key --cert landingserver.crt
	kubectl create secret -ndev tls fileserverservice --key fileserver.key --cert fileserver.crt
elif  [ "$(hostname)" == "scicat01.esss.lu.se" ]; then
    kubectl create ns ess
	openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout catanie.key -out catanie.crt -subj "/CN=scicat01.esss.lu.se" -days 3650
	openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout catamel.key -out catamel.crt -subj "/CN=scicat03.esss.lu.se" -days 3650
	openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout landingserver.key -out landingserver.crt -subj "/CN=scicat02.esss.lu.se" -days 3650
	#openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout fileserver.key -out fileserver.crt -subj "/CN=scicat03.esss.lu.se" -days 3650

	kubectl create secret -ness tls catanieservice --key catanie.key --cert catanie.crt
	kubectl create secret -ness tls landingserverservice --key landingserver.key --cert landingserver.crt
	kubectl create secret -ndev tls catamelservice --key catamel.key --cert catamel.crt
	# kubectl create secret -ndev tls fileserverservice --key fileserver.key --cert fileserver.crt
elif  [ "$(hostname)" == "k8-lrg-prod.esss.dk" ]; then
	openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout catanie.key -out catanie.crt -subj "/CN=scicat.esss.dk" -days 3650
	openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout catamel.key -out catamel.crt -subj "/CN=scicatapi.esss.dk" -days 3650
	openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout fileserver.key -out fileserver.crt -subj "/CN=scicatfileserver.esss.dk" -days 3650
	kubectl create secret -ndmscprod tls catanieservice --key catanie.key --cert catanie.crt
	kubectl create secret -ndev tls catamelservice --key catamel.key --cert catamel.crt
	kubectl create secret -ndev tls fileserverservice --key fileserver.key --cert fileserver.crt
	
fi
