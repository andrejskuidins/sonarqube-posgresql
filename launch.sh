go install sigs.k8s.io/kind@v0.24.0
export PATH=$HOME/.local/bin:$HOME/go/bin:$PATH
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 30000
    hostPort: 30000
    protocol: TCP
EOF
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
helm install postgres -f pg.yml oci://registry-1.docker.io/bitnamicharts/postgresql
sleep 90
kubectl apply -f secret.yml
helm repo add oteemocharts https://oteemo.github.io/charts
helm install sonarqube -f sq.yml oteemocharts/sonarqube

# Sounarsource option as oteemo is deprecated
# helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
# helm upgrade --install sonarqube -f sonarqube.yml sonarqube/sonarqube
