#!/bin/bash

# Setup minikube and kubectl
if [ "$(uname)" == "Darwin" ]; then
	brew cask install minikube
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl && chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/
  brew install kubernetes-helm
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
	curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
	curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/
  curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > scripts/get_helm.sh
  chmod +x scripts/get_helm.sh
  sh scripts/get_helm.sh
fi




