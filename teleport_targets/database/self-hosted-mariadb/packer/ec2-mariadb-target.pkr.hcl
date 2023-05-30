packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  config_template = templatefile("${path.root}/teleportconfig.tmpl", { token_name = var.ec2_token_name, auth_address = var.auth_address, database_name = var.database_name })
}

source "file" "teleport_config" {
  content = local.config_template
}

build {
  source "source.file.teleport_config" {
    target = "./mariadb-node.yaml"
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
    source = "./mariadb-node.yaml"
    destination = "~/teleport.yaml"
  }
  provisioner "file" {
    source = "./keys/"
    destination = "~/"
  }
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get -y install mariadb-server"
    ]

  }
  provisioner "shell" {
    inline = [
      "echo Creating config file...",
      "sudo mv ~/teleport.yaml /etc/teleport.yaml",
      "echo Starting Teleport service...",
      "sudo systemctl enable teleport.service",
      "sudo chown mysql:root ~/server.crt ~/server.cas ~/server.key",
      "sudo mkdir /etc/mysql-ssl",
      "sudo chown mysql:root /etc/mysql-ssl",
      "sudo mv ~/server.cas ~/server.crt ~/server.key /etc/mysql-ssl/",
      "sudo tee -a /etc/mysql/mariadb.cnf <<'EOT'\n[mariadb]\nrequire_secure_transport=ON\nssl-ca=/etc/mysql-ssl/server.cas\nssl-cert=/etc/mysql-ssl/server.crt\nssl-key=/etc/mysql-ssl/server.key\nEOT",
      "sudo systemctl restart mariadb"
    ]
  }
  provisioner "shell" {
    inline = [
      "echo Bootstrapping mariadb...",
      "sudo mysql <<EOF\nCREATE USER ${var.mariadb_user};\nCREATE DATABASE ${var.database_name};\nCREATE DATABASE customers;\nEOF",
      "sudo mysql <<EOF\nGRANT ALL PRIVILEGES ON customers.* TO 'developer'@'%';\nGRANT ALL PRIVILEGES ON ${var.database_name}.* TO 'developer'@'%';\nEOF",
      "sudo mysql <<EOF\nUSE ${var.database_name};\nCREATE TABLE vendors (vendorID int, vendorname varchar(255), website varchar(255));\ninsert into vendors values (1, 'Teleport', 'www.goteleport.com');\nEOF"
    ]
  }
}
