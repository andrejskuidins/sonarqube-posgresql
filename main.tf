terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# PostgreSQL
resource "helm_release" "postgresql" {
  name             = "postgresql"
  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "postgresql"
  namespace        = "default"
  create_namespace = false

  values = [file("${path.module}/postgres.yml")]
}

# SonarQube
resource "helm_release" "sonarqube" {
  name       = "sonarqube"
  repository = "https://SonarSource.github.io/helm-chart-sonarqube"
  chart      = "sonarqube"
  namespace  = "default"

  values = [file("${path.module}/sonarqube.yml")]

  depends_on = [helm_release.postgresql]
}

# PgAdmin
resource "kubernetes_manifest" "pgadmin" {
  manifest = yamldecode(file("${path.module}/pgadmin.yml"))

  depends_on = [helm_release.postgresql]
}

# Secret
resource "kubernetes_manifest" "secret" {
  manifest = yamldecode(file("${path.module}/secret.yml"))
}
