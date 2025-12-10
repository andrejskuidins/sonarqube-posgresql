#!/bin/bash
set -e  # Exit on any error


go install sigs.k8s.io/kind@v0.30.0
export PATH=$HOME/.local/bin:$HOME/go/bin:$PATH


# --- CHECK FOR EXISTING CLUSTER ---
if kind get clusters | grep -q "^kind$"; then
  echo "Cluster 'kind' already exists. Skipping creation."
else
  echo "Creating cluster 'kind'..."
  cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
  - containerPort: 9000
    hostPort: 9000
    protocol: TCP
  - containerPort: 5432
    hostPort: 5432
    protocol: TCP
EOF
fi


echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s
kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
echo "Cluster created successfully!"
echo ###############################

kubectl apply -f secret.yml
helm upgrade --install postgresql -f postgres.yml oci://registry-1.docker.io/bitnamicharts/postgresql
echo "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=Ready pod/postgresql-0 \
  --namespace=default --timeout=300s
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update
helm upgrade --install sonarqube -f sonarqube.yml  sonarqube/sonarqube

kubectl apply -f pgadmin.yml
