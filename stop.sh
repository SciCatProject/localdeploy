#!/bin/bash

minikube stop
kubectl config use-context admin@kubernetes
docker login registry.psi.ch/v2
