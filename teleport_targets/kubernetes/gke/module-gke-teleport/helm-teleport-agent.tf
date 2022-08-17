provider "helm" {
  kubernetes {
    host = "https://${google_container_cluster.primary.endpoint}"

    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}

resource "helm_release" "teleportagent" {
  name = "teleportagent"
  repository = "https://charts.releases.teleport.dev"
  chart = "teleport-kube-agent"
  namespace = "teleport-agent"
  create_namespace = true
  set {
    name = "kubeClusterName"
    value = var.clustername
  }
  set {
    name = "proxyAddr"
    value = var.proxy_address
  }
  set {
    name = "authToken"
    value = var.auth_token
  }
  set {
    name = "labels.environment"
    value = var.label-environment
  }
  set {
    name = "labels.cloud"
    value = "gcp"
  }
  set {
    name = "labels.region"
    value = var.region
  }
  set {
    name = "labels.node-count"
    value = google_container_node_pool.primary_nodes.node_count
  }
  set {
    name = "labels.kube-version"
    value = google_container_cluster.primary.master_version
  }
}