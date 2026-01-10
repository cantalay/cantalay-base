terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
    }
    vault = {
      source = "hashicorp/vault"
    }
  }
}
variable "postgres_password" {
  type      = string
  sensitive = true
}

variable "postgres_admin_password" {
  type      = string
  sensitive = true
}
############################################
# Namespace
############################################

resource "kubernetes_namespace_v1" "postgresql" {
  metadata {
    name = "database"
  }
}

############################################
# PostgreSQL Helm Release
############################################

resource "helm_release" "postgresql" {
  name      = "postgresql"
  namespace = kubernetes_namespace_v1.postgresql.metadata[0].name

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "18.1.13"

  values = [
    file("${path.module}/values-postgresql.yaml")
  ]

  set = [
    {
      name  = "auth.password"
      value = var.postgres_password
    },
    {
      name  = "auth.postgresPassword"
      value = var.postgres_admin_password
    }
  ]

  depends_on = [
    kubernetes_namespace_v1.postgresql,
  ]
}
