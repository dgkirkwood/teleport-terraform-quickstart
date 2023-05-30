provider "helm" {
  kubernetes {
    host = "https://${google_container_cluster.primary.endpoint}"

    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}

resource "helm_release" "teleportagent" {
  for_each = var.cluster_flavours
  name = "teleportagent-${each.value.environment}"
  repository = "https://charts.releases.teleport.dev"
  chart = "teleport-kube-agent"
  namespace = "teleport-agent-${each.value.environment}"
  create_namespace = true
  version = var.teleport_version
  set {
    name = "kubeClusterName"
    value = each.value.cluster_name
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
    value = each.value.environment
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

# resource "helm_release" "teleportagent" {
#   for_each = var.cluster_flavours
#   name = "teleportagent-${each.value.environment}"
#   repository = "https://charts.releases.teleport.dev"
#   chart = "teleport-kube-agent"
#   namespace = "teleport-agent-${each.value.environment}"
#   create_namespace = true
#   set {
#     name = "kubeClusterName"
#     value = each.value.clustername
#   }
#   set {
#     name = "proxyAddr"
#     value = var.proxy_address
#   }
#   set {
#     name = "authToken"
#     value = var.auth_token
#   }
#   set {
#     name = "labels.environment"
#     value = each.value.environment
#   }
#   set {
#     name = "labels.cloud"
#     value = "azure"
#   }
#   set {
#     name = "labels.region"
#     value = var.location
#   }
# }
