#!/bin/bash

aws eks update-kubeconfig --name wordpress-cluster
kubectl get nodes
