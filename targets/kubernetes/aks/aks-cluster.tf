resource "azurerm_kubernetes_cluster" "teleport" {
  name                = "${var.prefix}-aks"
  location            = azurerm_resource_group.teleport.location
  resource_group_name = azurerm_resource_group.teleport.name
  dns_prefix          = "teleport"

  default_node_pool {
    name           = "teleportpool"
    node_count     = 2
    vm_size        = "Standard_B2s"
    vnet_subnet_id = azurerm_subnet.teleport.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}

data "azurerm_public_ip" "teleport" {
  name                = reverse(split("/", tolist(azurerm_kubernetes_cluster.teleport.network_profile.0.load_balancer_profile.0.effective_outbound_ips)[0]))[0]
  resource_group_name = azurerm_kubernetes_cluster.teleport.node_resource_group
}