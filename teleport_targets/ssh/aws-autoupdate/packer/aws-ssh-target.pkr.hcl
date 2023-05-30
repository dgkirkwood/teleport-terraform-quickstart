packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  config_template = templatefile("${path.root}/teleportconfig.tmpl", { token_name = var.ec2_token_name, auth_address = var.auth_address })
}

source "file" "teleport_config" {
  content = local.config_template
}

build {
  source "source.file.teleport_config" {
    target = "../../config_files/aws_ssh_node.yaml"
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
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name    = "packer-teleport-target"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "shell" {
    inline = [
      "echo Changing default shell for new users...",
      "sudo sed -i 's/SHELL=\\/bin\\/sh/SHELL=\\/bin\\/bash/' /etc/default/useradd"
    ]
  }
  provisioner "shell" {
    inline = [
        "echo Adding Users...",
        "sudo adduser --gecos '' --disabled-password developer",
        "sudo adduser --gecos '' --disabled-password operations",
        "sudo adduser --gecos '' --disabled-password devops"
    ]
  }
  provisioner "shell" {
    inline_shebang = "/bin/bash -e"
    inline = [
      "echo Installing Teleport....",
      "TELEPORT_VERSION=${var.teleport_version}",
      "sudo curl https://apt.releases.teleport.dev/gpg -o /usr/share/keyrings/teleport-archive-keyring.asc",
      "echo 'deb [signed-by=/usr/share/keyrings/teleport-archive-keyring.asc] https://apt.releases.teleport.dev/ubuntu jammy stable/v13' | sudo tee /etc/apt/sources.list.d/teleport.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install teleport=$${TELEPORT_VERSION?} -y",
      "sudo mkdir /etc/teleport",
    ]
  }
  provisioner "file" {
    source = "../../config_files/aws_ssh_node.yaml"
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
  provisioner "shell" {
    inline = [
      "echo Creating auto-update configuration...",
      "sudo mkdir -p /etc/teleport-upgrade.d/",
      "echo dk-updater.teleportdemo.com/current | sudo tee /etc/teleport-upgrade.d/endpoint",
      "sudo apt install teleport-ent-updater"
    ]
  }
}
