output "target-public-ip" {
  value = {for k, v in aws_instance.target_nodes : k => v.public_ip}
}

output "control-public-ip" {
  value = aws_instance.control_node.public_ip
}

