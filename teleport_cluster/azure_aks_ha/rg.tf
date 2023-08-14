# Create a new Resource Group for all resources
resource "azurerm_resource_group" "teleport" {
  name     = "${var.prefix}-teleport"
  location = var.location
}

# If there is an existing DNS Zone in another resource group, pull its data
data "azurerm_resource_group" "dnszone" {
  name = var.dns_rg
}