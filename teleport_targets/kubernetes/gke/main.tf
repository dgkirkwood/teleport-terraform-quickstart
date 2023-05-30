module "gke_clusters" {
  source            = "./module-gke-teleport"
  clustername       = var.cluster_name
  project_id        = var.project_id
  region            = var.region
  proxy_address     = var.proxy_address
  auth_token        = var.token
  label-environment = var.environment
  cluster_flavours  = var.cluster_flavours
  teleport_version = var.teleport_version
}



