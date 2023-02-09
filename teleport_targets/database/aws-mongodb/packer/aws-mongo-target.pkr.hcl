packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  config_template = templatefile("${path.root}/teleportconfig.tmpl", { token_name = var.ec2_token_name, auth_address = var.auth_address, db_name = var.db_name, environment = var.environment })
}

source "file" "teleport_config" {
  content = local.config_template
}

build {
  source "source.file.teleport_config" {
    target = "../config_files/aws_mongodb_node.yaml"
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
      "echo Installing Teleport....",
      "sudo curl https://deb.releases.teleport.dev/teleport-pubkey.asc -o /usr/share/keyrings/teleport-archive-keyring.asc",
      "echo 'deb [signed-by=/usr/share/keyrings/teleport-archive-keyring.asc] https://deb.releases.teleport.dev/ stable main' | sudo tee /etc/apt/sources.list.d/teleport.list > /dev/null",
      "sudo apt-get update",
      "sleep 10",
      "sudo apt-get install teleport"
    ]
  }
  provisioner "file" {
    source = "../certs/"
    destination = "~/"
  }
  provisioner "shell" {
    inline = [
      "echo Moving Teleport certs...",
      "sudo mkdir /etc/certs",
      "sudo mv ~/mongo.crt /etc/certs/mongo.crt",
      "sudo mv ~/mongo.cas /etc/certs/mongo.cas"
    ]
  }
  provisioner "shell" {
    inline = [
      "echo Installing MongoDB...",
      "sudo apt install dirmngr gnupg apt-transport-https ca-certificates software-properties-common -y",
      "wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -",
      "echo 'deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list",
      "sudo apt-get update",
      "sleep 10",
      "sudo apt-get install -y mongodb-org",
      "sudo systemctl enable mongod",
      "sudo systemctl start mongod"
    ]
  }
  provisioner "shell" {
    inline = [
      "sleep 20",
      "echo Bootstrapping database...",
      "mongosh --eval 'db.getSiblingDB(\"$external\").runCommand( { createUser: \"CN=${var.user1}\", roles: [ { role: \"readWriteAnyDatabase\", db: \"admin\" }] })'",
      "mongosh --eval 'db.getSiblingDB(\"$external\").runCommand( { createUser: \"CN=${var.user2}\", roles: [ { role: \"readWriteAnyDatabase\", db: \"admin\" }] })'",
      "mongosh --eval 'db.users.insertOne({\"name\": \"Tom\", \"age\": 28, languages: [\"english\", \"spanish\"]})'"
    ]
  }
  provisioner "file" {
    source = "../config_files/"
    destination = "~/"
  }
  provisioner "shell" {
    inline = [
      "echo Creating config file...",
      "sudo mv ~/aws_mongodb_node.yaml /etc/teleport.yaml",
      "echo Starting Teleport service...",
      "sudo systemctl enable teleport.service",
      "sudo chown mongodb /etc/certs/mongo*",
      "sudo mv ~/mongod.conf /etc/mongod.conf",
      "sudo systemctl restart mongod"
    ]
  }
}
