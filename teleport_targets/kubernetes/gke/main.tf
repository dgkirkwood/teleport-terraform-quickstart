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
  auth_token = "cba296805454b9555dee0e39e1489172"
  label-environment = "production"
}


