packer {
  required_plugins {
    azure = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/azure"
    }
  }
}

locals {
  config_template = templatefile("${path.root}/teleportconfig.tmpl", {auth_address = var.auth_address })
}

source "file" "teleport_config" {
  content = local.config_template
}

build {
  source "source.file.teleport_config" {
    target = "../../config_files/azure_ssh_node.yaml"
  }
}

source "azure-arm" "ubuntu" {
  use_azure_cli_auth = true
  image_publisher = "Canonical"
  image_offer = "0001-com-ubuntu-server-focal"
  image_sku = "20_04-lts"
  location = var.region
  managed_image_resource_group_name = var.image_rg
  managed_image_name = var.image_name
  os_type = "Linux"
}

build {
  name    = "packer-teleport-target"
  sources = [
    "source.azure-arm.ubuntu"
  ]
  provisioner "shell" {
    inline = [
        "echo Adding Users...",
        "sudo adduser --gecos '' --disabled-password developer",
        "sudo adduser --gecos '' --disabled-password operations",
        "sudo adduser --gecos '' --disabled-password sysadmin"
    ]
  }
  provisioner "shell" {
    inline = [
      "echo Installing Teleport....",
      "sudo curl https://deb.releases.teleport.dev/teleport-pubkey.asc -o /usr/share/keyrings/teleport-archive-keyring.asc",
      "echo 'deb [signed-by=/usr/share/keyrings/teleport-archive-keyring.asc] https://deb.releases.teleport.dev/ stable main' | sudo tee /etc/apt/sources.list.d/teleport.list > /dev/null",
      "sudo apt-get update",
      "sleep 10",
      "sudo apt-get install teleport"
    ]
  }
  provisioner "file" {
    source = "../../config_files/azure_ssh_node.yaml"
    destination = "~/teleport.yaml"
  }
  provisioner "shell" {
    inline = [
      "echo Creating config file...",
      "sudo mv ~/teleport.yaml /etc/teleport.yaml",
      "echo Starting Teleport service...",
      "sudo systemctl enable teleport.service"
    ]
  }
}
