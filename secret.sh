#!/usr/bin/env bash

openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout cataniedev.key -out cataniedev.crt -subj "/CN=scicat07.esss.lu.se" -days 3650
openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout catanieqa.key -out catanieqa.crt -subj "/CN=scicat08.esss.lu.se" -days 3650
openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout catanie.key -out catanie.crt -subj "/CN=scitest.esss.lu.se" -days 3650

openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout catameldev.key -out catameldev.crt -subj "/CN=scicat07.esss.lu.se" -days 3650
openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout catamelqa.key -out catamelqa.crt -subj "/CN=scicat08.esss.lu.se" -days 3650
openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout catamel.key -out catamel.crt -subj "/CN=scitest.esss.lu.se" -days 3650

kubectl delete secret -ndev catanieservice
kubectl delete secret -nqa catanieservice
kubectl delete secret -nproduction catanieservice

kubectl create secret -ndev  tls catanieservice --key cataniedev.key --cert cataniedev.crt
kubectl create secret -nqa tls catanieservice --key catanieqa.key --cert catanieqa.crt
kubectl create secret -nproduction tls catanieservice --key catanie.key --cert catanie.crt

kubectl delete secret -ndev catamelservice
kubectl delete secret -nqa catamelservice
kubectl delete secret -nproduction catamelservice

kubectl create secret -ndev tls catamelservice --key catameldev.key --cert catameldev.crt
kubectl create secret -nqa tls catamelservice --key catamelqa.key --cert catamelqa.crt
kubectl create secret -nproduction tls catamelservice --key catamel.key --cert catamel.crt