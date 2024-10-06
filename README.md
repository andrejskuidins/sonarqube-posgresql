# SonarQube on Kubernetes Kind Cluster

## About the Project

This project sets up a local Kubernetes cluster using Kind (Kubernetes in Docker) and deploys SonarQube along with a PostgreSQL database. It's designed to provide a quick and easy way to get a SonarQube instance up and running for code quality analysis in a Kubernetes environment.

## Components

### Kubernetes Kind

Kind (Kubernetes in Docker) is a tool for running local Kubernetes clusters using Docker container "nodes". It was primarily designed for testing Kubernetes itself, but can be used for local development or CI workflows.

### SonarQube

SonarQube is an open-source platform developed by SonarSource for continuous inspection of code quality. It performs automatic reviews with static analysis of code to detect bugs, code smells, and security vulnerabilities.

### PostgreSQL

PostgreSQL is a powerful, open-source object-relational database system. In this setup, it's used as the backend database for SonarQube.

## Installation

To set up this project, follow these steps:

1. Install Go and add it to your PATH:
   ```
   go install sigs.k8s.io/kind@v0.24.0
   export PATH=$HOME/.local/bin:$HOME/go/bin:$PATH
   ```

2. Create a Kind cluster with the following configuration:
   ```
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
   ```

3. Apply the NGINX Ingress controller:
   ```
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
   ```

4. Install PostgreSQL using Helm:
   ```
   helm install postgres -f pg.yml oci://registry-1.docker.io/bitnamicharts/postgresql
   ```

5. Wait for PostgreSQL to be ready (approximately 90 seconds):
   ```
   sleep 90
   ```

6. Apply the secret configuration:
   ```
   kubectl apply -f secret.yml
   ```

7. Add the Oteemo Helm repository and install SonarQube:
   ```
   helm repo add oteemocharts https://oteemo.github.io/charts
   helm install sonarqube -f sq.yml oteemocharts/sonarqube
   ```

   **jdbcUrl:
   ```
   jdbc:postgresql://postgres-postgresql.default.svc.cluster.local/sonarDB"
   jdbc:postgresql://postgres-postgresql:5432/sonarDB
   ```

## Usage

After installation, SonarQube should be accessible at `http://localhost:30000`. You can use this instance to analyze your code and track code quality metrics.

## Configuration Files

- `pg.yml`: Contains PostgreSQL configuration for Helm.
- `sq.yml`: Contains SonarQube configuration for Helm.
- `secret.yml`: Contains secret configurations for the setup.

Make sure these files are present in your working directory before running the installation commands.

## Troubleshooting

If you encounter any issues during setup:
1. Ensure Docker is running and Kind is properly installed.
2. Check if the required ports are free on your machine.
3. Verify that all configuration files (`pg.yml`, `sq.yml`, `secret.yml`) are correctly formatted and present in your working directory.

For more detailed information on each component, refer to their official documentation:
- [Kind Documentation](https://kind.sigs.k8s.io/)
- [SonarQube Documentation](https://docs.sonarqube.org/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)