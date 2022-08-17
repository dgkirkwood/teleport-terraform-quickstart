resource "azurerm_virtual_network" "teleport" {
  name                = "${var.prefix}-k8s"
  location            = azurerm_resource_group.teleport.location
  resource_group_name = azurerm_resource_group.teleport.name
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_subnet" "teleport" {
  name                 = "${var.prefix}-k8s"
  resource_group_name  = azurerm_resource_group.teleport.name
  address_prefixes     = ["192.168.1.0/24"]
  virtual_network_name = azurerm_virtual_network.teleport.name
}