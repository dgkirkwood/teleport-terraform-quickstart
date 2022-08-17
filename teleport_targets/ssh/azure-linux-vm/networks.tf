resource "azurerm_virtual_network" "teleport" {
  name                = join("-", [var.prefix, "network"])
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.teleport.name
  dns_servers         = ["10.0.1.4", "8.8.8.8"]
}

resource "azurerm_subnet" "servers" {
  name                 = "teleport"
  address_prefixes     = ["10.0.1.0/24"]
  resource_group_name  = azurerm_resource_group.teleport.name
  virtual_network_name = azurerm_virtual_network.teleport.name
}

