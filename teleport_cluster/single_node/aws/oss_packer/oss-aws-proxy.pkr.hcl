packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  config_template = templatefile("${path.root}/teleportconfig.tmpl", {cluster_name = var.cluster_name, email = var.email})
}

source "file" "teleport_config" {
  content = local.config_template
}

build {
  source "source.file.teleport_config" {
    target = "../../config_files/teleport.yaml"
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = var.ami_name
  instance_type = "t2.micro"
  region        = var.region
  vpc_id = var.vpc_id
  subnet_id = var.subnet_id
  associate_public_ip_address = true
  ssh_interface = "public_ip"
  force_deregister = true
  force_delete_snapshot = true
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name    = "oss-teleport-proxy"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
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
    source = "../../config_files/teleport.yaml"
    destination = "~/teleport.yaml"
  }
  provisioner "shell" {
    inline = [
      "echo Moving files to correct location...",
      "sudo mv ~/teleport.yaml /etc/teleport.yaml",
      "sudo systemctl enable teleport"
    ]
  }
}
