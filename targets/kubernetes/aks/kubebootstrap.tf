provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.teleport.kube_config.0.host
  client_certificate = base64decode(azurerm_kubernetes_cluster.teleport.kube_config.0.client_certificate)
  client_key = base64decode(azurerm_kubernetes_cluster.teleport.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.teleport.kube_config.0.cluster_ca_certificate)
}

resource "kubernetes_cluster_role_binding" "view" {
  metadata {
    name = "view"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }
  subject {
    kind = "Group"
    name = "viewonly"
    api_group = "rbac.authorization.k8s.io"
  }
}