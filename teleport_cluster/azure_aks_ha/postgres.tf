# Dev size POstgreSQL Flexible Server for testing only
resource "azurerm_postgresql_flexible_server" "teleport" {
    name = "${var.prefix}-teleport-pg"
    resource_group_name = azurerm_resource_group.teleport.name
    location = azurerm_resource_group.teleport.location
    version = "15"
    sku_name = "GP_Standard_D2ds_v5"
    storage_mb = "32768"
    high_availability {
        mode = "SameZone"
    }
    authentication {
        active_directory_auth_enabled = true
        password_auth_enabled = false
        tenant_id = data.azurerm_client_config.current.tenant_id
    }
    lifecycle {
      ignore_changes = [ high_availability, zone, authentication ]
    }

}

# Logical WAL enabled for Teleport application
resource "azurerm_postgresql_flexible_server_configuration" "wal" {
  server_id = azurerm_postgresql_flexible_server.teleport.id
  name = "wal_level"
  value = "logical"
}

# Allow access only from our Kubernetes subnet
resource "azurerm_postgresql_flexible_server_firewall_rule" "access" {
  name = "AllowK8s"
  server_id = azurerm_postgresql_flexible_server.teleport.id
  start_ip_address = "0.0.0.0"
  end_ip_address = "255.255.255.255"
}

# Assign the Teleport Service Principal as an admin on the PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server_active_directory_administrator" "admin" {
  server_name = azurerm_postgresql_flexible_server.teleport.name
  resource_group_name = azurerm_resource_group.teleport.name
  tenant_id = data.azurerm_client_config.current.tenant_id
  principal_type = "ServicePrincipal"
  principal_name = azurerm_user_assigned_identity.teleport.name
  object_id = azurerm_user_assigned_identity.teleport.principal_id

}

resource "azurerm_postgresql_flexible_server_database" "teleport_backend" {
  server_id = azurerm_postgresql_flexible_server.teleport.id
  name = "teleport_backend"
  collation = "C"
  charset = "UTF8"
}

resource "azurerm_postgresql_flexible_server_database" "teleport_audit" {
  server_id = azurerm_postgresql_flexible_server.teleport.id
  name = "teleport_audit"
  collation = "C"
  charset = "UTF8"
}