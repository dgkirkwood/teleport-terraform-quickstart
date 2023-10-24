output "instance_public_ip" {
  description = "Instance public IP"
  value       = aws_instance.target_node.public_ip
}

output "rds_hostname" {
  value = { for k, v in aws_db_instance.teleport-rds : k => v.address }
}