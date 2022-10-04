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

echo "Creating Ansible directory..."
mkdir -p /home/ubuntu/ansible

echo "Creating Ansible config file..."
sudo tee -a /home/ubuntu/ansible/ansible.cfg <<'EOT'
[defaults]
host_key_checking = True
inventory=./hosts
remote_tmp=/tmp

[ssh_connection]
scp_if_ssh = True
ssh_args = -F /opt/machine-id/ssh_config
EOT

echo "Creating Ansible hosts file..."
sudo tee -a /home/ubuntu/ansible/hosts <<'EOT'
${var.target_machines["target1"]["hostname"]}.${var.proxy_address}
${var.target_machines["target2"]["hostname"]}.${var.proxy_address}
EOT

echo "Creating example Ansible playbook..."
sudo tee -a /home/ubuntu/ansible/playbook.yaml <<'EOT'
- hosts: all
  remote_user: ubuntu
  tasks:
    - name: "hostname"
      command: "hostname"
EOT

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
sudo apt-get install ansible -y
EOF
  metadata_options {
    http_endpoint = "enabled"
    instance_metadata_tags = "enabled"
  }

  tags = {
    Name = "target_node"
    Env = var.control_env
  }
}

resource "aws_instance" "target_nodes" {
  for_each = var.target_machines
  ami           = data.aws_ami.target.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.server.id
  vpc_security_group_ids = [ aws_security_group.serveraccess.id ]
  key_name = var.key_name
  user_data = <<EOF
#!/bin/bash
echo "Changing hostname..."
sudo hostnamectl set-hostname ${each.value.hostname}
sudo systemctl restart teleport
EOF
  metadata_options {
    http_endpoint = "enabled"
    instance_metadata_tags = "enabled"
  }

  tags = {
    Name = "target_node"
    Env = "${each.value.environment}"
  }
}