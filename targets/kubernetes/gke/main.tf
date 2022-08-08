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
  clustername = "minas-morgul"
  project_id = var.project_id
  region     = var.region
  proxy_address = var.proxy_address
  auth_token = "aedbd1630fecc9b166767a4448b59351"
  label-environment = "production"
}


