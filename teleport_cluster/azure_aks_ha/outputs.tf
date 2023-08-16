output "cluster-url" {
  value = "https://${azurerm_dns_a_record.teleport.fqdn}"
}