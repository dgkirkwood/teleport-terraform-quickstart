variable "project_id" {
  description = "Your GCP project ID"
}

variable "region" {
  description = "The GCP region where your cluster will be deployed"
}

variable "proxy_address" {
  description = "The address of your Teleport proxy, including port"
}

variable "token" {
  description = "The auth token for your Teleport proxy"
}

variable "gke_clusters" {
  description = "A map describing one or more GKE clusters to be created"
}