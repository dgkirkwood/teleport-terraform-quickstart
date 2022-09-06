resource "aws_db_instance" "teleport-rds" {
  for_each                            = var.dbs
  identifier                          = each.value.dbname
  instance_class                      = "db.t3.medium"
  allocated_storage                   = 5
  engine                              = "mysql"
  engine_version                      = "8.0.27"
  username                            = var.db_admin
  password                            = var.db_password
  db_subnet_group_name                = aws_db_subnet_group.teleport-rds.name
  vpc_security_group_ids              = [aws_security_group.rds.id]
  publicly_accessible                 = true
  skip_final_snapshot                 = true
  backup_retention_period             = 0
  deletion_protection                 = false
  iam_database_authentication_enabled = true
  tags = {
    env = each.value.environment
  }

}
