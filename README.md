# SciCat Localdeploy

## What?

The purpose of this repo is to create a minimal install of the Data Catalog project into a minikube cluster on your machine, with a configurable number of namespaces

### Software required:

* Docker
* MongoDB - running locally is easiest, but this will be installed by Helm
* RabbitMQ - running locally is easiest, but this will be installed by Helm
* Homebrew (OS X only)
* Node
* npm

### Software auto installed;

* Minikube
* Kubectl
* Helm

### If using macos, Docker hub account



## How? 

1. Install.sh

Running this will install:
* Minikube
* Kubectl 
* Helm 

2. Start.sh

Running this will start minikube and set up helm access.
It will also deploy a registry for docker images and an nginx ingress controller. 

NOTE: If you are using OS X, you cannot use a local registry as Docker is running inside a VM and you need to forward the port from within there. 
If you are running a local docker registry, you will need to port forward this connection and these can be found in `proxies.sh`

3. run.sh -d {DOCKER_REPO}

This looks inside the namespaces directory and creates them (default is only to make `dev`.

You will need to provide a docker repo (defaulting to localhost) if, for example, you are using a different registry. It needs to be the **full qualified address**.

For each namespace, a Rabbit MQ and MongoDB pod is deployed.

The services directory contains all custom code and this is deployed through helm. 

* First, the image is built using the script
* The image is then pushed to your docker regsitry and tagged
* Once pushed, the helm script starts and pulls down the image and deploys it into the `dev` namespace

4. `kubectl proxy`

Running the above command will allow you to view the Kubernetes dashboard at 127.0.0.1:8001/ui and you should see all services under the dev namespace.

5. Proxies for Catanie and Catamel

```
kubectl port-forward --namespace dev $(kubectl get po -n dev | grep catanie | awk '{print $1;}') 8000:80
kubectl port-forward --namespace dev $(kubectl get po -n dev | grep catamel | awk '{print $1;}') 3000:3000
```

### Setup

The scripts in this repository should do most of the work for you, that work is summarised here:

1. Install Minikube 
2. Install kubectl and helm
3. A separate run script will start a docker registry locally on your machine and configure kubectl to use a minikube instance
4. Clone and set up docker images for each component and deploy to the docker registry.
5. Pull into namespaces the components, as well as prebuilt images (RabbitMQ, Mongo etc)

## Notes

https://docs.docker.com/registry/insecure/

## Snippets

### Changing config

`kubectl config use-context <context-name>

### Access service

`kubectl run early-ibis-mongodb-client --rm --tty -i --image bitnami/mongodb --command -- mongo --host early-ibis-mongodb`

#### Port Forward Pod

```
export POD_NAME=$(kubectl get pods --namespace dev -l "app=calico-lynx-rabbitmq" -o jsonpath="{.items[0].metadata.name}")                                                
kubectl port-forward $POD_NAME 5672:5672 15672:15672 
```

#### Access Dashboard

`kubectl proxy`
`http://127.0.0.1:8002/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/#!/overview`
