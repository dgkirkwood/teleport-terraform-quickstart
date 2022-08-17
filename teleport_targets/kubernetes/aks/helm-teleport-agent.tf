provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.teleport.kube_config.0.host
    client_certificate = base64decode(azurerm_kubernetes_cluster.teleport.kube_config.0.client_certificate)
    client_key = base64decode(azurerm_kubernetes_cluster.teleport.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.teleport.kube_config.0.cluster_ca_certificate)
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
    value = var.label_environment
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