terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0.1"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

# Apply secret and pgadmin manifests
resource "null_resource" "apply_manifests" {
  provisioner "local-exec" {
    command = "kubectl apply -f secret.yml && kubectl apply -f pgadmin.yml"
  }
}

# PostgreSQL
resource "helm_release" "postgresql" {
  name             = "postgresql"
  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "postgresql"
  namespace        = "default"
  create_namespace = false
  timeout          = 600

  values = [file("${path.module}/postgres.yml")]

  depends_on = [null_resource.apply_manifests]
}

# SonarQube
resource "helm_release" "sonarqube" {
  name       = "sonarqube"
  repository = "https://SonarSource.github.io/helm-chart-sonarqube"
  chart      = "sonarqube"
  namespace  = "default"
  timeout    = 6000

  values = [file("${path.module}/sonarqube.yml")]

  depends_on = [helm_release.postgresql]
}
