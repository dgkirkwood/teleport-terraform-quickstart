data "aws_ami" "target" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_name]
  }
  owners = [var.ami_owner]
}


resource "aws_instance" "control_node" {
  ami           = data.aws_ami.target.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.server.id
  vpc_security_group_ids = [ aws_security_group.serveraccess.id ]
  key_name = var.key_name
  user_data = <<EOF
#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Changing hostname..."
sudo hostnamectl set-hostname ${var.control_hostname}


echo "Creating Teleport machine-id config file..."
sudo tee -a /etc/tbot.yaml <<'EOT'
auth_server: "${var.proxy_address}:443"
onboarding:
  join_method: "token"
  token: ${var.join_token}
storage:
  directory: /var/lib/teleport/bot
destinations:
  - directory: /opt/machine-id
    kubernetes_cluster: example-k8s-cluster
EOT

echo "Creating systemd unit file for machine-id..."
sudo tee -a /etc/systemd/system/machine-id.service <<'EOT'
[Unit]
Description=Teleport Machine ID Service
After=network.target

[Service]
Type=simple
Restart=on-failure
ExecStart=/usr/local/bin/tbot start -c /etc/tbot.yaml
ExecReload=/bin/kill -HUP $MAINPID
PIDFile=/run/machine-id.pid
LimitNOFILE=8192

[Install]
WantedBy=multi-user.target
EOT

echo "Reloading systemd for machine-id changes, enabling service..."
sudo systemctl daemon-reload
sudo systemctl enable machine-id.service
sudo systemctl start machine-id.service

echo "Restarting Teleport to pick up hostname change..."
sudo systemctl restart teleport

echo "Installing Ansbile, with sleep to allow for other cloud-init processes..."
sleep 10
sudo apt-get update
sleep 10
sudo apt-get upgrade -y
sleep 10
sudo apt-get install -y ca-certificates curl
sleep 10
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sleep 10
sudo apt-get install -y kubectl
EOF
  metadata_options {
    http_endpoint = "enabled"
    instance_metadata_tags = "enabled"
  }

  tags = {
    Name = "ansible_control_node"
    Env = var.control_env
  }
}