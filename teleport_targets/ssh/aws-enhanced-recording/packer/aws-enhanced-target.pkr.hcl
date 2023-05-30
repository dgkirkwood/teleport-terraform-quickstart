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
      name                = "*al2023-ami-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture = "x86_64"
      creation-date = "2023*"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  ssh_username = "ec2-user"
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
        "sudo adduser --comment '' developer",
        "sudo adduser --comment '' operations",
        "sudo adduser --comment '' devops"
    ]
  }
  provisioner "shell" {
    inline = [
      "echo Installing Teleport....",
      "TELEPORT_VERSION=${var.teleport_version}",
      "curl -O https://cdn.teleport.dev/teleport-v$TELEPORT_VERSION-linux-amd64-bin.tar.gz",
      "tar -xzf teleport-v$TELEPORT_VERSION-linux-amd64-bin.tar.gz",
      "cd teleport",
      "sudo ./install",
      "sudo cp examples/systemd/teleport.service /etc/systemd/system",
      "sudo mkdir /etc/teleport",
      "sudo rm -rf ~/teleport/",
      "sudo rm -rf ~/teleport-v$TELEPORT_VERSION-linux-amd64-bin.tar.gz"
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
}
