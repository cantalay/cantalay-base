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

############################################
# Namespace
############################################

resource "kubernetes_namespace_v1" "redis" {
  metadata {
    name = "redis"
  }
}

variable "redis_password" {
  type      = string
  sensitive = true
}

############################################
# Redis Helm Release
############################################

resource "helm_release" "redis" {
  name       = "redis"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"
  version    = "24.1.0"

  namespace = kubernetes_namespace_v1.redis.metadata[0].name

  values = [
    file("${path.module}/values-redis.yaml")
  ]

  timeout = 600
  atomic  = true

  set = [
    {
      name  = "auth.password"
      value = var.redis_password
    }
  ]

  depends_on = [
    kubernetes_namespace_v1.redis
      ]
}
