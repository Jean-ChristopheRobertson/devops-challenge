locals {
  kubeconfig_path = get_env("KUBECONFIG", "~/.kube/config")
  kube_context    = get_env("KUBE_CONTEXT", "minikube")
}

inputs = {
  kubeconfig_path = local.kubeconfig_path
  kube_context    = local.kube_context
}
