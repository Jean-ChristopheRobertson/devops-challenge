terraform {
  required_version = ">= 1.8.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.14"
    }
  }
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig"
  type        = string
}

variable "kube_context" {
  description = "Kubernetes context name"
  type        = string
  default     = "minikube"
}

provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kube_context
}

provider "helm" {
  kubernetes {
    config_path    = var.kubeconfig_path
    config_context = var.kube_context
  }
}

module "argocd" {
  source = "../../modules/argocd"
}

module "gitops_app" {
  source                    = "../../modules/gitops_app"
  application_manifest_path = "${path.module}/../../../../argocd/applications/devops-challenge.yaml"

  depends_on = [module.argocd]
}
