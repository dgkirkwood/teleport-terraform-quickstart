# Create a Service Principal for Teleport to use when accessing PostgreSQL and Blob Storage
resource "azurerm_user_assigned_identity" "teleport" {
  location            = azurerm_resource_group.teleport.location
  name                = "teleport-id"
  resource_group_name = azurerm_resource_group.teleport.name
}

# Assign Blob Storage permissions to the service principal
resource "azurerm_role_assignment" "teleport-blob" {
  scope = azurerm_storage_account.teleport.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id = azurerm_user_assigned_identity.teleport.principal_id
}

# Allow Kubernetes service account access to the service principal
resource "azurerm_federated_identity_credential" "teleport" {
    name = "aks"
    parent_id = azurerm_user_assigned_identity.teleport.id
    resource_group_name = azurerm_resource_group.teleport.name
    audience = ["api://AzureADTokenExchange"]
    subject = "system:serviceaccount:teleport-cluster:teleport"
    issuer = azurerm_kubernetes_cluster.teleport.oidc_issuer_url
}



# Create a Service Principal for cert manager to use when accessing Azure DNS
resource "azurerm_user_assigned_identity" "certmanager" {
  location            = azurerm_resource_group.teleport.location
  name                = "certmanager-teleport"
  resource_group_name = azurerm_resource_group.teleport.name
}

# Assign DNS Zone permissions to the service principal
resource "azurerm_role_assignment" "certmanager" {
  scope = data.azurerm_dns_zone.existing.id
  role_definition_name = "DNS Zone Contributor"
  principal_id = azurerm_user_assigned_identity.certmanager.principal_id
}

# Allow Kubernetes service account access to the service principal
resource "azurerm_federated_identity_credential" "certmanager" {
    name = "cert-manager"
    parent_id = azurerm_user_assigned_identity.certmanager.id
    resource_group_name = azurerm_resource_group.teleport.name
    audience = ["api://AzureADTokenExchange"]
    subject = "system:serviceaccount:cert-manager:cert-manager"
    issuer = azurerm_kubernetes_cluster.teleport.oidc_issuer_url
}