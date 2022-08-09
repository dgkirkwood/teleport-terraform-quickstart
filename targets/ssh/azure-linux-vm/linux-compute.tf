# Create network interface
resource "azurerm_public_ip" "linuxpublicip" {
  name                = "target-public-ip"
  location            = azurerm_resource_group.teleport.location
  resource_group_name = azurerm_resource_group.teleport.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "linuxnic" {
  name                = "myNIC"
  location            = azurerm_resource_group.teleport.location
  resource_group_name = azurerm_resource_group.teleport.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.servers.id
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
  name                  = "${var.prefix}-teleport-target"
  location              = azurerm_resource_group.teleport.location
  resource_group_name   = azurerm_resource_group.teleport.name
  network_interface_ids = [azurerm_network_interface.linuxnic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = data.azurerm_image.target.id

  admin_username                  = "dan"
  disable_password_authentication = true

  user_data = base64encode(<<EOF
#!/bin/bash
sudo hostnamectl set-hostname ${var.hostname}
echo ${var.jointoken} > /var/lib/teleport/jointoken
sudo systemctl restart teleport

EOF
)

  admin_ssh_key {
    username   = "dan"
    public_key = file("~/.ssh/id_rsa.pub")
  }
}