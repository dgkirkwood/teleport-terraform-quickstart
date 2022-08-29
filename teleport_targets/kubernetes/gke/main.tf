terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.28.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.6.0"
    }   
  }

  required_version = ">= 0.14"
}

module "cluster1" {
  source = "./module-gke-teleport"
  clustername = "bree"
  project_id = var.project_id
  region     = var.region
  proxy_address = var.proxy_address
  auth_token = "75e2f77f5ec82f8009714c3ae5fd544b"
  label-environment = "production"
}

# module "cluster2" {
#   source = "./module-gke-teleport"
#   clustername = "moria"
#   project_id = var.project_id
#   region     = var.region
#   proxy_address = var.proxy_address
#   auth_token = "7a60d96907e2839e7756fa077e15da07"
#   label-environment = "staging"
# }

# module "cluster3" {
#   source = "./module-gke-teleport"
#   clustername = "misty-mountains"
#   project_id = var.project_id
#   region     = var.region
#   proxy_address = var.proxy_address
#   auth_token = "157a05349dd1239889248efae889ef01"
#   label-environment = "dev"
# }



