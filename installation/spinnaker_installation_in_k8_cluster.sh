#!/bin/bash

echo "Installing Kubectl"

kubectl version

echo $?

if [ $? -ne 0 ]
then

    echo "Kubectl not installed"
    echo "Installing Kubectl using CURL:"
    curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
    echo "Make the kubectl binary executable:"
    chmod +x ./kubectl
    echo "Move the binary in to your PATH:"
    sudo mv ./kubectl /usr/local/bin/kubectl
    echo "Test to ensure the version you installed is up-to-date:"
    kubectl version

else 
	    echo "Kubectl is already installed"

fi

echo "Installing Minikube"
minikube start 
echo $?
if [ $? -ne 0 ]
then
	curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
      && chmod +x minikube
    sudo mkdir -p /usr/local/bin/
    sudo install minikube /usr/local/bin/
    minikube start --memory=10000 --cpus=2 --kubernetes-version=v1.15.3

else 
   
   echo "Minikube Already installed"

fi 

helm version
if [ $? -ne 0 ]
then
    echo "Installing Helm"
    curl -L https://git.io/get_helm.sh | bash -s -- --version v2.14.1
    helm init 
else
    echo "Helm is already installed" 

fi       


helm install stable/spinnaker --name spinnaker --namespace=spinnaker
echo "port-forwarding"
export DECK_POD=$(kubectl get pods --namespace spinnaker -l "cluster=spin-deck" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward --namespace spinnaker $DECK_POD 9000 &
export GATE_POD=$(kubectl get pods --namespace spinnaker -l "cluster=spin-gate" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward --namespace spinnaker $GATE_POD 8084 &
echo "Entered into Helm"
kubectl exec --namespace spinnaker -it spinnaker-spinnaker-halyard-0 bash 
hal config features edit --artifacts true  
hal config artifact github enable 
GITHUB_ACCOUNT_NAME=github_user 
hal config artifact github account add ${GITHUB_ACCOUNT_NAME} \
  --token 
hal deploy apply


