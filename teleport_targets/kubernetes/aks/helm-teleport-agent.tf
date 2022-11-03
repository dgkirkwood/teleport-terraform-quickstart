provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.teleport.kube_config.0.host
    client_certificate = base64decode(azurerm_kubernetes_cluster.teleport.kube_config.0.client_certificate)
    client_key = base64decode(azurerm_kubernetes_cluster.teleport.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.teleport.kube_config.0.cluster_ca_certificate)
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
    value = each.value.clustername
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
    value = "azure"
  }
  set {
    name = "labels.region"
    value = var.location
  }
}

