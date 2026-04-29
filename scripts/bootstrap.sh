#!/bin/bash

set -e

echo "Installing kubectl, awscli, eksctl..."

aws eks update-kubeconfig --name wordpress-cluster

echo "Installing Argo CD..."
kubectl create namespace argocd || true
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Done"
