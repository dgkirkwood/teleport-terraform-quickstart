data "azurerm_dns_zone" "existing" {
  name = var.dns_zone
}

# To ensure we can pull the Teleport service IP address from the Kubernetes API, we need to wait for the service to be created.
# In testing this takes on average 20s.
resource "time_sleep" "k8s_svc" {
  depends_on = [ azurerm_kubernetes_cluster.teleport, azurerm_postgresql_flexible_server.teleport ]
  create_duration = "40s"
}

data "kubernetes_service" "teleport" {
  depends_on = [ time_sleep.k8s_svc ]
  metadata {
    name = "teleport"
    namespace = "teleport-cluster"
  }
}


# Creating an A record for the Teleport cluster for user access
resource "azurerm_dns_a_record" "teleport" {
  name                = var.cluster_hostname
  zone_name           = data.azurerm_dns_zone.existing.name
  resource_group_name = data.azurerm_resource_group.dnszone.name
  ttl                 = 100
  records             = [data.kubernetes_service.teleport.status.0.load_balancer.0.ingress.0.ip]
}

# Wildcard A record for application access
resource "azurerm_dns_a_record" "teleportwildcard" {
  name                = "*.${var.cluster_hostname}"
  zone_name           = data.azurerm_dns_zone.existing.name
  resource_group_name = data.azurerm_resource_group.dnszone.name
  ttl                 = 100
  records             = [data.kubernetes_service.teleport.status.0.load_balancer.0.ingress.0.ip]
}