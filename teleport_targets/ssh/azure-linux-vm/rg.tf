resource "azurerm_resource_group" "teleport" {
  location = var.location
  name     = "${var.prefix}-rg"
}