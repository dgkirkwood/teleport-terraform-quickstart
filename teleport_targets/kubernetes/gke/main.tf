terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.28.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.6.0"
    }
  }

  required_version = ">= 0.14"
}

module "gke_clusters" {
  source            = "./module-gke-teleport"
  for_each          = var.gke_clusters
  clustername       = each.value.cluster_name
  project_id        = var.project_id
  region            = var.region
  proxy_address     = var.proxy_address
  auth_token        = var.token
  label-environment = each.value.environment
}



