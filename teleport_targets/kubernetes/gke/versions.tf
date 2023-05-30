terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.61.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.19.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.9.0"
    }   
  }

  required_version = ">= 0.14"
}



provider "google" {
  project = var.project_id
  region  = var.region
}


