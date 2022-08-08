variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

variable "clustername" {
  description = "unique name for your cluster"
}

variable "gke_num_nodes" {
  default     = 1
  description = "number of gke nodes"
}

variable "auth_token" {
  description = "The token generated from your Teleport proxy"
}

variable "app_auth_token" {
  description = "The app token generated from your Teleport proxy"
}

variable "proxy_address" {
  description = "The address of your Teleport proxy"
}

variable "label-environment" {
  description = "Env label for Teleport RBAC"
}

