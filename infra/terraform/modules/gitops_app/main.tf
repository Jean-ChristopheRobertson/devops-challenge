terraform {
  required_version = ">= 1.8.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32"
    }
  }
}

variable "application_manifest_path" {
  description = "Path to an Argo CD Application manifest"
  type        = string
}

resource "kubernetes_manifest" "app" {
  manifest = yamldecode(file(var.application_manifest_path))
}
