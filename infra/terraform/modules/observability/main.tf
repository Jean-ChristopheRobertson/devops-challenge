terraform {
  required_version = ">= 1.8.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.14"
    }
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  wait             = true
  timeout          = 600

  set {
    name  = "grafana.defaultDashboardsEnabled"
    value = "true"
  }

  set {
    name  = "grafana.sidecar.dashboards.enabled"
    value = "true"
  }

  set {
    name  = "prometheus.prometheusSpec.retention"
    value = "7d"
  }
}

resource "helm_release" "blackbox_exporter" {
  name             = "prometheus-blackbox-exporter"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus-blackbox-exporter"
  namespace        = "monitoring"
  create_namespace = false
  wait             = true
  timeout          = 300

  values = [yamlencode({
    config = {
      modules = {
        local_https = {
          prober  = "http"
          timeout = "5s"
          http = {
            valid_http_versions = ["HTTP/1.1", "HTTP/2.0"]
            preferred_ip_protocol = "ip4"
            tls_config = {
              insecure_skip_verify = true
            }
            headers = {
              Host = "devops-challenge.127.0.0.1.nip.io"
            }
          }
        }
      }
    }
  })]

  depends_on = [helm_release.kube_prometheus_stack]
}