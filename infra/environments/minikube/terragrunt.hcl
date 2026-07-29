include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

terraform {
  source = "${get_terragrunt_dir()}/../../..//infra/terraform/environments/minikube"
}
