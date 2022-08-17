resource "azurerm_resource_group" "teleport" {
  name     = "${var.prefix}-teleport"
  location = var.location
}