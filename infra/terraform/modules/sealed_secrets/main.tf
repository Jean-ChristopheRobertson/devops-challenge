terraform {
  required_version = ">= 1.8.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.14"
    }
  }
}

resource "helm_release" "sealed_secrets" {
  name             = "sealed-secrets"
  repository       = "https://bitnami.github.io/sealed-secrets"
  chart            = "sealed-secrets"
  namespace        = "kube-system"
  create_namespace = false
  wait             = true

  set {
    name  = "fullnameOverride"
    value = "sealed-secrets-controller"
  }
}