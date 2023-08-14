# Create a Storage Account for all session recordings
# Allow access only from the Kubernetes subnet
resource "azurerm_storage_account" "teleport" {
  resource_group_name = azurerm_resource_group.teleport.name
  location = azurerm_resource_group.teleport.location
  name = "${var.prefix}teleportblob"
  public_network_access_enabled = true
  account_replication_type = "LRS"
  account_tier = "Standard"
  network_rules {
    default_action = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.teleport.id]
  }
}

