packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/googlecompute"
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
    target = "teleport.yaml"
  }
}


source "googlecompute" "ubuntu" {
  project_id = var.project_id
  source_image_family = "ubuntu-2004-lts"
  ssh_username = "ubuntu"
  zone = var.zone
  image_family = var.ami_name
}


build {
  name    = "packer-teleport-target"
  sources = [
    "source.googlecompute.ubuntu"
  ]
  provisioner "shell" {
    inline = [
        "echo Adding Users...",
        "sudo adduser --gecos '' --disabled-password developer",
        "sudo adduser --gecos '' --disabled-password operations",
        "sudo adduser --gecos '' --disabled-password devops",
    ]
  }
  provisioner "shell" {
    inline = [
      "echo Installing Teleport....",
      "TELEPORT_VERSION=${var.teleport_version}",
      "curl -O https://cdn.teleport.dev/teleport-ent-v$TELEPORT_VERSION-linux-amd64-bin.tar.gz",
      "tar -xzf teleport-ent-v$TELEPORT_VERSION-linux-amd64-bin.tar.gz",
      "cd teleport-ent",
      "sudo ./install",
      "sudo cp examples/systemd/teleport.service /etc/systemd/system",
      "sudo mkdir /etc/teleport",
      "sudo rm -rf ~/teleport-ent/",
      "sudo rm -rf ~/teleport-ent-v$TELEPORT_VERSION-linux-amd64-bin.tar.gz"
    ]
  }
  provisioner "file" {
    source = "teleport.yaml"
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
