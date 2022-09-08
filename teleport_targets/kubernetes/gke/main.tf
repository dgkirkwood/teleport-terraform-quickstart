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
  auth_token = "27b20b762bef303b82c91e2ef45f0d27"
  label-environment = "production"
}

module "cluster2" {
  source = "./module-gke-teleport"
  clustername = "moria"
  project_id = var.project_id
  region     = var.region
  proxy_address = var.proxy_address
  auth_token = "27b20b762bef303b82c91e2ef45f0d27"
  label-environment = "staging"
}

module "cluster3" {
  source = "./module-gke-teleport"
  clustername = "misty-mountains"
  project_id = var.project_id
  region     = var.region
  proxy_address = var.proxy_address
  auth_token = "27b20b762bef303b82c91e2ef45f0d27"
  label-environment = "dev"
}



