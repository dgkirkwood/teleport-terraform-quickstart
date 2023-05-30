output "instance_public_ip" {
  description = "Instance public IP"
  value       = aws_instance.target_node.public_ip
}

output "redis_hostname" {
  value = aws_elasticache_cluster.example.cache_nodes.0.address
}