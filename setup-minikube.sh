#!/bin/bash
set -e

echo "Starting Minikube..."
minikube start --driver=docker \
  --ports=80:80 \
  --ports=443:443 \
  --ports=9000:9000 \
  --ports=5432:5432

echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

echo "Enabling Ingress addon..."
minikube addons enable ingress

echo "Waiting for Ingress controller..."
kubectl wait --for=condition=Available deployment/ingress-nginx-controller \
  -n ingress-nginx --timeout=300s

echo "Initializing Terraform..."
terraform init

echo "Deploying with Terraform..."
terraform apply -auto-approve

echo "Cluster ready!"
kubectl get all -A