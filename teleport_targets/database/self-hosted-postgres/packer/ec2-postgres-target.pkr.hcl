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
    target = "./postgres-node.yaml"
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
    source = "./postgres-node.yaml"
    destination = "~/teleport.yaml"
  }
  provisioner "file" {
    source = "./keys/"
    destination = "~/"
  }
  provisioner "shell" {
    inline = [
      #"echo 'deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main' > /etc/apt/sources.list.d/pgdg.list",
      "wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -",
      "sudo apt-get update",
      "sudo apt-get -y install postgresql"
    ]

  }
  provisioner "shell" {
    inline = [
      "echo Creating config file...",
      "sudo mv ~/teleport.yaml /etc/teleport.yaml",
      "echo Starting Teleport service...",
      "sudo systemctl enable teleport.service",
      "sudo chown postgres:postgres ~/server.crt ~/server.cas ~/server.key",
      "sudo mv ~/server.cas ~/server.crt /etc/ssl/certs/",
      "sudo mv ~/server.key /etc/ssl/private/",
      "sudo tee -a /etc/postgresql/14/main/postgresql.conf <<'EOT'\nssl = on\nssl_cert_file = '/etc/ssl/certs/server.crt'\nssl_key_file = '/etc/ssl/private/server.key'\nssl_ca_file = '/etc/ssl/certs/server.cas'\nEOT",
      # Remove line in the auth file which prevents cert based auth
      "sudo sed -i '97d' /etc/postgresql/14/main/pg_hba.conf",
      "sudo tee -a /etc/postgresql/14/main/pg_hba.conf <<'EOT'\nhostssl all             all             ::/0                    cert\nhostssl all             all             0.0.0.0/0               cert\nEOT",
      "sudo systemctl restart postgresql"
    ]
  }
  provisioner "shell" {
    inline = [
      "echo Bootstrapping postgres...",
      "sudo su -c psql - postgres <<EOF\nCREATE USER ${var.postgres_user};\nCREATE DATABASE ${var.database_name};\nCREATE DATABASE customers;\nEOF",
      "sudo su -c psql - postgres <<EOF\nGRANT ALL PRIVILEGES ON database customers TO developer;\nGRANT ALL PRIVILEGES ON database products TO developer;\nEOF",
      "sudo su -c psql - postgres <<EOF\nCREATE TABLE vendors (vendorID int, vendorname varchar(255), website varchar(255));\ninsert into vendors values (1, 'Teleport', 'www.goteleport.com');\nEOF"
    ]
  }
}
