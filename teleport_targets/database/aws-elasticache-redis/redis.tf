resource "aws_elasticache_cluster" "example" {
  cluster_id           = var.dbname
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis5.0"
  engine_version       = "5.0.5"
  port                 = 6379
  security_group_ids   = [aws_security_group.rds.id]
  snapshot_retention_limit = 0
  apply_immediately = true
  subnet_group_name = aws_elasticache_subnet_group.teleport-rds.name
}

resource "aws_elasticache_user" "arwen" {
  user_name = "arwen"
  user_id = "arwen"
  engine = "REDIS"
  no_password_required = true
  access_string = "on ~* +@all"
  tags = {
    "teleport.dev/managed" = "true"
  }
}

# resource "aws_elasticache_user_group" "dev" {
#   engine = "REDIS"
#   user_group_id = "dev"
#   user_ids = [aws_elasticache_user.arwen.user_id]
# }


# resource "aws_elasticache_user_group_association" "dev" {
#   user_group_id = aws_elasticache_user_group.dev.user_group_id
#   user_id = aws_elasticache_user.arwen.user_id
# }