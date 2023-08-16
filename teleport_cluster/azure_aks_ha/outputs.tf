output "cluster-url" {
  value = "https://${azurerm_dns_a_record.teleport.fqdn}"
}

output "kubeconfig_command" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.teleport.name} --name ${azurerm_kubernetes_cluster.teleport.name}"
}