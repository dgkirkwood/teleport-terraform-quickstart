# Create network interface
resource "azurerm_public_ip" "linuxpublicip" {
  name                = "target-public-ip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "linuxnic" {
  name                = "myNIC"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = module.network.domain_controllers_subnet_id
    public_ip_address_id          = azurerm_public_ip.linuxpublicip.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.10"
  }
}


data "azurerm_image" "target" {
  name = var.image_name
  resource_group_name = var.image_rg
}


resource "azurerm_linux_virtual_machine" "myterraformvm" {
  name                  = "${var.prefix}-teleport-rdp"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.linuxnic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = data.azurerm_image.target.id

  admin_username                  = "ubuntu"
  disable_password_authentication = true
  user_data = base64encode(<<EOF
#!/bin/bash
sudo hostnamectl set-hostname ${var.linux_hostname}
echo ${var.jointoken} > /var/lib/teleport/jointoken
sudo tee -a /etc/teleport.yaml <<'EOT'

windows_desktop_service:
  enabled: yes
  ldap:
    addr: "10.0.1.4:636"
    domain: ${var.active_directory_domain_name}
    username: 'svc-teleport'
    insecure_skip_verify: true
  discovery:
    base_dn: "*"
EOT
sudo systemctl restart teleport
EOF
)

  admin_ssh_key {
    username   = "ubuntu"
    public_key = file("~/.ssh/id_rsa.pub")
  }
}