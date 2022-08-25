output "linux_ip" {
  value = azurerm_linux_virtual_machine.myterraformvm.public_ip_address
}

output "windows_client_ip" {
  value = module.active-directory-member.public_ip_address
}

